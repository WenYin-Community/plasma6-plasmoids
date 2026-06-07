# AGENTS.md — Plasma 6 Plasmoids

## Repository Overview

KDE Plasma 6 widget collection (monorepo). Three usable projects, one partially ported KWin script:

| Directory | Type | Plugin ID | Status |
|-----------|------|-----------|--------|
| `kde-control-station/` | Plasma/Applet | `KdeControlStation` | ✅ Available, Plasma 6 |
| `launchpad-plasma/` | Plasma/Applet | `tt.launchpadPlasma` | ✅ Available, Plasma 6 |
| `bing-wallpaper-source/` | Plasma/Wallpaper | `com.wenyin.bingwallpapersource` | ✅ Available, Plasma 6 |
| `parachute-plasma6/` | KWin/Script | `Parachute` | ⚠️ NOT functional on Plasma 6 (KWin 5 API, 18+ incompatibilities) |

## Directory Structure (Per Project)

A critical gotcha: the package content root differs per project.

```
kde-control-station/
├── package/                    # <--- content root here
│   ├── metadata.json
│   ├── contents/{ui,config,locale}/
│   └── translate/*.po
└── build.sh

launchpad-plasma/
├── metadata.json               # <--- content root is project root
├── contents/{ui,config}/
└── contents/locale/<lang>/LC_MESSAGES/*.po + *.mo

bing-wallpaper-source/
├── metadata.json               # <--- content root is project root
├── contents/{ui,config,locale}/
└── translate/*.po

parachute-plasma6/
├── metadata.json               # <--- KWin/Script, content root is project root
├── Makefile                    # uses kpackagetool6
└── contents/ui/*.qml
```

## Commands

### Install for Local Dev (debugging)

```bash
# kde-control-station — copy from package/
cp -rf kde-control-station/package/* ~/.local/share/plasma/plasmoids/KdeControlStation/

# launchpad-plasma — copy entire project dir
cp -rf launchpad-plasma/* ~/.local/share/plasma/plasmoids/tt.launchpadPlasma/

# bing-wallpaper-source — copy entire project dir
cp -rf bing-wallpaper-source/* ~/.local/share/plasma/wallpapers/com.wenyin.bingwallpapersource/

# Restart Plasma to see changes
plasmashell --replace &
```

### Build .plasmoid Package

```bash
# kde-control-station (compile i18n + package)
cd kde-control-station && sh ./build.sh

# kde-control-station (i18n only)
cd kde-control-station && sh ./build.sh --i18n-only

# bing-wallpaper-source (i18n only)
cd bing-wallpaper-source && bash translate/build.sh

# CI builds all three with version from metadata.json KPlugin.Version
```

### Install Packaged .plasmoid

```bash
kpackagetool6 -i tt.launchpadPlasma-v<version>.plasmoid
```

### Install KWin Script

```bash
cd parachute-plasma6 && make install   # uses kpackagetool6 --type KWin/Script
```

### Translation Compile (manual)

```bash
# kde-control-station
msgfmt -o package/contents/locale/<lang>/LC_MESSAGES/plasma_applet_KdeControlStation.mo \
  package/translate/<lang>.po

# bing-wallpaper-source
msgfmt -o contents/locale/<lang>/LC_MESSAGES/plasma_wallpaper_com.wenyin.bingwallpapersource.mo \
  translate/<lang>.po

# launchpad-plasma (po/mo same dir)
msgfmt -o contents/locale/<lang>/LC_MESSAGES/plasma_applet_tt.launchpadPlasma.mo \
  contents/locale/<lang>/LC_MESSAGES/plasma_applet_tt.launchpadPlasma.po
```

## Translation System

- gettext (`*.po` → `*.mo`)
- Catalog naming:
  - Applet: `plasma_applet_<Id>` (e.g., `plasma_applet_KdeControlStation`)
  - Wallpaper: `plasma_wallpaper_<Id>` (e.g., `plasma_wallpaper_com.wenyin.bingwallpapersource`)
- QML calls:
  - Applets use `i18n("string")` / `i18nc("context", "string")`
  - Wallpapers use `i18nd("catalog_name", "string")` (must specify domain because wallpaper runs in plasmashell namespace)
