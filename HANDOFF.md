# Handoff: achroma light-theme support across the dotfiles

Context for the next agent continuing this work. Read this before touching
theme files.

## Goal and constraints

- Add light-variant support for the user's custom monochrome **achroma**
  theme across all CLI/TUI tools in this chezmoi repo, matching the light
  support they already built by hand in neovim and wezterm (separate repos,
  pulled in via `home/.chezmoiexternals/`).
- **Scope guard**: this is a company device. Theme work must stay separable
  from company-device changes. The uncommitted company diffs are
  `home/.chezmoidata/pm/*.yml` and `home/.chezmoiexternals/windows.toml.tmpl`
  — never mix them into theme commits. Nothing is committed yet; the intended
  branch is `feat/achroma-light` with only theme files.
- Commit messages: Conventional Commits, explain *why* in the body.

## Architecture (decided and implemented)

**The OS app theme is the single source of truth.** Windows
`AppsUseLightTheme` → wezterm (`wezterm.gui.get_appearance()`, pinnable via
`WEZTERM_THEME`) → terminal background → everything that detects OSC 11 or
OS appearance follows automatically.

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

## Done (implemented, applied locally, verified — NOT committed)

Every dark render was diffed against the original (byte-identical except
noted snaps). All files applied via targeted `chezmoi apply <path>`.

| Tool | How light works | Files |
|---|---|---|
| bat | native: `--theme-dark`/`--theme-light` in `bat/config`, bat ≥0.25 detects terminal bg | `.chezmoitemplates/bat-achroma.tmTheme`, wrappers in `dot_config/bat/themes/` |
| delta | both features in one rendered gitconfig; switch = `DELTA_FEATURES=achroma-light` env (bare value REPLACES gitconfig features) | `.chezmoitemplates/delta-achroma.gitconfig`, `dot_config/delta/achroma.gitconfig.tmpl` |
| ghostty | native: `theme = dark:achroma,light:achroma-light` in `ghostty/config` | `.chezmoitemplates/ghostty-achroma`, wrappers in `dot_config/ghostty/themes/` |
| yazi | native: `[flavor] dark/light` in `yazi/theme.toml`; light flavor is chezmoi-managed (dark stays the external `achroma.yazi` repo) | `.chezmoitemplates/yazi-achroma-flavor.toml`, `dot_config/yazi/flavors/achroma-light.yazi/` (flavor.toml + tmtheme.xml reusing the bat template) |
| Windows Terminal | native (≥1.16): per-profile `"colorScheme": {"dark":…, "light":…}` | `.chezmoitemplates/winterm-achroma-scheme.json`, `dot_config/winterm/settings.json.tmpl` |
| zed | native: theme family with light member + `"theme": {"mode":"system",…}` in `private_settings.json` | `.chezmoitemplates/zed-achroma-theme.json`, `dot_config/zed/themes/achroma.json.tmpl` |
| opencode | native: per-color `{"dark":…, "light":…}`; defs carry both palettes, light roles prefixed `light-` | `dot_config/opencode/themes/achroma.json.tmpl` |
| fzf | env: colors chosen by `ACHROMA_VARIANT` at shell start, both variants templated | `dot_config/nushell/env/fzf.nu.tmpl` |

**Phase 2 switcher** (implemented):

- `dot_config/pwsh/scripts/set-app-theme.ps1` — sets `AppsUseLightTheme`
  (apps only) and broadcasts `WM_SETTINGCHANGE "ImmersiveColorSet"` so
  running apps switch without restart. Tested (no-op dark→dark run).
- `dot_config/nushell/env/variant.nu` — sourced in `config.nu` right after
  `xdg.nu`; resolves `$env.ACHROMA_VARIANT` from OS (Windows registry /
  macOS `defaults`) and sets `$env.DELTA_FEATURES`.
- `dot_config/nushell/autoload/commands/theme.nu` — `theme` shows state;
  `theme light|dark` flips the OS app theme + refreshes session env. New
  tool flips get wired here. Sourced from `autoload/commands.nu`.

## Gotchas discovered (do not re-learn these the hard way)

