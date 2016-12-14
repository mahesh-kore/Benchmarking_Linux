#!/bin/bash
# A script to benchmark your server
# 1- CPU Benchmark
# 2- Memory Benchmark
# 3- System Benchmark
# 4- Hard Disk Benchmark
# 5- Download Speed Benchmark
# Note: A total of 1GB of data will be downloaded during execution


echo -e "\e[1;34m========== CPU Info ==========\e[0m"
cpuname=$( awk -F: '/model name/ {modelName=$2} END {print modelName}' /proc/cpuinfo )
cpucores=`grep -c ^processor /proc/cpuinfo`
cpucache=$( awk -F: '/cache size/ {cache=$2} END {print cache}' /proc/cpuinfo )
cpufreq=$( awk -F: '/cpu MHz/ {frequency=$2} END {print frequency}' /proc/cpuinfo )
echo "CPU model : $cpuname"
echo "Number of cores : $cpucores"
echo "CPU cache size : $cpucache"
echo "CPU frequency : $cpufreq MHz"
echo -e "\e[1;34m======= END of CPU Info =======\e[0m"

printf "\n"
echo -e "\e[1;34m========== Memory Info ==========\e[0m"
memorysize=$(free -m | awk 'NR==2'|awk '{ print $2 }')
swapsize=$(free -m | awk 'NR==4'| awk '{ print $2 }')
echo "Total RAM : $memorysize MB"
echo "Total swap : $swapsize MB"
echo -e "\e[1;34m======= END of Memory Info =======\e[0m"

printf "\n"
echo -e "\e[1;34m========== System Info ==========\e[0m"
uptime=$(uptime|awk '{ $1=$2=$(NF-6)=$(NF-5)=$(NF-4)=$(NF-3)=$(NF-2)=$(NF-1)=$NF=""; print }')
echo "System uptime : $uptime"
echo -e "\e[1;34m======= END of System Info =======\e[0m"

printf "\n"
echo -e "\e[1;34m========== Hard Disk Info ==========\e[0m"
echo "Now Testing I/O Speed. This might take a while..."
# Measuring disk speed with DD
        io=$( ( dd if=/dev/zero of=test_$$ bs=64k count=16k conv=fdatasync && rm -f test_$$ ) 2>&1 | awk -F, '{io=$NF} END { print io}' | sed 's/^[ \t]*//;s/[ \t]*$//' )
        io2=$( ( dd if=/dev/zero of=test_$$ bs=64k count=16k conv=fdatasync && rm -f test_$$ ) 2>&1 | awk -F, '{io=$NF} END { print io}' | sed 's/^[ \t]*//;s/[ \t]*$//' )
        io3=$( ( dd if=/dev/zero of=test_$$ bs=64k count=16k conv=fdatasync && rm -f test_$$ ) 2>&1 | awk -F, '{io=$NF} END { print io}' | sed 's/^[ \t]*//;s/[ \t]*$//' )
        # Calculating avg I/O (better approach with awk for non int values)
        ioraw=$( echo $io | awk 'NR==1 {print $1}' )
        ioraw2=$( echo $io2 | awk 'NR==1 {print $1}' )
        ioraw3=$( echo $io3 | awk 'NR==1 {print $1}' )
        ioall=$( awk 'BEGIN{print '$ioraw' + '$ioraw2' + '$ioraw3'}' )
        ioavg=$( awk 'BEGIN{print '$ioall'/3}' )
        # Output of DD result
        echo "I/O (1st run)     : $io" | tee -a $HOME/bench.log
        echo "I/O (2nd run)     : $io2" | tee -a $HOME/bench.log
        echo "I/O (3rd run)     : $io3" | tee -a $HOME/bench.log
        echo "Average I/O       : $ioavg MB/s" | tee -a $HOME/bench.log
hdds=$(df -h | awk '{if ($1 != "Filesystem") print $1 "\t" $2}')
echo "Hard Disk Space:"
echo "$hdds"
echo -e "\e[1;34m======= END of Hard Disk Info =======\e[0m"

printf "\n"
echo -e "\e[1;34m========== Network/Download Speed Info ==========\e[0m"
ethspeed=$(ethtool eth0 | grep -i speed)
echo "Ethernet speed : $ethspeed"

cachefly=$( wget -O /dev/null http://cachefly.cachefly.net/100mb.test 2>&1 | awk '/\/dev\/null/ {speed=$3 $4} END {gsub(/\(|\)/,"",speed); print speed}' )
echo "Download speed from CDN CacheFly: $cachefly "

linodeeast=$( wget -O /dev/null http://speedtest.newark.linode.com/100MB-newark.bin 2>&1 | awk '/\/dev\/null/ {speed=$3 $4} END {gsub(/\(|\)/,"",speed); print speed}' )
echo "Download speed from Linode, East, USA: $linodeeast "

softlayersingapore=$( wget -O /dev/null http://speedtest.sng01.softlayer.com/downloads/test100.zip 2>&1 | awk '/\/dev\/null/ {speed=$3 $4} END {gsub(/\(|\)/,"",speed); print speed}' )
echo "Download speed from Softlayer, Singapore: $softlayersingapore "
echo "======= END of Download Speed Info ======="

