#!/bin/bash

#colors

GREEN='\033[1;32m'
RED='\033[1;31m'
PURPLE='\033[1;35m'
CYAN='\033[1;36m'
BLUE='\033[1;34m'

echo -e "${BLUE}"
echo -e "
  _// //  _////////_///////    _//         _//_////////_///////      _// //  
_//    _//_//      _//    _//   _//       _// _//      _//    _//  _//    _//
 _//      _//      _//    _//    _//     _//  _//      _//    _//   _//      
   _//    _//////  _/ _//         _//   _//   _//////  _/ _//         _//    
      _// _//      _//  _//        _// _//    _//      _//  _//          _// 
_//    _//_//      _//    _//       _////     _//      _//    _//  _//    _//
  _// //  _////////_//      _//      _//      _////////_//      _//  _// //  
"

#check that user must be root

function ROOT_CHECK {
if [ "$EUID" -eq 0 ]
then    
		SECS=$((1 * 5))
		while [ $SECS -gt 0 ]; do
		   echo -ne "${RED}Checking dependency... $SECS\033[0K\r"
		   sleep 1
		   : $((SECS--))
		done
else
echo -e "${RED}You don't have root permissions\n"
	exit 1
fi
}

ROOT_CHECK

function SRV_TYPE_DETECT(){

if [ -f /etc/redhat-release ] ; then
    [ -d /etc/httpd/sites-available ] || mkdir -p /etc/httpd/sites-avaiable 
    [ -f /etc/httpd/conf/ports.conf ] || touch /etc/httpd/conf/ports.conf
    DIST_DET="$(cat /etc/redhat-release)"
    SRV_TYPE='httpd'
    VHOST_PATH='/etc/httpd/sites-available/'
    VHOST_PATH_EN='/etc/httpd/conf.d/'
    CONFIG_TEST_SYN='apachectl -t'
    PORTS_CONF='/etc/httpd/conf/ports.conf'
    CONF_PATH='/etc/httpd/conf/httpd.conf'
    DOC_ROOT='/var/www/html/'
    VAR_LOGS='/var/logs/custom_'${SRV_TYPE}'_logs'
elif [ -f /etc/arch-release ] ; then
    [ -d /etc/httpd/sites-available ] || mkdir -p /etc/httpd/sites-avaiable
    DIST_DET="$(cat /etc/arch-release)"
    SRV_TYPE='httpd'
    VHOST_PATH='/etc/httpd/sites-available/'
    VHOST_PATH_EN='/etc/httpd/vhosts.d/'
    CONFIG_TEST_SYN='apachectl configtest'
    PORT_CONF='/etc/httpd/conf/ports.conf'
    CONF_PATH='/etc/httpd/conf/httpd.conf'
    DOC_ROOT='/srv/http/'
    VAR_LOGS='/var/logs/custom_'${SRV_TYPE}'_logs'
elif [ -f /etc/SuSE-release ] ; then
    [ -d /etc/apache2/sites-available ] || mkdir -p /etc/httpd/sites-avaiable
    DIST_DET="$(cat /etc/SuSE-release)"
    SRV_TYPE='apache2'
    VHOST_PATH='/etc/apache2/sites-available/'
    VHOST_PATH_EN='/etc/apache2/vhost.d/'
    CONFIG_TEST_SYN='apachectl configtest'
    DOC_ROOT='/srv/www/htdocs/'
    PORT_CONF='/etc/apache2/ports.conf'
    CONF_PATH='/etc/apache2/httpd.conf'
    VAR_LOGS='/var/logs/custom_'${SRV_TYPE}'_logs'
elif [ -f /etc/debian_version ] ; then
    DIST_DET="$(cat /etc/lsb-release)"
    SRV_TYPE='apache2'
    VHOST_PATH='/etc/apache2/sites-available/'
    VHOST_PATH_EN='/etc/apache2/sites-enabled/'
    CONFIG_TEST_SYN='apache2ctl -t'
    PORT_CONF='/etc/apache2/ports.conf'
    CONF_PATH='/etc/apache2/apache2.conf'
    DOC_ROOT='/var/www/html/'
    VAR_LOGS='/var/logs/custom_'${SRV_TYPE}'_logs'
fi
}
#Detecting server types and inserting variable accordingly
SRV_TYPE_DETECT


