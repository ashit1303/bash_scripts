#!/bin/bash


GREEN='\033[0;32m'
RED='\033[0;31m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
echo -e "${BLUE}
__     _____ ____ _____ _   _   _    _     
\ \   / /_ _|  _ \_   _| | | | / \  | |    
 \ \ / / | || |_) || | | | | |/ _ \ | |    
  \ V /  | ||  _ < | | | |_| / ___ \| |___ 
   \_/  |___|_| \_\|_|  \___/_/   \_\_____|
                                           
 _   _  ___  ____ _____ ___ _   _  ____ 
| | | |/ _ \/ ___|_   _|_ _| \ | |/ ___|
| |_| | | | \___ \ | |  | ||  \| | |  _ 
|  _  | |_| |___) || |  | || |\  | |_| |
|_| |_|\___/|____/ |_| |___|_| \_|\____|

"
#root check

function ROOT_CHECK {
if [ "$EUID" -eq 0 ]
then    
		SECS=$((1 * 3))
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
    [ -d /etc/httpd/sites-available ] || mkdir -p /etc/httpd/sites-avaiable/ 
    [ -f /etc/httpd/conf/ports.conf ] || touch /etc/httpd/conf/ports.conf
    SRV_TYPE='httpd'
    VHOST_PATH='/etc/httpd/sites-available/'
    VHOST_PATH_EN='/etc/httpd/conf.d/'
    CONFIG_TEST_SYN='apachectl -t'
    PORTS_CONF='/etc/httpd/conf/ports.conf'
    CONF_PATH='/etc/httpd/conf/httpd.conf'
    DOC_ROOT='/var/www/html/'
    VAR_LOGS='/var/logs/custom_'${SRV_TYPE}'_logs'
elif [ -f /etc/arch-release ] ; then
    [ -d /etc/httpd/sites-available ] || mkdir -p /etc/httpd/sites-avaiable/
    SRV_TYPE='httpd'
    VHOST_PATH='/etc/httpd/sites-available/'
    VHOST_PATH_EN='/etc/httpd/vhosts.d/'
    CONFIG_TEST_SYN=''
    PORT_CONF='/etc/httpd/conf/ports.conf'
    CONF_PATH='/etc/httpd/conf/httpd.conf'
    DOC_ROOT='/srv/http/'
    VAR_LOGS='/var/logs/custom_'${SRV_TYPE}'_logs'
elif [ -f /etc/SuSE-release ] ; then
    SRV_TYPE='apache2'
    VHOST_PATH='/etc/apache2/sites-available/'
    VHOST_PATH_EN='/etc/apache2/vhosts.d/'
    CONFIG_TEST_SYN=''
    DOC_ROOT='/srv/www/htdocs/'
    PORT_CONF='/etc/apache2/ports.conf'
    CONF_PATH='/etc/apache2/httpd.conf'
    VAR_LOGS='/var/logs/custom_'${SRV_TYPE}'_logs'
elif [ -f /etc/debian_version ] ; then
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
    sleep 1
    echo -e "${CYAN}Site ${1} was already enabled!\n";
  elif [ -f "${VHOST_PATH}${1}" ]; then
    echo -e "${PURPLE}Enabling site ${1}...\n";
    sleep 1
    ln -s ${VHOST_PATH}$1 ${VHOST_PATH_EN}$1
    echo -e "${CYAN}<---Done--->"
  else
   echo -e "${RED}Site not found!\n"
  fi
else
  echo -e "${RED}Please enter the name of the site to enable\n."
fi
}

function a2dissite(){

if [ $1 ]; then
  if [ ! -f "${VHOST_PATH_EN}${1}" ]; then
    echo -e "${CYAN}Site ${1} was already disabled!\n";
  elif [ -f "${VHOST_PATH_EN}${1}" ]; then
    echo -e "${PURPLE}Disabling site ${1}...\n";
    unlink ${VHOST_PATH_EN}$1
    echo -e "${CYAN}<---Done--->"
  else
    echo -e "${RED}Site not found!\n"
  fi
else
  echo -e "${RED}Please enter the name of the site to enable\n."
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

function VHOST_ENABLE() {

echo -e "${PURPLE}This feature allows to enable specified virtual host files 
Avoid spaces in inputs"
sleep 1
echo -e "${CYAN}List of available conf\n"
ls  $VHOST_PATH
echo -e "${RED}"
read -p "Enter file name: " EN_FILE
a2ensite ${EN_FILE}
sleep 1

}

function VHOST_DISABLE() {
echo -e "${PURPLE}This feature allows to disable specified virtual host files 
All available virtual host files are \n"
sleep 1 
echo -e "${CYAN}List of enabled conf\n"
ls  $VHOST_PATH_EN
echo -e "${RED}"
read -p "Enter file name: " DIS_FILE
a2dissite ${DIS_FILE}
sleep 1

}



function VHOST_CREATE() {
echo -e "${PURPLE}This feature allows to create a new virtual host files 
${RED}NOTE:- Avoid spaces in inputs "
sleep 1 
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
sleep 1
    if [ "$?" -eq 0 ]
    then 
        echo -e "${CYAN}<--Done-->"
    else 
        echo -e "${RED}Unable to process request"
    fi

}


function DISP_MENU() {
echo -e "${PURPLE}
This Script will help you to create a virtual host file and provide options to enable or disable a particular virtual hosting file
<---VIRTUAL HOSTING OPTIONS--->
1)ENABLE A WEBSITE CONFIG FILE      2)DISABLE A WEBSITE CONFIG FILE
3)CREATE NEW V-HOST FILE            4)PRINT THIS MENU
5)PRINT HELP                        6)EXIT"
}



DISP_MENU
LOOP=0
while [ ${LOOP} = 0 ] ; do
echo -e "${RED}"
read -p "Choose your option (numbers only..!!): " OPT


case $OPT in
1)
    VHOST_ENABLE
    ;;
2)
    VHOST_DISABLE
    ;;
3)
    VHOST_CREATE
    ;;
4)
    DISP_MENU  
    ;;
5)
    HELP_VHOST
    ;;
6)
    echo -e "${BLUE}Developed by Ashit Kumar"        
    SECS=$((1 * 5))
    while [ $SECS -gt 0 ]; do
       echo -ne "Exiting in... $SECS\033[0K\r"
       sleep 1
	   : $((SECS--))
	done
    LOOP=1 #exit
    ;;
*)
    echo "Incorrect option please try again"
    ;;
esac

done

