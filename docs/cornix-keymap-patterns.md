# Cornix and compact split keymap patterns

Research date: 2026-08-23

## Scope

Public layouts for the exact 48-key PandaKB/RMK Cornix are scarce. The strongest
exact-family references are the Cornix ZMK project’s stock and advanced keymaps;
for broader compact-split practice, Miryoku is a widely adopted reference design.
The recommendations below preserve this repository’s QWERTY/Karabiner behavior
rather than proposing a wholesale layout replacement.

Current managed artifacts:

- `home/dot_local/etc/keyboard/vial/cornix-productivity.vil`
- `home/dot_local/etc/keyboard/vial/cornix-productivity.md`

## Patterns found

### 1. Stock Cornix: dedicated editing keys and simple Lower/Raise thumbs

The Cornix ZMK board default keeps `Backspace` on the base layer’s upper-right
outer key and `Escape` on the lower-right outer key. Its primary thumb roles are
`GUI`, Lower, and Space on the left and Enter, Raise, and Alt on the right.
Lower combines digits and arrows; Raise contains symbols. Space and Enter remain
available on those layers.[^cornix-board-default]

This pattern prioritizes reliability and discoverability:

- Backspace and Enter do not depend on tap-hold timing.
- Layers are momentary rather than sticky.
- Important thumb tap functions are duplicated on layers.
- Navigation and numbers can coexist when the board has enough keys.

### 2. Advanced Cornix community map: opposite-hand layers by purpose

The Cornix project’s more developed example uses thumb layer-taps, home-row
mods, combos for Escape/Tab/Enter, and dedicated Symbol, Navigation/Mouse,
Numpad, Adjust, and Debug layers. It uses a 250 ms hold-tap term and positional
hold triggers. Its Navigation layer places mouse movement on one hand and
cursor movement on the other, while its Numpad uses a conventional 3×3
arrangement.[^cornix-advanced]

Useful patterns independent of home-row mods are:

- A layer has one coherent purpose per hand.
- Cursor and mouse movement use matching spatial arrangements.
- A system/Adjust layer is reached indirectly rather than consuming a prime
  base-layer key.
- Bluetooth, bootloader, and hardware controls are isolated from typing keys.
- Page movement belongs with navigation, not on the base layer.

The home-row modifiers and combos are not an obvious fit here because the
current layout deliberately preserves MacBook/Karabiner muscle memory.

### 3. Miryoku: thumb editing keys and opposite-hand layer operation

Miryoku’s base thumb taps are Space, Tab, and Escape on the left and Backspace,
Enter, and Delete on the right. Thumb holds activate purpose-specific layers,
and each layer is designed primarily for the opposite hand. Its documented
principles are “use layers instead of reaching,” “use both hands instead of
contortions,” and “make full use of the thumbs.”[^miryoku]

Miryoku also provides several directly relevant consistency rules:

- Navigation and mouse layers mirror movement positions.
- Mouse buttons live on thumbs, allowing movement and drag at the same time.
- Function keys mirror number positions.
- Base thumb functions are duplicated on layers where repeat is important.
- System/Bluetooth controls are grouped on a low-frequency media/system layer.

A full Miryoku conversion would conflict with the current one-handed Karabiner
layers, but these consistency rules transfer well.

### 4. Tap-hold policy must match layer handedness

QMK’s Chordal Hold defaults to settling same-hand chords as taps before the
tapping term, while opposite-hand chords remain eligible for Permissive Hold or
Hold On Other Key Press. Hold On Other Key Press settles an eligible layer-tap
as held as soon as the next key is pressed.[^qmk-tap-hold]

This matters because the current map mixes both models:

- `Tab/Num` activates numbers on the **same** left hand.
- The right layer-3 thumb activates numbers on the **opposite** left hand.
- Either Space thumb is expected to reach both halves of Symbols/Functions.

Chordal Hold should therefore be retained only if quick same-hand tests still
produce the intended layer keys. Otherwise it undermines the map’s explicit
one-handed behavior.

## Fit analysis for the current layout

### Preserve

- QWERTY base and Karabiner-derived `Esc/Nav`, `Tab/Num`, and `Space/Sym` roles.
- Vim-style navigation and symbols.
- Left-hand number strip, because one-handed numbers are an explicit goal.
- Layer 3’s split purpose: numbers on the left and mouse on the right.
- Encoders for brightness and volume.
- Hold On Other Key Press, which fixed the observed layered-Backspace race.