#a2ensite and a2dissite function created to load and remove website config
function a2ensite(){
if [ $1 ]; then
  if [ -f "${VHOST_PATH_EN}${1}" ]; then
    sleep 0.3s
    echo -e "${BLUE}\nSite ${1} was already enabled!\n";
  elif [ -f "${VHOST_PATH}${1}" ]; then
    echo -e "${PURPLE}\nEnabling site ${1}...\n";
    sleep 0.3s
    ln -s ${VHOST_PATH}$1 ${VHOST_PATH_EN}$1
    echo -e "${CYAN}<---Done--->"
    sleep 0.5s
  else
   echo -e "${RED}\nSite not found!\n"
    sleep 0.5s
  fi
else
  echo -e "${RED}\nPlease enter the name of the site to enable\n"
    sleep 0.5s
fi
}

function a2dissite(){

if [ $1 ]; then
  if [ ! -f "${VHOST_PATH_EN}${1}" ]; then
    echo -e "${BLUE}\nSite ${1} was already disabled!\n";
  elif [ -f "${VHOST_PATH_EN}${1}" ]; then
    echo -e "${PURPLE}\nDisabling site ${1}...\n";
    unlink ${VHOST_PATH_EN}$1
    sleep 0.5s
    echo -e "${CYAN}<---Done--->"
  else
    sleep 0.5s
    echo -e "${RED}\nSite not found!\n"
  fi
else
  sleep 0.5s
  echo -e "${RED}\nPlease enter the name of the site to enable\n"
fi
}



#Help for noobs to understand what and how this config file work
function HELP_VHOST(){
echo -e "${BLUE}"
echo -e "VIRTUAL HOST CREATING GUIDE

Virtual Hosting is method of hosting multiple websites on single web server,
There are two type of Virtual Hosting in web server, Name based and IP based.
looks like

<----FILE STARTED---->

<VirtualHost *:80>
ServerAdmin webmaster@dummy-host.example.com
DocumentRoot ${DOC_ROOT}dummy-host.example.com
ServerName example2.com
ServerAlias www.example2.com
ErrorLog logs/dummy-host.example.com-error_log
CustomLog logs/dummy-host.example.com-access_log common

</VirtualHost>
<----VIRTUAL HOST FILE STARTED---->

EXPLANATION:
<VirtualHost *:80>   – This ensures the Virtual Host listening on the port 80, change this to listen on other port.
ServerAdmin          – Mail Id of the Server administrator.
ServerAlias          – Defines names that should match like base name. This is useful for matching hosts you defined, like www
DocumentRoot         – Location of the web documents.
ServerName           – Domain name of the Virtual Host (like www.example.com).
ErrorLog             – Error Log location of  the particular virtual host.
CustomLog            – Log location of the particular virtual host.
</VirtualHost>       – End of virtual host container.


Name Based Virtual Host:


Name based virtual host uses domain name requested by the client to identify the correct virtual host to serve, you need to setup the DNS server to map each hostname to the corresponding IP address and then configure the Apache Server to recognize hostname. Before hosting multiple domains, you need to setup the default virtual host. Default virtual host will serve the pages to client, who’s requested domain yet to be configured or not configured on the server (due to the wrong pointing by the DNS server). Configure the DNS server to setup the Name based virtual hosting.

<----VIRTUAL HOST FILE STARTED---->

NameVirtualHost www.example1.com
<VirtualHost www.example1.com:80>
ServerAdmin root@example1.com
ServerName example1.com
ServerAlias www.example1.com
DocumentRoot ${DOC_ROOT}example1
ErrorLog logs/example1-error_log
CustomLog logs/example1-access_log common
</VirtualHost>



<VirtualHost www.example2.com:80>
ServerAdmin root@example2.com
ServerName example2.com
ServerAlias www.example2.com
DocumentRoot ${DOC_ROOT}example2
m
ErrorLog logs/example2.com-error_log
CustomLog logs/example2.com-access_log common
</VirtualHost>

<----VIRTUAL HOST FILE ENDED---->



If the client requests www.example1.com or www.example2.com from web server, client will receive the home page receptively. If the client requests other than www.example1.com and www.example2.com, client will receive the home page of the default virtual host ie. www.example1.com. Name based virtual require either DNS server or host entries to verify the configuration.

IP Based Virtual Host:

IP based virtual host uses ip address requested by the client to identify the correct virtual host to serve, there fore you need to have separate ip address for each virtual host. Use ip address instead of host name in the

<----VIRTUAL HOST FILE STARTED---->

<VirtualHost 192.168.0.1:80>
    ServerAdmin root@example1.com
    ServerName example1.com
    ServerAlias www.example1.com
    DocumentRoot ${DOC_ROOT}example1
    ErrorLog logs/example1-error_log
    CustomLog logs/example1-access_log common
</VirtualHost>

<VirtualHost 192.168.0.2:80>
    ServerAdmin root@example2.com
    DocumentRoot ${DOC_ROOT}example2
    ServerName example2.com
    ServerAlias www.example2.com
    ErrorLog logs/example2.com-error_log
    CustomLog logs/example2.com-access_log common
</VirtualHost>

<----VIRTUAL HOST FILE ENDED---->


From the above you can see that each virtual host configured with diffident ip address, you need to have multiple network card’s installed on the server. Name based virtual host is most widely used on the internet servers to serve the web content.\n" | less
}

