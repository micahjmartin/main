# Windows Web Backdoor
Run `tiny.exe` in a folder that has a file called "index.html" and youre all set. 

    $ TINY.EXE C:\

Fun to mess with.

While reading some stuff about the small webserver, I discovered that if you create a folder called `cgi-bin` you can run any native script on the victim. So I created a backdoor to allow RCE over the web. Simply call the file with a question mark and put the command after that. Parsing allows for quotes and spaces in the commands.

    10.80.100.43?ipconfig /all

Here is an (almost) useless web backdoor.
