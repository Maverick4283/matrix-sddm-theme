# Matrix Trilogy SDDM Theme — CLAUDE.md

## Credits (Preserve These)

- **Author:** VORAGO (mens@tutamail.com)
- **Copyright:** 2026 VORAGO
- **License:** MIT
- Inspired by The Matrix trilogy (1999-2003)
- Created for the Linux/KDE community
- Special thanks to SDDM developers

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

## Key Technical Notes

- Theme targets SDDM with Qt/QML rendering
- Currently imports `QtGraphicalEffects 1.15` — primary Qt6 compat blocker
- Screen detection uses `screenModel` (SDDM-provided) and `Qt.application.screens`
- All config values come from `config.*` (bound to `theme.conf`)
- Test locally: `sddm-greeter-qt6 --test-mode --theme /path/to/theme`
