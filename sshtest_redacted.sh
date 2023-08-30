#!/bin/bash

#*********************************************************************************
#                          Test SSH connectivity to servers                      *
#                          ---------------------------------------------------   *
#   author(s)              : Erik Santana                                        *
#                                                                                *
#*********************************************************************************

clear

#==================================================================
# Function that tests SSH conectivity to sy server(s)
#==================================================================

function SSH_test() {

         local user="user_test"
         local timeout="5"
         local server=$1

         echo -e "\nTesting connectivity to $server...\n"

         ssh_test_result=$(ssh -o "BatchMode=yes" -o "ConnectTimeout $timeout" $user@$server 2>&1 | grep -v denied | grep -v key | grep -v connecting | grep -v authenticity)

         if [ -z "$ssh_test_result" ]; then
            echo -e "Successful connectivity to $server.\n"
            return 0
         else
            echo -e "Failed connectivity to $server.\n"
            return 1
         fi
}

#==================================================================
# Test SSH connectivity to default server
#==================================================================

default_server='1' #Change this variable to the default 

SSH_test $default_server

ssh_test_result="$?"

#==================================================================
# Test connection to other s if connection to default fails
#==================================================================

if [ $ssh_test_result = '0' ];then
     echo -e "\nConnectivity to default sy server, $default_server is functional...\n"
     exit 0
else
     echo -e "\nFailed connection to default  server: $default_server, checking connectivity to other s...\n"
     #/usr/bin/logger -p local0.alert -t "Failed connection to default  server: $default_server, checking connectivity to other s..."
     
     for server in 4 3 2;do #Change these  servers from least to most desired connectivity
         sleep 5
         SSH_test $server
         result="$?"
         if [ $result = '0' ];then
            new_server="$server"
         fi   
     done
     if [ -z "$new_server" ];then
        echo -e "\nConnectivity tests to all sy servers failed, maintaining default configuration...\n"
        #/usr/bin/logger -p local0.alert -t "Connectivity tests to all sy servers failed, maintaining default configuration..."
        exit 0
     fi 
fi

#==================================================================
# Change  configuration file
#==================================================================

# Start new with new configuration file

if [ "$new_server" = 1 ];then
   echo -e "\nUsing new configuration file for 1\n"
   conf_file="ng1.conf"
   #/usr/sbin/ng -f /etc/ng/ng1.conf
   #/usr/bin/logger -p local0.alert -t "Using new configuration file for 1"
else
   if [ "$new_server" = 2 ];then
      echo -e "\nUsing new configuration file for 2\n"
      conf_file="ng2.conf"
      #/usr/sbin/ng -f /etc/ng/ng2.conf
      #/usr/bin/logger -p local0.alert -t "Using new configuration file for 2"
   else
      if [ "$new_server" = 3 ];then
         echo -e "\nUsing new configuration file for 3\n"
         conf_file="ng3.conf"
         #/usr/sbin/ng -f /etc/ng/ng3.conf
         #/usr/bin/logger -p local0.alert -t "Using new configuration file for 3"
      else
         if [ "$new_server" = 4 ];then
            echo -e "\nUsing new configuration file for 4\n"
            conf_file="ng4.conf"
            #/usr/sbin/ng -f /etc/ng/ng4.conf
            #/usr/bin/logger -p local0.alert -t "Using new configuration file for 4"
         fi
      fi
   fi
fi

#==================================================================
# Verify new process is running
#==================================================================

PID=$(ps aux | grep new | awk '{print $2}')
current_conf_file=$(ps aux | grep new | cut -d"/" -f6)

if [ "$current_conf_file" == "$conf_file" ];then
   echo -e "ng sucessfuly started on process: $PID/n"
   #/usr/bin/logger -p local0.alert -t "ng sucessfuly started on process: $PID"
else
   echo -e "ng not running or did not restart correctly, restarting process.../n"
   #/usr/bin/logger -p local0.alert -t "ng not running or did not restart correctly, restarting process..."
   #/etc/init.d/ng restart
fi

exit 0
