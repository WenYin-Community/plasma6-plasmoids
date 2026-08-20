// 共享工具：主界面与配置页共用的路径与转义逻辑
function resolveArchiveDir() {
    var pictures = StandardPaths.standardLocations(StandardPaths.PicturesLocation);
    var dir = pictures.length > 0
        ? pictures[0].toString()
        : StandardPaths.standardLocations(StandardPaths.HomeLocation)[0].toString() + "/Pictures";
    if (dir.startsWith("file://")) {
        dir = dir.substring(7);
    }
    return dir + "/bing-wallpaper-source";
}

function shellQuote(raw) {
    var s = (raw || "").toString();
    return "'" + s.split("'").join("'\\''") + "'";
}
