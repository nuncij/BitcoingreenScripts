#!/bin/bash
PARAM1=$*
NAME="bitg"

if [ -z "$PARAM1" ]; then
  PARAM1="*"  	  
else
  PARAM1=${PARAM1,,} 
fi

for FILE in ~/bin/${NAME}-cli_$PARAM1.sh; do
  echo "*******************************************"
  echo "FILE "$FILE
  $FILE stop
done
