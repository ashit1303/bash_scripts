#!/bin/bash

#colors

GREEN='\033[0;32m'
RED='\033[0;31m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'

echo -e "${BLUE}
 _  _____ _     _          _    ____  ____  
| |/ /_ _| |   | |        / \  |  _ \|  _ \ 
| ' / | || |   | |       / _ \ | |_) | |_) |
| . \ | || |___| |___   / ___ \|  __/|  __/ 
|_|\_\___|_____|_____| /_/   \_\_|   |_|                                             
"

#check that user must be root

function ROOT_CHECK {

if [ "$EUID" -eq 0 ]
then    
	SECS=$((1 * 5))
	while [ $SECS -gt 0 ]; do
       echo -ne "${PURPLE}Developed by ASH"
       echo -ne "${RED}Starting Application... $SECS\033[0K\r"
       
	   sleep 1
	   : $((SECS--))
	done
else
echo -e "${RED}You don't have root permissions"
	exit 1
fi
}

ROOT_CHECK

function KILL_PORT(){
echo -e "${CYAN}This application allow you to kill application using the network port you want to use. 
This might kill applicaiton which is in use.
${RED}USE IT ON YOUR OWN RISK"
read -p "Enter the port you want to check for application:  " PORT_NO
sudo netstat -nlp | grep :${PORT_NO}

read -p "Sure to kill listed applications ? { yes | no }:  " REPLY

if [ $REPLY == "yes" ]
then

PID="$(ss -lptn sport = :${PORT_NO} | grep LISTEN | cut -d "=" -f 2 | cut -d "," -f 1)"
echo -e "${CYAN}Killing ${PID}"
kill -9 $PID && echo -e "${RED}Process killed" ||echo -e "${PURPLE}Failed to kill process"
else
echo -e "${RED}Aborted"
exit 0
fi
return 0
}

KILL_PORT















 
