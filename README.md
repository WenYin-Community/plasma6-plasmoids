# KDE Control Station

A modern and feature-rich control center widget for KDE Plasma 6.

## Features

* **Customizable Layout** - Create your own layout! Reorder, add, delete widgets and customize each widget individually
* **Multiple Layouts** - Choose between 5 prebuilt layouts: Default, Control Center, Flat, Tahoe, Custom
* **Battery Widget** - Shows detailed battery information including charge level, health, and time remaining
* **Session Actions** - Quick access to suspend, restart, shutdown, hibernate, lock screen, and log out
* **Toggle Buttons** - Network, Bluetooth, Night Light, Color Scheme Switcher with state highlighting
* **Dark/Light Mode** - Switch between dark and light themes, with optional Global Theme switching
* **Night Light Control** - Toggle and configure Night Light directly from the widget
* **Custom Commands** - Execute custom commands with configurable icons and titles
* **Media Player** - Modern media player UI with album art and playback controls
* **Volume Control** - Slider with device selection and application-level volume control
* **Brightness Control** - Screen brightness slider with keyboard brightness support
* **Network Management** - WiFi, mobile broadband, and VPN connection management
* **Bluetooth Management** - Device pairing, connection, and file transfer
* **Animations** - Smooth page transition animations
* **Multi-language Support** - 11 languages with high translation coverage

## Dependencies

- KDE Plasma >= 6.0
- Packages: `plasma-nm`, `kdeplasma-addons`, `plasma-pa`
- KDE Connect (optional, for KDE Connect widget)

## Installation

### Method 1: KDE Store (Recommended)

1. Right click on the desktop
2. Click on "Add Widgets"
3. Click on "Get New Widgets"
4. Click on "Download New Plasma Widgets"
5. Search for "KDE Control Station"
6. Click on "Install"

### Method 2: Manual Installation

```bash
# Download the .plasmoid file from releases
# Then install via System Settings:
# System Settings → Appearance → Widgets → Get New Widgets → Install from local file

# Or manually extract:
mkdir -p ~/.local/share/plasma/plasmoids/KdeControlStation
cd ~/.local/share/plasma/plasmoids/KdeControlStation
unzip /path/to/KdeControlStation-v2.8.0-plasma6-0.plasmoid
```

### Method 3: Build from Source

```bash
git clone https://github.com/EliverLara/kde-control-station.git
cd kde-control-station
git checkout plasma6

# Build .plasmoid package
sh ./build

# The package will be created as KdeControlStation-v{version}-plasma6-0.plasmoid
```

## Usage

1. Right click on the desktop or panel
2. Click "Add Widgets"
3. Search for "KDE Control Station" or "KDE 控制中心"
4. Drag and drop to your desired location

## Configuration

Right-click the widget and select "Configure" to access:

- **Appearance** - Scale, layout selection, transparency, borders
- **Toggle Buttons** - Show/hide Network, Bluetooth, Night Light, Color Switcher, etc.
- **Sliders** - Volume and brightness slider styles and colors
- **Custom Commands** - Configure up to 2 custom command buttons
- **Screenshot** - Screenshot command configuration
- **Color Schemes** - Light/dark theme selection

## Supported Languages

| Language | Coverage |
|----------|----------|
| 简体中文 (zh_CN) | 100% |
| 繁体中文 (zh_TW) | 100% |
| Русский (ru) | 99% |
| Deutsch (de) | 98% |
| Nederlands (nl) | 98% |
| Polski (pl) | 98% |
| Українська (uk) | 97% |
| Português Brasil (pt_BR) | 93% |
| 한국어 (ko) | 85% |
| Français (fr) | 67% |
| Español (es) | 15% |

## Development

### Building

```bash
# Build .plasmoid for KDE Store
sh ./build

# Build translations only (for distro packaging)
sh ./build --i18n-only
```

### Translation

Translation files are located in `package/translate/`. To contribute translations:

1. Copy `template.pot` to your locale code (e.g., `fr.po`)
2. Translate all `msgstr ""` entries
3. Submit a pull request

### Project Structure

```
package/
  metadata.json              # Plugin metadata
  contents/
    ui/
      main.qml               # Main entrypoint
      FullRepresentation.qml  # Expanded widget
      CompactRepresentation.qml # Panel icon
      layouts/                # Layout variants
      pages/                  # Feature pages
      components/             # UI components
      lib/                    # Reusable components
      js/                     # JavaScript helpers
    config/                   # Configuration pages
    assets/                   # Icons and images
    locale/                   # Compiled translations
  translate/                  # Source translation files
```

## Qt6 Compatibility

This version has been updated for full Qt6/Plasma 6 compatibility:

- ✅ Removed Qt5Compat.GraphicalEffects dependency
- ✅ Fixed version detection logic
- ✅ Updated deprecated QML syntax
- ✅ Fixed binding loops and import issues
- ✅ Unified QML import format

## Support

If you enjoy this project, consider supporting the developer:

<a href="https://ko-fi.com/eliverlara"><img alt="Buy Me A Coffee" src="https://img.shields.io/badge/Buy%20Me%20A%20Coffee-%234D798C?style=for-the-badge&logo=ko-fi"/></a>
<a href="https://www.paypal.com/paypalme/EliverLara/"><img alt="Donate via PayPal" src="https://img.shields.io/badge/Donate-Blue?style=for-the-badge&logo=paypal&color=%23002991"/></a>

## License

[GPLv3](https://www.gnu.org/licenses/gpl-3.0.en.html)
