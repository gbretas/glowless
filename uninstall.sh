#!/bin/sh
# Removes Glowless and gives the LED back to macOS.
echo system > /Users/Shared/Glowless/mode 2>/dev/null && sleep 3
sudo launchctl bootout system/com.glowless.daemon 2>/dev/null
sudo rm -f /Library/LaunchDaemons/com.glowless.daemon.plist /usr/local/bin/glowlessd
sudo rm -rf /Users/Shared/Glowless
pkill -x Glowless
rm -f ~/Library/LaunchAgents/com.glowless.app.plist
rm -rf /Applications/Glowless.app
echo "Glowless removido."
