# Handoff: achroma light-theme support across the dotfiles

Context for the next agent continuing this work. Read this before touching
theme files. State as of 2026-08-21 (second pass): ALL CLI/TUI tools are
DONE, the yazi icon restructuring is DONE, the deferred group (lazygit,
lazydocker, bottom, gh-dash, pwsh, zsh) is DONE, and zebar/flow-launcher/
antinote have light variants. What remains is mac-side verification and the
merge back; blender/stylus/shareX/fcitx5 were deliberately skipped.

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
| yazi icons | moved from `theme.toml` into the shared flavor template, role-mapped per variant; `theme.toml` keeps only `[flavor]` |
| lazygit | colors split into `theme-achroma{,-light}.yml` layered over `config.yml` via `LG_CONFIG_FILE` (env-selected, no apply drift) |
| gh-dash | had NO theme colors before (upstream defaults); both variants now carry role-consistent `theme.colors`, selected via `GH_DASH_CONFIG` env |
| bottom | reads one file, no env override: `theme.nu` copies `bottom-achroma{,-light}.toml` over `bottom.toml` |
| lazydocker | same copy pattern: `config-achroma{,-light}.yml` over `config.yml` |
| pwsh | `scripts/variant.ps1` (sourced first in profile.ps1) resolves `ACHROMA_VARIANT` + DELTA/EZA/LS_COLORS/LG/GH_DASH env; `fzf.ps1` is a template with both variants |
| zsh (mac) | `env.zsh.tmpl` resolves variant from `AppleInterfaceStyle` and picks delta/eza/vivid/fzf/lazygit/gh-dash env per variant |
| zebar | dual-variant CSS (`:root` light, `:root.dark` dark) + bootstrap in `main.html` follows the Windows app theme via prefers-color-scheme; pinnable via localStorage `achroma-variant` |
| flow-launcher | `achroma-light.xaml` sibling rendered from shared template; theme is selected in-app |
| antinote | `achroma-light.json` sibling; imported/selected in-app on the mac |

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

1. **Verify on darwin**: zellij (ignored on Windows, untested), jjui binary,
   the macOS branch of `variant.nu` / `theme.nu` (`osascript` flip), the new
   `env.zsh.tmpl` (variant resolution + fzf/eza/vivid/lazygit/gh-dash env;
   syntax-checked only on Windows), and antinote's light theme import.
2. **Merge back**: user merges `feat/achroma-light` toward the original
   dotfiles repo (branch is pushed; PR link:
   https://github.com/noidilin/dotfiles/pull/new/feat/achroma-light).
3. Deliberately skipped (revisit only if the user asks): blender (1672-line
   XML theme — needs visual tuning in blender, not a mechanical mirror),
   stylus (`achroma.json` is a 3MB full userstyles backup, not a theme
   file), shareX (no config in the repo), fcitx5 (linux-only, untestable
   here).

## Standing behaviors to remember

- **Config-flip drift**: `theme.nu` edits APPLIED files for jjui, k9s,
  starship, pi, posting, and copies over carapace's styles.json, bottom's
  bottom.toml and lazydocker's config.yml; chezmoi source keeps the dark
  default, so `chezmoi apply` while in light mode resets those until
  `theme light` is rerun. lazygit and gh-dash are env-selected
  (LG_CONFIG_FILE / GH_DASH_CONFIG) and have NO drift. If the drift annoys
  the user, a chezmoi `modify_` script or a variant-aware template driven
  by a state file would fix it — not built.
- The machine was left in **light mode** with all flips applied.
- **Zebar had an uncommitted on-disk dual-variant design** (bootstrap in
  main.html + light-default styles.css with `:root.dark`) that chezmoi
  source had never captured; it is now templated into source and verified
  render-identical. Lesson: before overwriting an applied GUI config, diff
  it — on-disk may be ahead of source.
- flow-launcher's Settings.json is live-managed by the app; theme selection
  happens in its UI, so the switcher does not touch it.
- The pre-migration external yazi flavor clone is backed up at
  `~/.claude/jobs/77365eba/tmp/achroma.yazi-external-backup` (job-temporary;
  gone once the job is deleted — the GitHub repo still has everything).

## Next best task

**Darwin verification (item 1)** — everything implementable on this Windows
machine is done. On the mac: source env.zsh in a fresh zsh and check
ACHROMA_VARIANT/fzf/eza/vivid/LG_CONFIG_FILE/GH_DASH_CONFIG, run
`theme light`/`theme dark` (osascript flip), and eyeball zellij, jjui,
lazygit, gh-dash, antinote in both variants. Then merge (item 2).

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
