#!/bin/bash
COM="iptables"

# Flush
iptables -F
iptables -X
iptables -T nat -F
iptables -T nat -X
iptables -T mangle -F
iptables -T mangle -X

# Loopback in and out
$COM -A INPUT -i lo -j ACCEPT # loopback
$COM -A OUTPUT -o lo -j ACCEPT # loopback

# input
for p in 22 25 587 143; do
    $COM -A INPUT -p tcp --dport $p -j ACCEPT
    $COM -A OUTPUT -p tcp --sport $p -m state --state REL,EST -j ACCEPT
done

# output
for p in 80 443; do
    $COM -A OUTPUT -p tcp --dport $p -j ACCEPT
    $COM -A INPUT -p tcp --sport $p -m state --state REL,EST -j ACCEPT
done

# DNS
$COM -A INPUT -p udp --sport 53 -j ACCEPT
$COM -A OUTPUT -p udp --dport 53 -j ACCEPT
$COM -A INPUT -j DROP
$COM -A OUTPUT -j DROP

# lockout timer add a command parameter to save changes
if [[ "$1" == "" ]]; then 
	echo Rules will be flushed in 15 seconds...
	(sleep 15 && $COM -F && echo Rules Flushed)&
fi
