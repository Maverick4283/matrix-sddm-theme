# Matrix Trilogy SDDM Theme — CLAUDE.md

## Credits (Preserve These)

- **Author:** VORAGO (mens@tutamail.com)
- **Copyright:** 2026 VORAGO
- **License:** MIT
- Inspired by The Matrix trilogy (1999-2003)
- Created for the Linux/KDE community
- Special thanks to SDDM developers

## Target Environment

- **Greeter:** `sddm-greeter-qt6` (Wayland mode invokes this automatically)
- **Display server:** Wayland (`DisplayServer=wayland` in `/etc/sddm.conf.d/sddm.conf`)
- **Greeter compositor:** `weston --shell=kiosk` — must be installed: `sudo pacman -S weston`
- **Default user session:** `hyprland.desktop`
- **Test command:** `sddm-greeter-qt6 --test-mode --theme /usr/share/sddm/themes/matrix-trilogy`

## Project Goals

1. **Qt6 compatibility** — Update QML imports and APIs to work with the latest Qt versions.
   - `import QtGraphicalEffects 1.15` was removed in Qt6; replacement is `Qt5Compat.GraphicalEffects` or native Qt6 alternatives.
   - All `import QtQuick 2.x` / `QtQuick.Controls 2.x` style imports should migrate to unversioned Qt6 style (`import QtQuick`, `import QtQuick.Controls`).
   - `QtQuick.Window 2.x` → `import QtQuick.Window`

2. **Large display scaling** — Improve layout so the theme looks balanced on high-resolution and large-format monitors (4K, ultrawide, multi-monitor setups).
   - Login box, clock, and UI elements should scale relative to screen size, not use fixed pixel values.
   - Matrix rain column density and font size should adapt to resolution.
   - Hands/ASCII art on side monitors need proportional positioning.

## File Structure

```
Main.qml                    # Root entry point; screen detection, intro, layout
theme.conf                  # All user-facing settings
metadata.desktop            # Theme metadata (author, version, license)
components/
  LoginBox.qml              # Login form + power buttons
  MatrixRainCanvas.qml      # Canvas-based falling rain animation
  MatrixClock.qml           # Clock with scramble effect
  MatrixHand.qml            # ASCII hand renderer (Morpheus hands)
  TypeWriter.qml            # Intro sequence + rotating quotes
  KeyboardIndicator.qml     # Keyboard layout switcher
fonts/                      # JetBrainsMono, matrix-code.ttf, NotoSansJP
ascii/                      # ASCII art for left/right monitor hands
```

## Local Testing

Test the theme without restarting SDDM using test mode. Run from inside the repo root.

**Qt6 greeter (target):**
```bash
sddm-greeter-qt6 --test-mode --theme $PWD
```

**Qt5 greeter (legacy, current live):**
```bash
sddm-greeter --test-mode --theme $PWD
```

**Against the installed copy** (after `sudo cp -r . /usr/share/sddm/themes/matrix-trilogy`):
```bash
sddm-greeter-qt6 --test-mode --theme /usr/share/sddm/themes/matrix-trilogy
```

Notes:
- `$PWD` must be the theme root (contains `Main.qml` and `metadata.desktop`)
- Test mode runs the greeter as your current user — SDDM login/session features won't work, but all visual/animation elements will
- Close the test window with `Alt+F4` or `Ctrl+C` in the terminal

## Key Technical Notes

- Theme targets SDDM with Qt/QML rendering
- Currently imports `QtGraphicalEffects 1.15` — primary Qt6 compat blocker
- Screen detection uses `screenModel` (SDDM-provided) and `Qt.application.screens`
- All config values come from `config.*` (bound to `theme.conf`)
