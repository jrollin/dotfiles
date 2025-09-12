#!/bin/bash

# light
if ! command -v xbacklight &> /dev/null; then
    #command does not exist
    brightnessctl set 15%
else
    #command exists
    xbacklight -set 1
fi


# background
$HOME/dotfiles/i3/bg.sh

## DPMS monitor setting (standby -> suspend -> off) (seconds)
xset dpms 300 600 900 

