#!/bin/bash
base=/ng_edrop_a/umgi/incoming
cd /ng_edrop_a/umgi/incoming
umask 0002
function find_problems
{
	find -mindepth 1 -maxdepth 1 -type d | while read -r D; do test -z "$(shopt -s nullglob; printf "%s\n" "$D"/*.complete)" && printf "%s\n" "$D"; done > "$base/UMGI-EMI_missing_trigger.txt"
}

function find_batches
{
	while IFS= read -r line ;
	do
		printf '%s\n' "$line" > temp.txt
		find -mindepth 2 -maxdepth 2 -type d | while read -r D; do test -z "$(shopt -s nullglob; printf "%s\n" "$D"/*.complete)" && printf "%s\n" "$D"; done > "$base/missing_batch.txt"
	done < "$base/UMGI-EMI_missing_trigger.txt"
}

function add_files
{
	while IFS= read -r batches ;
	do
		printf '%s\n' "$batches" >> temp.txt
		echo > $batches/delivery.complete
	done < "$base/missing_batch.txt"
}

function make_log
{
	echo "These folders were incorrectly set up as batches:" > $base/log.txt
	cat $base/UMGI-EMI_missing_trigger.txt >> $base/log.txt
	echo -e "\nTrigger files were automatically added to these folders:" >> $base/log.txt
	cat $base/missing_batch.txt >> $base/log.txt
}
	
function alert_problems
{
	if [ -s $base/UMGI-EMI_missing_trigger.txt ]
	then
		find_batches ;
		echo -e "EMI forgot to add delivery.complete files again. (This is an automated message.)\n" | cat - $base/log.txt | mail -r cops@mndigital.com -s "EMI ZA trigger files missing" ContentOps@mndigital.com
	fi
}

find_problems
add_files
make_log
alert_problems
