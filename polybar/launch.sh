#!/usr/bin/env bash

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

echo "---" | tee -a /tmp/polybar1.log 

MACHINE=`uname -n`

if [ "$MACHINE" = "julien-xps13" ]; then
    polybar mine --config=~/.config/polybar/config_mine.ini 2>&1 | tee -a /tmp/polybar1.log & disown
    polybar DP2 --config=~/.config/polybar/config_mine.ini 2>&1 | tee -a /tmp/polybar2.log & disown
else
    polybar mine --config=~/.config/polybar/config_pro.ini 2>&1 | tee -a /tmp/polybar1.log & disown
    polybar DP2 --config=~/.config/polybar/config_pro.ini 2>&1 | tee -a /tmp/polybar2.log & disown
fi


echo "Bar launched!"

