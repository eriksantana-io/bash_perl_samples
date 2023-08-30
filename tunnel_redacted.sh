#!/bin/bash

### Welcome to the tunneling script. This simple script performs ssh tunnel connections for clients with enabled firewalls. 
### Hope this makes connectivity a little easier --Erik

### Variable declaration

RANDOM=`date '+%s'`
random_port1=`echo "111"$[($RANDOM % 60) + 1]`
random_port2=`echo "222"$[($RANDOM % 60) + 1]`
Ver='3.1'

### Client SSH tunnel connections

FW1()
{
clear
echo -e "Connecting to FW1 device:\n"
echo -e "\nConnect to: http://localhost:$random_port1\n"
echo -e "Please enter sudo password twice:"
ssh -o -t -L $random_port1:localhost:$random_port2 server2 sudo ssh -L $random_port2:127.0.0.1:80 server1
}

################## Menu Function ##################

badchoice="Invalid selection...ending script. Thank you."

menu()
{}
clear
echo -e "\t\t`date`"
echo
echo -e "\t\t====================$Ver====================="
echo -e "\t\t*                                                                        *"
echo -e "\t\t*\t\tConnect to:                                              *"
echo -e "\t\t*                                                                        *"
echo -e "\t\t*\t\t\t A. FW1
echo -e "\t\t*\t\t\t ===================================             *"
echo -e "\t\t*\t\t\t X. Exit                                         *"
echo -e "\t\t*                                                                        *"
echo -e "\t\t=========================================================================="
echo -e "\n\t\tPlease enter your letter selection:\n"
}


clear
menu
read -n1 selection
case $selection in
a|A)
FW1
;;
*)
echo -e "\n\n$badchoice"
sleep 2
;;
esac
