#!/bin/bash
#
# Scan a /24 ip range. Need to add CIDR still
# USAGE: ./sweep.sh 10.0.0.0
# Micah Martin - knif3

if [ "$1" == "" ]; then
	echo "[!] Please enter a network ip address" 1>&2
	exit 1
fi
ip=$(echo $1 | cut -d'.' -f1,2,3)
echo "[*] Checking DNS" 1>&2
dns=0
nslookup -timeout=1 8.8.8.8 &>/dev/null
if [ "$?" == "1" ]; then
	dns=1
	echo "[!] DNS failed" 1>&2
fi
echo "[+] Starting Scan" 1>&2
for i in `seq 1 254`; do
	{
	x=$(ping $ip.$i -c 1 -W 1 | grep 'bytes f' \
	| tr ':' ' ' | cut -d' ' -f4)
	if [ "$x" != "" ]; then
		if [ "$dns" == "0" ]; then
			name=$(nslookup -timeout=1 $x | grep "name =" | awk '{print $4}')
			printf "$x  \t$name\n"
		else
			echo "$x"
		fi
	fi
	} &
done
sleep 5
echo "[+] Finished" 1>&2

