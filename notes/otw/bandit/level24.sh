for i in `seq 0 9999`; do
printf "jc1udXuA1tiHqjIsL8yaapX5XIAI6i0n %04d\n" $i | nc localhost 30002
done
