# AGENTS.md

This file provides guidance to the AI agent when working with code in this repository.

## 仓库概况

KDE Plasma 6 小部件（monorepo），4 个项目：

| 目录 | 类型 | 插件 ID | 内容根目录 |
|------|------|---------|-----------|
| `kde-control-station/` | Plasma/Applet | `KdeControlStation` | `package/` 子目录 |
| `launchpad-plasma/` | Plasma/Applet | `tt.launchpadPlasma` | 项目根 |
| `bing-wallpaper-source/` | Plasma/Wallpaper | `com.wenyin.bingwallpapersource` | 项目根 |
| `parachute-plasma6/` | KWin/Script | `Parachute` | 项目根 |

**关键 gotcha**：kde-control-station 的 metadata.json 和 contents/ 都在 `package/` 下，修改/打包/翻译都以此为根；其余三个项目以项目根为根。

## 构建与安装命令

```bash
# kde-control-station：打包 .plasmoid（自动编译翻译），或仅编译翻译
cd kde-control-station && sh ./build.sh [--i18n-only]

# bing-wallpaper-source：仅编译翻译
cd bing-wallpaper-source && bash translate/build.sh

# parachute-plasma6：安装 KWin 脚本
cd parachute-plasma6 && make install

# 本地开发调试：复制后重启 shell 生效
cp -rf kde-control-station/package/* ~/.local/share/plasma/plasmoids/KdeControlStation/
cp -rf launchpad-plasma/* ~/.local/share/plasma/plasmoids/tt.launchpadPlasma/
cp -rf bing-wallpaper-source/* ~/.local/share/plasma/wallpapers/com.wenyin.bingwallpapersource/
plasmashell --replace &
```

launchpad-plasma 没有构建脚本，打包由 CI 直接 zip。`.github/workflows/release.yml` 手动触发时打包全部四个项目，版本号从各项目 `metadata.json` 的 `KPlugin.Version` 读取——改版本需同步改对应目录下的 build.sh / CI 中读取逻辑。

## 翻译系统（gettext）

- Catalog 命名：Applet 用 `plasma_applet_<Id>`，Wallpaper 用 `plasma_wallpaper_<Id>`
- 语言目录名是 `zh_CN` / `zh_TW`（**不是** `zh_Hans` / `zh_Hant`）
- `.po` 位置各项目不同：kde-control-station 在 `package/translate/`，bing 在 `translate/`，launchpad 的 `.po` 与 `.mo` 同目录（`contents/locale/<lang>/LC_MESSAGES/`）
- `.mo` 与 `.plasmoid` 已被 .gitignore 排除，不要提交
- QML 调用：Applet 用 `i18n()` / `i18nc()`；**Wallpaper 必须用 `i18nd("plasma_wallpaper_<Id>", ...)` 显式指定 domain**，因为 wallpaper 运行在 plasmashell 命名空间

## QML 规范（Plasma 6）

- **不使用版本化 import**：`import QtQuick`，不是 `import QtQuick 2.12`
- 根元素：Applet 用 `PlasmoidItem`，Wallpaper 用 `WallpaperItem`，KWin 脚本用 `Window`
- `import QtCore` 合法（Qt6 QML 模块，导出 `QtCore.StandardPaths`）
- 鼠标事件用 `MouseArea`（Plasma 5 的 `MouseEventListener` 已移除）
- KWin 脚本用 `import org.kde.kwin`，API 是 KWin 6 命名：`workspace.windowList()`、`activeWindow`、`client.output`、`client.desktops`、`virtualScreenGeometry`

## 注意事项

- `kde-control-station/CMakeLists.txt` 引用 KF5Plasma，是遗留文件，**实际构建只用 build.sh**
- `kde-control-station/build` 和 `kpac` 是二进制文件，不要修改
- `parachute-plasma6` 的 `metadata.json` 无 `X-Plasma-API-Minimum-Version`（KWin 脚本不需要）
- `.qoder/` 与 `.claude/` 是 AI 工具配置目录，不要提交改动
