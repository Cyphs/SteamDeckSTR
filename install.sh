#!/usr/bin/env bash
set -euxo pipefail

mkdir -p ~/.local/share/applications/

mkdir -p ~/.Cyphs
cd ~/.Cyphs
wget -O steam-deck.zip https://github.com/Cyphs/steam-deck/archive/refs/heads/master.zip
unzip -o steam-deck.zip
rm steam-deck.zip

~/.Cyphs/steam-deck-master/post-install.sh

echo "Success! Exiting in 3..."
sleep 3