#functions for performing actions listed in menu
function SRV_STATUS() {
    echo -e "${PURPLE}\nServer status (Press 'q' to exit):\n${GREEN}"
    sleep 0.3s
    systemctl status $SRV_TYPE 
    if [ "$?" -eq 0 ]
    then 
        echo -e "${CYAN}\n<---- Server is RUNNING ---->\n"
    else 
        echo -e "${RED}\n<---- Server is NOT RUNNING ---->"
    fi
}

function SRV_START() {
    echo -e "${PURPLE}Starting server\n"
    sleep 0.3s
    systemctl start $SRV_TYPE
    systemctl status $SRV_TYPE > /dev/null
    if [ "$?" -eq 0 ]
    then 
        echo -e "${CYAN}<---- Server is UP & RUNNING ---->"
    else 
        echo -e "${RED}ERROR occurred please check check server status for error info"
  fi

}

function SRV_STOP() {
    echo -ne "${PURPLE}Stoping Server\n"
    sleep 0.3s
    systemctl stop $SRV_TYPE
    systemctl status $SRV_TYPE > /dev/null
    if [ "$?" -eq 0 ]
    then 
        echo -e "${CYAN}<--- Error ---->"
    else 
        echo -e "${RED}\n<--- Server is DOWN ---->"
    fi

}

function SRV_RESTART()  {
    echo -ne "${PURPLE}Restarting server\n"
    systemctl restart $SRV_TYPE 
    systemctl status $SRV_TYPE > /dev/null
    if [ "$?" -eq 0 ]
    then 
        echo -e "${CYAN}<--- Server restarted ---->"
    else 
        echo -e "${RED}ERROR occurred please check check server status for error info"
    fi

}

function SRV_RELOAD() {
    echo -ne "${PURPLE}Reloading server${RED}\n"
    sleep 0.3s
    systemctl reload $SRV_TYPE 
    systemctl status $SRV_TYPE > /dev/null
    if [ "$?" -eq 0 ]
    then 
        echo -e "${CYAN}<--DONE-->"
    fi

}

function VHOST_ENABLE() {
echo -e "${PURPLE}This feature allows to enable specified virtual host files"
sleep 0.3s
echo -e "${CYAN}List of available configuration files\n"
ls  -1 $VHOST_PATH
echo -e "${RED}"
read -p "Enter exact file name without spaces: " EN_FILE
a2ensite ${EN_FILE}
}

function VHOST_DISABLE() {
echo -e "${PURPLE}This feature allows to disable specified virtual host files"
sleep 0.3s 
echo -e "${CYAN}List of enabled conf\n"
ls  -1 $VHOST_PATH_EN
echo -e "${RED}"
read -p "Enter exact file name without spaces: " DIS_FILE
a2dissite ${DIS_FILE}
}

