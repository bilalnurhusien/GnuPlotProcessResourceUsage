#!/bin/bash

if [ $# -lt 1 ]
then
	echo "Please pass ip addr file for remote host to monitor"
	echo "Usage ./memorymon.sh XXX.XXX.XXX.XXX"
	exit
fi

export ip_addr=${1}
export ps_mon_file=psmon.sh
export tmp_process_list_file=processlist.in
export tmp_process_list_path=/tmp/${tmp_process_list_file}
export tmp_ps_mon_path=/tmp/${ps_mon_file}
export resource_append=_resource_usage.dat
export resource_usage_plot=resourceusageplot.in

#copy script to remote host
scp ${ps_mon_file} "root@${ip_addr}:${tmp_ps_mon_path}"
scp ${tmp_process_list_file} "root@${ip_addr}:${tmp_process_list_path}"

#kill previously running task and launch new one on remote host
ssh "root@${ip_addr}" "pkill ${ps_mon_file}; ${tmp_ps_mon_path} &"

# wait for script to launch
sleep 5

while (true) do

	#copy resource usage data
	while read p; do
			scp "root@${ip_addr}:/tmp/${p}${resource_append}" /tmp/
	done < ${tmp_process_list_file}

	#run gnuplot
	gnuplot -e "file_name='${tmp_resource_data_path}'" $resource_usage_plot
	#exit gnuplot window
	pkill "gnuplot $resource_usage_plot"

done


