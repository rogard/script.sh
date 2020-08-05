# !/bin/bash
# Source:
#       https://github.com/rogard/script.sh
# Requirement
#	sendemail.sh in the same directory
# Usage:
#	batchemail.sh SUBJECT GREET FILE_TO_GREET FILE_BODY FILE_ATTACH

if [[ "$#" == 5 ]]
then 
    true
else
    echo "FAIL $0 #1"
    exit
fi

IFS=$'	'
printf  "Are you OK with IFS=$IFS? [y/n]: "
read answer < /dev/tty
case ${answer:0:1} in
    y|Y)
        echo Yes ;;
    *)
        echo No ;;
esac

SOURCE_DIR=$(dirname "$0") # https://stackoverflow.com/questions/59895/how-to-get-the-source-directory-of-a-bash-script-from-within-the-script-itself
SUBJECT="$1"
GREET="$2"	
FILE_TO_GREET="$3"	
FILE_BODY="$4"
FILE_ATTACH="$5"

while read TO GREET
do
    "$SOURCE_DIR"/sendemail.sh\
		 "$TO"\
		 "$SUBJECT"\
		 "$GREET"\
		 "$FILE_BODY"\
		 "$FILE_ATTACH"
done < "$FILE_TO_GREET"
