#! /bin/sh

SRC="ip_list.txt"
OPT="./lg_expect.sh"

cat $SRC | sed '/^$/d' | while read line
do
	TEMP=`echo $line | grep -E '^#'`
	if [ -z "$TEMP" ]; then
		T1=`echo $line |awk -F '=' '{print $1;}'`
        	T2=`echo $line |awk -F '=' '{print $2;}'`
		$OPT $T1 $T2
	fi
done 
