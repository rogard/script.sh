# !/bin/bash
# Source:
#       https://github.com/rogard/script.sh
# Requirement
#	sendemail.sh in the same directory
# Usage:
#	batchemail.sh [--safe n] FILE
# To do:
#	- Flexible field separator

usage()
{
    cat << EOF
Usage:
	sendemail.sh [--safe n] FILE

For each ROW in FILE, 
	- i++<n sendmail.sh --safe ROW
	- sendmail.sh ROW
EOF
}

params="$(getopt -o s:h --long safe,help --name "$(basename "$0")" -- "$@")" #https://stackoverflow.com/a/9274633

EXIT_CODE="$?"
(( $EXIT_CODE == 0 )) ||  { usage; exit 1; }

eval set -- "$params"
unset params

#echo "$@"

SAFE_COUNT=0
DO_SAFE='F'
while true
do
    case $1 in
	-s|--safe)
	    DO_SAFE='T'; shift 1;;
	-h|--help) usage; exit 0 ;;
	--) shift; break;;
	*) echo "ABORT, wrong options"; exit 1;;
    esac
    #    shift $((OPTIND-1))
done

if [[ $DO_SAFE == 'T' ]]
then
    [[ $1 =~ ^[0-9]+$ ]]\
	|| ( echo "ABORT, --safe $1 must be non-neg integer"; exit 1 )
    SAFE_COUNT="$1"
    shift;
else
    true
fi

[[ $# == 1 ]] || { echo >&2 "ABORT $0 FILE missing "; exit 1; }

FILE="$1" # tested in subprocess

IFS=$'	'
printf  "Are you OK with IFS=$IFS? [y/n]: "
read answer < /dev/tty
case ${answer:0:1} in
    y|Y)
        true ;;
    *)
        echo "ABORT"; exit 1 ;;
esac

SOURCE_DIR=$(dirname "$0")

COUNT=0
while read TO SUBJECT FILE_BODY FILE_ATTACH
do
    ARGS=($TO $SUBJECT $FILE_BODY $FILE_ATTACH)
    if (( $COUNT < $SAFE_COUNT )) #FAIL
    then
	"$SOURCE_DIR"/sendemail.sh\
		     --safe \
		     "${ARGS[@]}"
	((++COUNT))
    else
#	echo "${ARGS[@]}"
	"$SOURCE_DIR"/sendemail.sh\
		     "${ARGS[@]}"
    fi    
done < "$FILE"
