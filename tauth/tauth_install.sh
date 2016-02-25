#!/bin/bash
VERSION="1.0"
SSH_CONF=""
EMAIL_User=""
EMAIL_Pass=""
EMAIL_Serv="smtps://smtp.gmail.com:465"
GITHUB_LOCATION="https://raw.githubusercontent.com/micahjmartin/main/master/tauth/"

NOCOLOR='\033[0m'
red() { CRED='\033[0;31m'; echo -e ${CRED}$1${NOCOLOR}; }
blue() { CBLUE='\033[0;34m'; echo -e ${CBLUE}$1${NOCOLOR}; }
green() { CGREEN='\033[0;32m'; echo -e ${CGREEN}$1${NOCOLOR}; }

write_settings() {
if [[ ! -d /etc/tauth ]]; then
	mkdir /etc/tauth
fi
echo "Version "$VERSION > /etc/tauth/tauth_config
echo "EmailUser "$EMAIL_User >> /etc/tauth/tauth_config
echo "EmailPass "$EMAIL_Pass >> /etc/tauth/tauth_config
echo "EmailServer "$EMAIL_Serv >> /etc/tauth/tauth_config
echo "Users "$USERS >> /etc/tauth/tauth_config
}

check_root() {
#check root
if [ $(whoami) != "root" ]; then
	red "restart as root!"
	red "Exiting...."
	exit
fi
}

check_ssh() {
#find SSH config file
if [[ -f /etc/ssh/sshd_config ]]; then
	SSH_CONF="/etc/ssh/sshd_conf"
	green "SSH config file found at "$SSH_CONF
	
else
	red "No SSH config found in /etc/ssh/sshd_conf"
	read -p "Enter location of SSH config file: " loc
	if [[ -f $loc ]]; then
		SSH_CONF=$loc
		green "SSH config file found at "$SSH_CONF
	else
		red "No SSH config found in "$loc
		red "Exiting...."
	fi
fi
}

install_tuath() {
check_ssh()
mkdir /usr/local/tauth
curl $GITHUB_LOCATION/tauth_login.sh >> /usr/local/tauth/tauth-login.sh
curl $GITHUB_LOCATION/tauth_manage.sh >> /usr/local/tauth/tauth-manager.sh
read -p "Enter Gmail address: " EMAIL_User
read -p "Enter Gmail password: " -s EMAIL_User
write_settings()
echo "ForceCommand /usr/local/tauth/tauth-login.sh" >> $SSH_CONF
green "Install Successfull!"
}
check_root()
install_tauth
