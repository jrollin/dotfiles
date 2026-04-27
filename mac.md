# macOS Notes

## Keyboard — French AZERTY on external keyboard (Keychron Q2 65%)

macOS has no `Alt Gr` key. The standard "French" input source does not map `@` correctly with external keyboards.

Use the **"French - Numerical"** input source (System Settings → Keyboard → Input Sources).

The Keychron Q2 is a 65% layout — no key where `@` and `#` physically live on a full AZERTY board. Use Karabiner mappings instead:

- `Shift + Esc` → `#`
- `Cmd + Shift + Esc` → `@`

These use `osascript keystroke` to send the literal character regardless of active layout.

## utils

shottr (screnshot )
