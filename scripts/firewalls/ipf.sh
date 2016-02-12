#! /bin/sh

interface_d=$(ifconfig | head -n1 | awk '{print $1}')
echo "Enter network interface (press enter for default): [$interface_d]"
read interface
if $interface = ""; then
	interface=$interface_d
fi
ip=$(ifconfig $interface | head -n2 | tail -n 1 | awk '{print $2}' | cut -d':' -f2)
echo $interface $ip
