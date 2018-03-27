#!/bin/sh

process_list_path=/tmp/processlist.in

if [ ! -f ${process_list_path} ]
	then
	echo "Process list file doesn't exist"
	exit
fi

while (true) do
	while read p; do
		exist=`pgrep $p | wc -l`
		if [ $exist -gt 0 ];
			then
				ps -p `pgrep $p` -o %cpu,%mem | awk -v timestamp=$(date +"%H:%M") 'NR==2{print timestamp,$1,$2}' >> ${p}_resource_usage.dat
		fi
	done < ${process_list_path}
	sleep 60
done


