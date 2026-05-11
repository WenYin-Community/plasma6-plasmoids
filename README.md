# Plasma 6 Plasmoids

A modern control center widget for KDE Plasma 6.

## Features

- 5 layout variants (Default, Control Center, Flat, Tahoe, Custom)
- Battery, Network, Bluetooth, Volume, Brightness widgets
- Session actions (suspend, restart, shutdown, hibernate, lock, logout)
- Dark/Light mode with Global Theme switching
- Night Light control, Color Scheme switcher
- Media player with album art
- Custom command buttons
- 11 languages supported

## Dependencies

- KDE Plasma ≥ 6.0
- Packages: `plasma-nm`, `kdeplasma-addons`, `plasma-pa`

## Installation

### KDE Store (Recommended)

Right-click desktop → Add Widgets → Get New Widgets → Search "KDE Control Station"

### Build from Source

```bash
git clone https://github.com/WenYin-Community/plasma6-plasmoids.git
cd plasma6-plasmoids/kde-control-station
sh ./build
```

Install via System Settings → Appearance → Widgets → Install from local file.

## Development

```bash
cd kde-control-station
sh ./build              # Build .plasmoid
sh ./build --i18n-only  # Build translations only
```

## License

[GPLv3](https://www.gnu.org/licenses/gpl-3.0.en.html)
