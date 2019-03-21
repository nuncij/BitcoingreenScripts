#!/bin/bash

PARAM1=$*
NAME="bitcoingreen"

if [ -z "$PARAM1" ]; then
  PARAM1="*"  	  
else
  PARAM1=${PARAM1,,} 
fi

for FILE in ~/bin/${NAME}d_$PARAM1.sh; do
  echo "*******************************************"
  COUNTER=1
  DATE=$(date '+%d.%m.%Y %H:%M:%S');
  echo "DATE="$DATE
  echo FILE: " $FILE"
  #cat $FILE
  STARTPOS=$(echo $FILE | grep -b -o _)
  LENGTH=$(echo $FILE | grep -b -o .sh)
  # echo ${STARTPOS:0:2}
  STARTPOS_1=$(echo ${STARTPOS:0:2})
  STARTPOS_1=$[STARTPOS_1 + 1]
  ALIAS=$(echo ${FILE:STARTPOS_1:${LENGTH:0:2}-STARTPOS_1})
  CONFPATH=$(echo "$HOME/.${NAME}_$ALIAS")
  # echo $STARTPOS_1
  # echo ${LENGTH:0:2}
  echo "NODE ALIAS: "$CONFPATH
  echo "CONF FOLDER: "$CONFPATH
done