function VHOST_CREATE() {
echo -e "${PURPLE}This feature allows to create a new virtual host files 
${RED}NOTE:- Avoid spaces in inputs ${GREEN}"
sleep 0.3s 
read -p "Enter virtual host file name (no spaces in file names): " VHOST_FILE
read -p "Enter domain name (eg website.com | gle.in): " DOMAIN_NAME
read -p "Enter Email id of admin server administrator(eg webmaster@example.com): " SRV_ADMIN
read -p "Enter website address (like www.example.com): " WEB_ADDR
read -p "Enter port on which it should listen: " PORT_LISTEN
read -p "Enter name of your domain or your host ip : " IP_ASSIGN
[  -zIP_ASSIGN ]  || IP_ASSIGN='*' 
echo -e "
<VirtualHost ${IP_ASSIGN}:${PORT_LISTEN}>
    DocumentRoot ${DOC_ROOT}${VHOST_FILE}
    ServerName ${DOMAIN_NAME}
    ServerAlias ${WEB_ADDR}
    ServerAdmin ${SRV_ADMIN} 
    
    ErrorLog ${VAR_LOGS}/${VHOST_FILE}error.log
    CustomLog ${VAR_LOGS}/${VHOST_FILE}requests.log combined 

<Directory ${DOC_ROOT}${VHOST_FILE}>
    Options FollowSymLinks MultiViews
    AllowOverride All  
    Order allow,deny 
    Allow from all
    Require all granted
</Directory>

</VirtualHost>" > ${VHOST_PATH}${VHOST_FILE}.conf
echo -e "${RED}"
[ -d ${DOC_ROOT}${VHOST_FILE} ] && echo -e "Folder ${DOC_ROOT}${VHOST_FILE} already available" || mkdir -p ${DOC_ROOT}${VHOST_FILE} && echo -e "Folder ${DOC_ROOT}${VHOST_FILE} created"
chmod -R 755 ${DOC_ROOT}${VHOST_FILE}
chown -R ${USER}:${USER} ${DOC_ROOT}${VHOST_FILE}
sleep 0.3s
    if [ "$?" -eq 0 ]
    then 
        echo -e "${CYAN}<--Done-->"
    else 
        echo -e "${RED}Unable to process request"
    fi

}





function SRV_BOOT_START() {

    echo -ne "${RED}Processing...\n"
   sleep 0.3s
   systemctl enable $SRV_TYPE
    if [ "$?" -eq 0 ]
    then 
        sleep 0.3s
        echo -e "${CYAN}<-- DONE -->" 
    else 
        sleep 0.3s
        echo -e "${RED}Unable to process request"
    fi

}

function SRV_BOOT_OFF() {

    echo -ne "${RED}Processing...\n"
   sleep 0.3s
   systemctl disable $SRV_TYPE
    if [ "$?" -eq 0 ]
    then 
        sleep 0.3s
        echo -e "${CYAN}<-- DONE -->"
    else 
        sleep 0.3s
        echo -e "${RED}Unable to process request"
        
    fi

}

function FIREWALL_LIST() {

    echo -ne "${BLUE}Showing Firewall Rules\n"
   sleep 0.3s
    
    iptables -L 
    if [ "$?" -eq 0 ]
    then 
        echo -e "${CYAN}<-- IPTABLES SETTINGS -->"
    else 
        echo "${RED}Unable to process request"
    fi

}

function FIREWALL_RESET() {

    echo -ne "${BLUE} "
   sleep 0.3s
    iptables --flush
    if [ "$?" -eq 0 ]
    then 
        echo -e "${CYAN}<-- DONE -->"
    else 
        echo "${RED}Unable to process request"
    fi

}

function FIREWALL_LISTEN_80() {

    echo -ne "${BLUE} "
   sleep 0.3s
   iptables -I INPUT -p tcp --dport 80 -j ACCEPT 
    if [ "$?" -eq 0 ]
    then 
        echo -e "${CYAN}<-- DONE -->"
    else 
        echo "${RED}Unable to process request"
    fi

}

