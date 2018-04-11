#!/bin/sh

process_list_path=/tmp/processlist.in
max_file_length=2000
trim_length=100

if [ ! -f ${process_list_path} ];
	then
		echo "Process list file doesn't exist"
	exit
fi

while (true) do
	while read p; do
		exist=`pgrep -f $p | wc -l`
		if [ $exist -gt 0 ]
			then
				file_size=`cat /tmp/${p}-resource-usage.dat | wc -l`
				if [ $file_size -gt $max_file_length ]
					then
						sed -e '1,${trim_length}d' < /tmp/${p}-resource-usage.dat > /tmp/tmp_${p}-resource-usage.dat
						mv /tmp/tmp_${p}-resource-usage.dat /tmp/${p}-resource-usage.dat
				fi

				file=`echo "${p}" | sed -e 's/_/-/g'`

				ps -p `pgrep -f $p` -o %cpu,%mem | awk -v timestamp=$(date +"%H:%M") 'NR==2{print timestamp,$1,$2}' >> /tmp/${file}-resource-usage.dat
		fi
	done < ${process_list_path}
	sleep 60
done



