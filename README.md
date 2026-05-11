# Plasma 6 Plasmoids

[English](README.md) | [中文](README_zh.md)

A collection of KDE Plasma 6 widgets (plasmoids).

## Projects

### 1. KDE Control Station

A modern control center widget for KDE Plasma 6.

**Features:**
- 5 layout variants (Default, Control Center, Flat, Tahoe, Custom)
- Battery, Network, Bluetooth, Volume, Brightness widgets
- Session actions (suspend, restart, shutdown, hibernate, lock, logout)
- Dark/Light mode with Global Theme switching
- Night Light control, Color Scheme switcher
- Media player with album art
- Custom command buttons
- 11 languages supported

**Dependencies:**
- KDE Plasma ≥ 6.0
- Packages: `plasma-nm`, `kdeplasma-addons`, `plasma-pa`

**Installation:**

```bash
git clone https://github.com/WenYin-Community/plasma6-plasmoids.git
cd plasma6-plasmoids/kde-control-station
sh ./build
```

Install via System Settings → Appearance → Widgets → Install from local file.

### 2. Launchpad Plasma

A configurable application launcher grid for KDE Plasma 6.

**Features:**
- Application launcher grid
- Customizable layout
- Bottom favorites row synced from the existing KDE Application Menu favorites
- Separate system action buttons for power/session actions

**Installation:**

Install a local `.plasmoid` package:

```bash
kpackagetool6 -i tt.launchpadPlasma-v1.19.plasmoid
```

For development, copy `launchpad-plasma/` to `~/.local/share/plasma/plasmoids/tt.launchpadPlasma/` and restart Plasma Shell.

## License

- kde-control-station: [GPLv3](https://www.gnu.org/licenses/gpl-3.0.en.html)
- launchpad-plasma: [GPL-2.0+](https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html)
