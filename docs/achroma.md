# Achroma Theme: Dark/Light Variants

How the custom monochrome **achroma** theme supports both a dark and a light
variant across every CLI/TUI/GUI tool in this repo, and how chezmoi and the
shell switcher cooperate to toggle between them.

## Design principles

### The OS app theme is the single source of truth

Windows `AppsUseLightTheme` (or macOS `AppleInterfaceStyle`) decides the
variant. Everything else derives from it:

```text
OS app theme
 ├─ wezterm (wezterm.gui.get_appearance, pinnable via WEZTERM_THEME)
 │   └─ terminal background → tools that detect OSC 11 / terminal bg
 │      (neovim, bat, delta)
 ├─ tools with native dark/light config keys (ghostty, yazi, zed, …)
 ├─ ACHROMA_VARIANT env var, resolved from the OS at shell start
 │   └─ tools that only read colors at startup (fzf, vivid, eza,
 │      lazygit, gh-dash, nushell color_config)
 └─ the `theme` command, which flips the OS setting and reconciles
    everything that cannot follow on its own
```

### One palette, addressed by role

`home/.chezmoidata/colors.yml` defines `color.achroma.dark` and
`color.achroma.light`. Keys are **roles, not lightness**:

- `mono00`–`mono25` run background-side → foreground-side. In the dark
  palette `mono03` is the near-black base; in the light palette the same key
  is the near-white base. A theme body that says `mono13` gets a readable
  mid-gray in both variants.
- `acc00`–`acc08` / `accDim00`–`accDim08`: the warm accent ramps, lightness
  mirrored with hue/saturation preserved.
- Chromatic ramps (`red00/01`, `green00/01`, `yellow00/01`, `blue00/01`,
  `magenta00/01`, `cyan00/01`, `orange00/01`): same hues in both variants,
  re-derived (not inverted) for 4.3–7.5:1 contrast on the light base.
  `XX01` stays the "emphasis" slot in both.
- `mixRed10/25`, `mixGreen10/25`, `mixMagenta/Blue/Cyan/Yellow25`: accent
  mixed into the base at the given percentage, for tinted surfaces (delta
  diff backgrounds and the like).

The palette mirrors `wezterm/utils/palette-dark.lua` / `palette-light.lua`
and neovim's `lush_theme/_primitive.lua` (separate repos) — keep them in
sync when a color changes.

### Per-tool template pattern

Each themed tool has:

1. a **theme body** in `home/.chezmoitemplates/<tool>-achroma.*` that
   references colors only as `{{ .c.<role> }}`, and
2. thin **wrapper templates** that render dark and light by passing the
   palette via `dict`:

```text
{{ template "jjui-achroma.toml" (dict "c" .color.achroma.light ...) }}
```

Rendering a new variant is just passing the other palette.

### Ink overrides

Some slots do not survive role mirroring, because the light mono ramp is
**compressed at the background end** (`mono03`–`mono07` are within a few RGB
points of each other, while the dark equivalents are clearly separated).
Wrappers pass these as an extra `ink` dict so the shared body stays
role-based:

