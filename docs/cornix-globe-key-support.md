# Cornix, Vial, and macOS Globe-key support

Research date: 2026-08-23

## Conclusion

Vial does **not** currently expose a native, assignable Globe key. Upstream QMK,
Vial's QMK fork, and RMK understand the relevant HID Consumer usage internally,
but that is not the same as having a `KC_GLOBE` keycode that Vial can store in a
keymap.

For the Cornix vendor RMK/Vial firmware, `cornix-productivity.vil` therefore
cannot safely be changed to `KC_GLOBE`. The practical no-firmware solution is
still to make the key emit `KC_CAPS` and use macOS's per-keyboard Modifier Keys
setting to translate Caps Lock to Globe. A direct hardware Globe key requires
custom firmware support, potentially exposed through a firmware-defined
`USER00`-style keycode.

## Findings

### QMK supports the HID usage, not an assignable `KC_GLOBE`

QMK merged “AC Next Keyboard Layout Select” in October 2023 and documented it in
the 2023-11-26 changelog as the macOS Globe key.[^qmk-pr][^qmk-changelog]
Current QMK defines `AC_NEXT_KEYBOARD_LAYOUT_SELECT = 0x29D` in its Consumer-page
usage enum.[^qmk-report]

This constant is a raw Consumer usage for firmware code such as
`host_consumer_send()`. Current upstream QMK does not define `KC_GLOBE`,
`QK_APPLE_FN`, or another ordinary keymap keycode for it. Consequently it is not
directly selectable in configurators using QMK's 16-bit keycode space.

### Vial has inherited the QMK constant but does not expose it

Current `vial-qmk` contains the same
`AC_NEXT_KEYBOARD_LAYOUT_SELECT = 0x29D` enum entry inherited from QMK.[^vial-qmk-report]
However, current Vial GUI's media-key list has no Globe entry, and its source has
no `KC_GLOBE`, `APPLE_FN`, or `0x029D` mapping.[^vial-gui-keycodes]

Vial's latest published desktop release is v0.7.5 (2025-08-02). Current GUI main
also lacks the key, so this is not merely an old installed-app issue.[^vial-release]
Vial's **Any** dialog accepts arbitrary 16-bit dynamic-keymap values, so it may
accept the expression `0x029D`; that does not make it Globe. The dialog writes
`0x029D` into the firmware's QMK-compatible keycode field, while `0x029D` is the
value needed inside a separate USB Consumer report. No Vial keycode currently
bridges those two namespaces. On firmware where that 16-bit keycode is
unassigned, the result is normally no action; another firmware could interpret
it differently.

### RMK can represent the Consumer usage internally

RMK v0.8.2 defines
`ConsumerKey::NextKeyboardLayoutSelect = 0x29D`.[^rmk-082-keycodes] Current RMK
main retains `NextKeyboardLayoutSelect` in its Consumer-key model.[^rmk-main-consumer]
This means custom RMK code can emit the usage.

Neither RMK v0.8.2's ordinary `KeyCode` enum nor its aliases provide a Globe
keycode, though, and current RMK does not convert `NextKeyboardLayoutSelect` to
one of the Vial-compatible HID keycodes. Vial therefore cannot assign it through
the normal dynamic keymap interface without additional firmware plumbing.

## Options for this Cornix

1. **Recommended, no firmware work:** assign `KC_CAPS` in the `.vil`; select the
   Cornix under macOS **Keyboard → Keyboard Shortcuts → Modifier Keys** and map
   only that device's Caps Lock to Globe. Disable Karabiner event modification
   for the Cornix so the repository's global Caps Lock manipulator does not
   consume it.
2. **Direct firmware implementation:** modify or replace the vendor RMK firmware
   so a custom keycode (for example one exposed to Vial as `USER00`) sends
   Consumer usage `0x029D` on press and zero on release. This requires the
   Cornix firmware source and a safe flashing/recovery path.
3. **Wait for end-to-end support:** Vial GUI, the firmware's dynamic-keymap
   keycode table, and the firmware report path would all need to agree on a new
   assignable keycode. QMK merely naming the raw Consumer usage does not provide
   that end-to-end support.

## Sources

[^qmk-pr]: QMK PR #22256, [Add “AC Next Keyboard Layout Select” consumer usage entry (macOS Globe key)](https://github.com/qmk/qmk_firmware/pull/22256).
[^qmk-changelog]: QMK, [`docs/ChangeLog/20231126.md`](https://github.com/qmk/qmk_firmware/blob/master/docs/ChangeLog/20231126.md).
[^qmk-report]: QMK, [`tmk_core/protocol/report.h`](https://github.com/qmk/qmk_firmware/blob/master/tmk_core/protocol/report.h).
[^vial-qmk-report]: Vial QMK, [`tmk_core/protocol/report.h`](https://github.com/vial-kb/vial-qmk/blob/vial/tmk_core/protocol/report.h).
[^vial-gui-keycodes]: Vial GUI, [`src/main/python/keycodes/keycodes.py`](https://github.com/vial-kb/vial-gui/blob/main/src/main/python/keycodes/keycodes.py).
[^vial-release]: Vial GUI, [v0.7.5 release](https://github.com/vial-kb/vial-gui/releases/tag/v0.7.5).
[^rmk-082-keycodes]: RMK v0.8.2, [`rmk-types/src/keycode.rs`](https://github.com/rmk-rs/rmk/blob/rmk-v0.8.2/rmk-types/src/keycode.rs).
[^rmk-main-consumer]: RMK main, [`rmk-types/src/keycode/consumer.rs`](https://github.com/rmk-rs/rmk/blob/main/rmk-types/src/keycode/consumer.rs).
