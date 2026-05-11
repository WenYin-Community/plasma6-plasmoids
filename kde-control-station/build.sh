#!/bin/bash
# KDE Control Station Build Script
# Version: 2.8.0

packageDir="package"
i18nDir="package/translate"
version="2.8.0"
plasmaMinVer="6.0"
filenameTag="plasma${plasmaMinVer//./-}"
outputFile="KdeControlStation-v${version}-${filenameTag}.plasmoid"

function printHelp() {
    echo "KDE Control Station Build Script"
    echo ""
    echo "Usage:"
    echo "  sh ./build                Build .plasmoid package"
    echo "  sh ./build --i18n-only    Compile translations only"
    echo "  sh ./build --help         Show this help"
}

function buildI18n() {
    echo "[i18n] Compiling translations..."
    
    # Get plugin ID from metadata.json
    pluginId=$(grep -o '"Id": *"[^"]*"' "$packageDir/metadata.json" | cut -d'"' -f4)
    pluginId="KdeControlStation"
    
    # Compile .po files to .mo
    for poFile in "$i18nDir"/*.po; do
        if [ -f "$poFile" ]; then
            locale=$(basename "$poFile" .po)
            moDir="$packageDir/contents/locale/$locale/LC_MESSAGES"
            moFile="$moDir/plasma_applet_${pluginId}.mo"
            
            mkdir -p "$moDir"
            msgfmt -o "$moFile" "$poFile" 2>/dev/null
            
            if [ $? -eq 0 ]; then
                echo "[i18n]   $locale -> OK"
            else
                echo "[i18n]   $locale -> FAILED"
            fi
        fi
    done
    
    echo "[i18n] Done."
}

function buildPackage() {
    echo "[build] Building $outputFile..."
    
    # First compile translations
    buildI18n
    
    # Create .plasmoid package (zip format)
    cd "$packageDir" && zip -r "../$outputFile" . -x "*.po" -x "*.pot" -x "translate/ReadMe.md" && cd ..
    
    if [ $? -eq 0 ]; then
        echo "[build] Success: $outputFile"
        echo "[build] Size: $(du -h "$outputFile" | cut -f1)"
    else
        echo "[build] FAILED"
        exit 1
    fi
}

# Parse arguments
showHelp=false
i18nOnly=false

for arg in "$@"; do
    case "$arg" in
        --i18n-only) i18nOnly=true;;
        -h|--help) showHelp=true;;
        *) ;;
    esac
done

# Execute
if $showHelp; then
    printHelp
elif $i18nOnly; then
    buildI18n
else
    buildPackage
fi
