# Cornix productivity layout

Vial layout for the 48-key Cornix LP with two encoders, adapted from
`~/.config/karabiner/source/karabiner.yml`.

Import `cornix-productivity.vil` with **File → Load saved layout** in the Vial
app. It targets the vendor's RMK/Vial firmware V1.12. Back up the current Vial
layout before importing.

Legend: `tap / hold`; `▽` means transparent (the key falls through to the base
layer).

## Layer 0 — Base

```text
Tab/Num  Q    W    E    R    T       Y    U    I    O    P   \/Ctrl
Esc/Nav  A    S    D    F    G       H    J    K    L   ;/⇧  '/⌥
Shift    Z    X    C    V    B       N    M    ,    .    /   PgUp
Globe* Ctrl Opt  Cmd Space/Sym Enter   Num(toggle) Space/Sym Cmd Opt Cmd PgDn
                    [sleep]          [mute]
```

The outer `Tab` and `Esc` keys retain the laptop layout's dual roles. The
right number-layer thumb toggles layer 3, while holding the outer `Tab` key
accesses that layer momentarily. The symbol layer remains available by holding
either Space key.

- left encoder: display brightness down/up; press: sleep
- right encoder: volume down/up; press: mute
- `Globe*` emits `KC_CAPS`; configure macOS to remap Caps Lock to Globe for
  this keyboard as described below
- `\\`: tap backslash, hold right Control
- `;`: tap semicolon, hold right Shift
- `'`: tap quote, hold left Option
- the base layer currently has no dedicated Backspace key

## Layer 1 — Nav/Vim (`Esc` hold)

```text
Home  H    J    K    L   End       #    *    (    )    ▽    ▽
 ▽   Left Down  Up Right Enter     ^    $    {    }    ▽    ▽
 ▽    Y    U    I    O    P        %    @    &    ▽    ▽    ▽
 ▽    ▽    ▽    ▽   Bksp  ▽        ▽   Bksp  ▽    ▽    ▽    ▽
```

This preserves the merged Caps layer: arrows and Vim letters on the left,
Vim motion symbols on the right, and backspace under either Space thumb.

## Layer 2 — Symbols/functions (`Space` hold)

```text
 `    -    =    [    ]    \       F6   F7   F8   F9  F10   ▽
 ▽    ;    '    ,    .    /       F11  F12   ▽    ▽    ▽    ▽
 ▽    F1   F2   F3   F4   F5       ▽    ▽    ▽    ▽    ▽    ▽
 ▽    ▽    ▽    ▽    ▽    ▽        ▽    ▽    ▽    ▽    ▽    ▽
```

## Layer 3 — Numbers/mouse (`Tab` hold or right thumb toggle)

```text
 ▽    ▽    1    2    3    4       WhDn Btn1 MsUp Btn2  ▽    ▽
 ▽    ▽    5    6    7    8       WhUp MsLt MsDn MsRt  ▽    ▽
 ▽    ▽    9    0    -    =        ▽   Acc0 Acc1 Acc2  ▽    ▽
 ▽    ▽    ▽    ▽   Bksp  ▽        ▽   Bksp  ▽    ▽    ▽    ▽
```

`Acc0`, `Acc1`, and `Acc2` select mouse-key acceleration levels.

## Known issue — layered Backspace

Backspace is currently available only in the Space-thumb positions on layers
1 and 3. When entering either layer with the `Esc`/navigation or `Tab`/number
layer-tap key and then pressing Backspace repeatedly, the first press can emit
Space instead. A dedicated and reliable base-layer Backspace position is still
to be chosen.

## macOS Globe setup

The vendor RMK/Vial firmware cannot directly emit Apple's Globe usage. The
outer-left key therefore emits `KC_CAPS` as a per-device remapping proxy:

1. Connect the Cornix and open **System Settings → Keyboard → Keyboard
   Shortcuts → Modifier Keys**.
2. Select the Cornix in the keyboard dropdown.
3. Set **Caps Lock key** to **Globe**.
4. In Karabiner-Elements, disable event modification for the Cornix so the
   global Caps Lock dual-role rule does not consume this key.

This differs from the patched-QMK `QK_APPLE_FN` approach: the Cornix vendor
firmware does not expose that keycode, and placing raw Consumer usage `0x029D`
in a Vial keymap does not emit a Consumer report.

## Compatibility notes

- The file uses the Cornix V1.12 8×7 matrix and embedded Vial keyboard UID.
- The Vial desktop export contains all 10 firmware layers. Layers 0–3 are the
  user-facing layout documented above; layers 4–9 preserve firmware mappings
  but are not activated by this layout.
- Macros, combos, tap dances, and overrides remain unconfigured.
- Loading the layout replaces those programmable sections and firmware
  settings. Export a backup first if the keyboard already has any configured.
- Firmware updates can erase mappings; re-import this file afterward.
