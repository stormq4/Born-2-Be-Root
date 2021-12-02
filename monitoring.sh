#!/bin/bash

#echo "        MONITORING SCRIPT"

#architecure and Kernal Version
var=$(uname -a)
#echo "    #Architecure:" "$var"

#Physical CPU's
#echo "    #CPU physical:" $(lscpu | grep -a "^CPU(s):" | awk '{print $2}')

#nr of Virtual CPU's
threads=$(lscpu | grep -a "Thread(s) per core:" | awk '{print $4}')
sockets=$(lscpu | grep -a "Socket(s):" | head -1 | awk '{print $2}')
core=$(lscpu | grep -a "Core(s) per socket:" | awk '{print $4}')
vCPU=$((threads * sockets * core))
#echo "    #vCPU: $vCPU"

#Current available RAM
total=$(free -m | grep -a "Mem:" | awk '{print $2}')
used=$(free -m | grep -a "Mem:" | awk '{print $3}')
frac=$(echo "scale=2;100*$used/$total" | bc)
#echo "    #Memory usage: $used/$total MB" " ($frac%)"

#Current utilization rate
usedD=$(df / -m | head -2 | tail -1 | awk '{print $3}')
avail=$(df / -m | head -2 | tail -1 | awk '{print $4}')
total2=$((usedD + avail))
usep=$(echo "scale=2;100*$usedD/$total2" | bc)
#echo "    #Disk usage: $used/$available MB ($usep)"

#CPU Load
idle=$(mpstat | head -4 | tail -1 | awk '{print $13}' | bc)
load=$(echo "scale=2;100-$idle" | bc)
#echo "    #CPU Load: $load%"

#Date and time of last reboot
reboot=$(who -b | grep -a "boot" | awk '{print $3}')
rtime=$(who -b | grep -a "boot" | awk '{print $4}')
#echo "    #Last reboot: $reboot $rtime"

#LVM activity
check=$(lsblk | awk '{print $6}' | grep -a "lvm" | wc -l )
if [ $check -ge 1 ]
then
    check2=$(echo "Yes")
else
    check2=$(echo "No")
fi

#nr of Active Connections
TCPa=$( netstat -s | grep -A 5 "Tcp:" | tail -1 )
#echo "    #Connections TCP:$TCPa"

#nr of Users using Server
Users=$(who | cut -d " " -f 1 | sort -u | wc -l)
#echo "    #User Log: $Users"

#IPv4 Adress of your Server and its MAC adress
IP=$(/sbin/ifconfig | grep -a "inet" |  head -1 | awk '{print $2}')
MAC=$(ip a | grep -a "ether" | awk '{print $2}')
#echo "    #Network: IP $IP ($MAC)"

#nr of Commands executed by SUDO Program
Commands=$(grep -a "sudo" /var/log/auth.log | grep -a "session opened" | wc -l)
#echo "    #Nr of SUDO commands: $Commands"

wall "
        MONITORING SCRIPT
    Architecure: $var
    CPU physical: $(lscpu | grep -a "^CPU(s):" | awk '{print $2}')
    vCPU: $vCPU
    Memory usage: $used/$total MB ($frac%)
    Disk usage: $usedD/$total2 MB ($usep%)
    CPU Load: $load%
    Last reboot: $reboot $rtime
    LVM Use: $check2
    Connections TCP:$TCPa
    User Log: $Users
    Network: IP $IP ($MAC)
    Nr of SUDO commands: $Commands
"
