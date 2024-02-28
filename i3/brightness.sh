#!/bin/bash

if [ -z "$1" ]
  then
    echo "No argument up/down supplied"
fi

VOL=$1


# light
if ! command -v xbacklight &> /dev/null; then
    if [[ "$VOL" = "up" ]]; then
        brightnessctl set 2%+
    else
        brightnessctl set 2%-
    fi
else
    if [[ "$VOL" =  "up" ]]; then
        xbacklight -inc 1
    else
        xbacklight -dec 1
    fi
fi


