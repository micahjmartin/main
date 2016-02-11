#! /bin/bash

print_logo()
{
clear
printf "\n\n\n		 __  ____  ____  __   ____  __    ____  ____\n		(  )(  _ \(_  _)/ _\ (  _ \(  )  (  __)/ ___)\n		 )(  ) __/  )( /    \ ) _ (/ (_/\ ) _) \___ \ \n		(__)(__)   (__)\_/\_/(____/\____/(____)(____/\n\n\n	A loose collection of commands to create a basic IPTABLES setup\n\n			   	Micah Martin 2015"
echo
echo
}

useless_select()
{
while true; do
    read -p "Do you wish to continue? [Y/n] " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
}

flush_all()
{
	echo [Flushing Tables.....]
	iptables -F
	print_options=$print_options"[Tables Flushed]\n"
	if [ "$1" = "-c" ]; then
		echo [Flushing Chains.....]
		iptables -X
		print_options=$print_options"[Chains Flushed]\n"
	fi
	iptables -F -t nat
}

defaults()
{
echo [Setting Defaults....]

# Default Policies
iptables -P INPUT ACCEPT
iptables -P FORWARD DROP
iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
print_options=$print_options"[Defaults Policies Set]\n"
#Allow Loopback in/out
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT
print_options=$print_options"[Allow Loopback]\n"

#Allow established in/out
iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
print_options=$print_options"[Allow Established]\n"
#Limit pings

allow_ping
#Allow DNS out/in
allow_dns
print_options=$print_options"[Defaults Set]\n"
}

allow_ping()
{
iptables -A INPUT -p icmp --icmp-type 0 -j ACCEPT
iptables -A OUTPUT -p icmp --icmp-type 8 -j ACCEPT
print_options=$print_options"[ICMP Enabled]\n"
}
allow_dns()
{
print_options=$print_options"[DNS Enabled]\n"
iptables -A INPUT -p tcp --sport 53 -j ACCEPT
iptables -A INPUT -p udp --sport 53 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 53 -j ACCEPT
iptables -A OUTPUT -p udp --dport 53 -j ACCEPT
}


#allow(ports,chain,sport/dport)
allow()
{

if [ "$2" = "" ]; then
	allow_chain="INPUT"
else
	allow_chain=$(echo $2 | tr '[:lower:]' '[:upper:]')
fi
if [ "$3" = "" ]; then
	port_target="dport"
else
	port_target=$(echo $3 | tr '[:upper:]' '[:lower:]')
fi
if [ "$1" = "any" ] || [ "$1" = "all" ]; then
	iptables -A $allow_chain -j ACCEPT
	print_options=$print_options"[All $allow_chain ports allowed]\n"
else
	echo $1 | tr "," "\n" | xargs -n1 iptables -A $allow_chain -j ACCEPT -p tcp --$port_target
	print_options=$print_options"[$allow_chain ports $1 allowed]\n"
fi
}

save_rules()
{
if [ "$1" = "" ]; then
	out="iptables_rules.txt"
else
	out="$1"
fi
iptables-save > $out
print_options=$print_options"[Rules Saved to \"$out\"]\n"

}

deny()
{
if [ "$2" = "" ]; then
	deny_chain="INPUT"
else
	deny_chain=$(echo $2 | tr '[:lower:]' '[:upper:]')
fi
if [ "$3" = "" ]; then
	port_target="dport"
else
	port_target=$(echo $3 | tr '[:upper:]' '[:lower:]')
fi
echo $1 | tr "," "\n" | xargs -n1 iptables -A $allow_chain -j DROP -p tcp --$port_target
}

end_append()
{
iptables -A INPUT -j DROP
iptables -A OUTPUT -j DROP
}

print_rules()
{
clear
print_logo
echo
echo [Current Rules]
iptables-save | grep - | grep -v "#"
echo ""
}

main()
{
print_options=""
print_logo
flush_all -c
defaults
read -e -p "Enter Input Ports to Allow: " -i "22,80" ports
allow  $ports "INPUT" "dport"
read -e -p "Enter Output Ports to Allow: " -i "80,443" ports
allow  $ports "OUTPUT" "dport"
end_append
#print_rules
save_rules
echo -e "$print_options"
}

flags_set()
{
inports=$1
outports=$2
flush_all -c
defaults
allow  $inports "INPUT" "dport"
allow  $outports "OUTPUT" "dport"
end_append
save_rules
echo -e "$print_options"
}

if [ "$1" = "" ]; then
	main
else
	flags_set $1 $2
fi
