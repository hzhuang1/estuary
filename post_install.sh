#!/bin/bash
#author: Justin Zhao
#date: 31/10/2015
#description: automatically call all post install scripts in post_dir

lastupdate="2015-10-15"
post_dir="/usr/bin/estuary/postinstall"

###################################################################################
############################# Check initilization status ##########################
###################################################################################
check_init()
{
    tmpfile=$1
    tmpdate=$2

    if [ -f "$tmpfile" ]; then
	    inittime=`stat -c %Y $tmpfile`
	    checktime=`date +%s -d $tmpdate`

	    if [ $inittime -gt $checktime ]; then
	          return 1
	    fi
	fi

	return 0
}

netstatus=${post_dir}/.network
if [ ! -f ${netstatus} ]; then
	netrst=`ping www.baidu.com -c 4`
	rcv=`echo "$netrst" | grep -E "..received" -o`
	if [ x"0" != x"$?" ]; then
		exit 1
	fi
	rcv=`echo "$rcv" | cut -d " " -f1`
	if [ x"0" = x"$rcv" ]; then
		exit 1
	fi
fi

# preprocess...
if [ ! -f $netstatus ]; then
	echo "$netrst" > $netstatus
fi

for fullfile in $post_dir/*
do
	file=${fullfile##*/}
	if [ -f $fullfile ]; then
		check_init "$post_dir/.$file" $lastupdate
		if [ x"0" = x"$?" ]; then
			$fullfile
			if [ x"0" = x"$?" ]; then
				touch "$post_dir/.$file"
			fi
		fi
	fi
done
#enable function_graph as default tracer
echo function_graph > /sys/kernel/debug/tracing/current_tracer
