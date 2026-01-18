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
  - Basic Key Modifications (CapsLock, Tab, Semicolon)
  - Hyper Layer (navigation, Vim motions, jumps)
  - Space Layer (one-handed input, numbers, symbols)

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
   - **Hyper Layer** sections - Hyper layer mappings
   - **Space Layer** sections - Space layer mappings
   - **Tab Layer** sections - Tab layer mappings

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

### Special Key Combination Conflicts

**Problem:** When combining two special modifier keys (like `;+h` or `space+;`), the expected layer mapping doesn't trigger.

**Root Cause:**

Karabiner-Elements processes rules **sequentially from top to bottom**. When a key has multiple rule definitions, the first matching rule wins and prevents subsequent rules from being evaluated.

#### Example: Semicolon + H (`;+h`) fails to output `^`

1. **Rule Processing Order:**
   - Rule A (line ~86): Semicolon modifier - `tap→;, hold→Hyper` with `optional: [any]` modifiers
   - Rule B (line ~100): H key modifier - `tap→h, hold→Ctrl` with `optional: [any]` modifiers  
   - Rule C (line ~360): Hyper + H → `^` (requires Hyper modifiers)

2. **What Happens:**
   - You hold `;` → Semicolon rule outputs Hyper modifiers (right_shift + right_command + right_control + right_option)
   - You press `h` while holding `;`
   - **Rule B matches first** because it appears before Rule C and accepts `[any]` optional modifiers
   - The H modifier rule intercepts the keypress, preventing Hyper+H rule from triggering

3. **Why CapsLock + Tab works:**
   - Tab is no longer a modifier key (removed from Basic Key Modifications)
   - No conflicting rule exists for Tab
   - Hyper + Tab rule matches successfully ✓

#### Solutions

**Solution 1: Explicit Exclusions (Recommended - Currently Implemented)**

Modify the `from.modifiers` of conflicting modifier keys to exclude specific modifiers, combined with variable conditions:

```yaml
# H key modifier - only match when Hyper modifiers are NOT present
- description: "h = h(tap) | ctrl(hold)"
  type: basic
  from:
    key_code: h
    modifiers:
      # Explicitly list allowed modifiers (excludes all Hyper modifiers)
      optional: [caps_lock, shift, command, control, option, fn]
  to:
    - key_code: left_control
  to_if_alone:
    - key_code: h
  parameters:
    <<: *hyper-timing

# Semicolon modifier - exclude when Space layer is active  
- description: "semicolon = ;(tap) | hyper(hold)"
  type: basic
  from:
    key_code: semicolon
    modifiers:
      optional: [any]
  to:
    - key_code: right_shift
      modifiers: [right_command, right_control, right_option]
  to_if_alone:
    - key_code: semicolon
  conditions:
    # Don't activate when space layer is active
    - type: variable_unless
      name: space_layer
      value: 1
  parameters:
    <<: *hyper-timing
```

**How it works:**
- For H key: By listing specific modifiers in `optional` (instead of `any`), we exclude the right-side Hyper modifiers, allowing the Hyper+H rule to match when Semicolon is held
- For Semicolon: Using `variable_unless` condition prevents the modifier from activating when Space layer is active

**Pros:**
- Surgical fix targeting specific conflicts
- Preserves all existing functionality
- Clean and maintainable

**Cons:**
- Requires understanding of modifier precedence
- Must be careful with `optional` modifier lists

**Solution 2: Rule Reordering**

Move all layer mapping rules to appear **before** Basic Key Modifications section in the file.

**Pros:**
- Simple structural change
- Layer mappings get priority over modifier keys

**Cons:**
- May create unexpected edge cases
- Against typical Karabiner configuration conventions
- Could affect other key combinations
- Would require extensive testing

**Implementation:** The current configuration uses Solution 1 (Explicit Exclusions).

---

## Key Mappings

- **Caps Lock**:
  - tap -> escape
  - hold -> hyper modifier
- **; key**:
  - tap -> ;
  - hold -> hyper modifier
- **h key**:
  - tap -> h
  - hold -> left ctrl modifier

### Hyper Layer

**Modifier Pass-Through:** All hyper layer mappings support additional modifiers (Option, Command, Shift). When you press extra modifiers along with hyper combinations, they are passed through to the output. For example:

- `option + hyper + q` → `option + left arrow` (word navigation)
- `shift + hyper + e` → `shift + up arrow` (text selection)
- `command + hyper + a` → `command + command + left` (still works, though redundant)

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
  - Space -> Delete

#### Right Hand

- Top Row:
  - Y -> # (prev match word)
  - U -> * (next match word)
  - I -> %
  - O -> @
- Mid Row:
  - H -> ^ (start char in line)
  - J -> $ (end char in line)
  - K -> { (prev paragraph)
  - L -> } (next paragraph)
- Bot Row:
  - N -> ~ (match char)
  - M -> ! (jump to mark)

### Space Layer - (symbols and functions)

#### Left Hand

- Top Row:
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
  - Q -> 1
  - W -> 2
  - E -> 3
  - R -> 0
- Mid Row:
  - A -> 4
  - S -> 5
  - D -> 6
  - F -> .
- Bot Row:
  - Z -> 7
  - X -> 8
  - C -> 9

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
