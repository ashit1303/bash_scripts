#!/bin/bash

#check that user must be root

function ROOT_CHECK {
if [ "$EUID" -eq 0 ]
then
    LOOP=0
    MIN=" battery"
    while [ ${LOOP} = 0 ] ; do
    VAL=$(sudo tlp stat | grep power\ source | cut -d'=' -f2 | cut -d'[' -f1)
    if [ "$VAL" == "$MIN" ] ; then
        audacious --play /etc/apt/low_battery.mp3 -H -q
    fi
    sleep 4m
    done
else
	exit 1
fi
}
ROOT_CHECK



