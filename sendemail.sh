#!/usr/bin/env bash
# Source:
#       https://github.com/rogard/script.sh
# Usage:
#	sendemail.sh [--safe] TO SUBJECT FILE_BODY FILE_ATTACH
# Prompt:
#	Send
#	To: -VALUE-
#	Subject: -VALUE-
#	Greet: -VALUE-
#	Att.: -VALUE-
#	[y/n]: -VALUE- 
# Set up:
#	https://unix.stackexchange.com/questions/595410/troubleshooting-ssmtp-authorization-failed
# TODO
#	- flexible field separator
#	- catch error

#set -euo pipefail

usage()
{
    cat << EOF
Usage:
sendemail.sh [--safe] TO SUBJECT FILE_BODY FILE_ATTACH
EOF
}

params="$(getopt -o sh --long safe,help --name "$(basename "$0")" -- "$@")" #https://stackoverflow.com/a/9274633

EXIT_CODE="$?"
(( $EXIT_CODE == 0 )) ||  { usage; exit 1; }

eval set -- "$params"
unset params

BOOL_SAFE='F'
while true
do
    case $1 in
	-s|--safe) BOOL_SAFE='T'; shift ;;
	-h|--help) usage; exit 0 ;;
	--) shift; break;;
	*) echo "ABORT, wrong options"; exit 1;;
    esac
#    shift $((OPTIND-1))
done

[[ $# == 4 ]] || ( echo "ABORT $0 require \$# == 4, not $@ ";  exit 1; )
[[ $1 =~ .+@.+\..+ ]] && TO="$1" || ( echo "ABORT $0 TO=$1 not email address";  exit 1; )
[[ -n "$2" ]] && SUBJECT="$2" || ( echo "ABORT $0 SUBJECT=$2 not string";  exit 1; )
[[ -f "$3" && -s "$3" ]] && FILE_BODY="$3"  || ( echo "ABORT $0 FILE_BODY=$3 not file or empty";  exit 1; )
[[ -f "$4" && -s "$4" ]] && FILE_ATTACH="$4" || ( echo "ABORT $0 $4 not file or empty";  exit 1; )
GREET=$(awk '{print; exit}' "$FILE_BODY")

#[[ -n $FIRST_NON_BLANK ]] || {  echo "ABORT $0 #2"; exit 1; }

COLUMNS=$(tput cols)
printf %"$COLUMNS"s "-" | tr ' ' '-'
[[ $BOOL_SAFE == 'T' ]] &&\
   ( printf '%s\n' "About to send" )\
	||   (  printf '%s\n' "Sending" )\
       
IFS=$'	'
while read FIELD
do
printf '%s\n' "$FIELD"
done <<EOF
To: $TO
Subject: $SUBJECT
Greet: $GREET
Att.: $FILE_ATTACH
EOF

if [[ "$BOOL_SAFE" == 'T' ]]
then
    printf  "Proceed? [y/n]: "
    read answer < /dev/tty
else
    answer='y'
fi
case ${answer:0:1} in
    y|Y)
        true ;;
    *)
        echo "ABORT"; exit 1
esac

cat "$FILE_BODY"\
    |     mutt -a "$FILE_ATTACH"\
	       -s "$SUBJECT"\
	       -- "$TO"

