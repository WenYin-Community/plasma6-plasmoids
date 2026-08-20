# Plasma 6 小部件集合

[English](README.md) | [中文](README_zh.md)

KDE Plasma 6 小部件（plasmoids）集合。

## 项目列表

### 1. KDE 控制中心

KDE Plasma 6 现代化控制中心小部件。

**功能特性：**
- 5 种布局变体（默认、控制中心、扁平、Tahoe、自定义）
- 电池、网络、蓝牙、音量、亮度小部件
- 会话操作（挂起、重启、关机、休眠、锁定、注销）
- 深色/浅色模式，支持全局主题切换
- 夜灯控制、配色方案切换
- 媒体播放器，支持专辑封面
- 自定义命令按钮
- 支持 11 种语言

**依赖项：**
- KDE Plasma ≥ 6.0
- 软件包：`plasma-nm`、`kdeplasma-addons`、`plasma-pa`

**安装方法：**

```bash
git clone https://github.com/WenYin-Community/plasma6-plasmoids.git
cd plasma6-plasmoids/kde-control-station
sh ./build
```

通过系统设置 → 外观 → 小部件 → 从本地文件安装。

### 2. Launchpad Plasma

KDE Plasma 6 可配置的应用程序启动器网格。

**功能特性：**
- 应用程序启动器网格
- 可自定义布局
- 底部收藏应用栏，同步现有 KDE Application Menu 收藏应用
- 独立的电源/会话系统操作按钮

**安装方法：**

使用本地 `.plasmoid` 安装包：

```bash
kpackagetool6 -i tt.launchpadPlasma-v1.31.plasmoid
```

开发调试时，可将 `launchpad-plasma/` 复制到 `~/.local/share/plasma/plasmoids/tt.launchpadPlasma/`，然后重启 Plasma Shell。

### 3. 必应壁纸

KDE Plasma 6 Bing 每日壁纸插件，支持历史壁纸浏览。

**功能特性：**
- 完全独立从 Bing API 获取每日壁纸（无任何官方壁纸插件依赖）
- 每日首次启动时下载一次，跨天自动刷新
- 历史壁纸自动归档至 `~/Pictures/bing-wallpaper-source/`，仅保留最近 30 张
- 配置页点击历史缩略图或右键菜单即时切换壁纸
- 动态天气效果（下雪/下雨），可在设置中配置
- 可配置壁纸定位方式（裁剪、拉伸、适应、居中、平铺）
- 支持中文和英文本地化

**安装方法：**

开发调试时，可将 `bing-wallpaper-source/` 复制到 `~/.local/share/plasma/wallpapers/com.wenyin.bingwallpapersource/`，然后重启 Plasma Shell。

### 4. Parachute

KWin 脚本，从俯视视角展示窗口与桌面，已迁移至 Plasma 6（KWin 6）API。

**功能特性：**
- 全屏展示所有屏幕上的窗口与桌面总览
- 拖拽窗口到其他桌面或屏幕
- 窗口搜索

**安装方法：**

```bash
cd parachute-plasma6
make install   # kpackagetool6 --type KWin/Script --install .
```

卸载使用 `make uninstall`（kpackagetool6 --type KWin/Script --remove Parachute）。

## 许可证

- kde-control-station：[GPLv3](https://www.gnu.org/licenses/gpl-3.0.en.html)
- launchpad-plasma：[GPL-2.0+](https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html)
- bing-wallpaper-source：[GPL-3.0-or-later](https://www.gnu.org/licenses/gpl-3.0.en.html)
- parachute-plasma6：[GPL-3.0-or-later](https://www.gnu.org/licenses/gpl-3.0.en.html)
