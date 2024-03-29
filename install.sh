#!/usr/bin/env bash
set -euxo pipefail

mkdir -p ~/.local/share/applications/

mkdir -p ~/.Cyphs
cd ~/.Cyphs
wget -O SteamDeckSTR.zip https://github.com/Cyphs/SteamDeckSTR/archive/refs/heads/tests.zip
unzip -o SteamDeckSTR.zip
rm SteamDeckSTR.zip

~/.Cyphs/SteamDeckSTR-tests/post-install.sh

echo "Success! Exiting in 3..."
sleep 3
