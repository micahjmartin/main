![](https://www.freebsd.org/logo/logo-full.png)
# FreeBSD
A five minute plan.

#### Basic starting points
Run a quick `ifconfig` to get a list of interfaces. Make sure one is networked. /*if not check out 1a.*/
Select the interface connected and flick it off. If you need to, now is a good time to change the name before turning it off. `ifconfig [em0] name [eth0]`

	$ ifconfig [em0] down

The timer starts. DO NOT KEEP THE NIC OFF FOR MORE THEN 5 MINUTES

Now lets change the password. Its important to do this after the interface is down so any attackers cannot harvest credentials.

	$ passwd
	
check if your SSH is running, if so, disable it.

	$ service sshd status
	$ service sshd stop
	
If you plan on never having SSH running, it might be a good idea to move `/etc/ssh/sshd_config` so that it cannot be run. The edit `/etc/rc.conf` and remove sshd from startup.

	$ vi /etc/rc.conf

#### Users
Audit your users with `/etc/passwd`, `grep -v /nologin`. find users you do not want and lock them

	$ pw lock [user]

NOTE: Users 'root' and 'toor' should stay there by default!

Now lets make sure no users can `su root`
	$ vi /etc/pam.d/su

Find the line that has `no_warn group=` modify the user groups to `wheel root` or just `root`
Next you should remove all the users from wheel that you dont want to have access. There is two commands for this.
First you can remove the user from the group in `/etc/group`
	
	$ vi /etc/group
	
or

	$ pw usermod [user] -g wheel

Finally, remove tasks from your crontab

	$ crontab -e


#### Firewalls

Firstly, you must enable the pf firewall in `/etc/rc.conf`. This allows the firewall to run on boot and to load the logs from a file.

	$ pf_enable="YES"
	$ pf_rules="/etc/pf.conf" *#Check if you can change the name of this file*
	$ pflog_enable="YES"
	$ pflog_logfile="/var/log/pflog"

Load the kernal module for pf

	$ kldload pf

Load the service onetime
Create the file `/etc/pf.conf` and start adding some rules

	$ vi /etc/pf.conf
	~ iports = "{ 110 995 }"
	~ oports = "{ 25 465 }"

`$iports` is the ports to allow in seperated by spaces and `$oports` is the ports to allow out
Now you should send the ports to the pf
NOTE: You must allow loopback and ICMP
	
	~ #Block all ports to start
	~ block all
	~ pass in quick on lo0 all
	~ pass out quick on lo0 all
	~ pass in quick proto icmp all
	~ pass out quick proto icmp all
	~ #Now allow in and out ports
	~ pass in proto tcp to port $iports
	~ pass out proto tcp to port $iports

Start the pf firewall for the current sesison, or reboot to restart your box.

	$ service pf onestart
	$ service pf onestatus

#### Put the box online
It's good to get in the habit of changing your passwords before you re-enable the interface.

	$ passwd
	
Now you should check your firewalls, check the first command and if the fails use the second

	$ service pf status
	$ service pf onestatus
	
Check `netstat` or `sockstack` for listening connections

	$ netstat -a | grep LIS
	$ sockstat -4 #IPV4 Only
	
Adjust your firewall accordingly.
Now allow the box internet acces.

	$ ifconfig [em0] up

You should now be done! Good luck


## Bonus information
#### PKG and installs

Consider installing pkg by running `pkg` (remember to turn your interface back on first). I noticed a bug where `pkg` would linger, try stopping the command and pinging the outside world then restart the install.

Re-install critical services to check for updates.

	$ pkg install dovecot
	$ pkg install postfix
	
Disable the network interface again `ifconfig [em0] down`

#### Monitoring Processes 

The ps command is very versitile, for basic usage use the command below

	$ ps -au
	
to kill processes use one of these commands

	$ kill [PID]
	$ killall [COMMAND NAMEcoomand]
	
### - Micah Martin
