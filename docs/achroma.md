# Achroma Theme: Dark/Light Variants

How the custom monochrome **achroma** theme supports both a dark and a light
variant across every CLI/TUI/GUI tool in this repo, and how chezmoi and the
shell switcher cooperate to toggle between them.

This file is the mechanism. For *which rung of the palette a given piece of UI
should take* — the foreground ladder, the chroma budget, the surface metrics and
the direction-sensitive slots, digested from the neovim and wezterm configs —
see [docs/achroma-design.md](achroma-design.md).

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
        starship, carapace, bottom, lazydocker, herdr, claude code, leaf,
        tuxedo)
```

### Stable paths, one pointer

The twelve tools at the bottom of that tree cannot detect the OS theme and
have no dark/light config key. They are handled by indirection rather than by
rewriting their configs:

```text
~/.config/achroma/
  variants/
    dark/   { jjui.toml k9s.yaml pi.json posting.yaml starship.toml
              carapace.json bottom.toml lazydocker.yml herdr.toml
              claude.json leaf.toml tuxedo.toml }
    light/  { same twelve names }
  current -> variants/dark        # the only mutable state; `theme` owns it
```

Each of the twelve reads a path that **never changes** and resolves through
`current`, so switching variants never touches an applied config. chezmoi
renders both trees and owns all twelve symlinks; it ignores `current`.

This is the pattern omarchy uses (`~/.config/omarchy/current/theme/<file>`,
which every app config `import`s or `source`s), with one deviation: omarchy
rebuilds a `next-theme/` directory and `mv`s it over `current/theme`, while
here both trees are permanently on disk and only a symlink moves. Same
property — the app's own config file is never rewritten — with less copying.

The earlier mechanism did rewrite them, either flipping one selection key in
place or copying a variant render over the applied file. Because the chezmoi
source had to pick a default, `chezmoi apply` while in light mode reset all
of them to dark. That failure mode is gone.

### One palette, addressed by role

`home/.chezmoidata/colors.yml` defines `color.achroma.dark` and
`color.achroma.light`. Keys are **roles, not lightness**:

- The mono ramp runs background-side → foreground-side over 26 rungs. Rungs
  with a role carry its name; the rungs between them keep `monoNN`. In the
  dark palette `base` is near-black; in the light palette the same key is
  near-white. A theme body that says `overlay1` gets a readable mid-gray in
  both variants.
- `acc00`–`acc08` / `accDim00`–`accDim08`: the warm accent ramps, lightness
  mirrored with hue/saturation preserved.
- Chromatic pairs, one hue each: same hues in both variants, re-derived (not
  inverted) for 4.3–7.5:1 contrast on the light base. The second name of each
  pair is the "emphasis" slot in both.
- `mixRed10/25`, `mixGreen10/25`, `mixMauve25`, `mixBlue25`, `mixSky25`,
  `mixPeach25`: that role mixed into `base` at the given percentage, for
  tinted surfaces (delta diff backgrounds and the like).

neovim's and wezterm's palettes and
[docs/achroma-design.md](achroma-design.md) keep rung numbers on purpose: they
are where rung choices get made, and the arithmetic ("climb two rungs in
light") needs the ordering that role names hide. This is the translation:

| rung | key | rung | key |
| --- | --- | --- | --- |
| `mono21` | `text` | `mono07` | `surface1` |
| `mono19` | `subtext1` | `mono05` | `surface0` |
| `mono17` | `subtext0` | `mono03` | `base` |
| `mono15` | `overlay2` | `mono02` | `mantle` |
| `mono13` | `overlay1` | `mono01` | `crust` |
| `mono11` | `overlay0` | `red00` / `red01` | `red` / `maroon` |
| `mono09` | `surface2` | `green00` / `green01` | `green` / `teal` |
| `yellow00` / `yellow01` | `peach` / `yellow` | `blue00` / `blue01` | `blue` / `lavender` |
| `magenta00` / `magenta01` | `mauve` / `pink` | `cyan00` / `cyan01` | `sapphire` / `sky` |
| `orange00` / `orange01` | `flamingo` / `rosewater` | | |

The palette mirrors `wezterm/utils/palette-dark.lua` / `palette-light.lua`
and neovim's `lush_theme/_primitive.lua` (separate repos) — keep them in
sync when a color changes. The `mix*` keys live only here; neither repo uses
them.

### Per-tool template pattern

The colors themselves are chosen per the conventions in
[docs/achroma-design.md](achroma-design.md); this section is only about where
the files go. Each themed tool has:

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
`dot_config/lazygit/theme-achroma[-light].yml.tmpl`). The twelve
pointer-selected tools have theirs under
`dot_config/achroma/variants/{dark,light}/<tool>.<ext>.tmpl`, one uniform
filename per tool in each tree — that is what lets a single symlink swap
switch all twelve.

A wrapper may also pass values that are not colors at all, when a tool has a
setting that cannot be role-mirrored. leaf's `base` (built-in preset to fall
back on) and `syntax` (syntect theme for fenced code) are polarity-dependent
strings, so its wrappers pass `"base" "ocean"` / `"base" "arctic"` alongside
the palette rather than branching inside the shared body.

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

The compression is worth quantifying, because "one step up in light" is the
rule of thumb it produces. Contrast of each line slot against the two surfaces
tools actually draw on — `mono03` (base) and `mono02` (mantle, which is what
ghostty sets the terminal background to):

| slot | dark on base | light on base | dark on mantle | light on mantle |
| --- | --- | --- | --- | --- |
| `mono09` | 1.63:1 | 1.27:1 | 1.72:1 | 1.38:1 |
| `mono10` | 1.79:1 | 1.49:1 | 1.89:1 | 1.63:1 |
| `mono11` | 2.00:1 | 1.77:1 | 2.11:1 | 1.94:1 |
| `mono12` | 2.24:1 | 2.26:1 | 2.36:1 | 2.47:1 |

So a line mirrored naively loses about a fifth of its weight in light, on
either surface, and the ramps only re-converge at `mono12`. Stepping the light
side up one slot restores it (on mantle, dark `mono10` 1.89 ≈ light `mono11`
1.94).

leaf is where this matters most, since it has more line-type slots than any
other tool here, so its wrappers replace the single `border` with a graded
ramp — `hairline` (table separator, status separator) → `frame` (table box,
code frame, heading underline) → `rule` (thematic break). Each sits one slot
higher in light than in dark, which holds the hierarchy in both variants.
`border` itself stays on the chrome convention above, so leaf's sidebar split
matches jjui's and bottom's.

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
   carapace, bottom, lazydocker, herdr, claude code and leaf.
4. **Reload herdr** — `herdr server reload-config`, so the running server
   re-reads the pointer's new target without dropping the session.

### Where chezmoi fits

chezmoi owns the **source of every variant** and every path that reaches into
them: both variant trees under `~/.config/achroma/variants/`, and the twelve
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

One residual caveat, unrelated to chezmoi: two apps rewrite their own
symlinked config — herdr's settings UI (Ctrl+q Shift+S) and `carapace
--style`. How they write matters:

- **open-truncate-write** follows the symlink, so the bytes land in
  `variants/<live>/…` and the symlink survives. Verified for herdr on
  2026-09-12: after saving from its settings UI, `config.toml` was still a
  symlink and `chezmoi status` showed `MM
  .config/achroma/variants/dark/herdr.toml`.
- **temp-file-plus-rename** would instead *replace* the symlink with a regular
  file and silently break the indirection. Not observed so far.

Either way `chezmoi status` surfaces it, and `chezmoi apply` reverts it — so
edit the source, not the app. Note the write is now **variant-scoped**: an
in-app change lands only in whichever variant was live, so it disappears on
switching rather than persisting as it did when the applied config was a
single real file. If a setting is worth keeping, put it in the shared body
(`.chezmoitemplates/<tool>-achroma.*`) so both renders carry it.

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

All twelve read a path that never changes. The seven with a themes directory
get a fixed *filename* their config names forever; the five that read exactly
one config file have that whole file symlinked.

Claude Code is the only member whose themes directory is outside `~/.config`
(it lives at `~/.claude/themes/`), so its relative symlink climbs to `$HOME`
before descending into `.config/achroma/current/`, the same shape posting
already needed from `~/.local/share/`.

| Tool | Stable path | Variant file | Config says |
| --- | --- | --- | --- |
| jjui | `jjui/themes/achroma-current.toml` | `jjui.toml` | `theme = "achroma-current"` |
| k9s | `k9s/skins/achroma-current.yaml` | `k9s.yaml` | `skin: achroma-current` |
| pi | `pi/themes/achroma-current.json` | `pi.json` | `"theme": "achroma-current"` |
| posting | `posting/themes/achroma-current.yaml` | `posting.yaml` | `theme: achroma-current` |
| Claude Code | `.claude/themes/achroma-current.json` | `claude.json` | `"theme": "custom:achroma-current"` |
| leaf | `leaf/themes/achroma-current.toml` | `leaf.toml` | `theme = "themes/achroma-current.toml"` |
| tuxedo | `tuxedo/themes/achroma-current.toml` | `tuxedo.toml` | `theme = Achroma` (a theme *name*, not a filename) |
| starship | `starship.toml` (whole file) | `starship.toml` | `palette = 'noidilin'` (fixed) |
| carapace | `carapace/styles.json` (whole file) | `carapace.json` | — |
| bottom | `bottom/bottom.toml` (whole file) | `bottom.toml` | — |
| lazydocker | `lazydocker/config.yml` (whole file) | `lazydocker.yml` | — |
| herdr | `herdr/config.toml` (whole file) | `herdr.toml` | — |

Four members behave specially:

- **starship** is the only tool that updates live in *every* running shell: it
  re-reads and re-resolves `~/.config/starship.toml` on each prompt, so a
  pointer flip recolors every open shell on its next prompt. This is why it
  gets a whole-file symlink rather than a `STARSHIP_CONFIG` env var — the env
  var would only ever reach the shell that ran `theme`. Cost: the prompt body
  is rendered into both variant trees, but the source stays single
  (`.chezmoitemplates/starship-achroma.toml`).
- **herdr** (darwin-only) holds its config in the running server, so `theme`
  follows the flip with `herdr server reload-config`.
- **leaf** is the only member whose config names its theme by *path* rather
  than by a registered name, and the only one that also offered an
  env-selected route. `LEAF_THEME` was declined deliberately: it outranks the
  config key but would only ever reach the shell that ran `theme`, and leaf
  gets launched from editors, pipes and fzf previews too. The path is relative
  (`themes/achroma-current.toml`), which leaf resolves from its own config
  directory, so the pointer does the whole job.

  All of leaf's surfaces — content pane, sidebar, status bar — sit on
  **mantle** (`mono02`), not base, because mantle is what ghostty sets the
  terminal background to, so leaf's panes disappear into the terminal instead
  of floating one step above it. jjui and pi already use mantle the same way;
  base (`mono03`) goes unused here. The trade-off is that the sidebar and
  status bar have no fill of their own and are delineated by `toc_border` and
  `status_separator` instead; selection still lifts clear of them, since
  `ink.selectionBg` is three slots up.
- **tuxedo** is the only member selected by theme *name* rather than by
  filename or path: `theme = <name>` in `tuxedo/config.toml` is matched
  against each loaded theme's own `name` field, and an unmatched name falls
  back silently to the first built-in. Both renders therefore carry
  `name = Achroma`, and `themes/achroma-current.toml` — the symlink into
  `current/` — only decides where the theme lands in the `T` picker's sorted
  order.

  It is also the only member whose config file chezmoi refuses to manage.
  tuxedo rewrites `config.toml` itself whenever the theme, density, sort or a
  pane toggle changes, and saved searches live in the same file as
  `filter.<name>` lines, so a managed file would make `chezmoi apply` delete
  real user data. The source is `create_config.toml`: chezmoi writes it once
  when it is missing, seeding `theme = Achroma`, and never touches it again
  (verified — after a rewrite adding `density` and `filter.weekly`,
  `chezmoi status` stays silent and `apply` leaves both keys alone). The
  colors are still fully declarative, since they all live in the pointer's
  target.

The other ten apply on next launch.

For pi and posting the theme file carries an internal `name:` field that the
app registers the theme under, so both variant renders pass
`"name" "achroma-current"` — it has to match the fixed filename, not the
variant. tuxedo's `name` is fixed for the opposite reason: there the name *is*
the selection key and the filename is irrelevant, so the body hardcodes
`Achroma` instead of taking it from the wrapper.

Claude Code pins the same way, but as a precaution rather than a proven
requirement. It selects a theme as `custom:<basename>`, which suggests the
filename is the key and the internal `name` is only a display label — the
pre-pointer setup ran `"theme": "custom:achroma"` against a file whose `name`
was `Achroma`. That is suggestive, not conclusive: a case-insensitive match on
`name` would also explain it, and the loader was not decompiled far enough to
settle it. Pinning `achroma-current` is correct under either reading; the only
cost is the theme picker listing `achroma-current` rather than `Achroma`.

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

Verified 2026-09-12, after `chezmoi apply` landed the symlinks: all nine live
links resolve as intended; `herdr server reload-config` succeeds against the
symlinked `config.toml` (`outcome="ok"`, `changes_ui=true` in
`herdr-server.log`); and herdr's settings UI writes *through* the symlink
rather than replacing it.

Verified 2026-09-14, when leaf joined (leaf-markdown-viewer 1.28.1, before
applying): both renders parse, and their key set is byte-identical to
upstream's `gruvbox.toml` at the same tag — the check that matters, since leaf
ignores unknown keys silently. The whole chain was exercised against a scratch
`XDG_CONFIG_HOME` rather than the live config: relative `theme` path → stable
`themes/achroma-current.toml` → `../../achroma/current/leaf.toml` →
`variants/<live>/leaf.toml`. Flipping only the pointer moved `heading_1` from
`#faf5eb` (dark `acc08`) to `#24211a` (light `acc08`) and back, with the
symlink and its target path unchanged throughout. `chezmoi status` lists the
two variant renders, the symlink and `config.toml`, and does **not** list
`.config/achroma/current`.

