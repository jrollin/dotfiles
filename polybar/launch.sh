#!/usr/bin/env bash

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

echo "---" | tee -a /tmp/polybar1.log 
polybar mine --config=~/.config/polybar/config.ini 2>&1 | tee -a /tmp/polybar1.log & disown

polybar DP2 --config=~/.config/polybar/config.ini 2>&1 | tee -a /tmp/polybar2.log & disown



echo "Bar launched!"

