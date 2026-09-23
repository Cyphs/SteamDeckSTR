#!/usr/bin/env bash
set -euo pipefail

echo "Downloading SteamDeckSTR..."

mkdir -p ~/.local/share/applications/

mkdir -p ~/.Cyphs
cd ~/.Cyphs
wget -q -O SteamDeckSTR.zip https://github.com/Cyphs/SteamDeckSTR/archive/refs/heads/master.zip
unzip -q -o SteamDeckSTR.zip
rm SteamDeckSTR.zip

~/.Cyphs/SteamDeckSTR-master/post-install.sh