Also audited every fg/bg pair leaf renders (55 pairs × 2 variants) for WCAG
contrast. All text pairs clear 3.5:1 and most sit above 4.5:1 in both
variants; the line slots land between 1.6:1 and 2.5:1 by design, tracking
within about 0.1 of each other across variants after the ink grading above.
Every pair meets its floor in both variants — moving all surfaces onto mantle
to match the terminal lifted each foreground onto a slightly further ground
and resolved the one earlier outlier (light table separator, 1.49 → 1.63).

Verified 2026-09-16, when tuxedo joined (tuxedo 2026.8.1, before applying):
both renders carry exactly the 25 required color keys plus `name`, checked
against `COLOR_FIELDS` in upstream's `src/theme.rs` at the installed tag. The
chain was then driven for real in a scratch `XDG_CONFIG_HOME` — tuxedo run
under a pty, keys fed in to open the filter pane, the search overlay, visual
mode and a todo file carrying priorities A–E plus a completed task — and the
emitted SGR sequences decoded back to hex. All 25 slots appear on screen in
both variants with **no color from outside the theme**, which is the check that
matters here: an unparseable theme is skipped silently into the first built-in,
so foreign colors are how a broken render would show. Flipping only the pointer
replaced every on-screen color with the light render's (25/25) and back, with
`themes/achroma-current.toml` and its target path unchanged throughout.

