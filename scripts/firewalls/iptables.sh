#! /bin/bash

print_logo()
{
clear
printf "\n\n\n		 __  ____  ____  __   ____  __    ____  ____\n		(  )(  _ \(_  _)/ _\ (  _ \(  )  (  __)/ ___)\n		 )(  ) __/  )( /    \ ) _ (/ (_/\ ) _) \___ \ \n		(__)(__)   (__)\_/\_/(____/\____/(____)(____/\n\n\n	A loose collection of commands to create a basic IPTABLES setup\n\n			   	knif3 2015"
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
#allow_dns
print_options=$print_options"[Defaults Set]\n"
}

allow_ping()
{
read -r -p "Allow ICMP (Reply in/Request out)? [y/N] " yn
case $yn in
    [yY][eE][sS]|[yY]) 
        iptables -A INPUT -p icmp --icmp-type 0 -j ACCEPT
	iptables -A OUTPUT -p icmp --icmp-type 8 -j ACCEPT
	print_options=$print_options"[ICMP Enabled]\n"
        ;;
    *)
        print_options=$print_options"[ICMP Disabled]\n"
        ;;
esac
}
allow_dns()
{
read -r -p "Allow DNS in? [y/N] " yn
case $yn in
    [yY][eE][sS]|[yY]) 
        print_options=$print_options"[DNS in Enabled]\n"
	iptables -A INPUT -p tcp --sport 53 -j ACCEPT
	iptables -A INPUT -p udp --sport 53 -j ACCEPT
        ;;
    *)
        print_options=$print_options"[DNS in Disabled]\n"
        ;;
esac
read -r -p "Allow DNS out? [y/N] " yn
case $yn in
    [yY][eE][sS]|[yY]) 
        print_options=$print_options"[DNS out Enabled]\n"
	iptables -A OUTPUT -p tcp --dport 53 -j ACCEPT
	iptables -A OUTPUT -p udp --dport 53 -j ACCEPT
        ;;
    *)
        print_options=$print_options"[DNS out Disabled]\n"
        ;;
esac
}


#allow(ports,chain,sport/dport,tcp/udp)
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
if [ "$4" = "" ]; then
	proto="TCP"
else
	proto=$(echo $4 | tr '[:lower:]' '[:upper:]')
fi
if [ "$1" = "any" ] || [ "$1" = "all" ]; then
	iptables -A $allow_chain -j ACCEPT
	print_options=$print_options"[All $proto $allow_chain ports allowed]\n"
else
	echo $1 | tr "," "\n" | xargs -n1 iptables -A $allow_chain -j ACCEPT -p $proto --$port_target
	print_options=$print_options"[$proto $allow_chain ports $1 allowed]\n"
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
#inbound tcp
read -e -p "Enter incoming TCP ports to allow: " -i "22" ports
if [ "$ports" = "none" ] || [ "$ports" = "" ]; then
	print_options=$print_options"[No TCP INPUT ports allowed]\n"
else
	allow  $ports "INPUT" "dport" "TCP"
fi
#inbound udp
read -e -p "Enter incoming UDP ports to allow: " -i "none" ports
if [ "$ports" = "none" ] || [ "$ports" = "" ]; then
	print_options=$print_options"[No UDP INPUT ports allowed]\n"
else
	allow  $ports "INPUT" "dport" "UDP"
fi
#outbound tcp
read -e -p "Enter outgoing TCP ports to allow: " -i "80,443,53" ports
if [ "$ports" = "none" ] || [ "$ports" = "" ]; then
	print_options=$print_options"[No TCP OUTPUT ports allowed]\n"
else
	allow  $ports "OUTPUT" "dport" "TCP"
fi
#outbound udp
read -e -p "Enter outgoing UDP ports to allow: " -i "53" ports
if [ "$ports" = "none" ] || [ "$ports" = "" ]; then
	print_options=$print_options"[No UDP OUTPUT ports allowed]\n"
else
	allow  $ports "OUTPUT" "dport" "UDP"
fi
end_append
#print_rules
save_rules
clear
print_logo
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