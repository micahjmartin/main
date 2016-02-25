#!/bin/bash
sel() {
while true; do
    read -e -p "Choose SMS or EMAIL: " -i "SMS" method
    case $method in
        "EMAIL" | "email" ) 
		info=$(cat /home/$(whoami)/.tauth/tauth_conf | grep Email | awk '{print $2}')
		break;;
        "sms" | "SMS" ) 
		info=$(cat /home/$(whoami)/.tauth/tauth_conf | grep Phone | awk '{print $2}')
		break;;
        * ) echo "Please choose SMS or EMAIL";;
    esac
done
}

NOCOLOR='\033[0m'
red() { CRED='\033[0;31m'; echo -e ${CRED}$1${NOCOLOR}; }
blue() { CBLUE='\033[0;34m'; echo -e ${CBLUE}$1${NOCOLOR}; }
green() { CGREEN='\033[0;32m'; echo -e ${CGREEN}$1${NOCOLOR}; }

blue "Please verify login with SMS code"
read -p "Press enter to send SMS"



code=$(head /dev/urandom | tr -dc 0-9 | head -c5)
info=$(cat /home/$(whoami)/.tauth/tauth_conf | grep Phone | awk '{print $2}')
message='message="Authentication: $code"'
sent=$(curl -s http://textbelt.com/text -d number=$info -d $message)
success=$(echo $sent | cut -d" " -f3)

if [ $success == "true" ]; then 
	green "Code sent! Please wait up to 1 minute for code to arrive..."
else
	red "Sending code failed!! I hope you have backup"
	exit
fi

read -e -p "Enter Code: " pass
if [ $pass == $code ]; then
	green "Accepted Code!"
	/bin/bash
	exit
else
	red "Incorrect! Removing from server..."
fi
