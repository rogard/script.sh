# !/bin/bash
# Source:
#       https://github.com/rogard/script.sh
# Usage:
#	sendemail.sh TO SUBJECT GREET FILE_BODY FILE_ATTACH
# Prompt:
#	Send
#	To: -VALUE-
#	Subject: -VALUE-
#	Greet: -VALUE-
#	Body: -VALUE-
#	Att.: -VALUE-
#	[y/n]: -VALUE- 
# Set up:
#	https://unix.stackexchange.com/questions/595410/troubleshooting-ssmtp-authorization-failed

if [[ "$#" == 5 ]]
then 
    true
else
    echo "FAIL $0 #1"
    exit
fi

TO="$1"	
SUBJECT="$2"
GREET="$3"	
FILE_BODY="$4"
FILE_ATTACH="$5"
FIRST_NON_BLANK=$(awk '/^[^[:space:]]/{print $0; exit}' "$FILE_BODY")

if [[ -n "$FIRST_NON_BLANK" ]]
then
    true
else
    echo "FAIL $0 #2"
    exit
fi    

COLUMNS=$(tput cols)
printf %"$COLUMNS"s "-" | tr ' ' '-'
printf '%s\n' 'Send'
IFS=$'	'
while read FIELD
do
printf '%s\n' "$FIELD"
done <<EOF
To: $TO
Greet: $GREET
Subject: $SUBJECT
Body: $FIRST_NON_BLANK...
Att.: $FILE_ATTACH
EOF

printf  "[y/n]: "
read answer < /dev/tty
case ${answer:0:1} in
    y|Y)
        true ;;
    *)
        echo "Aborted"; exit
esac

printf '%s,\n' "$GREET"\
    | cat - "$FILE_BODY"\
    |     mutt -a "$FILE_ATTACH"\
	       -s "$SUBJECT"\
	       -- "$TO"
