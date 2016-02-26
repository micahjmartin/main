#!/bin/bash
TAUTH_CONF="/etc/tauth/tauth_config"
TAUTH_ROOT="/usr/local/tauth"

code=$(head /dev/urandom | tr -dc 0-9 | head -c5)


NOCOLOR='\033[0m'
red() { CRED='\033[0;31m'; echo -e ${CRED}$1${NOCOLOR}; }
blue() { CBLUE='\033[0;34m'; echo -e ${CBLUE}$1${NOCOLOR}; }
green() { CGREEN='\033[0;32m'; echo -e ${CGREEN}$1${NOCOLOR}; }


sel() {
while true; do
    read -e -p "Choose SMS or EMAIL: " -i "SMS" method
    case $method in
        "EMAIL" | "email" ) 
		
		echo "Authentication Code: "$code > mail.txt
		curl --url "$EMAIL_Serv" --ssl-reqd --mail-from "$EMAIL_User" --mail-rcpt "$info" --upload-file mail.txt --user "$EMAIL_User:$EMAIL_Pass" --insecure
		rm mail.txt
	break;;
        "sms" | "SMS" ) 
		message='message="Authentication: $code"'
		sent=$(curl -s http://textbelt.com/text -d number=$info -d $message)
		success=$(echo $sent | cut -d" " -f3)

		if [ $success == "true" ]; then 
			green "Code sent! Please wait up to 1 minute for code to arrive..."
		else
			red "Sending code failed!! Restart to try Email"
			exit
		fi

		break;;
        * ) echo "Please choose SMS or EMAIL";;
    esac
done
}

load_settings() {
if [[ -f /etc/tauth/tauth_config ]]; then
	$EMAIL_User=$(cat $TAUTH_CONF | grep EmailUser | awk '{print $2}')
	$EMAIL_Pass=$(cat $TAUTH_CONF | grep EmailPass | awk '{print $2}')
	$EMAIL_Serv=$(cat $TAUTH_CONF | grep EmailServer | awk '{print $2}')
	$USERS=$(cat $TAUTH_CONF | grep Users | awk '{print $2}')
	green "Configuration file loaded"
else
	red "No configuration file found! Restart Program!"
	exit
fi
}

main_login() {
read -e -p "Enter Code: " pass
if [ $pass == $code ]; then
	green "Accepted Code!"
	/bin/bash
	blue "Thank you for using t-auth"
	exit
else
	red "Incorrect! Removing from server..."
fi
}

load_user() {
#check if the user has tauth files
#if not, directly login
USER=$(whoami)
USER_CONF="/home/$USER/.tauth/user_config"
USER_DIR="/home/$USER/.tauth"
if [[ -f $USER_CONF ]]; then
	EMAIL=$(cat $USER_CONF | grep Email | awk '{print $2}')
	PHONE=$(cat $USER_CONF | grep Phone | awk '{print $2}')
else
	tauth_login $code
fi
}

tauth_login() {
if [ $1 == $code ]; then
	/bin/bash
	blue "Thank you for using t-auth"	
	exit
fi
}

load_settings
load_user
blue "Please login with tauth"
#Select message version and send code
sel
#read users input
main_login

