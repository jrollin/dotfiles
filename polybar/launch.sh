#!/usr/bin/env bash

# Terminate already running bar instances
killall -q polybar
sleep 1

echo "---" | tee -a /tmp/polybar1.log 
polybar mine --config=~/.config/polybar/config.ini 2>&1 | tee -a /tmp/polybar1.log & disown

polybar DP2 --config=~/.config/polybar/config.ini 2>&1 | tee -a /tmp/polybar1.log & disown



echo "Bar launched!"

