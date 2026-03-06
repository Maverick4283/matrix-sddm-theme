# Matrix Trilogy SDDM Theme

![Version](https://img.shields.io/badge/version-1.0.0-green)
![License](https://img.shields.io/badge/license-MIT-blue)
![SDDM](https://img.shields.io/badge/SDDM-compatible-brightgreen)

A cinematic Matrix-inspired login theme for SDDM with falling code rain, multi-monitor support, and Morpheus' red/blue pill choice.

---

## 📑 Table of Contents

- [Features](#-features)
- [Installation](#-installation)
- [Configuration Guide](#-configuration-guide)
  - [Colors](#1-colors)
  - [Matrix Rain](#2-matrix-rain-settings)
  - [Intro Sequence](#3-intro-sequence)
  - [Quotes](#4-quotes)
  - [Login Box](#5-login-box)
  - [Clock](#6-clock)
  - [Hands (Side Monitors)](#7-hands-side-monitors)
  - [Multi-Monitor](#8-multi-monitor)
  - [Performance](#9-performance)
- [File Structure](#-file-structure)
- [Troubleshooting](#-troubleshooting)
- [Advanced Customization](#-advanced-customization)
- [License](#-license)

---

## ✨ Features

🌧️ **Authentic Matrix Rain** - Falling Japanese Katakana + Latin + numbers with depth effects  
🎬 **Cinematic Intro** - "Wake up, Neo..." typewriter animation  
🖥️ **Multi-Monitor** - Adaptive layout for 1-3 monitors with Morpheus hands + pills  
🎨 **Customizable** - All settings in `theme.conf`, no code editing required  
⚡ **Performance** - Optimized Canvas rendering, 60 FPS smooth animation  
🔐 **Unique Password** - Katakana masking instead of boring asterisks  
💚 **Pure QML** - No external dependencies except standard Qt libraries  

---

## 🚀 Installation

### Option 1: Via KDE System Settings (Recommended)

1. Download `matrix-trilogy.tar.gz` from [KDE Store](https://store.kde.org)
2. Open **System Settings** → **Startup and Shutdown** → **Login Screen (SDDM)**
3. Click **"Install From File..."** button
4. Select downloaded archive
5. Choose **"Matrix Trilogy"** from theme list
6. Click **Apply** and enter password

### Option 2: Manual Installation

```bash
# Download and extract files to:

/usr/share/sddm/themes/matrix-trilogy

# Configure SDDM
sudo nano /etc/sddm.conf
```

Add/modify in `/etc/sddm.conf`:
```ini
[Theme]
Current=matrix-trilogy
```

Restart SDDM:
```bash
sudo systemctl restart sddm
```

### Test Before Applying

**Qt6 greeter (target):**
```bash
sddm-greeter-qt6 --test-mode --theme /usr/share/sddm/themes/matrix-trilogy
```

**Qt5 greeter (legacy):**
```bash
sddm-greeter --test-mode --theme /usr/share/sddm/themes/matrix-trilogy
```

**Restrict test to a specific display (Wayland):**

Use the `QT_QPA_SCREEN` environment variable with your output name. Find your output names with `hyprctl monitors`, `wlr-randr`, or `xrandr`:

```bash
# Example: only open on display DP-3
QT_QPA_SCREEN=DP-3 sddm-greeter-qt6 --test-mode --theme /usr/share/sddm/themes/matrix-trilogy

# Example: only open on display DP-2
QT_QPA_SCREEN=DP-2 sddm-greeter-qt6 --test-mode --theme /usr/share/sddm/themes/matrix-trilogy
```

Replace `DP-3`/`DP-2` with your actual output name from `hyprctl monitors`.


---

## ⚙️ Configuration Guide

**All settings are in `theme.conf`** - edit with any text editor:

```bash
sudo nano /usr/share/sddm/themes/matrix-trilogy/theme.conf
```

After changes, restart SDDM or test mode to see effects.

---

### 1. Colors

```ini
# --- MAIN COLORS ---

# Primary Matrix green (symbols, text, UI borders)
MatrixGreen=#00FF41

# Darker green for fading symbol tails
MatrixDarkGreen=#003B00

# Background (black recommended for Matrix aesthetic)
BackgroundColor=#000000

# Glow effect color (usually same as MatrixGreen)
GlowColor=#00FF41

# --- PILL COLORS (Morpheus hands) ---

# Red pill (left monitor, right hand)
RedPillColor=#FF0000
RedPillGlow=#FF4444

# Blue pill (right monitor, left hand)
BluePillColor=#0066FF
BluePillGlow=#4488FF
```

**Examples:**
- Classic green Matrix: `#00FF41`
- Blue Matrix: `#00BFFF`
- Red Matrix: `#FF0033`
- Purple Matrix: `#AA00FF`

---

### 2. Matrix Rain Settings

```ini
# --- MATRIX RAIN SETTINGS ---

# Rain falling speed (1.0 = default)
FallSpeed=1.0
# Examples:
# 0.5  = Half speed (slower, more cinematic)
# 1.5  = 1.5x speed (faster action)
# 2.0  = Double speed (very fast)

# Depth effect speed (flying-through effect)
DepthSpeed=0.5
# 0.0  = Disabled (flat rain)
# 0.5  = Default (moderate depth)
# 1.0  = Strong depth effect

# Symbol change rate in tails (0.0-1.0)
SymbolChangeRate=0.3
# 0.0  = Symbols never change (static)
# 0.5  = Moderate changes
# 1.0  = Maximum randomness

# Glow intensity around bright symbols (0.0-1.0)
GlowIntensity=0.6
# 0.0  = No glow (performance mode)
# 0.6  = Default
# 1.0  = Maximum glow

# Rain column density (higher = more columns)
ColumnDensity=1.0
# 0.5  = Half density (less CPU usage)
# 1.0  = Default
# 2.0  = Double density (more intensive)
```

**Performance tip:** For older hardware, use:
```ini
FallSpeed=0.8
ColumnDensity=0.6
GlowIntensity=0.3
TargetFPS=30
```

---

### 3. Intro Sequence

```ini
# --- INTRO SEQUENCE ---

# Enable intro animation
IntroEnabled=true
# true  = Show "Wake up, Neo..." on boot
# false = Skip directly to login

# Total intro duration before login appears (seconds)
IntroDuration=6

# Typing speed (milliseconds per character)
TypewriterSpeed=50
# 30  = Fast typing
# 50  = Default
# 100 = Slow, dramatic typing

# Allow skipping intro with key/mouse
IntroSkippable=true
# true  = Press any key to skip
# false = Must wait for full intro

# Intro text (separated by | character)
IntroText=Wake up, Neo...|The Matrix has you...|Follow the white rabbit...
```

**Custom intro examples:**
```ini
# Short version
IntroText=Wake up...|Welcome to the Matrix

# Hacker style
IntroText=Access granted...|Loading system...|Welcome, user

# No intro (instant login)
IntroEnabled=false
```

---

### 4. Quotes

```ini
# --- QUOTES ---

# Enable rotating quotes at bottom
QuotesEnabled=true

# Time each quote displays (seconds)
QuoteChangeInterval=5
# 3   = Fast rotation
# 5   = Default
# 10  = Slow rotation

# Typing animation speed (ms per character)
QuoteTypingSpeed=30

# Quotes list (format: "quote" - Author | next quote | ...)
Quotes="There is no spoon." - Neo|"Free your mind." - Morpheus|"Welcome to the real world." - Morpheus|"The Matrix has you." - Trinity|"I know kung fu." - Neo|"Dodge this." - Trinity|"What is real?" - Morpheus|"Choice. The problem is choice." - Neo
```

**Add your own quotes:**
```ini
Quotes=Your first quote - Author|Your second quote - Someone|And so on...
```

**Disable quotes:**
```ini
QuotesEnabled=false
```

---

### 5. Login Box

```ini
# --- LOGIN BOX ---

# Background opacity (0.0 = transparent, 1.0 = solid)
LoginBoxOpacity=0.85

# Border color
LoginBoxBorderColor=#00FF41

# Border width (pixels)
LoginBoxBorderWidth=2

# Show Matrix symbol avatar
ShowMatrixAvatar=true
# true  = Neo's glasses with pills
# false = No avatar

# --- PASSWORD FIELD ---

# Password masking style
PasswordCharStyle=katakana
# Options:
# "katakana" = Random Japanese characters (default)
# "asterisk" = Traditional * * * *
# "bullet"   = • • • •
# "block"    = █ █ █ █
```

**Note:** Currently only `katakana` is fully implemented in code.

---

### 6. Clock

```ini
# --- CLOCK ---

# Show clock above login box
ShowClock=true

# Time format (Qt format)
ClockFormat=HH:mm:ss
# HH:mm:ss = 24-hour with seconds (14:35:22)
# HH:mm    = 24-hour no seconds (14:35)
# hh:mm AP = 12-hour with AM/PM (02:35 PM)

# Date format (Qt format)
DateFormat=yyyy.MM.dd
# yyyy.MM.dd = 2025.01.18
# dd/MM/yyyy = 18/01/2025
# MMMM d, yyyy = January 18, 2025
# dddd, MMMM d = Friday, January 18
```

**Disable clock:**
```ini
ShowClock=false
```

---

### 7. Hands (Side Monitors)

```ini
# --- HANDS (Side monitors) ---

# Enable Morpheus hands with pills
HandsEnabled=true
# true  = Show hands on side monitors
# false = Only rain on all monitors

# Hand breathing animation (not implemented yet)
HandBreathingSpeed=1.0

# Symbol density (not implemented yet)
HandSymbolDensity=1.0
```

**Note:** Hands only appear if you have 2+ monitors connected.

---

### 8. Multi-Monitor

```ini
# --- MULTI-MONITOR ---

# Auto-detect monitor layout
AutoDetectMonitors=true

# Force specific layout (leave empty for auto)
ForceLayout=
# Options:
# ""              = Auto-detect (recommended)
# "single"        = Force single monitor mode
# "left,center,right" = Force 3-monitor layout
```

**Monitor behavior:**
- **1 monitor:** Login + rain on center
- **2 monitors:** Rain on left, Login + rain on right (right hand with red pill on left)
- **3 monitors:** Left hand + blue pill | Login + rain | Right hand + red pill

---

### 9. Performance

```ini
# --- PERFORMANCE ---

# Shader quality (not used in Canvas version)
ShaderQuality=high

# Enable glow effects
EnableGlow=true
# true  = Full glow effects (looks better)
# false = Disable glow (better performance)

# Target frame rate
TargetFPS=60
# 30  = Lower CPU usage
# 60  = Smooth animation
# 0   = Unlimited (not recommended)
```

**For low-end systems:**
```ini
EnableGlow=false
TargetFPS=30
ColumnDensity=0.5
GlowIntensity=0.2
```

---

## 📁 File Structure

```
matrix-trilogy/
├── Main.qml                    # Main entry point, screen detection
├── theme.conf                  # ← ALL YOUR SETTINGS HERE
├── metadata.desktop            # Theme metadata
│
├── components/                 # QML components
│   ├── KeyboardIndicator.qml   # Keyboard layout switcher
│   ├── LoginBox.qml            # Login form + power buttons
│   ├── MatrixClock.qml         # Clock with scramble effect
│   ├── MatrixHand.qml          # ASCII hand renderer
│   ├── MatrixRainCanvas.qml    # Main rain animation
│   └── TypeWriter.qml          # Intro + quotes typewriter
│
├── fonts/                      # Fonts
│   ├── JetBrainsMono-Regular.ttf  # UI font
│   ├── matrix-code.ttf            # Matrix symbols font
│   └── NotoSansJP-Regular.ttf     # Japanese characters
│
└── ascii/                      # ASCII art for hands
    ├── LeftMonitor_reduced.txt    # Right hand (red pill)
    └── RightMonitor_reduced.txt   # Left hand (blue pill)
```

---

## 🐛 Troubleshooting

### Rain is too slow/fast
```ini
FallSpeed=1.5  # Increase for faster
```

### Too many columns (lag)
```ini
ColumnDensity=0.5  # Reduce density
TargetFPS=30       # Lower FPS
```

### Intro annoying
```ini
IntroEnabled=false  # Disable intro
```

### Japanese characters show as boxes □□□
Install CJK fonts:
```bash
# Arch/Manjaro
sudo pacman -S noto-fonts-cjk

# Ubuntu/Debian
sudo apt install fonts-noto-cjk

# Fedora
sudo dnf install google-noto-sans-cjk-fonts
```

### Hands not showing on side monitors
1. Verify 2+ monitors connected
2. Check `HandsEnabled=true` in theme.conf
3. Test with: `xrandr` to see monitor layout

### Theme not applying
```bash
# Check SDDM config
cat /etc/sddm.conf | grep Current

# Should show:
# Current=matrix-trilogy

# Restart SDDM
sudo systemctl restart sddm
```

### Test mode crashes
```bash
# Check logs
journalctl -u sddm -b

# Try with root
sudo sddm-greeter --test-mode --theme /path/to/theme
```

---

## 🔧 Advanced Customization

### Changing Pill Coordinates (Hands)

If you want to adjust pill positions on hands, edit `Main.qml`:

**For red pill (left monitor, right hand):**
```qml
// Around line 320
pillCoordRanges: [
    {row: 125, colStart: 251, colEnd: 259},
    {row: 126, colStart: 249, colEnd: 260},
    // Add/modify rows here...
]
```

**For blue pill (right monitor, left hand):**
```qml
// Around line 355
pillCoordRanges: [
    {row: 131, colStart: 140, colEnd: 146},
    {row: 132, colStart: 137, colEnd: 149},
    // Add/modify rows here...
]
```

Format: `{row: LINE_NUMBER, colStart: START_COLUMN, colEnd: END_COLUMN}`

### Changing Intro Lines

Edit `Main.qml` around line 50:
```qml
property var introLines: [
    "Your custom line 1...",
    "Your custom line 2...",
    "Your custom line 3..."
]
```

Or use `theme.conf`:
```ini
IntroText=Line 1|Line 2|Line 3
```

---

## 📝 License

**MIT License**

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

---

## 💚 Credits

- Inspired by **The Matrix** trilogy (1999-2003)
- Created for the Linux/KDE community
- Special thanks to SDDM developers

**"Unfortunately, no one can be told what the Matrix is. You have to see it for yourself."**

Follow the white rabbit... 🐰
