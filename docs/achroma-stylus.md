# Achroma for Stylus

Catppuccin owns website selectors and layout rules; Achroma supplies the palette.
The Python builder bundles its Less standard library and variable-based syntax
highlighting CSS into each UserCSS source. There are no runtime CSS/ Less imports.
External image/font URLs used by website rules are not bundled.

## Ownership and paths

| Path | Owner |
| --- | --- |
| `home/.chezmoidata/colors.yml` | Authoritative palette |
| `home/dot_config/achroma/stylus/browser-map.json` | Browser-specific role mapping |
| `home/dot_config/achroma/stylus/vendor/` | Reviewed, checksummed upstream snapshots |
| `$XDG_CONFIG_HOME/achroma/stylus/` | Applied inputs and Python builder, managed by chezmoi |
| `$XDG_DATA_HOME/achroma/stylus/import.json` | Generated candidate; **not** managed by chezmoi |
| `$XDG_DATA_HOME/achroma/stylus/lib.less` | Generated standalone library, for optional future hosting |
| `$XDG_DATA_HOME/achroma/stylus/build-report.json` | Provenance, output hashes, resolved colors, filter errors, exclusions |
| `$XDG_CACHE_HOME/achroma/stylus/` | Disposable filter diagnostics |

Unset XDG variables fall back to `~/.config`, `~/.local/share`, and `~/.cache`,
including on Windows. The repository configures these variables on all platforms.
The old `home/dot_local/etc/stylus/achroma.json` is retained unchanged during
migration; it is **not** the new build output.

## Palette contract

- `latte` means Achroma Light; `mocha` means Achroma Dark.
- Keep these flavor identifiers: upstream styles test `@flavor = latte` for
  light-specific behavior and native `color-scheme`.
- All 26 palette roles come from the corresponding YAML keys, except browser
  `rosewater → acc07` and `flamingo → acc06`. These exceptions preserve the
  previous hosted dark accents; the corresponding light roles follow automatically.
- The selected accent defaults to `rosewater` in `browser-map.json`.
- Frappé and Macchiato remain upstream Catppuccin palettes, not Achroma variants.
- Light/dark resolution remains website-specific: some rules follow browser
  `prefers-color-scheme`, others follow a website setting. The shell's
  `ACHROMA_VARIANT` is not a browser-extension control channel.

Filters are fitted from the resolved colors, not copied from Catppuccin. The
stdlib-only solver uses seeded restarts and measures the emitted, rounded filter.
The maximum permitted absolute sRGB channel error is 8/255; the initial real
palette build measured **0.478/255** worst case. This is a numerical approximation,
not proof of identical browser rendering or antialiasing. Grays use direct invert.
Filter diagnostics are regenerated, never trusted as build inputs.

This is not a complete Achroma redesign: upstream still chooses which elements
receive chromatic colors, fills, and emphasis. No global TUI-style foreground or
surface remapping is imposed on websites. Add small documented overrides only
when actual browser review demonstrates a problem.

## Normal build: offline

After the mise tool-install step, platform-specific `run_onchange_after_50`
scripts invoke the same Python entry point. Triggers cover the palette, mapping,
builder, Python version, lock manifest, licenses, and all vendored files.

The repository uses mise Python `latest`; the builder requires Python 3.11 or
newer and only its standard library. Python updates belong to the normal tool-update
workflow, not theme generation. The triggers explicitly disable mise auto-installation
and capture XDG paths before mise can override its child environment. Missing tools
fail instead of downloading. No pip/npm installation occurs during generation.
Initial machine bootstrap can install mise tools, as before; the **theme build
itself** performs no downloads, upgrades, browser writes, or remote publication.

After `chezmoi apply`, run from any shell:

```text
mise exec -- python <XDG_CONFIG_HOME>/achroma/stylus/build.py build
mise exec -- python <XDG_CONFIG_HOME>/achroma/stylus/build.py examine
mise exec -- python <XDG_CONFIG_HOME>/achroma/stylus/build.py check
```

Use the actual config path in place of `<XDG_CONFIG_HOME>` (quote paths containing
spaces). In Nushell, `stylus-build`, `stylus-examine [file]`, and `stylus-check`
are convenience wrappers. `stylus-update` is now an offline alias with a
migration notice; it no longer takes an accent or remote-library URL.

The builder verifies every vendored checksum before checking whether output is
unchanged. It fingerprints inputs, hashes existing artifacts, and skips writes
when nothing changed. Deleted or modified outputs are rebuilt. Transformation
failures leave the previous candidate untouched. Artifacts are individually
atomically replaced; the report is written last. An interrupted multi-file write
is detected by `check` or the next build.

`check` verifies output integrity and structural safety, **not compilation**.

## Explicit upstream refresh

From the repository root, choose a full Catppuccin userstyles commit SHA:

