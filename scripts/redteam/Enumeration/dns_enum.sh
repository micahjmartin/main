#!/bin/bash
#
# Author: Micah Martin (knif3)
# Description: Enumerates DNS names on a network. Listing IP addresses and DNS
# names. Currently only works on /24 networks
#
# USAGE: ./dnsenum ip [outfile]

clearup() {
	printf "\033[$1A"
	for i in `seq $1`; do
		echo -e "\033[K"
	done
	printf "\033[$1A"
}

cprint() {
	if [[ "$2" == "" ]]; then
		clearup 1
	else
		clearup $2
	fi
	echo -e $1
}

#check arguments
if [[ "$1" == "" ]]; then
	echo "USAGE: dnsenum [ip]"
	exit
fi
if [[ "$2" != "" ]]; then
	printf "" > $2
fi

#create variables
timeout=1
ip=$1
ip=( $(echo $ip | tr "." "\n") )
count=0

#start scanning
echo Scanning... >&2
echo ""
for i in `seq 254`; do
	addr=$(echo ${ip[0]}.${ip[1]}.${ip[2]}.$i) #create the address to lookup
	cprint "Scanning $addr\n$count found  %$(( ($i*100)/254 )) complete..." 2
	res=$(nslookup -timeout=$timeout $addr | grep -i name | awk '{print $4}')
	if [[ $res != "" ]]; then
		if [[ "$2" != "" ]]; then
			echo "$addr $res" >> $2
		else
			cprint "$addr $res\n" 2
			echo ""
		fi
		count=$(( $count + 1 ))
	fi
done


clearup 2