function FIREWALL_LISTEN_443() {

    echo -ne "${BLUE} "
   sleep 0.3s
   iptables -I INPUT -p tcp --dport 443 -j ACCEPT 
    if [ "$?" -eq 0 ]
    then 
        echo -e "${CYAN}<-- DONE -->"
    else 
        echo "${RED}Unable to process request"
    fi

}



function CONFIRM_INSTALL(){
    if [[ "$?" -eq 0 ]]        
    then
      echo -e "${GREEN}\n<----Apache server installed successfully---->\n"          
    else
      echo -e "${RED}\n<----Unable to install Apache Server---->\n"
      exit 2
    fi
}




#dependency check if not install packages 

if [[ -f /etc/apache2/apache2.conf || -f /etc/httpd/conf/httpd.conf || -f /etc/apach2/httpd.conf ]]
then 
#installed
    echo -e "${PURPLE}Required packages are already installed skipping installation process\n"

else
#installing
    echo -e "${BLUE}Installing dependency packages"
	sleep 0.3s
    if [ -f /etc/redhat-release ] ; then
        yum install -y httpd 
        CONFIRM_INSTALL
    elif [ -f /etc/arch-release ] ; then	    
        pacman -S apache
        CONFIRM_INSTALL
    elif [[ -f /etc/SuSE-release || -f /etc/sles-release ]] ; then
        zypper install httpd
        CONFIRM_INSTALL
    elif [ -f /etc/debian_version ] ; then
	    apt-get install -y apache2
        CONFIRM_INSTALL
    fi
fi    
#displaying linux version
DIST_DET1="$(cat /proc/version)"
sleep 0.3s
echo -e "${CYAN}Your linux distribution details\n\n${DIST_DET}\n\n${DIST_DET1}\n"
sleep 0.4s

function DISP_MENU() {
echo -e "${RED}You can do following things
        0)EXIT    100) PRINT THIS MENU
<---SERVER OPTIONS--->
1)SHOW STATUS        2)START           3)STOP 
4)RESTART            5)RELOAD          

<---VIRTUAL HOSTING OPTIONS--->
6)ENABLE A WEBSITE CONFIG FILE      7)DISABLE A WEBSITE CONFIG FILE
8)CREATE NEW V-HOST FILE            9)PRINT HELP FOR VIRTUAL HOSTING

<---AUTO-START SERVER ON BOOT--->
10)ENABLE             11)DISABLE 

<---FIREWALL OPTIONS (ONLY IPTABLES SUPPORTED)--->
12)CHECK FIREWALL STATUS            13)RESET FIREWALL SETTINGS
14)ENABLE FIREWALL ON PORT 80       15)ENABLE FIREWALL ON PORT 443

Choose {1-15}           
"
}
#Displaying menu

DISP_MENU
LOOP=0
while [ ${LOOP} = 0 ] ; do
echo -e "${GREEN}"
read -p "Choose your option (numbers only..!!)  :" OPT


case $OPT in

0)
echo -e "${CYAN}DEVELOPED BY ASHIT KUMAR \nReport bugs to kmr.ashit1303@gmail.com\n"
    
        SECS=$((1 * 3))
		while [ $SECS -gt 0 ]; do
		   echo -ne "Exiting in... $SECS\033[0K\r"
		   sleep 1
		   : $((SECS--))
		done
    LOOP=1 #exit
    ;;

1)
    SRV_STATUS
    ;;
2)
    SRV_START
    ;;
3)
    SRV_STOP
    ;;
4)
    SRV_RESTART
    ;;
5)
    SRV_RELOAD
    ;;
6)
    VHOST_ENABLE
    ;;
7)
    VHOST_DISABLE
    ;;
8)
    VHOST_CREATE
    ;;
9)
    HELP_VHOST
    ;;
10) 
    SRV_BOOT_START
    ;;
11)
    SRV_BOOT_OFF
    ;;
12)
    FIREWALL_LIST
    ;;
13)
    FIREWALL_RESET
    ;;
14)
    FIREWALL_LISTEN_80
    ;;
15)
    FIREWALL_LISTEN_443
    ;;
100)
    DISP_MENU
    ;;
*)
    echo -e "${BLUE}Incorrect option please try again"
    ;;
esac
done
