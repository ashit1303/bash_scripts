#!/bin/bash

#colors

GREEN='\033[1;32m'
RED='\033[1;31m'
PURPLE='\033[1;35m'
CYAN='\033[1;36m'
BLUE='\033[1;34m'


echo -e "${BLUE}
 _  _____ _     _          _    ____  ____  
| |/ /_ _| |   | |        / \  |  _ \|  _ \ 
| ' / | || |   | |       / _ \ | |_) | |_) |
| . \ | || |___| |___   / ___ \|  __/|  __/ 
|_|\_\___|_____|_____| /_/   \_\_|   |_|                                             
"

#check that user must be root
echo -ne "${PURPLE}Developed by ASHIT KUMAR Report bugs to kmr.ashit1303@gmail.com\n"
function ROOT_CHECK {
if [ "$EUID" -eq 0 ]
then    
	SECS=$((1 * 3))
	while [ $SECS -gt 0 ]; do
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

echo -e "${CYAN}This application allow you to kill application using the network port you want to use. 
This might kill applicaiton which is in use.
${RED}\n<--- USE IT ON YOUR OWN RISK --->\n<--- USE 'ctrl+c' TO EXIT ---> "

function KILL_PORT(){
echo -e "${BLUE}"
read -p "Enter the port you want to check for application:  " PORT_NO
netstat -nlp | grep :${PORT_NO}
if [ "$?" -eq 0 ]
then 
    read -p "Sure to kill listed applications ? { yes | no }:  " REPLY
else 
    echo -e "${RED}No process is running on port ${PORT_NO}\nPlease try again"
    KILL_PORT
fi

if [ $REPLY == "yes" ]
then

PID="$(ss -lptn sport = :${PORT_NO} | grep LISTEN | cut -d "=" -f 2 | cut -d "," -f 1)"
echo -e "${CYAN}Killing ${PID}"
kill -9 $PID && echo -e "${RED}Process killed" ||echo -e "${PURPLE}Failed to kill process"
else
echo -e "${RED}\nAborted"
KILL_PORT
exit 1
fi
return 0
}

KILL_PORT
