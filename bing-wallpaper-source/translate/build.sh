#!/bin/bash
# Build .mo translation files for Bing Wallpaper Source
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PACKAGE_DIR="$(dirname "$SCRIPT_DIR")"
CATALOG="plasma_wallpaper_com.wenyin.bingwallpapersource"

for po in "$SCRIPT_DIR"/*.po; do
    [ -f "$po" ] || continue
    lang="$(basename "$po" .po)"
    mo_dir="$PACKAGE_DIR/contents/locale/$lang/LC_MESSAGES"
    mkdir -p "$mo_dir"
    msgfmt -o "$mo_dir/$CATALOG.mo" "$po"
    echo "Built: $lang -> $mo_dir/$CATALOG.mo"
done
