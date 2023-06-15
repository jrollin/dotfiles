#!/bin/bash

# light
xbacklight -set 1

# background
feh --bg-fill ~/.config/pictures/city.jpg

## DPMS monitor setting (standby -> suspend -> off) (seconds)
xset dpms 300 600 900 

