#!/bin/bash
code=$(head /dev/urandom | tr -dc 0-9 | head -c5)
sel() {
while true; do
    read -e -p "Choose SMS or EMAIL: " -i "SMS" method
    case $method in
        "EMAIL" | "email" ) 
		info=$(cat /home/$(whoami)/.tauth/tauth_conf | grep Email | awk '{print $2}')
		echo "Authentication Code: "$code > mail.txt
		curl --url "$EMAIL_Serv" --ssl-reqd --mail-from "$EMAIL_User" --mail-rcpt "$info" --upload-file mail.txt --user "$EMAIL_User:$EMAIL_Pass" --insecure
		rm mail.txt
	break;;
        "sms" | "SMS" ) 
		message='message="Authentication: $code"'
		info=$(cat /home/$(whoami)/.tauth/tauth_conf | grep Phone | awk '{print $2}')
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

NOCOLOR='\033[0m'
red() { CRED='\033[0;31m'; echo -e ${CRED}$1${NOCOLOR}; }
blue() { CBLUE='\033[0;34m'; echo -e ${CBLUE}$1${NOCOLOR}; }
green() { CGREEN='\033[0;32m'; echo -e ${CGREEN}$1${NOCOLOR}; }

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

blue "Please verify login with authentication code"
sel

read -e -p "Enter Code: " pass
if [ $pass == $code ]; then
	green "Accepted Code!"
	/bin/bash
	exit
else
	red "Incorrect! Removing from server..."
fi
