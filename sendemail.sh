# !/bin/bash
# Source:
#       https://github.com/rogard/script.sh
# Usage:
#	sendmail.sh ADDRESS SUBJECT GREET FILE_BODY
# Set up:
#	https://unix.stackexchange.com/questions/595410/troubleshooting-ssmtp-authorization-failed

if [[ "$#" == 4 ]]
then 
    true
else
    echo "FAIL $0 #1"
    exit
fi

ADDRESS="$1"	
SUBJECT="$2"
GREET="$3"	
FILE_BODY="4"   

printf '%s,\n' "$GREET" | cat - "$FILE_BODY"\
    mutt -a "$ATTACH"\
	 -s "$SUBJECT"\
	 -- "$ADDR"
