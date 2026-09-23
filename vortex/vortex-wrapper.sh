#!/usr/bin/env bash
source ~/.Cyphs/SteamDeckSTR-master/vortex/versions.sh

export WINEPREFIX="$HOME/.vortex-linux/compatdata/pfx"

if [ -f "$VORTEX_DIR/Vortex.exe" ]; then
    cd "$VORTEX_DIR" || exit 1
else
    cd "$OLD_VORTEX_DIR" || exit 1
fi

# Check for -d or -i with no "nxm" in the following argument
if [[ ("$1" == "-d" || "$1" == "-i") && "$2" != *"nxm"* ]]; then
    exec "$UMU_DIR/umu-run" Vortex.exe
else
    export PROTON_VERB="runinprefix"
    exec "$UMU_DIR/umu-run" Vortex.exe "$@"
fi
