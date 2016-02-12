#! /bin/bash

print_logo()
{
clear
printf "\n\n
			        __  _______      __
			       / / / / __/ | /| / /
			      / /_/ / _/ | |/ |/ /
			      \____/_/   |__/|__/
\n\n	A loose collection of commands to create a basic UFW setup\n\n			   	Micah Martin 2016"
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
	{
	echo y | ufw reset
	} >/dev/null
	print_options=$print_options"[Firewall Flushed]\n"
}

defaults()
{
echo [Setting Defaults....]
{
ufw enable
ufw default deny incoming
ufw default deny outgoing
print_options=$print_options"[Default Policies Set]\n"
allow_dns
} >/dev/null


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
ufw allow out 53/tcp
ufw allow out 53/udp
ufw allow in 53/tcp
ufw allow in 53/udp
}


#allow(ports,out/in,protocol)
allow()
{
#split string into array by ','
IFS=',' read -r -a ports <<< "$1"

#check if out or in
if [ "$2" = "out" ]; then
	egress="out"
else
	egress="in"
fi
#check tcp or udp
if [ "$3" = "udp" ]; then
	pro="udp"
else
	pro="tcp"
fi
#loop through array and set rules
for i in "${ports[@]}"; do
	ufw allow $egress $i/$pro &>/dev/null
done
#print allowed rules
print_options=$print_options"[$pro ports $1 allowed $egress]\n"
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
allow  $ports
read -e -p "Enter Output Ports to Allow: " -i "80,443" ports
allow  $ports "out"
#end_append
#print_rules
#save_rules
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