- **delta 0.19.2**: features are unconditional (no auto light/dark feature
  selection), and `light = true` inside a feature errors with "--light and
  --dark cannot be used together" whenever delta falls back to its dark
  default. So the light feature has NO mode key; the dark feature keeps
  `dark = true`. Verified empirically with isolated HOME.
- **Go templates**: vim fold markers `{{{` in config comments parse as
  template actions and break ALL template rendering; escape as
  `{{ "{{{" }}` (see `yazi-achroma-flavor.toml`).
- **Deliberate off-ramp values** were snapped to the nearest role (flag to
  user if it matters): bat/zed `#222222`→mono04, bat `#4b4b4b`→mono11, zed
  `#505050`→mono11. Zed's custom dark ansi yellow `#b09661` is kept verbatim
  as an ink literal. opencode `info` `#dc8a78` got re-derived light
  counterpart `#8b574c`.
- After changing bat themes run `bat cache --build` (light+dark verified
  registered).
- Subagent model overrides fail in this environment (API errors); work
  inline.

## Left to do

Tools with no native switching — each needs: role-mapped body in
`.chezmoitemplates/`, light theme file rendered, and a config-key flip added
to `theme.nu`:

1. **zellij** (`themes/achroma.kdl`; `theme` key in `config.kdl`)
2. **k9s** (`skins/achroma.yaml`; skin key in `private_config.yaml`)
3. **jjui** (`themes/achroma.toml`; theme key in `jjui/config.toml`)
4. **pi** (`themes/achroma.json` — has defs like opencode but NO light
   support in the format; needs a separate `achroma-light.json` + flip in
   `pi/settings.json`)
5. **posting** (`dot_local/share/posting/themes/achroma.yaml`)
6. **starship** (palette inlined in `starship.toml`; add
   `[palettes.achroma-light]` and flip the `palette =` key)
7. **vivid / LS_COLORS** (`vivid/themes/achroma.yml`; light theme + pick by
   `ACHROMA_VARIANT` in `nushell/env/shell.nu` line that runs
   `vivid generate`)
8. **eza** (`eza/theme.yml` — eza reads exactly one file; needs file swap
   or symlink flip)
9. **carapace** (`carapace/styles.json`)
10. **nushell's own colors** (`nushell/config/theme.nu` — mono ramp
    hardcoded; make `color_config` variant-aware)
11. Deferred/optional: lazygit, lazydocker, gh-dash, bottom (colors inlined,
    no theme indirection — worst effort/payoff); zsh/mac side of variant
    resolution + fzf (env.zsh still dark-only); GUI apps (flow-launcher,
    stylus, shareX, antinote, blender, fcitx5, zebar).
12. **Known limitation**: yazi icon colors (~750 lines in `yazi/theme.toml`
    `[icon]`) apply on top of both flavors and cannot follow the variant;
    proper fix is moving icons into each flavor (flavor-repo restructuring).
13. **Migration option**: move `achroma-light.yazi` into the user's flavor
    repo family for symmetry with the external dark flavor.
14. **Commit + merge back**: create `feat/achroma-light`, commit theme files
    only (list = `git status --short | rg -v 'pm/|windows.toml'`), then
    user merges toward the original dotfiles repo.

## Next best task

Do **zellij, jjui, and k9s** next: they follow the established pattern
exactly (small theme files, single selection key, all hexes likely on-ramp)
and each adds a one-line flip to `theme.nu` — highest value per effort and
they exercise the switcher's config-flip path for the first time. Start with
zellij. After those, starship (trivial palette block), then vivid+eza
(introduces the file-swap pattern), then pi/posting, then decide with the
user whether the deferred group is worth doing.

## Verification habits used so far

- Render with `chezmoi cat <target>` and diff against
  `git show HEAD:<source>` (normalize CRLF with `tr -d '\r'`).
- jq for JSON validation and ref-resolution checks; `nu -c` to smoke-test
  nushell files (quote whole command in single quotes — Git Bash eats
  `$env`).
- Grep templates for leftover `#[0-9a-f]{6}` after substitution — should be
  zero (ink literals excepted).