The slot mapping was then rebuilt to follow the neovim theme rather than
tuxedo's own upstream themes, and re-verified the same way (25/25 in both
variants, no foreign colors, no leakage from the other variant). Every value
now cites the neovim group it comes from — body text on the `Normal`/`@markup`
rung, `dim` on `info`, `done` on `@markup.strikethrough`, the priorities on the
`error`/`warn`/`change`/`info`/`hint` severity ramp, search matches as an
inverted gray chip rather than a yellow one, and chroma limited to the four
slots the neovim specs actually use. See
[docs/achroma-design.md](achroma-design.md) for the reasoning; the cost is a
dimmer theme than the first pass, and the floors moved with it.

Contrast audited per background a task row can sit on (list, status bar, cursor
row, selection). Text pairs run 2.48–10.80:1 dark and 3.38–6.24:1 light. The
low end is neovim's own level, not a regression: `fg` on the selection fill is
3.06:1 in dark, which is exactly what `Visual` (`mono16` on `mono07`) measures
in the editor, and `dim`/`pri_d` at 2.48:1 sit where `info` does. `done`
(1.65–2.47:1) and `pri_other` (1.86–3.22:1) are deliberately faded, tracking
`@markup.strikethrough` and `hint`. Surfaces track across variants in ΔL\*, the
metric wezterm's `config/theme.lua` uses for this: status bar 2.5 → 3.5, cursor
row 8.3 → 8.1, selection 13.4 → 12.3, i.e. the cursor row lands on the same
raised-plate parity wezterm established for its active tab.

