#!/bin/bash
umgi_base=/ng_edrop_a/umgi/incoming
cd /ng_edrop_a/umgi/incoming
umask 0002
function find_problems
{
	find -mindepth 1 -maxdepth 1 -mtime +2 -type d | while read -r D; do test -z "$(shopt -s nullglob; printf "%s\n" "$D"/*.complete)" && printf "%s\n" "$D"; done > "$umgi_base/UMGI-EMI_missing_trigger.txt"
}

function alert_problems
{
	if [ -s $umgi_base/UMGI-EMI_missing_trigger.txt ]
	then
		echo -e "EMI forgot to add delivery.complete files again. Go to the ng_edrop_a/umgi folder and add them to the folders below. \n\n(This is an automated message - $umgi_base/mising_trigger.sh running on edr02.)\n\n" | cat - $umgi_base/UMGI-EMI_missing_trigger.txt | mail -r cops@mndigital.com -s "EMI ZA trigger files missing" contentops@mndigital.com
	fi
}

find_problems
alert_problems
