#!/bin/sh
# Builds and installs the daemon (root, launchd) and the menu bar app.
set -e
cd "$(dirname "$0")"

make
sudo -v

sudo mkdir -p /Users/Shared/MagSafeLED
[ -f /Users/Shared/MagSafeLED/mode ] || echo off | sudo tee /Users/Shared/MagSafeLED/mode >/dev/null
sudo chmod 666 /Users/Shared/MagSafeLED/mode

sudo mkdir -p /usr/local/bin
sudo install -m 755 build/magsafeledd /usr/local/bin/magsafeledd
sudo install -m 644 daemon/com.magsafeled.daemon.plist /Library/LaunchDaemons/
sudo launchctl bootout system/com.magsafeled.daemon 2>/dev/null || true
sudo launchctl bootstrap system /Library/LaunchDaemons/com.magsafeled.daemon.plist

rm -rf /Applications/MagSafeLED.app
cp -R build/MagSafeLED.app /Applications/
open /Applications/MagSafeLED.app

echo "Pronto. Ícone de raio na barra de menu."
