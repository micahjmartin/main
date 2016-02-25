#!/bin/bash
VERSION="1.0"
SSH_CONF=""
EMAIL_User=""
EMAIL_Pass=""
EMAIL_Serv="smtps://smtp.gmail.com:465"

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

load_settings() {
if [[ -f /etc/tauth/tauth_config ]]; then
	$EMAIL_User=$(cat /home/$(whoami)/.tauth/tauth_conf | grep EmailUser | awk '{print $2}')
	$EMAIL_Pass=$(cat /home/$(whoami)/.tauth/tauth_conf | grep EmailPass | awk '{print $2}')
	$EMAIL_Serv=$(cat /home/$(whoami)/.tauth/tauth_conf | grep EmailServer | awk '{print $2}')
	$USERS=$(cat /home/$(whoami)/.tauth/tauth_conf | grep Users | awk '{print $2}')
	green "Configuration file loaded"
else
	red "No configuration file found! Restart Program!"
	exit
fi
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
mkdir /usr/local/tauth
curl https://raw.githubusercontent.com/micahjmartin/main/master/tauth/tauth_login.sh >> /usr/local/tauth/tauth-login.sh
curl https://raw.githubusercontent.com/micahjmartin/main/master/tauth/tauth_manage.sh >> /usr/local/tauth/tauth-manager.sh
read -p "Enter Gmail address: " EMAIL_User
read -p "Enter Gmail password: " -s EMAIL_User
write_settings()
echo "ForceCommand /usr/local/tauth/tauth-login.sh" >> $SSH_CONF
green "Install Successfull!"
}

add_user() {
if [[ ! -f /home/$1/.tauth ]]; then
	mkdir /home/$1/.tauth
fi
if [[ -f /home/$1/.tauth/user_conf ]]; then
	chattr -i /home/$1/.tauth/user_conf
	rm /home/$1/.tauth/user_conf
fi

read -p "Enter user's SMS number: " num
read -p "Enter user's Email: " em
echo "Phone "$num > /home/$1/.tauth/user_conf
echo "Email "$em >> /home/$1/.tauth/user_conf
chattr +i /home/$1/.tauth/user_conf
green $1" added to tauth!"
}

remove_user() {
if [[ -f /home/$1/.tauth/user_conf ]]; then
	chattr -i /home/$1/.tauth/user_conf
	rm /home/$1/.tauth/user_conf
fi
if [[ -f /home/$1/.tauth ]]; then
	rm /home/$1/.tauth
fi
}

#curl http://textbelt.com/text -d number=7172625000 -d "message=hello from Micah"

init
