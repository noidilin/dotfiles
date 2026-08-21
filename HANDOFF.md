# Handoff: achroma light-theme support across the dotfiles

Context for the next agent continuing this work. Read this before touching
theme files. State as of 2026-08-21: all planned CLI/TUI tools are DONE and
pushed on `feat/achroma-light` (11 commits); what remains is the deferred
group, the yazi icon restructuring, and mac-side verification.

## Goal and constraints

- Add light-variant support for the user's custom monochrome **achroma**
  theme across all CLI/TUI tools in this chezmoi repo, matching the light
  support they already built by hand in neovim and wezterm (separate repos,
  pulled in via `home/.chezmoiexternals/`).
- **Scope guard**: this is a company device. Theme work must stay separable
  from company-device changes. The uncommitted company diffs are
  `home/.chezmoidata/pm/*.yml` and `home/.chezmoiexternals/windows.toml.tmpl`
  — never mix them into theme commits. They are the ONLY uncommitted files;
  everything else lives on `feat/achroma-light` (pushed to origin).
- Commit messages: Conventional Commits, explain *why* in the body.

## Architecture (decided and implemented)

**The OS app theme is the single source of truth.** Windows
`AppsUseLightTheme` → wezterm (`wezterm.gui.get_appearance()`, pinnable via
`WEZTERM_THEME`) → terminal background → everything that detects OSC 11 or
OS appearance follows automatically. Tools that can't detect are driven by
`ACHROMA_VARIANT` (resolved from the OS at shell start) or by the `theme`
switcher command editing their applied config in place.

**Single palette source**: `home/.chezmoidata/colors.yml` defines
`color.achroma.dark` and `color.achroma.light`. Keys are ROLES, not
lightness: `mono00`–`mono25` run background-side → foreground-side, plus
`acc00-08`, `accDim00-08`, chromatic ramps (`red00/01`, etc.) and blend
tokens `mixRed10/25`, `mixGreen10/25`, `mixMagenta/Blue/Cyan/Yellow25`
(accent mixed into base: dark base `#1f1f1f`, light base `#ededed`). Values
mirror `~/.config/wezterm/utils/palette-dark.lua` / `palette-light.lua` —
keep the three in sync.