```text
mise exec -- python home/dot_config/achroma/stylus/build.py update --vendor-dir home/dot_config/achroma/stylus/vendor --commit <40-character-SHA>
```

This is the only builder command that accesses the network. It refreshes the
standard library, official export, MIT license, and four syntax-highlighting CSS
snapshots. URLs and SHA-256 values are recorded in `upstream.lock.json`.
The official release export and external CSS endpoints can be mutable: the
vendored bytes plus checksums, **not their URL**, are the reproducible inputs.
The export release is pinned independently of the standard-library commit;
compilation is the compatibility gate. Do not assume a shared upstream revision.

Review vendor/lock diffs, rebuild a candidate, and run checks before importing.
New dependency URLs or standard-library layouts fail closed instead of being
silently fetched or ignored. Refresh updates applied inputs only after a later
`chezmoi apply`; never point `--vendor-dir` at live config to bypass review.

For a repository-only candidate without applying dotfiles, render `palette.json`
into a scratch config directory, copy `browser-map.json` there, and copy the
`vendor` directory there. Then pass `build --config <scratch-config> --output
<scratch-output> --cache <scratch-cache>`. No fixed checkout path is assumed.

## Automated checks

From the repository root:

```text
mise exec -- python -m unittest discover -s scripts/stylus -v
npm ci --prefix scripts/stylus --ignore-scripts
node scripts/stylus/check.mjs <output>/import.json <output>/lib.less
```

The Node dependencies are development-only and pinned by `package-lock.json`.
The compiler check parses source metadata with `usercss-meta`, simplifies saved
variables as Stylus does, runs Less with Stylus's `parens-division` math setting,
and parses compiled CSS/document scopes. It forces both flavor paths and checks
library helpers, RGB/HSL output, SVG interpolation, filters, and light branches.
It is not a full extension harness; actual import remains a separate gate.

Initial verification: **22 Python tests**, **132 userstyles × 2 flavor paths**,
**310 document sections**, and helper fixtures passed. The macOS trigger and
Nushell wrappers were exercised against a scratch config/output with spaces in
its path; both Bash wrappers were also tested with a mise stub that overwrites
XDG variables and asserts auto-installation is disabled. Windows templating was
checked, but PowerShell execution remains unverified (pwsh is not installed).
No main-browser import, visual approval, or hosted-library change has been performed.

## Explicit exclusions

The initial upstream snapshot contains 134 styles; 132 are generated.

| Excluded style | Reason |
| --- | --- |
| Codeberg | Imports complete, hardcoded Gitea themes, rather than variable-based CSS |
| PythonAnywhere | Imports complete, hardcoded Chroma syntax themes |

Both exclusions appear in the build report and build console output. Adapting
those dependencies requires a separate semantic-token conversion, not a return
to blind hex substitution. A first-time import does not install these styles;
reimporting into an existing profile does **not** remove old copies. Disable old
copies explicitly if they should not remain active.

## Browser rollout and rollback

1. Export the current **live** Stylus configuration as a backup.
2. Test the candidate in an isolated profile, not the main browser.
3. Review one text-heavy site, one application/dashboard, one site with an
   independent appearance toggle, and SVG/filter/syntax-highlighting examples.
4. Inspect text, links, controls, placeholders, focus/hover/selection, modals,
   borders, elevated surfaces, alerts, and disabled states in both modes.
5. Check body text against 4.5:1 where feasible; document intentional muted
   exceptions. Check actual surfaces, not only palette swatches.
6. Switch dark → light → dark without reinstalling. Distinguish website appearance
   settings from browser/OS color-scheme overrides.
7. Test reimport behavior for enabled states, custom inclusion patterns, and
   site-specific variables. Do not assume the live profile's settings survive.
8. Only after approval, import `$XDG_DATA_HOME/achroma/stylus/import.json` into the
   main profile. Inspect the settings-record effects before accepting them.

Generated styles retain upstream names, namespaces, attribution, and website
settings, but remove `updateUrl`, metadata/source `@updateURL`, stale compiled
sections, and old digests. The export disables automatic updates globally
(`updateInterval = 0`), which also affects unrelated installed styles if imported.
Review that trade-off in the isolated profile. Without per-style upstream update
URLs, manual updates cannot restore the original standard-library import through
those URLs. Existing extension state still needs verification after migration.

Rollback means restoring the saved **live Stylus backup**, not just reverting
repository files. The remote `noidilin.github.io/achroma/lib/lib.less` remains
unchanged and is not required by new generated styles.

## References

- [Catppuccin usage](https://userstyles.catppuccin.com/getting-started/usage/)
- [Standard-library versioning](https://userstyles.catppuccin.com/contributing/reference/libraries/standard/)
- [Stylus Less preprocessing](https://github.com/openstyles/stylus/blob/master/src/js/worker/pre-less.js)
- [Stylus variable simplification](https://github.com/openstyles/stylus/blob/master/src/js/worker/usercss-compiler.js)