Still pending: visual confirmation of leaf's TUI chrome (the `[ui]` half —
sidebar, status bar and the search-match background are not reachable from
`--inline`, which renders only the `[markdown]` half); visual confirmation inside zellij, jjui, herdr and antinote;
the `osascript` appearance flip (sending Apple events to System Events needs
Automation permission, which a non-interactive process does not have
(`-1743`), so run `theme light` from a real terminal once); whether
`reload-config` picks up a *changed* pointer target — every observed reload so
far ran with the pointer standing still, so use the isolated test below; and
the whole Windows path (`set-achroma-current.ps1` and the
`run_after_06-seed-achroma-current.ps1` seeder are unrun and un-syntax-checked —
no pwsh on the current machine).

### Isolated herdr reload test

Do not verify this with `theme light`. herdr's `[theme] name = "terminal"`
makes pane *content* inherit the host terminal's ANSI colors, and ghostty
switches those on its own, so the panes recolor even if herdr never reloaded.
The only proof is the **chrome** (sidebar, tab bar, panel surfaces) driven by
`[theme.custom]`, where `surface0` runs `#2a2a2a` dark → `#eaeaea` light.

Move the pointer without touching the OS appearance, so the terminal stays
dark and any chrome change can only have come from the reload:

```bash
readlink ~/.config/achroma/current                       # variants/dark
ln -sfn variants/light ~/.config/achroma/current
herdr server reload-config
# PASS: chrome goes near-white while pane content stays dark
ln -sfn variants/dark ~/.config/achroma/current && herdr server reload-config
```

