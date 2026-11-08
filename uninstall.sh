#!/bin/sh
# Removes everything and gives the LED back to macOS.
sudo launchctl bootout system/com.magsafeled.daemon 2>/dev/null
sudo rm -f /Library/LaunchDaemons/com.magsafeled.daemon.plist /usr/local/bin/magsafeledd
sudo rm -rf /Users/Shared/MagSafeLED
pkill -x MagSafeLED
rm -rf /Applications/MagSafeLED.app
echo "Removido. A luz volta ao normal ao reconectar o cabo."
