# Claude Desktop extensions (DXT)

How the `metaage-aws-estimator` extension gets a Python interpreter that has its
dependencies, and why that takes a patch to a file chezmoi does not own.

Claude Code's own config is a separate concern — see `docs/claude-code.md`.

## The failure

The extension's MCP server died at startup with:

```
ModuleNotFoundError: No module named 'mcp'
  File ".../ant.dir.ant.0x624df87.metaage-aws-estimator/server/server.py", line 5
    from mcp.server.fastmcp import FastMCP
```

Its `manifest.json` hardcodes `"command": "python3"`, and Claude Desktop
resolves that against a PATH it builds itself:

```
/usr/local/bin  /opt/homebrew/bin  ~/.local/bin  ~/.orbstack/bin  /usr/bin  …
```

`/opt/homebrew/bin` wins, so `python3` is Homebrew's `python@3.14`. The deps had
been installed into that interpreter's site-packages at some point — the stale
`server/__pycache__/*.cpython-314.pyc` files prove the server once ran there —
and a `brew upgrade python` took them out.

Two things make this worse than it looks:

- **Reinstalling from the extension's own `requirements.txt` does not fix it.**
  It pins bare `mcp`, which now resolves to **mcp 2.x**, where `FastMCP` was
  renamed `MCPServer`. You trade the error above for
  `No module named 'mcp.server.fastmcp'` and conclude the extension is broken.
- **`botocore[crt]` is a hidden requirement.** `server.py` builds a boto3
  pricing client at import time; the credential chain reaches a provider that
  needs `awscrt` and raises `MissingDependencyException` before any tool runs.

mise cannot fix the launch. Claude Desktop's PATH contains no
`~/.local/share/mise/shims`, and `/opt/homebrew/bin` precedes `~/.local/bin`
anyway, so no `mise.toml` anywhere changes which interpreter Desktop picks.

## The fix, in two halves

| Half | Path | Owner |
| --- | --- | --- |
| venv + pins | `~/.local/share/metaage-aws-estimator/{mise.toml,requirements.txt}` | chezmoi |
| `.venv` itself | `~/.local/share/metaage-aws-estimator/.venv` | `mise run install` (ignored) |
| patched entry point | `~/.local/etc/claude-desktop/metaage-aws-estimator-run.py` | chezmoi |
| the copy that runs | `…/Claude Extensions/*metaage-aws-estimator/run.py` | Claude Desktop |

`run.py` probes for its imports and, on failure, `execv`s into the venv:

```python
if os.path.exists(VENV_PY) and os.path.realpath(sys.executable) != os.path.realpath(VENV_PY):
    os.execv(VENV_PY, [VENV_PY, os.path.abspath(__file__), *sys.argv[1:]])
```

`execv` rather than a subprocess because it replaces the process image, keeping
the PID and the inherited fd 0/1/2 — MCP is a stdio protocol, so the venv
interpreter picks up the exact pipes Desktop already holds. The import probe
means a future Desktop that ships a Python with these deps makes this a no-op
instead of a forced downgrade, and the `realpath` comparison turns a broken venv
into one clean traceback instead of an `execv` loop.

## Why the venv's base is the minor alias

`pyvenv.cfg` records an absolute path to the base interpreter:

```
home = /Users/noid/.local/share/mise/installs/python/3.12/bin
```

That is `installs/python/3.12`, a symlink mise re-points on patch bumps — not
`installs/python/3.12.14`. `upgrade.auto_prune` is on with
`upgrade.prune_after = "24h"`, so a `mise up` landing 3.12.15 would install it
and delete 3.12.14 the next day, dangling an exact-version base. The alias
survives that, and staying inside 3.12 keeps the compiled wheels
(`pydantic-core`, `awscrt`) ABI-valid.

Homebrew has the same property, for the record — `uv venv --python
/opt/homebrew/bin/python3` records `home = /opt/homebrew/opt/python@3.14/bin`,
the stable `opt/` alias, so a brew-based venv would survive `brew upgrade` too.
mise was chosen because the version requirement ends up *declared* in a file
next to the pins and the rebuild task, whereas this machine has no `Brewfile` —
brew state here is imperative, so `python@3.12` would live only in memory.

## Ownership boundary

`run.py` sits inside a directory Claude Desktop manages and **replaces on every
extension update**, which wipes the patch. Re-applying it is the `patch` task in
the runtime directory's `mise.toml`; it keeps the first pristine copy it ever
sees as `run.py.dxt-orig`, so the patch stays revertible after several updates,
and it no-ops when the extension is not installed.

`run_onchange_after_40-claude-dxt-aws-estimator.sh` is only a bootstrap wrapper
around the two tasks. It is keyed on the patch, the pins, and the `mise.toml`
itself, so it fires on a fresh machine and whenever any of those change — which
is everything chezmoi can actually see.

It deliberately does **not** try to catch extension updates. An earlier version
was `run_after_`, re-asserting on every apply, and that was the wrong trade: the
update happens while Claude Desktop is running, uncorrelated with `chezmoi
apply`, so the script could not catch it promptly anyway — you notice because
the estimator's tools vanish. Paying 0.8s on every apply forever to half-cover a
monthly, loud, one-command failure was not worth it. The recovery is:

```sh
cd ~/.local/share/metaage-aws-estimator && mise run patch
```

One consequence worth knowing: because the wrapper will not fire again on its
own, it builds the venv even when the extension is absent. If you install the
DXT later on a machine that has already run it, `mise run patch` is the single
command that finishes the job.

The purely additive alternative — shadowing `python3` earlier on Desktop's PATH,
i.e. a wrapper at `/usr/local/bin/python3` — was rejected: `/usr/local/bin` is
root-owned, and it would sit in front of `python3` for every process that
resolves PATH that way, including other extensions.

## Operating it

```sh
cd ~/.local/share/metaage-aws-estimator
mise run install   # create/refresh the venv (idempotent)
mise run patch     # re-assert the run.py patch after an extension update
mise run verify    # -> [estimator] ok: python 3.12.14, 13 tools
```

After any of these touch `run.py`, Claude Desktop needs a full **Cmd+Q** and
relaunch — closing the window does not respawn extension servers.

To check the real path end to end, launch it the way Desktop does and drive the
handshake by hand:

```sh
printf '%s\n' \
  '{"jsonrpc":"2.0","id":0,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"t","version":"1"}}}' \
  '{"jsonrpc":"2.0","method":"notifications/initialized"}' \
  '{"jsonrpc":"2.0","id":1,"method":"tools/list"}' \
| AWS_DEFAULT_REGION=ap-northeast-1 AWS_ACCESS_KEY_ID=dummy AWS_SECRET_ACCESS_KEY=dummy \
  /opt/homebrew/bin/python3 \
  ~/Library/Application\ Support/Claude/Claude\ Extensions/*metaage-aws-estimator/run.py
```

Desktop's own logs are the other source of truth: `~/Library/Logs/Claude/`.

## Upstream

The real defect is in the DXT source, which this machine does not have write
access to. If that ever changes, two lines fix it for every install: pin
`mcp>=1.2,<2` and add `botocore[crt]` in both `requirements.txt` copies (root
and `server/`). Vendoring the deps into a `lib/` directory inside the extension
is **not** a fix — `pydantic-core` and `awscrt` are ABI-tagged per Python minor
version, so a tree built for 3.12 breaks when Desktop's `python3` is 3.14.
