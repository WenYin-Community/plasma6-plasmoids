# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

KDE Plasma 6 小部件集合，包含四个子项目：

| 子项目 | 类型 | 插件 ID | 状态 |
|--------|------|---------|------|
| `kde-control-station/` | Plasma/Applet | `KdeControlStation` | 可用，Plasma 6 |
| `launchpad-plasma/` | Plasma/Applet | `tt.launchpadPlasma` | 可用，Plasma 6 |
| `bing-wallpaper-source/` | Plasma/Wallpaper | `com.wenyin.bingwallpapersource` | 可用，Plasma 6 |
| `parachute-plasma6/` | KWin/Script | `Parachute` | **未移植**，仍是 Plasma 5 代码 |

## 目录结构差异（关键）

三个可用项目的包内容位置**不同**：

```
kde-control-station/
├── package/               # 实际包内容在 package/ 下
│   ├── metadata.json
│   ├── contents/{ui,config,locale}/
│   └── translate/*.po
└── build.sh

launchpad-plasma/
├── metadata.json          # 根目录
├── contents/{ui,config}/
└── contents/locale/<lang>/LC_MESSAGES/*.po + *.mo  # po/mo 同目录

bing-wallpaper-source/
├── metadata.json          # 根目录
├── contents/{ui,config,locale}/
└── translate/*.po

parachute-plasma6/         # Plasma 5 KWin 脚本（未移植）
├── metadata.desktop       # 老格式，Plasma 6 需要 metadata.json
├── Makefile               # 使用 kpackagetool5（需改为 kpackagetool6）
└── contents/ui/*.qml      # 使用 Qt 5 版本化 import（需改为无版本）
```

## 常用命令

### 安装到本地（开发调试）

```bash
# kde-control-station — 源是 package/*
cp -rf kde-control-station/package/* ~/.local/share/plasma/plasmoids/KdeControlStation/

# launchpad-plasma
cp -rf launchpad-plasma/* ~/.local/share/plasma/plasmoids/tt.launchpadPlasma/

# bing-wallpaper-source
cp -rf bing-wallpaper-source/* ~/.local/share/plasma/wallpapers/com.wenyin.bingwallpapersource/

# 重启 Plasma 生效
plasmashell --replace &
```

### 构建 .plasmoid 包

```bash
# kde-control-station（编译翻译 + 打包为 .plasmoid zip）
cd kde-control-station && sh ./build.sh

# kde-control-station（仅编译翻译）
cd kde-control-station && sh ./build.sh --i18n-only

# bing-wallpaper-source（仅编译翻译）
cd bing-wallpaper-source && bash translate/build.sh
```

### 翻译编译（手动）

```bash
# kde-control-station
msgfmt -o package/contents/locale/<lang>/LC_MESSAGES/plasma_applet_KdeControlStation.mo \
  package/translate/<lang>.po

# bing-wallpaper-source
msgfmt -o contents/locale/<lang>/LC_MESSAGES/plasma_wallpaper_com.wenyin.bingwallpapersource.mo \
  translate/<lang>.po

# launchpad-plasma（po/mo 同目录）
msgfmt -o contents/locale/<lang>/LC_MESSAGES/plasma_applet_tt.launchpadPlasma.mo \
  contents/locale/<lang>/LC_MESSAGES/plasma_applet_tt.launchpadPlasma.po
```

## 翻译系统

使用 gettext（`.po` → `.mo`）。

**catalog 命名：**
- Applet：`plasma_applet_<Id>`（如 `plasma_applet_KdeControlStation`）
- Wallpaper：`plasma_wallpaper_<Id>`（如 `plasma_wallpaper_com.wenyin.bingwallpapersource`）

**QML 调用：**
- Applet：`i18n("string")` / `i18nc("context", "string")`
- Wallpaper：`i18nd("catalog_name", "string")`（Wallpaper 运行在 plasmashell 命名空间，需显式指定 domain）

**目录命名：** 简体中文 `zh_CN`，繁体中文 `zh_TW`（无 `zh_Hans`/`zh_Hant`）。

**翻译覆盖：**
- kde-control-station：11 种语言（de, es, fr, ko, nl, pl, pt_BR, ru, uk, zh_CN, zh_TW）
- launchpad-plasma：仅 zh_CN
- bing-wallpaper-source：仅 zh_CN
- parachute-plasma6：无翻译

## QML 开发要点

- 所有可用项目面向 Plasma 6 API（`X-Plasma-API-Minimum-Version: 6.0`）
- QML import 不使用版本号（`import QtQuick`，不是 `import QtQuick 2.12`）
- `PlasmoidItem` 是 Applet 根元素，`WallpaperItem` 是 Wallpaper 根元素
- `Plasma5Support.DataSource`（engine: `"executable"`）用于执行系统命令
- `import QtCore` 合法，用于获取 `StandardPaths` 单例（Qt6 QML 模块，导出 `QtCore/StandardPaths 6.2`）
- `PotdBackend`（`org.kde.plasma.wallpapers.potd`）提供 Bing 每日壁纸
- `MouseArea` 是 Plasma 6 中处理鼠标事件的标准组件（`MouseEventListener` 是 Plasma 5 私有 API，已移除）
- `org.kde.kitemmodels` 提供 KItemModels（kde-control-station 使用）
- `org.kde.plasma.private.kicker` 提供 Kicker 私有 API（launchpad-plasma 使用）

## CI/CD

`.github/workflows/release.yml` 在 GitHub Release 发布时自动运行：
1. 编译所有 `.po` → `.mo`
2. 打包为 `.plasmoid`（zip 格式）
3. 上传到 release assets

版本号从各子项目 `metadata.json` 的 `KPlugin.Version` 字段读取。

## parachute-plasma6 注意事项

这是一个 **Plasma 5 的 KWin 脚本**，尚未移植到 Plasma 6。移植需要：
- `metadata.desktop` → `metadata.json`
- `kpackagetool5` → `kpackagetool6`
- Qt 5 版本化 import（`QtQuick 2.12`）→ 无版本 import（`QtQuick`）
- `QtGraphicalEffects 1.12` → Qt 6 等效模块
- `org.kde.kwin 2.0` → Plasma 6 KWin 脚本 API
- 无翻译文件，无 README

## 注意事项

- `*.plasmoid` 和 `*.mo` 已在 `.gitignore` 中排除
- kde-control-station 的 `CMakeLists.txt` 存在但引用 `KF5Plasma`，实际构建使用 `build.sh`
- kde-control-station 的 `build` 和 `kpac` 是二进制文件，不应修改
