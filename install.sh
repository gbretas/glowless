#!/bin/sh
# Builds and installs Glowless: root daemon (launchd) + menu bar app that starts at login.
set -e
cd "$(dirname "$0")"

make
sudo -v

sudo mkdir -p /Users/Shared/Glowless
[ -f /Users/Shared/Glowless/mode ] || echo off | sudo tee /Users/Shared/Glowless/mode >/dev/null
sudo chmod 666 /Users/Shared/Glowless/mode

sudo mkdir -p /usr/local/bin
sudo install -m 755 build/glowlessd /usr/local/bin/glowlessd
sudo install -m 644 daemon/com.glowless.daemon.plist /Library/LaunchDaemons/
sudo launchctl bootout system/com.glowless.daemon 2>/dev/null || true
sudo launchctl bootstrap system /Library/LaunchDaemons/com.glowless.daemon.plist

pkill -x Glowless || true
rm -rf /Applications/Glowless.app
cp -R build/Glowless.app /Applications/
mkdir -p ~/Library/LaunchAgents
cp app/com.glowless.app.plist ~/Library/LaunchAgents/
open /Applications/Glowless.app

echo "Pronto. Glowless está na barra de menu e no Spotlight (⌘ + espaço → Glowless)."
