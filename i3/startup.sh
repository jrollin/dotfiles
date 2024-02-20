#!/bin/bash

# light
# xbacklight -set 1
brightnessctl set 15%

# background
feh --bg-fill ~/dotfiles/pictures/foundation_landscape.jpg

## DPMS monitor setting (standby -> suspend -> off) (seconds)
xset dpms 300 600 900 

