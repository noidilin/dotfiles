# Karabiner-Elements Configuration

## Architecture

### Requirements

- **macOS** (Karabiner-Elements is macOS-only)
- **yq**: `brew install yq`
- **Karabiner-Elements**: `brew install --cask karabiner-elements`

### File Structure

```txt
source/
├── karabiner.yml         # Complete configuration (metadata, parameters, rules)
└── Makefile              # Build script (YAML → JSON conversion)
```

The single `karabiner.yml` file is organized into sections using comments:

- **Metadata**: Title, version, author, description
- **Timing Parameters**: Reusable YAML anchors for timing values (`x-parameters`)
- **Rules**: All key mapping rules organized by layer:
  - Basic Key Modifications (CapsLock, `;`, `[`, `.`, Tab)
  - Caps Layer (navigation, Vim motions, symbols)
  - Space Layer (one-handed input, symbols, function keys)
  - Tab Layer (one-handed numbers)

### Automatic Updates (via Chezmoi)

When managed by chezmoi, configuration automatically recompiles when any source YAML changes:

```bash
chezmoi apply  # Triggers run_onchange script
```

The script at `~/.chezmoiscripts/darwin/run_onchange_after_30-karabiner-config.sh.tmpl` handles automatic compilation.

---

## Usage

### Compile Configuration

```bash
cd ~/.config/karabiner/source
make compile
```

This converts `karabiner.yml` to JSON and generates `~/.config/karabiner/assets/complex_modifications/karabiner.json`.

### Install to Karabiner-Elements

```bash
make install
```

This compiles the configuration (same as `make compile` since output goes directly to the final location).

### Enable Rules

1. Open **Karabiner-Elements** app
2. Go to **Complex Modifications** tab
3. Click **Add rule**
4. Select **Productivity Keymap**
5. Enable the rules you want (or click **Enable All**)

---

## Customization

### Adjust Timing Parameters

Edit `karabiner.yml` and find the `x-parameters` section:

- Increase `to_if_alone_timeout` for slower typing
- Decrease `to_if_held_down_threshold` for faster activation
- Recompile: `make install`

```yaml
x-parameters:
  hyper-timing: &hyper-timing
    basic.to_if_alone_timeout_milliseconds: 200       # Tap timeout
    basic.to_if_held_down_threshold_milliseconds: 150 # Hold threshold
```

### Add New Mappings

1. Edit `karabiner.yml` and find the appropriate section:
   - **Basic Key Modifications** - Base key modifications
   - **Caps Layer** sections - Caps layer mappings
   - **Space Layer** sections - Space layer mappings
   - **Tab Layer** sections - Tab layer mappings

2. Follow existing pattern:

   ```yaml
   - description: 'caps + x = something'
     type: basic
     from:
       key_code: x
       modifiers:
         optional: [any]
     to:
       - key_code: something
     conditions:
       - type: variable_if
         name: caps_layer
         value: 1
   ```

3. Recompile: `make install`

### Add New Layers

Add new rule sections in `karabiner.yml` using the placeholder templates at the bottom of the file:

```yaml
# ----------------------------------------------------------------------------
# CUSTOM LAYER - [NAME]
# ----------------------------------------------------------------------------
# Description of what this layer provides

  - description: Custom Layer - [Category]
    manipulators:
      # Add your custom mappings here
```

Uncomment and customize these templates when adding new functionality.

---

## Troubleshooting

### Layer Notes

- The old semicolon layer has been merged into the Caps Lock hold layer.
- `caps_lock` now exposes both the original left-hand caps mappings and the old right-hand semicolon mappings.
- `;` is now a plain dual-role control key.
- `[` is now the dual-role option key.
- `.` is back to a plain period key.

---

## Key Mappings

- **Caps Lock**:
  - tap -> escape
  - hold -> merged caps layer
- **; key**:
  - tap -> ;
  - hold -> control modifier
- **[ key**:
  - tap -> [
  - hold -> left option modifier
- **. key**:
  - tap -> .
  - hold -> no special behavior

### Caps Layer

**Modifier Pass-Through:** Caps layer mappings support additional modifiers (Option, Command, Shift). When you press extra modifiers along with caps combinations, they are passed through to the output. For example:

- `option + caps + q` → `option + h`
- `shift + caps + e` → `shift + k`
- `command + caps + a` → `command + left arrow`

#### Left Hand

- Top Row:
  - Tab -> Home
  - Q -> H
  - W -> J
  - E -> K
  - R -> L
  - T -> End
- Mid Row:
  - A -> Left
  - S -> Down
  - D -> Up
  - F -> Right
  - G -> Return
- Bot Row:
  - Z -> Y
  - X -> U
  - C -> I
  - V -> O
  - B -> P
- Special:
  - Space -> backspace

#### Right Hand

- Top Row:
  - Y -> #
  - U -> *
  - I -> (
  - O -> )
- Mid Row:
  - H -> ^
  - J -> $
  - K -> {
  - L -> }
- Bot Row:
  - N -> %
  - M -> @
  - , -> &

### Space Layer - (symbols and functions)

#### Left Hand

- Top Row:
  - Tab -> `
  - Q -> -
  - W -> =
  - E -> [
  - R -> ]
  - T -> \
- Mid Row:
  - A -> ;
  - S -> '
  - D -> ,
  - F -> .
  - G -> /
- Bot Row:
  - Z -> F1
  - X -> F2
  - C -> F3
  - V -> F4

#### Right Hand

- Top Row:
  - U -> F5
  - I -> F6
  - O -> F7
  - P -> F8
- Mid Row:
  - J -> F9
  - K -> F10
  - L -> F11
  - ; -> F12

### Tab Layer - numbers (not numpads)

- Top Row:
  - W -> 1
  - E -> 2
  - R -> 3
  - T -> 4
- Mid Row:
  - S -> 5
  - D -> 6
  - F -> 7
  - G -> 8
- Bot Row:
  - X -> 9
  - C -> 0
  - V -> -
  - B -> =
- Special
  - space -> backspace

---

## Reference

- [Karabiner-Elements Documentation](https://karabiner-elements.pqrs.org/docs/)
- [Complex Modifications Reference](https://karabiner-elements.pqrs.org/docs/json/complex-modifications-manipulator-definition/)
- [Capslock Enhancement (inspiration)](https://github.com/Vonng/Capslock)

```txt
- `a - jump to position of mark 'a'
- `0 - go to where vim was previously exited
- `" - go to last editing in this file

- `` - go to last jump
- ctrl + o - go to prev jump location
- ctrl + i - go to next jump location

- `. - go to last change in this file
- g; - go to prev change location
- g, - go to next change location
```

### Original Keybinds in MacOS (not related to karabiner)

- navigation:
  - ctrl + L: scroll to center the cursor
  - ctrl + B: move a char backward
  - ctrl + F: move a char forward
  - ctrl + P: move a line up
  - ctrl + N: move a line down
  - ctrl + A: move to beginning of paragraph (option + up)
  - ctrl + E: move to end of paragraph (option + down)
  - option + left: move a word backward
  - option + right: move a word forward
  - option + up: move to beginning of paragraph
  - option + down: move to end of paragraph
  - command + left: move to beginning of line
  - command + right: move a end of line
  - command + up: move to beginning of document
  - command + down: move to end of document

- editing:
  - ctrl + O: insert a new line
  - ctrl + T: swap the characters around the cursor
  - ctrl + H: delete a char ahead
  - ctrl + D: delete a char after
  - option + backspace: delete a word ahead
  - command + backspace: delete to beginning of line
  - ctrl + K: cut highlighted text
  - ctrl + Y: paste previously cut text
