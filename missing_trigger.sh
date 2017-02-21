#!/bin/bash
base=/ng_edrop_a/umgi/incoming
cd /ng_edrop_a/umgi/incoming
umask 0002
function find_problems
{
	find -mindepth 2 -maxdepth 2 -type d | while read -r D; do test -z "$(shopt -s nullglob; printf "%s\n" "$D"/*.complete)" && printf "%s\n" "$D"; done > "$base/UMGI-EMI_missing_trigger.txt"
}

function add_files
{
	while IFS= read -r line ;
	do
		printf '%s\n' "$line" > temp.txt
		echo > $line/delivery.complete
	done < "$base/UMGI-EMI_missing_trigger.txt"
}

function make_log
{
	echo -e "\nTrigger files were automatically added to these folders:\n" > $base/log.txt
	cat $base/UMGI-EMI_missing_trigger.txt >> $base/log.txt
	echo -e "\n(This is an automated message.)" >> $base/log.txt
}
	
function alert_problems
{
	if [ -s $base/UMGI-EMI_missing_trigger.txt ]
	then
	add_files ;
		echo -e "EMI forgot to add delivery.complete files again." | cat - $base/log.txt | mail -r cops@mndigital.com -s "EMI ZA Trigger Files Created" ContentOps@mndigital.com
	fi
}

find_problems
make_log
alert_problems
