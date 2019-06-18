#!/bin/bash

NAME="bitgreen"
URL="https://raw.githubusercontent.com/CryptoCatOkiOKi/BitcoingreenScripts/master/"

##
##
##

RED='\033[1;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
YELLOW='\033[1;33m'
BROWN='\033[0;34m'
NC='\033[0m' # No Color


## Black        0;30     Dark Gray     1;30
## Red          0;31     Light Red     1;31
## Green        0;32     Light Green   1;32
## Brown/Orange 0;33     Yellow        1;33
## Blue         0;34     Light Blue    1;34
## Purple       0;35     Light Purple  1;35
## Cyan         0;36     Light Cyan    1;36
## Light Gray   0;37     White         1;37

echo && echo
echo "*******************************v1.3.0*****"
echo "***************${NAME} COIN***************"
echo "***************MAIN MENU******************"
echo "******************************************"
echo ""
echo -e "${RED}1. LIST ALL NODES" # -> ${NAME}_LIST.SH" # OK
echo -e "2. CHECK NODES SYNC" #  -> ${NAME}_CHECK_SYNC.SH" # OK
echo -e "3. RESYNC NODES THAT ARE OUT OF SYNC" #  -> ${NAME}_CHECK_RESYNC_ALL.SH" # OK
echo -e "4. RESTART NODES" #  -> ${NAME}_RESTART.SH" # OK
echo -e "5. STOP NODES" #  -> ${NAME}_STOP.SH" # OK
echo -e "6. INSTALL NEW NODES" #  -> ${NAME}_SETUPV2.SH" # OK
echo -e "7. CHECK NODES STATUS" #  -> ${NAME}_CHECK_STATUS.SH" # OK
echo -e "8. RESYNC SPECIFIC NODE (useful if node is stopped)" # -> ${NAME}_resync.sh # OK 
echo -e "9. EXIT${NC}" # OK
echo "---------------------------------------"
echo "choose option number:"
read OPTION
# echo ${OPTION}
ALIAS=""

if [[ ${OPTION} == "1" ]] ; then
  rm ${NAME}_list.sh > /dev/null 2>&1
  wget ${URL}${NAME}_list.sh -O ${NAME}_list.sh > /dev/null 2>&1
  chmod 777 ${NAME}_list.sh
  dos2unix ${NAME}_list.sh > /dev/null 2>&1
  /bin/bash ./${NAME}_list.sh
elif [[ ${OPTION} == "2" ]] ; then
  echo -e "${RED}Which node do you want to check if synced? Enter alias (if empty then will check all)${NC}"
  read ALIAS
  rm ${NAME}_check_sync.sh > /dev/null 2>&1
  wget ${URL}${NAME}_check_sync.sh -O ${NAME}_check_sync.sh > /dev/null 2>&1
  chmod 777 ${NAME}_check_sync.sh  
  dos2unix ${NAME}_check_sync.sh > /dev/null 2>&1
  /bin/bash ./${NAME}_check_sync.sh $ALIAS
elif [[ ${OPTION} == "3" ]] ; then
  echo -e "${RED}Which node do you want to check sync and resync? Enter alias (if empty then will check all)${NC}"
  read ALIAS
  rm ${NAME}_check_resync_all.sh > /dev/null 2>&1
  wget ${URL}${NAME}_check_resync_all.sh -O ${NAME}_check_resync_all.sh > /dev/null 2>&1
  chmod 777 ${NAME}_check_resync_all.sh  
  dos2unix ${NAME}_check_resync_all.sh > /dev/null 2>&1
  /bin/bash ./${NAME}_check_resync_all.sh $ALIAS
elif [[ ${OPTION} == "4" ]] ; then
  echo -e "${RED}Which node do you want to restart? Enter alias (if empty then will check all)${NC}"
  read ALIAS
  rm ${NAME}_restart.sh > /dev/null 2>&1
  wget ${URL}${NAME}_restart.sh -O ${NAME}_restart.sh > /dev/null 2>&1
  chmod 777 ${NAME}_restart.sh  
  dos2unix ${NAME}_restart.sh > /dev/null 2>&1
  /bin/bash ./${NAME}_restart.sh $ALIAS
elif [[ ${OPTION} == "5" ]] ; then
  echo -e "${RED}Which node do you want to stop? Enter alias (if empty then will check all)${NC}"
  read ALIAS
  rm ${NAME}_check_sync.sh > /dev/null 2>&1
  wget ${URL}${NAME}_stop.sh -O ${NAME}_stop.sh > /dev/null 2>&1
  chmod 777 ${NAME}_stop.sh  
  dos2unix ${NAME}_stop.sh > /dev/null 2>&1
  /bin/bash ./${NAME}_stop.sh $ALIAS
elif [[ ${OPTION} == "6" ]] ; then
  rm ${NAME}_setupv2.sh > /dev/null 2>&1
  wget ${URL}${NAME}_setupv2.sh -O ${NAME}_setupv2.sh > /dev/null 2>&1
  chmod 777 ${NAME}_setupv2.sh
  dos2unix ${NAME}_setupv2.sh > /dev/null 2>&1
  /bin/bash ./${NAME}_setupv2.sh
elif [[ ${OPTION} == "7" ]] ; then
  echo -e "${RED}For which node do you want to check masternode status? Enter alias (if empty then will check all)${NC}"
  read ALIAS
  rm ${NAME}_check_status.sh > /dev/null 2>&1
  wget ${URL}${NAME}_check_status.sh -O ${NAME}_check_status.sh > /dev/null 2>&1
  chmod 777 ${NAME}_check_status.sh  
  dos2unix ${NAME}_check_status.sh > /dev/null 2>&1
  /bin/bash ./${NAME}_check_status.sh $ALIAS
elif [[ ${OPTION} == "8" ]] ; then  
  echo -e "${RED}For which node do you want to check masternode status? Enter alias (mandatory!)${NC}"
  read ALIAS
  rm ${NAME}_resync.sh > /dev/null 2>&1
  wget ${URL}${NAME}_resync.sh -O ${NAME}_resync.sh > /dev/null 2>&1
  chmod 777 ${NAME}_resync.sh
  dos2unix ${NAME}_resync.sh > /dev/null 2>&1
  /bin/bash ./${NAME}_resync.sh $ALIAS
elif [[ ${OPTION} == "9" ]] ; then
  exit 0
fi
###
read -n 1 -s -r -p "****Press any key to go back to ${NAME} MAIN MENU*****"
/bin/bash ./${NAME}.sh