If the chrome does not move, check whether herdr can read the light render at
all — `HERDR_CONFIG_PATH=~/.config/achroma/variants/light/herdr.toml herdr
--no-session`. If that works, the reload is not re-resolving the symlink, and
herdr goes back to the copy approach as a single exception.

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
- **pi, posting and Claude Code theme files carry an internal `name:`** that
  must match the filename they are read under, so both variants pass
  `achroma-current`. Proven for pi and posting; precautionary for Claude Code,
  which is selected by basename (`custom:achroma-current`).
- **Windows symlinks** need `SeCreateSymbolicLinkPrivilege` or Developer Mode,
  both set up by `init/win.ps1`. nushell has no `ln` builtin, so the pointer
  swap goes through `pwsh/scripts/set-achroma-current.ps1`, which falls back
  to a directory junction (no elevation needed, absolute target required).
- **The bootstrap seeder must be create-if-missing.** `.chezmoiscripts/*/
  run_after_06-seed-achroma-current.*` guards on `[ -e ] || [ -L ]` and exits; if
  it ever re-pointed the pointer, `chezmoi apply` in light mode would reset
  everything to dark again.
- **leaf silently ignores unknown theme keys.** A misspelled key is not an
  error and not a warning — it just falls back to `base`, so a typo shows up
  only as one stubbornly wrong-colored element. An invalid `base` *does* error
  (`Unknown base theme "…"`), so parse success proves nothing about the color
  keys. The check that actually catches typos is diffing the rendered key set
  against upstream's reference theme, which lists every supported key:
  `curl -fsSL https://raw.githubusercontent.com/RivoLink/leaf/<version>/gruvbox.toml`.
  There are 81 color keys (34 `[ui]`, 47 `[markdown]`) plus `base` and
  `syntax`; the body sets all of them.
- **leaf ships only four syntect themes** for fenced code blocks —
  `base16-ocean.dark`, `base16-ocean.light`, `InspiredGitHub` and
  `Solarized (dark)`. Code-block colors do NOT come from the achroma palette,
  so that is as close as the light/dark pair gets. Of the four `base` presets
  (`arctic`, `forest`, `ocean`, `solarized-dark`) only `arctic` is light.
- **`leaf --config reset` / `remove`** rewrites or deletes
  `~/.config/leaf/config.toml`, which would drop the `theme` key that names the
  pointer. Same class as the herdr/carapace caveat: `chezmoi status` surfaces
  it and `chezmoi apply` reverts it.
- **tuxedo's theme file only looks like TOML.** It is parsed line by line as
  `key = value` (bare or quoted), `#` starts a comment only at the start of a
  line, and unknown keys are ignored — but all 25 color keys are *required*,
  so a missing or unparseable one skips the whole theme with a warning on the
  first frame. That makes typos loud, unlike leaf. The silent failure is one
  level up: `theme = <name>` in `config.toml` that matches nothing falls back
  to the first built-in without a word, so renaming `name` in the body is a
  quiet regression. The proof that the theme is actually live is that no
  on-screen color comes from outside it.
- **tuxedo's `matched` is a background whose text color is `bg`.** tuxedo
  accepts `reset` / `transparent` for `bg`, `panel` and `statusbar` to inherit
  the terminal's own background, but taking it for `bg` would paint
  default-colored text on the search-match chip. `bg` stays an explicit
  `mono02`, which is the terminal background anyway. Its `selection` key is
  required but never read by the UI (2026.8.1); upstream's themes set it to
  `selected`, so the body does too.
- After changing bat themes, run `bat cache --build`.
- **Before overwriting an applied GUI config, diff it** — the on-disk file
  may be ahead of chezmoi source (zebar's dual-variant design existed only
  on disk until it was captured).
