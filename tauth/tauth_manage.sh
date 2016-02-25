#!/bin/bash

SSH_CONF=""
RED='\033[0;31m'
NOCOLOR='\033[0m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
init () {
#check root
if [ $(whoami) != "root" ]; then
	echo -e ${RED}"Restart as root!"
	echo "Exiting...."
	exit
fi
#find SSH config file
SSH_CONF=$(find /etc -name "sshd_config")
if [[ -f /etc/ssh/sshd_config ]]; then
	SSH_CONF="/etc/ssh/sshd_conf"
	echo -e ${GREEN}"SSH config file found at "$SSH_CONF
	
else

echo -e ${GREEN}"SSH config file found at "$SSH_CONF
	echo -e ${RED}"No SSH config found in /etc/ssh/sshd_conf"
	echo "Exiting...."
	exit
fi
}

fc_add() {
echo -e "\nForceCommand $1 login" #>> ${SSHD_CONFIG}
      echo ""

#curl http://textbelt.com/text -d number=7172625000 -d "message=hello from Micah"

init
