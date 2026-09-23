#!/usr/bin/env bash
# Sourced by the scripts behind the desktop shortcuts. Everything they print (Steam,
# Proton and download logs included) goes to a log file, and the window only shows
# short step messages from `say`. If something fails, the window stays open and
# shows where the log is.
# Usage: source ~/.Cyphs/SteamDeckSTR-master/vortex/quiet.sh <log name>

SDSTR_LOG="$HOME/.Cyphs/logs/$1.log"
mkdir -p "$(dirname "$SDSTR_LOG")"
exec 3>&1 >"$SDSTR_LOG" 2>&1
echo "$(date): $0"

say() {
    echo "$*" >&3
    echo "== $*"
}

# Keeps the window open so the message can be read
pause_window() {
    read -r -p "Press Enter to close this window..." </dev/tty >&3 2>&1 || sleep 30
}

sdstr_failed() {
    trap - ERR
    {
        echo
        echo "Something went wrong. The details are saved in:"
        echo "$SDSTR_LOG"
        echo "You can attach that file when reporting an issue on GitHub."
    } >&3
    pause_window
}

# Vortex's settings can't be changed while Vortex is open (the change waits forever)
wait_for_vortex_closed() {
    if pgrep -f "[V]ortex\.exe" > /dev/null; then
        say "Vortex is open. Please close Vortex to continue..."
        while pgrep -f "[V]ortex\.exe" > /dev/null; do sleep 2; done
        say "Thanks, continuing..."
    fi
}

set -E
trap sdstr_failed ERR
