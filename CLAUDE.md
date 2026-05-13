# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

KDE Plasma 6 小部件（plasmoids）集合，包含三个子项目：

| 子项目 | 类型 | 安装路径 |
|--------|------|----------|
| `kde-control-station/` | Plasma/Applet | `~/.local/share/plasma/plasmoids/` |
| `launchpad-plasma/` | Plasma/Applet | `~/.local/share/plasma/plasmoids/` |
| `bing-wallpaper-source/` | Plasma/Wallpaper | `~/.local/share/plasma/wallpapers/` |

## 常用命令

### 构建 .plasmoid 包

```bash
# kde-control-station
cd kde-control-station && sh ./build

# bing-wallpaper-source（仅编译翻译）
cd bing-wallpaper-source && bash translate/build.sh
```

### 安装到本地（开发调试）

```bash
# Applet 类型
cp -rf kde-control-station/package/* ~/.local/share/plasma/plasmoids/KdeControlStation/
cp -rf launchpad-plasma/* ~/.local/share/plasma/plasmoids/tt.launchpadPlasma/

# Wallpaper 类型
cp -rf bing-wallpaper-source/* ~/.local/share/plasma/wallpapers/com.wenyin.bingwallpapersource/

# 重启 Plasma 生效
plasmashell --replace &
```

### 翻译编译

```bash
# 编译 .po -> .mo
cd bing-wallpaper-source && bash translate/build.sh
cd kde-control-station && sh ./build --i18n-only
```

## 翻译系统

使用 gettext（`.po` → `.mo`）。

**catalog 命名规则：**
- Applet：`plasma_applet_<Id>`（如 `plasma_applet_KdeControlStation`）
- Wallpaper：`plasma_wallpaper_<Id>`（如 `plasma_wallpaper_com.wenyin.bingwallpapersource`）

**QML 中调用：**
- Applet 使用 `i18n("string")` / `i18nc("context", "string")`
- Wallpaper 使用 `i18nd("catalog_name", "string")`（因运行在 plasmashell 进程中，需显式指定 domain）

**翻译文件位置：**
- 源文件：`<项目>/translate/*.po`
- 编译输出：`<项目>/contents/locale/<locale>/LC_MESSAGES/<catalog>.mo`

## CI/CD

`.github/workflows/release.yml` 在 GitHub Release 发布时自动运行：
1. 编译所有 `.po` → `.mo`
2. 打包为 `.plasmoid`（zip 格式）
3. 上传到 release assets

版本号从各子项目的 `metadata.json` 的 `KPlugin.Version` 字段读取。

## 注意事项

- `*.plasmoid` 和 `*.mo` 已在 `.gitignore` 中排除
- 所有项目的简体中文本地化统一使用 `zh_CN`（metadata.json 用 `[zh_CN]` 后缀，po 文件命名为 `zh_CN.po`）
