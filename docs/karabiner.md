# Karabiner-Elements Configuration

## Architecture

### Requirements

- **macOS** (Karabiner-Elements is macOS-only)
- **yq**: `brew install yq`
- **Karabiner-Elements**: `brew install --cask karabiner-elements`

### File Structure

```txt
source/
├── main.yml              # Metadata (title, version, author)
├── config/
│   ├── parameters.yml    # Timing parameters (YAML anchors)
│   ├── basic.yml         # CapsLock/Tab/Semicolon base modifiers
│   ├── hyper.yml         # Hyper layer (navigation, vim motions)
│   └── space.yml         # Space layer (one-handed input)
├── Makefile              # Build script (merge YAML → JSON)
└── README.md             # This file
```

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

This merges all YAML files and generates `../assets/complex_modifications/karabiner.json`.

### Install to Karabiner-Elements

```bash
make install
```

This compiles and copies the JSON to Karabiner's configuration directory.

### Enable Rules

1. Open **Karabiner-Elements** app
2. Go to **Complex Modifications** tab
3. Click **Add rule**
4. Select **Productivity Keymap**
5. Enable the rules you want (or click **Enable All**)

---

## Customization

### Adjust Timing Parameters

Edit `config/parameters.yml`:

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

1. Edit the appropriate config file:
   - `config/basic.yml` - Base key modifications
   - `config/hyper.yml` - Hyper layer mappings
   - `config/space.yml` - Space layer mappings

2. Follow existing pattern:

   ```yaml
   - description: 'hyper + x = something'
     type: basic
     from:
       key_code: x
       modifiers:
         mandatory: [right_command, right_control, right_shift, right_option]
     to:
       - key_code: something
   ```

3. Recompile: `make install`

### Split Large Rules

Add new files in `config/` directory, then update `Makefile`:

```makefile
YAML_SOURCES = main.yml config/parameters.yml config/basic.yml config/hyper.yml config/space.yml config/your_new_file.yml
```

---

## Key Mappings

- **Caps Lock**:
  - tap -> escape
  - hold -> left control
- **Tab**:
  - tap -> tab
  - hold -> hyper modifier
- **; key**:
  - tap -> ;
  - hold -> hyper modifier

### Hyper Layer

#### Functionality

- **Space** -> Delete
- **G** -> Return

#### Navigation

- **Top Row:** Extended Navigation
  - **Q** -> Page Up
  - **W** -> Page Down
  - **E** -> Home
  - **R** -> End
- **Mid Row:** Basic Navigation
  - **A** -> Left
  - **S** -> Down
  - **D** -> Up
  - **F** -> Right
- **Bot Row:**
  - **Z** ->  (haven't think of good use case)
  - **X** ->  (haven't think of good use case)
  - **C** ->  (haven't think of good use case)
  - **V** ->  (haven't think of good use case)

#### Vim navigation (char)

- **Top Row:**
  - **Y** -> # (prev match word)
  - **U** -> * (next match word)
  - **I** -> , (prev match char)
  - **O** -> ; (next match char)
- **Mid Row:**
  - **H** -> ^ (start char in line)
  - **J** -> $ (end char in line)
  - **K** -> { (prev paragraph)
  - **L** -> } (next paragraph)
- **Bot Row:**
  - **N** -> % (match char)
  - **M** -> ` (jump to mark)
  - **,** ->  (haven't think of good use case)
  - **.** ->  (haven't think of good use case)

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

#### Space Layer - (left hand keyboard + mouse)

- **Num Row**:
  - **`** -> 0
  - **1** -> .
  - **2** -> 6
  - **3** -> 7
  - **4** -> 8
  - **5** -> 9
- **Top Row**:
  - **Q** -> -
  - **W** -> =
  - **E** -> [
  - **R** -> ]
  - **T** -> \
- **Mid Row**:
  - **A** -> H
  - **S** -> J
  - **D** -> K
  - **F** -> L
  - **G** -> Return
- **Bot Row**:
  - **Z** -> ;
  - **X** -> '
  - **C** -> ,
  - **V** -> .
  - **B** -> /

---

## Reference

- [Karabiner-Elements Documentation](https://karabiner-elements.pqrs.org/docs/)
- [Complex Modifications Reference](https://karabiner-elements.pqrs.org/docs/json/complex-modifications-manipulator-definition/)
- [Capslock Enhancement (inspiration)](https://github.com/Vonng/Capslock)

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
