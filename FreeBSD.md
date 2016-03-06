# FreeBSD
## Five minute plan.
Assuming you are configuring a mail server
--------------

#### 1. Basic starting points
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

Audit your users with `/etc/passwd`, `grep -v /nologin`. find users you do not want and lock them

	$ pw lock [user]

NOTE: Users 'root' and 'toor' should stay there by default!






#### PKG and installs

Consider installing pkg by running `pkg` (remember to turn your interface back on first). I noticed a bug where `pkg` would linger, try stopping the command and pinging the outside world then restart the install.

Re-install critical services to check for updates.

	$ pkg install dovecot
	$ pkg install postfix
	
Disable the network interface again `ifconfig [em0] down`