**Per-tool pattern**: theme body lives in `home/.chezmoitemplates/<tool>-achroma.*`
with `{{ .c.<role> }}` refs; thin `.tmpl` wrappers render dark and light by
passing the palette via `dict`. Direction-sensitive slots that don't survive
role mirroring (from wezterm's `config/theme.lua` "ink" table) are passed as
an extra `ink` dict: ansi black stays dark / white stays light (light white
borrows the DARK palette's warm acc06/acc07), cursor text and selection use
background-side tones, borders/splits step to a mid tone (light mono10)
because the light ramp is compressed at the background end.

**The switcher** (`theme` / `theme light|dark` in nushell):

- `dot_config/pwsh/scripts/set-app-theme.ps1` — sets `AppsUseLightTheme`
  (apps only) and broadcasts `WM_SETTINGCHANGE "ImmersiveColorSet"` so
  running apps switch without restart.
- `dot_config/nushell/env/variant.nu` — sourced near the top of `config.nu`
  (BEFORE `$env.config`, which needs it); resolves `$env.ACHROMA_VARIANT`
  from the OS (Windows registry / macOS `defaults`) and sets
  `$env.DELTA_FEATURES`.
- `dot_config/nushell/autoload/commands/theme.nu` — `theme` shows state;
  `theme light|dark` flips the OS app theme, refreshes session env
  (DELTA_FEATURES, LS_COLORS via vivid, EZA_CONFIG_DIR), flips single
  selection keys in applied configs (jjui, k9s, starship, pi, posting via a
  `[file key name]` table), and copies the carapace variant file over
  `styles.json`.

## Done (committed and pushed on `feat/achroma-light`)

Every dark render was diffed against the original (byte-identical except
noted snaps); light renders validated (jq / tool-native parsers / live
switcher runs).

| Tool | How light works |
|---|---|
| bat | native: `--theme-dark`/`--theme-light` in `bat/config` (bat ≥0.25 detects terminal bg) |
| delta | both features in one gitconfig; switch = `DELTA_FEATURES=achroma-light` env |
| ghostty | native: `theme = dark:achroma,light:achroma-light` |
| yazi | native: `[flavor] dark/light`; BOTH flavors now chezmoi-managed (external `achroma.yazi` repo removed from `.chezmoiexternals`; user archives it) |
| Windows Terminal | native (≥1.16): per-profile `"colorScheme": {"dark":…, "light":…}` |
| zed | native: theme family + `"theme": {"mode":"system",…}` |
| opencode | native: per-color `{"dark":…, "light":…}` |
| fzf | env: colors chosen by `ACHROMA_VARIANT` at shell start |
| zellij | native: `theme_dark`/`theme_light` in `config.kdl`; no switcher flip. darwin-only in `.chezmoiignore` — NOT testable on Windows |
| jjui | `theme.nu` flips `theme = "…"` in `jjui/config.toml` |
| k9s | `theme.nu` flips `skin: …` in `k9s/config.yaml` |
| starship | both `[palettes.noidilin{,-light}]` rendered; `theme.nu` flips `palette = '…'`; re-read every prompt, so live shells update |
| pi | format has no light support → separate `achroma-light.json`; `theme.nu` flips `"theme"` in `pi/settings.json` |
| posting | `theme.nu` flips `theme:` in `posting/config.yaml` |
| vivid/LS_COLORS | both themes rendered; `shell.nu` picks by `ACHROMA_VARIANT`; `theme` regenerates in-session |
| eza | per-variant config dirs `eza/achroma{,-light}/theme.yml`; `EZA_CONFIG_DIR` selects (env flip, no file copies) |
| carapace | reads exactly one `styles.json`; `theme.nu` copies `styles-achroma{,-light}.json` over it |
| nushell color_config | `config/palette.nu.tmpl` carries both variants, picked by `ACHROMA_VARIANT` at shell start |

Role snaps made along the way (flag to user if they matter): bat/zed
`#222222`→mono04, bat `#4b4b4b`→mono11, zed `#505050`→mono11, zellij
`#8f8f8f`→mono18, eza `#b3b0a7`→accDim05, pi toolErrorBg `#271717`→mixRed10.
Zed's dark ansi yellow `#b09661` kept verbatim as ink; opencode `info`
`#dc8a78` got re-derived light counterpart `#8b574c`. Ink overrides beyond
the wezterm table: zellij light selected-ribbon fill mono12 and unselected
frame mono10; jjui borders mono10; starship `frame` key mono10 (light).

## Gotchas discovered (do not re-learn these the hard way)

- **delta 0.19.2**: features are unconditional, and `light = true` inside a
  feature errors whenever delta falls back to its dark default. The light
  feature has NO mode key; the dark feature keeps `dark = true`.
- **Go templates**: `{{{` vim fold markers and literal `{{ … }}` in config
  bodies (e.g. nushell records) parse as template actions and break ALL
  rendering; escape as `{{ "{{" }}` (see `yazi-achroma-flavor.toml`,
  `palette.nu.tmpl`).
- **nushell module/command shadowing**: a config module whose `main` is
  imported by name (old `config/theme.nu`) silently shadows a same-named
  autoload command. That's why the palette module is called `palette`.
- **nushell `registry query`** returns a record `{name, value, type}` —
  compare `| get value`, not the whole result (this bug made every shell
  resolve dark).
- **Autoload commands don't load in `nu -l -c`** — to test the switcher
  non-interactively, `source` `autoload/commands/theme.nu` explicitly.
- **chezmoi + removed externals**: after deleting an external entry, the
  applied dir stays on disk unmanaged and `chezmoi apply` prompts
  interactively ("has changed since chezmoi last wrote it") — move the old
  dir aside and use `chezmoi apply --force`.
- After changing bat themes run `bat cache --build`.
- Subagent model overrides fail in this environment (API errors); work
  inline.
- 1Password commit signing intermittently fails ("failed to fill whole
  buffer") — just retry the commit.

## Left to do

1. **Yazi icons** (structural): ~750 lines of `[icon]` overrides in
   `yazi/theme.toml` apply on top of BOTH flavors with dark-tuned hexes, so
   icons look washed out in light mode. Both flavors are now chezmoi-managed,
   so the fix is moving the icon tables into each flavor's
   `flavor.toml.tmpl`, role-mapped per variant.
2. **zsh/mac side**: variant resolution + fzf colors in `env.zsh` are still
   dark-only; port the `ACHROMA_VARIANT` resolution (macOS `defaults read -g
   AppleInterfaceStyle`) and the fzf/eza/vivid env selection to zsh.
3. **Verify on darwin**: zellij (ignored on Windows, untested), jjui binary,
   and the macOS branch of `variant.nu` / `theme.nu` (`osascript` flip).
4. Deferred/optional (decide with user): lazygit, lazydocker, gh-dash,
   bottom (colors inlined, no theme indirection — worst effort/payoff);
   GUI apps (flow-launcher, stylus, shareX, antinote, blender, fcitx5,
   zebar). A pwsh `variant.ps1` for PowerShell sessions was also discussed.
5. **Merge back**: user merges `feat/achroma-light` toward the original
   dotfiles repo (branch is pushed; PR link:
   https://github.com/noidilin/dotfiles/pull/new/feat/achroma-light).

## Standing behaviors to remember

- **Config-flip drift**: `theme.nu` edits APPLIED files for jjui, k9s,
  starship, pi, posting, carapace; chezmoi source keeps the dark default, so
  `chezmoi apply` while in light mode resets those until `theme light` is
  rerun. If this annoys the user, a chezmoi `modify_` script or a
  variant-aware template driven by a state file would fix it — not built.
- The machine was left in **light mode** with all flips applied.
- The pre-migration external yazi flavor clone is backed up at
  `~/.claude/jobs/77365eba/tmp/achroma.yazi-external-backup` (job-temporary;
  gone once the job is deleted — the GitHub repo still has everything).

## Next best task

**Yazi icon migration (item 1)** — it's the only remaining piece that makes
the already-shipped light mode visibly wrong, and it's now unblocked: move
the `[icon]` tables from `yazi/theme.toml` into `yazi-achroma-flavor.toml`
(role-map the handful of repeated hexes: `#5d5d5d`→mono13, `#4e4e4e`→mono11,
`#707070`→mono15, etc.), leaving `theme.toml` with just the `[flavor]`
table. Verify the dark flavor render against the current combined output.
After that, item 2 (zsh/mac port) — but note it can only be smoke-tested on
the mac, so keep it to a small reviewable commit and lean on item 3's
darwin verification pass.

## Verification habits used so far

- Render with `chezmoi cat <target>` (or `chezmoi execute-template` for
  platform-ignored files like zellij's) and diff against
  `git show HEAD:<source>` (normalize CRLF with `tr -d '\r'`).
- jq for JSON validation and ref-resolution checks; `nu -l -c` to smoke-test
  nushell files (quote whole command in single quotes — Git Bash eats
  `$env`); `starship print-config` to validate starship.
- Grep templates for leftover `#[0-9a-f]{6}` after substitution — should be
  zero (ink literals excepted).
- Exercise the real switcher end-to-end (`theme light`) and check the
  flipped keys landed in the applied configs.
