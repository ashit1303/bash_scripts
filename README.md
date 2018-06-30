# bash_scripts
Scripts for running lots of different works
#To run files 

1)Download

2)Make it a executable file with 
    
    chmod +x file_name_here

3)Run with following command (<--- sudo permissions needed to execute some commands --->)
    
    ./file_name_here
    
that's it 
ENJOY

1)TO RUN server_fast.sh 
    
    chmod +x server_fast.sh
    ./server_fast.sh

AUTOMATED APACHE SERVER
Execute apache2 server commands faster with just enter few numbers
--> A list is available to { start | stop | reload | restart | and checking server status} of apache server.

--> Enable or Disable a website configuration with choosing numbers.

--> Beyond that you can create a website configuration file without hassle and just copy your files to apache website root directory folder and get running website quickly (Also a small help section to learn how it works).

--> Manage firewall to listen on port 80(http) and https(443) and even reset and check firewall status (NOTE:- ONLY IPTABLES SUPPORTED install it on your linuxbox to use this feature.)
--> Finally a settings to Enable or Disable running apache web server on boot.

Supported to most of the linux distos  (REDHAT/CENTOS DEBIAN/UBUNTU ARCH and OpenSuSE)
Report any bugs to kmr.ashit1303@gmail.com
Open to feedbacks and further feature requests

2)TO RUN kill_app_port.sh 
    
    chmod +x kill_app_port.sh
    ./kill_app_port.sh

KILL APPLICATION USING SPECIFIED PORT
Run and enter the port no you want to know which application is using it
enter "yes" to kill that application.

3)TO RUN virtual_hosting.sh

    chmod +x virtual_hosting.sh
    ./virtual_hosting.sh 
Complete automated Create virtual host configuration file for apache servers and automated
    
    a2ensite 
    a2dissite
    
Create virtual hosting files for apache configuration without hassle 
just enter details and it will create file in default folder
Enable and Disable website options are also avaiable 
(ie a2ensite and a2dissite)
It will also create document root folder in default folder

Supported to most of the linux distos  (REDHAT/CENTOS DEBIAN/UBUNTU ARCH and OpenSuSE)
Report any bugs to kmr.ashit1303@gmail.com
still under development

