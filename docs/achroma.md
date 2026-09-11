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
 └─ the `theme` command, which flips the OS setting and re-points
    ~/.config/achroma/current
     └─ everything that cannot follow on its own (jjui, k9s, pi, posting,
        starship, carapace, bottom, lazydocker, herdr)
```

### Stable paths, one pointer

The nine tools at the bottom of that tree cannot detect the OS theme and have
no dark/light config key. They are handled by indirection rather than by
rewriting their configs:

```text
~/.config/achroma/
  variants/
    dark/   { jjui.toml k9s.yaml pi.json posting.yaml starship.toml
              carapace.json bottom.toml lazydocker.yml herdr.toml }
    light/  { same nine names }
  current -> variants/dark        # the only mutable state; `theme` owns it
```

Each of the nine reads a path that **never changes** and resolves through
`current`, so switching variants never touches an applied config. chezmoi
renders both trees and owns all nine symlinks; it ignores `current`.

This is the pattern omarchy uses (`~/.config/omarchy/current/theme/<file>`,
which every app config `import`s or `source`s), with one deviation: omarchy
rebuilds a `next-theme/` directory and `mv`s it over `current/theme`, while
here both trees are permanently on disk and only a symlink moves. Same
property — the app's own config file is never rewritten — with less copying.

The earlier mechanism did rewrite them, either flipping one selection key in
place or copying a variant render over the applied file. Because the chezmoi
source had to pick a default, `chezmoi apply` while in light mode reset all
nine to dark. That failure mode is gone.

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

Where the wrappers live depends on how the tool is switched. Env-selected
tools keep theirs next to the tool's own config (e.g.
`dot_config/lazygit/theme-achroma[-light].yml.tmpl`). The nine
pointer-selected tools have theirs under
`dot_config/achroma/variants/{dark,light}/<tool>.<ext>.tmpl`, one uniform
filename per tool in each tree — that is what lets a single symlink swap
switch all nine.

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
3. **Re-point `~/.config/achroma/current`** — one symlink swap
   (`ln -sfn variants/<variant>`; Windows goes through
   `pwsh/scripts/set-achroma-current.ps1`, since nushell has no `ln`
   builtin). That is the entire switch for jjui, k9s, pi, posting, starship,
   carapace, bottom, lazydocker and herdr.
4. **Reload herdr** — `herdr server reload-config`, so the running server
   re-reads the pointer's new target without dropping the session.

### Where chezmoi fits

chezmoi owns the **source of every variant** and every path that reaches into
them: both variant trees under `~/.config/achroma/variants/`, and the nine
stable-path symlinks that point through `current`. It owns **nothing** about
which variant is live — `.chezmoiignore` excludes `.config/achroma/current`,
and the `theme` command is its only writer.

That is what makes the whole thing drift-free. Every tool is now in one of
three classes, and none of them can be reset by `chezmoi apply`:

- **OS-native** — the tool reads the OS app theme or the terminal background
  itself.
- **Env-selected** — both renders sit on disk, an env var picks one.
- **Pointer-selected** — the tool reads a path that never changes, and that
  path resolves through `current`.

One residual caveat, unrelated to chezmoi: an app that rewrites its own
symlinked config via temp-file-plus-rename will *replace* the symlink with a
regular file and silently break its own indirection. herdr's settings UI
(Ctrl+q Shift+S) and `carapace --style` are the two known writers. `chezmoi
status` surfaces it as an `M`, so it is visible rather than silent — but edit
the source, not the app.

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

### Reached through `achroma/current` (re-pointed by `theme`)

All nine read a path that never changes. The four with a themes directory get
a fixed *filename* their config names forever; the five that read exactly one
config file have that whole file symlinked.

| Tool | Stable path | Variant file | Config says |
| --- | --- | --- | --- |
| jjui | `jjui/themes/achroma-current.toml` | `jjui.toml` | `theme = "achroma-current"` |
| k9s | `k9s/skins/achroma-current.yaml` | `k9s.yaml` | `skin: achroma-current` |
| pi | `pi/themes/achroma-current.json` | `pi.json` | `"theme": "achroma-current"` |
| posting | `posting/themes/achroma-current.yaml` | `posting.yaml` | `theme: achroma-current` |
| starship | `starship.toml` (whole file) | `starship.toml` | `palette = 'noidilin'` (fixed) |
| carapace | `carapace/styles.json` (whole file) | `carapace.json` | — |
| bottom | `bottom/bottom.toml` (whole file) | `bottom.toml` | — |
| lazydocker | `lazydocker/config.yml` (whole file) | `lazydocker.yml` | — |
| herdr | `herdr/config.toml` (whole file) | `herdr.toml` | — |

Two members behave specially:

- **starship** is the only tool that updates live in *every* running shell: it
  re-reads and re-resolves `~/.config/starship.toml` on each prompt, so a
  pointer flip recolors every open shell on its next prompt. This is why it
  gets a whole-file symlink rather than a `STARSHIP_CONFIG` env var — the env
  var would only ever reach the shell that ran `theme`. Cost: the prompt body
  is rendered into both variant trees, but the source stays single
  (`.chezmoitemplates/starship-achroma.toml`).
- **herdr** (darwin-only) holds its config in the running server, so `theme`
  follows the flip with `herdr server reload-config`.

The other seven apply on next launch.

For pi and posting the theme file carries an internal `name:` field that the
app registers the theme under, so both variant renders pass
`"name" "achroma-current"` — it has to match the fixed filename, not the
variant.

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

Verified on macOS (2026-09-11, after `chezmoi apply`): every dark/light
variant pair renders and landed on disk; `zsh/env.zsh` and
`nushell/env/variant.nu` both resolve `ACHROMA_VARIANT` from
`AppleInterfaceStyle`.

### Verifying the pointer design

The drift regression test is the acceptance criterion — it is the bug the
indirection exists to kill:

```nu
theme light
theme                # => pointer: light
chezmoi apply
theme                # => pointer: light   <-- used to come back dark
```

`theme` with no argument reports `pointer`, which resolves the symlink, so it
is the authoritative live variant. `chezmoi status` must never mention
`.config/achroma/current`; if it does, the `.chezmoiignore` entry is wrong.

Verified 2026-09-11 against the refactor, before applying: all nine relative
symlink targets resolve into the variants trees; the twelve renders that
should not have changed are byte-identical to the pre-refactor ones; pi and
posting differ only in the `name` field; `chezmoi status` lists the 18 variant
files, the nine symlinks and the four fixed config keys, and does **not** list
`.config/achroma/current`.

Still pending: visual confirmation inside zellij, jjui, herdr and antinote;
the `osascript` appearance flip (sending Apple events to System Events needs
Automation permission, which a non-interactive process does not have
(`-1743`), so run `theme light` from a real terminal once); whether `herdr
server reload-config` re-reads through a symlink whose target changed; and the
whole Windows path (`set-achroma-current.ps1` and the
`run_after_06-achroma-current.ps1` seeder are unrun and un-syntax-checked —
no pwsh on the current machine).

**`theme` aborts if the appearance flip fails.** The `osascript` call is
unguarded and runs before the pointer swap, so a TCC denial leaves every tool
on the old variant rather than half-switched — noisy but safe. Wrap it in
`try` only if this starts happening on a machine that matters.

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
- **`ln -sfn`, never `ln -sf`** — when `current` already exists as a symlink
  to a directory, `-f` alone dereferences it and creates the new link *inside*
  the old target (`variants/dark/light`). `-n` is what makes it a replace.
- **pi and posting theme files carry an internal `name:`** that must match the
  filename they are read under, so both variants pass `achroma-current`.
- **Windows symlinks** need `SeCreateSymbolicLinkPrivilege` or Developer Mode,
  both set up by `init/win.ps1`. nushell has no `ln` builtin, so the pointer
  swap goes through `pwsh/scripts/set-achroma-current.ps1`, which falls back
  to a directory junction (no elevation needed, absolute target required).
- **The bootstrap seeder must be create-if-missing.** `.chezmoiscripts/*/
  run_after_06-achroma-current.*` guards on `[ -e ] || [ -L ]` and exits; if
  it ever re-pointed the pointer, `chezmoi apply` in light mode would reset
  everything to dark again.
- After changing bat themes, run `bat cache --build`.
- **Before overwriting an applied GUI config, diff it** — the on-disk file
  may be ahead of chezmoi source (zebar's dual-variant design existed only
  on disk until it was captured).
