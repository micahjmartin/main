# Mirai

Quick and dirty nmap to start
```
nmap -T4 -F -sV 10.10.10.48 -oN inital.txt
```

Ports open:
```
22 - OpenSSH 6.71p1 - Not vulnerable
53 - dnsmasq 2.76 - Not vulnerable
80 - lighttpd 1.4.35 - No vulns
```

Navigate to site, no content. Gonna DirBuster

DirBuster found `/admin/index.php` appears to be running something called pihole

Try to ssh in as rpi default creds

```
ssh pi@10.10.10.48
# password raspberry
```

Works.
user.txt is missing
Mentions a flashdrive. Find device in `dev/sdb`. Try to mount but it is already
mounted in `/media/usbstick`. File tells us the file got deleted. Try to recover
with fsck.

Much easier, just run strings on it

Got Root.

Go back and find user.txt on the Pi/ Located in Desktop folder.

Got user.