- selection backgrounds: dark `mono05` → light `mono07`
- borders/splits: dark `mono07` → light `mono10`
- ANSI black stays dark / white stays light regardless of variant (light
  white borrows the dark palette's warm `acc06`/`acc07`)
- zebar's light `--crust` is a literal `#f2f2f2`, deliberately darker than
  `--mantle` so the bar reads as elevated

## How switching works

### Variant resolution at shell start

Each shell resolves `ACHROMA_VARIANT` from the OS once per session and
derives the startup-time env from it:

| Shell | File | Also sets |
| --- | --- | --- |
| nushell | `nushell/env/variant.nu` (sourced before `$env.config`) + `env/shell.nu` + `env/fzf.nu.tmpl` | `DELTA_FEATURES`, `EZA_CONFIG_DIR`, `LS_COLORS` (vivid), `LG_CONFIG_FILE`, `GH_DASH_CONFIG`, fzf colors, nushell `color_config` |
| zsh (macOS) | `zsh/env.zsh.tmpl` | same set (reads `defaults read -g AppleInterfaceStyle`; the key is absent when Light) |
| pwsh | `pwsh/scripts/variant.ps1` (sourced first in `profile.ps1`) + `scripts/fzf.ps1.tmpl` | same set (reads the `AppsUseLightTheme` registry value) |

### The `theme` command (nushell)

`theme` shows the current state; `theme light` / `theme dark`
(`nushell/autoload/commands/theme.nu`) performs, in order:

1. **Flip the OS app theme** — Windows via
   `pwsh/scripts/set-app-theme.ps1` (sets `AppsUseLightTheme` for apps only
   and broadcasts `WM_SETTINGCHANGE "ImmersiveColorSet"` so running apps
   switch without restart); macOS via an `osascript` appearance toggle.
   Everything with native detection follows from here on its own.
2. **Refresh the current session's env** — `ACHROMA_VARIANT`,
   `DELTA_FEATURES`, `LS_COLORS` (vivid regenerate), `EZA_CONFIG_DIR`,
   `LG_CONFIG_FILE`, `GH_DASH_CONFIG`. Other running shells re-resolve on
   their next start.
3. **Flip single selection keys in applied configs** — a `[file key name]`
   table rewrites one line in place for jjui, k9s, starship, pi, posting
   (e.g. `skin: achroma` ↔ `skin: achroma-light`).
4. **Copy variant renders over single-file configs** — carapace
   `styles.json`, bottom `bottom.toml`, lazydocker `config.yml` read exactly
   one file with no env/flag override, so the variant render is copied over
   the applied file.

### Where chezmoi fits

chezmoi owns the **source of every variant**: both renders always exist on
disk after `chezmoi apply` (e.g. `theme-achroma.yml` and
`theme-achroma-light.yml`). The switcher never generates colors — it only
selects between files chezmoi already rendered, by env var, key flip, or
copy.

**Known drift**: for the key-flip and copy tools (jjui, k9s, starship, pi,
posting, carapace, bottom, lazydocker) the chezmoi source keeps the dark
default, so `chezmoi apply` while in light mode resets them to dark until
`theme light` is rerun. Env-selected tools (lazygit, gh-dash, eza, fzf,
vivid, delta) have no drift. If the drift ever becomes annoying, the fix
would be a chezmoi `modify_` script or a variant-aware template driven by a
state file — deliberately not built yet.

## Per-tool mechanism catalog

### Native detection (nothing to switch)

| Tool | Mechanism |
| --- | --- |
| wezterm | `wezterm.gui.get_appearance()`; pin with `WEZTERM_THEME` |
| neovim | follows the terminal background via OSC 11 |
| bat | `--theme-dark` / `--theme-light` in `bat/config` (bat ≥ 0.25) |
| ghostty | `theme = dark:achroma,light:achroma-light` |
| yazi | `[flavor] dark/light` in `theme.toml`; icons live inside each flavor, role-mapped |
| Windows Terminal | per-profile `"colorScheme": {"dark": …, "light": …}` (≥ 1.16) |
| zed | theme family + `"theme": {"mode": "system", …}` |
| opencode | per-color `{"dark": …, "light": …}` |
| zellij | `theme_dark` / `theme_light` in `config.kdl` (darwin-only) |
| zebar | dual-variant CSS (`:root` light, `:root.dark` dark); a bootstrap script in `main.html` follows the app theme via `prefers-color-scheme`, pinnable with `localStorage.setItem('achroma-variant', …)` |

### Env-selected at shell start (refreshed by `theme`)

| Tool | Mechanism |
| --- | --- |
| delta | both features in one gitconfig; `DELTA_FEATURES=achroma[-light]` |
| fzf | color set chosen by `ACHROMA_VARIANT` |
| vivid / LS_COLORS | `LS_COLORS` generated from `achroma[-light].yml` |
| eza | `EZA_CONFIG_DIR` points at `eza/achroma[-light]/` |
| lazygit | `LG_CONFIG_FILE=config.yml,theme-achroma[-light].yml` (later file layers over the shared config) |
| gh-dash | `GH_DASH_CONFIG` points at `config-achroma[-light].yml` |
| nushell color_config | `config/palette.nu.tmpl` carries both variants, picked at shell start |

### Selection key flipped in place by `theme`

| Tool | Flipped key |
| --- | --- |
| jjui | `theme = "achroma[-light]"` in `jjui/config.toml` |
| k9s | `skin: achroma[-light]` in `k9s/config.yaml` |
| starship | `palette = 'noidilin[-light]'` (re-read every prompt, so live shells update) |
| pi | `"theme": "achroma[-light]"` in `pi/settings.json` |
| posting | `theme: achroma[-light]` in `posting/config.yaml` |

### Variant render copied over the applied file by `theme`

| Tool | Copy |
| --- | --- |
| carapace | `styles-achroma[-light].json` → `styles.json` |
| bottom | `bottom-achroma[-light].toml` → `bottom.toml` |
| lazydocker | `config-achroma[-light].yml` → `config.yml` |

### Light file exists; selected manually in the app

| Tool | Notes |
| --- | --- |
| flow-launcher | `achroma-light.xaml` next to `achroma.xaml`; pick in Flow Launcher's settings (its `Settings.json` is live-managed by the app, so the switcher stays out) |
| antinote | `achroma-light.json` next to `achroma.json` (macOS); import/select in-app |

## Not supported yet

Deliberately skipped — revisit only if it starts to matter:

- **blender** — `achroma.xml` is a 1672-line interface theme; a mechanical
  role mirror would look wrong without visual tuning inside blender.
- **stylus** — `achroma.json` there is a full 3MB userstyles backup export,
  not a theme file; light support would mean authoring per-site CSS.
- **shareX** — no config captured in this repo.
- **fcitx5** — linux-only and untestable on the current machines.

Pending verification (implemented but never run on macOS): zellij, jjui,
the `osascript` flip in `theme.nu`, `zsh/env.zsh.tmpl` (syntax-checked
only), and antinote's light theme import.

## Gotchas worth keeping

- **delta 0.19.2**: features are unconditional, and `light = true` inside a
  feature errors whenever delta falls back to its dark default. The light
  feature has NO mode key; the dark feature keeps `dark = true`.
- **Go templates**: `{{{` vim fold markers and literal `{{ … }}` in config
  bodies (nushell records, yazi fold markers) parse as template actions and
  break ALL rendering; escape as `{{ "{{" }}`.
- **nushell module/command shadowing**: a config module whose `main` is
  imported by name silently shadows a same-named autoload command (that is
  why the palette module is called `palette`, not `theme`).
- **nushell `registry query`** returns a record `{name, value, type}` —
  compare `| get value`, not the whole result.
- **Autoload commands don't load in `nu -l -c`** — to test the switcher
  non-interactively, `source autoload/commands/theme.nu` explicitly.
- After changing bat themes, run `bat cache --build`.
- **Before overwriting an applied GUI config, diff it** — the on-disk file
  may be ahead of chezmoi source (zebar's dual-variant design existed only
  on disk until it was captured).
