#!/bin/bash

if [ $# -lt 1 ]
then
	echo "Please pass ip addr file for remote host to monitor"
	echo "Usage ./resourcemon.sh XXX.XXX.XXX.XXX"
	exit
fi

export ip_addr=${1}
export ps_mon_file=psmon.sh
export tmp_process_list_file=processlist.in
export tmp_process_list_path=/tmp/${tmp_process_list_file}
export tmp_ps_mon_path=/tmp/${ps_mon_file}
export resource_append=-resource-usage.dat
export resource_usage_plot=resourceusageplot.in

#copy script and process list to remote host
scp ${ps_mon_file} "root@${ip_addr}:${tmp_ps_mon_path}"
scp ${tmp_process_list_file} "root@${ip_addr}:${tmp_process_list_path}"

#kill previously running task and launch new one on remote host
ssh -n "root@${ip_addr}" "pkill ${ps_mon_file}; chmod +x ${tmp_ps_mon_path}; ${tmp_ps_mon_path} &"

# wait for script to launch
sleep 5

while (true) do

	#copy resource usage data
	while read p; do
			export file=`echo "${p}" | sed -e 's/_/-/g'`
			scp "root@${ip_addr}:/tmp/${file}${resource_append}" /tmp/
	done < ${tmp_process_list_file}

	#run gnuplot
	gnuplot $resource_usage_plot

	#close gnuplot window
	pkill "gnuplot $resource_usage_plot"

done


