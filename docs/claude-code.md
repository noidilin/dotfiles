# Claude Code

What chezmoi owns under `~/.claude`, and what it deliberately does not.

## Managed

| Path | Notes |
| --- | --- |
| `.claude/CLAUDE.md` | global instructions |
| `.claude/keybindings.json` | see below |
| `.claude/settings.json` | model, plugins, theme, hooks |
| `.claude/themes/achroma-current.json` | symlink through `achroma/current`; see `docs/achroma.md` |

The directory source is plain `dot_claude`, **not** `exact_dot_claude`, so
everything else Claude Code keeps in `~/.claude` — `sessions/`, `projects/`,
`history.jsonl`, `plugins/`, `shell-snapshots/` and the rest of the runtime
state — is untouched by `chezmoi apply`.

## The herdr hook: split ownership

`~/.claude/hooks/herdr-agent-state.sh` is installed and owned by **herdr**. Its
header says so explicitly (`HERDR_INTEGRATION_ID=claude`,
`HERDR_INTEGRATION_VERSION=8`, "reinstalling or updating the integration
overwrites this file", "add custom hooks beside this file instead of editing
it"). It is intentionally **not** chezmoi-managed — do not capture it into the
source. It survives `chezmoi apply` on its own because chezmoi never removes
unmanaged files from a non-`exact_` directory.

What is captured is the `SessionStart` block in `settings.json` that wires it
up:

```json
"hooks": {
  "SessionStart": [
    { "matcher": "*", "hooks": [ { "type": "command",
      "command": "bash '/Users/noid/.claude/hooks/herdr-agent-state.sh' session",
      "timeout": 10 } ] }
  ]
}
```

That block has to be in the chezmoi source, because the two tools would
otherwise fight over one file: herdr re-adds it whenever its integration is
installed or updated, and any `chezmoi apply` from a source that lacked it
would strip it straight back out. The script would stay on disk and silently
never fire. Capturing it is what makes the two agree.

The source writes the block expanded, while herdr writes it as a single line.
JSON whitespace is insignificant so the two are semantically identical, but
chezmoi compares bytes — so a herdr reinstall shows up as a `settings.json`
diff, and the next apply restores the expanded form. That oscillation is
cosmetic and self-correcting; the wiring never breaks.

## Known rough edges

- **`settings.json` is macOS-shaped.** Three absolute `/Users/noid` paths are
  stored verbatim: the herdr hook command, the `robcsc-skills-repo`
  marketplace, and `desktop-skills-bridge`. herdr writes its path that way and
  matching it byte-for-byte is what avoids a permanent diff. The cost is that
  on the arch/wsl/windows targets these resolve nowhere — and since herdr is
  darwin-only (see `.chezmoiignore`), the hook would point at a script that was
  never installed and fail on every session start. If Claude Code ever gets
  used on those machines, the fix is to rename the source to
  `settings.json.tmpl` and wrap the `hooks` block in
  `{{ if eq .chezmoi.os "darwin" }}`, using `{{ .chezmoi.homeDir }}` for the
  path. Not done yet because nothing needs it.
- **`app:toggleTodos` has no binding.** `ctrl+t` is nulled in `Global` so
  `Chat` can use it for `chat:thinkingToggle`, and the `ctrl+x t` binding that
  used to hold `toggleTodos` was removed — `ctrl+x` is a prefix in Claude
  Code's own defaults (`ctrl+x ctrl+k`, `ctrl+x ctrl+e`, `ctrl+x b`,
  `ctrl+x ctrl+b`) and is also used bare in the footer strip, so a user prefix
  on it swallowed the bare press.
- **`enter` is `chat:newline`,** which shadows the footer strip's bare `enter`
  for opening the selected background/subagent session. `ctrl+y` is bound to
  `footer:openSelected` to get it back, matching the accept idiom used in
  `Autocomplete`, `Confirmation`, `Select` and `MessageSelector`.