- Locale dir names: `zh_CN`, `zh_TW` (NOT `zh_Hans`/`zh_Hant`)
- Coverage: kde-control-station (11 langs), launchpad-plasma (zh_CN only), bing-wallpaper-source (zh_CN only), parachute-plasma6 (none)

## QML Dev Notes

- All usable projects target Plasma 6 API (`X-Plasma-API-Minimum-Version: 6.0`)
- **No versioned imports**: `import QtQuick`, NOT `import QtQuick 2.12`
- Root elements: `PlasmoidItem` (Applet), `WallpaperItem` (Wallpaper), `Window` (KWin script)
- `Plasma5Support.DataSource` with `engine: "executable"` for running system commands
- `import QtCore` valid — exports `QtCore.StandardPaths` singleton (Qt6 QML module, 6.2)
- `PotdBackend` (`org.kde.plasma.wallpapers.potd`) provides Bing daily wallpaper support
- `MouseArea` is the standard mouse event handler (Plasma 5's `MouseEventListener` is private API, removed in Plasma 6)
- `org.kde.kitemmodels` → KItemModels (used by kde-control-station)
- `org.kde.plasma.private.kicker` → Kicker private API (used by launchpad-plasma)

## CI/CD

- `.github/workflows/release.yml` runs on GitHub Release publish
- Steps: compile `.po` → `.mo` → package each project into `.plasmoid` (zip) → upload to release assets
- Version read from each project's `metadata.json` → `KPlugin.Version`
- Manual trigger available via `workflow_dispatch`

## parachute-plasma6 Notes

⚠️ **NOT functional on Plasma 6**: Despite having `metadata.json` and unversioned imports (cosmetic porting), the code still uses **KWin 5 API** throughout. The `KWin 5 → 6` migration renamed types, signals, and properties extensively (e.g., `Client` → `Window`, `clientList()` → `windowList()`, `activeClient` → `activeWindow`, `desktop` → `desktops`, `screen` → `output`).

### Key blockers for Plasma 6 (18+ API incompatibilities)

**Fatal (script crashes at startup):**
- `workspace.numScreens` removed → use `workspace.screens.length`
- `workspace.displayWidth/Height` removed → use `workspace.virtualScreenGeometry`
- `workspace.clientList()` removed → use `workspace.windowList()`
- `workspace.activeClient` → `workspace.activeWindow`
- `workspace.currentDesktop` changed from `int` to `VirtualDesktop*` object
- `workspace.desktops` changed from `int` count to `QList<VirtualDesktop*>`
- `client.desktop` removed → use `client.desktops` (array of VirtualDesktop)
- `client.screen` removed → use `client.output` (Output* object)
- `client.windowId` removed; `WindowThumbnail.winId` now depends on `PlasmaCore.WindowThumbnail` changes
- All signals renamed: `clientActivated`→`windowActivated`, `clientAdded`→`windowAdded`, `clientRemoved`→`windowRemoved`, etc.
- `PlasmaCore.WindowThumbnail` → `KWin.WindowThumbnail` (from `org.kde.kwin` module)

**Functional (features broken):**
- `client.closeWindow()` → `client.close()`
- `client.switchSwitcher` → `client.skipSwitcher`
- `client.onClientFinishUserMovedResized` → `client.onInteractiveMoveResizeFinished`
- `clientArea()` signatures changed (takes Output* / VirtualDesktop* instead of int)
- `sendClientToScreen()` now takes Output* instead of int screen index
- `currentDesktopChanged` signal: `(desktop, client)` → `(previous, current, output)`
- `Qt5Compat.GraphicalEffects` import needs migration to Qt6 equivalents
- `metadata.json` has obsolete KWin 5 fields (`X-KDE-Library`, `X-KDE-PluginKeyword`, `X-KDE-ParentComponents`)

Detailed per-line migration guide written to `parachute-plasma6/PORT_TO_PLASMA6.md`.

## Build Artifacts

- `*.plasmoid` and `*.mo` are gitignored
- `kde-control-station/build` and `kde-control-station/kpac` are binary files — do not modify
- `kde-control-station/CMakeLists.txt` references KF5Plasma; actual build uses `build.sh`