### Highest-value adaptations

#### A. Restore direct Backspace and Enter

This is the strongest shared pattern across stock Cornix and Miryoku.

Recommended incremental mapping:

- Replace base `PgUp` with `Backspace`.
- Put `PgUp` and `PgDn` on the navigation layer near Home/End.
- Restore Enter on a thumb. Two viable variants are:
  1. `LT4(Enter)` in the current `MO(4)` position, retaining tap Enter and hold
     system-layer access.
  2. `LT3(Enter)` in the current right `TG(3)` position, following Miryoku’s
     right-thumb Enter/Num pattern; move system access elsewhere.

Variant 1 changes less. Variant 2 creates a cleaner opposite-hand number layer
but removes the convenient sticky mouse layer unless a separate layer-lock key
is added.

#### B. Reclaim the duplicate left Control

The outer of the two former `KC_LCTRL` keys now emits `KC_CAPS` as a macOS
per-device Globe-remapping proxy; the adjacent key remains left Control. This
removes the duplicate without requiring unsupported native Globe handling in
the vendor RMK/Vial firmware.

#### C. Make navigation absorb page/edit operations

Move Page Up/Down from base to layer 1 and consider adding Delete plus Mac
Undo/Cut/Copy/Paste shortcuts in currently transparent positions. Both the
advanced Cornix map and Miryoku treat page movement and editing as navigation
concerns.[^cornix-advanced][^miryoku]

Keep the existing arrows and Vim characters; this is an extension rather than
a redesign.

#### D. Put mouse buttons on layer-3 thumbs

Current mouse movement and buttons occupy the same right-hand finger area,
which makes click-drag awkward. Put Button 1/2/3 on otherwise unused layer-3
thumb positions while retaining right-hand movement and wheel keys. This
follows Miryoku’s ability to move with fingers and click with thumbs.[^miryoku]

#### E. Prefer momentary access; add locking only where sustained use needs it

Momentary Lower/Raise access is the stock Cornix pattern. A persistent layer is
useful for mouse work, but sticky number state creates mode errors. If firmware
support allows it, keep ordinary number access momentary and provide a
separate, deliberate layer lock for sustained mouse sessions.

#### F. Test Chordal Hold against actual design goals

With the tapping term at 250 ms and Hold On Other Key Press enabled, test rapid
same-hand layer chords. Disable Chordal Hold if `Esc/Nav` + left navigation,
`Tab/Num` + left numbers, or same-side Space/Symbol chords emit their base tap
instead. Chordal Hold is valuable for home-row mods but is not inherently an
optimization for this map.[^qmk-tap-hold]

## Suggested target pattern

The best fit is a **Karabiner/Miryoku hybrid**, not a full Miryoku conversion:

1. Keep the current alphas and three familiar layer-tap concepts.
2. Give Backspace and Enter reliable base taps.
3. Put navigation/editing on layer 1.
4. Keep symbols/functions on layer 2, optionally making F-key positions mirror
   number positions later.
5. Keep numbers/mouse on layer 3, but move mouse buttons to thumbs.
6. Keep Bluetooth/output controls isolated on layer 4.
7. Use Hold On Other Key Press; retain Chordal Hold only if hardware tests show
   it does not block intentional same-hand chords.

This gains the most common compact-split ergonomics without discarding the
existing MacBook muscle memory or the tested one-handed workflows.

## Sources

[^cornix-board-default]: Cornix ZMK board default keymap, [`boards/jzf/cornix/cornix.keymap`](https://github.com/hitsmaxft/zmk-keyboard-cornix/blob/main/boards/jzf/cornix/cornix.keymap).
[^cornix-advanced]: Cornix ZMK advanced example, [`config/cornix.keymap`](https://github.com/hitsmaxft/zmk-keyboard-cornix/blob/main/config/cornix.keymap).
[^miryoku]: Manna Harbour, [Miryoku Reference Manual](https://github.com/manna-harbour/miryoku/tree/master/docs/reference).
[^qmk-tap-hold]: QMK Firmware, [Tap-Hold Configuration Options](https://docs.qmk.fm/tap_hold).
