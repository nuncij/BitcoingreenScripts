#!/bin/bash

NAME="bitcoingreen"
NAMEALIAS="bitg"
URL="https://github.com/bitcoingreen/bitcoingreen/releases/download/v1.3.0/bitcoingreen-1.3.0-x86_64-linux-gnu.tar.gz"
WALLETDL="bitcoingreen-1.3.0-x86_64-linux-gnu.tar.gz"
WALLETDLFOLDER="bitcoingreen-1.3.0"

RED='\033[1;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
YELLOW='\033[1;33m'
BROWN='\033[0;34m'
NC='\033[0m' # No Color

cd ~
echo "*****************************************************************************"
echo "* Ubuntu 16.04 is the recommended operating system for this install.        *"
echo "*                                                                           *"
echo "* This script will install and configure your ${NAME} Coin masternodes.     *"
echo "*****************************************************************************"
echo && echo && echo
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo "!                                                 !"
echo "! Make sure you double check before hitting enter !"
echo "!                                                 !"
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo && echo && echo

if [[ $(lsb_release -d) != *16.04* ]]; then
  echo -e "${RED}The operating system is not Ubuntu 16.04. You must be running on Ubuntu 16.04.${NC}"
  exit 1
fi

echo -e "${YELLOW}Do you want to install all needed dependencies (no if you did it before, yes if you are installing your first node)? [y/n]${NC}"
read DOSETUP

if [[ ${DOSETUP,,} =~ "y" ]] ; then
  sudo apt-get update
  sudo apt-get -y upgrade
  sudo apt-get -y dist-upgrade
  sudo apt-get install -y nano htop git
  sudo apt-get install -y software-properties-common
  sudo apt-get install -y build-essential libtool autotools-dev pkg-config libssl-dev
  sudo apt-get install -y libboost-all-dev
  sudo apt-get install -y libevent-dev
  sudo apt-get install -y libminiupnpc-dev
  sudo apt-get install -y autoconf
  sudo apt-get install -y automake unzip
  sudo add-apt-repository  -y  ppa:bitcoin/bitcoin
  sudo apt-get update
  sudo apt-get install -y libdb4.8-dev libdb4.8++-dev
  sudo apt-get install -y dos2unix
  sudo apt-get install -y jq

  cd /var
  sudo touch swap.img
  sudo chmod 600 swap.img
  sudo dd if=/dev/zero of=/var/swap.img bs=1024k count=2000
  sudo mkswap /var/swap.img
  sudo swapon /var/swap.img
  sudo free
  sudo echo "/var/swap.img none swap sw 0 0" >> /etc/fstab
  cd

  ## COMPILE AND INSTALL
  mkdir -p ~/${NAME}_tmp
  cd ~/${NAME}_tmp
  
  wget ${URL}
  chmod 775 ${WALLETDL}
  tar -xvzf ${WALLETDL}
  cd ./${WALLETDLFOLDER}/bin
  sudo chmod 775 *
  sudo mv ./${NAME}* /usr/bin
  #read
  cd ~
  rm -rfd ~/${NAME}_tmp

  sudo apt-get install -y ufw
  sudo ufw allow ssh/tcp
  sudo ufw limit ssh/tcp
  sudo ufw logging on
  echo "y" | sudo ufw enable
  sudo ufw status

  mkdir -p ~/bin
  echo 'export PATH=~/bin:$PATH' > ~/.bash_aliases
  source ~/.bashrc
fi

## Setup conf
mkdir -p ~/bin
rm ~/bin/masternode_config.txt &>/dev/null &
IP=$(curl -s4 icanhazip.com)
COUNTER=1

MNCOUNT=""
REBOOTRESTART=""
re='^[0-9]+$'
while ! [[ $MNCOUNT =~ $re ]] ; do
   echo ""
   echo -e "${YELLOW}How many nodes do you want to create on this server?, followed by [ENTER]:${NC}"
   read MNCOUNT
   echo -e "${YELLOW}Do you want wallets to restart on reboot? [y/n]${NC}"
   read REBOOTRESTART
done

for i in `seq 1 1 $MNCOUNT`; do 
  for (( ; ; ))
  do  
    echo "************************************************************"
    echo ""
    #echo "Enter alias for new node. Name must be unique! (Don't use same names as for previous nodes on old chain if you didn't delete old chain folders!)"
	echo -e "${YELLOW}Enter alphanumeric alias for new node. Name must be unique!${NC}"
    read ALIAS 

    ALIAS=${ALIAS,,}  
  
    if [[ "$ALIAS" =~ [^0-9A-Za-z]+ ]] ; then
      echo -e "${RED}$ALIAS has characters which are not alphanumeric. Please use only alphanumeric characters.${NC}"
	elif [ -z "$ALIAS" ]; then
	  echo -e "${RED}$ALIAS in empty!${NC}"
    else
	  CONF_DIR=~/.${NAME}_$ALIAS
	  
      if [ -d "$CONF_DIR" ]; then
        echo -e "${RED}$ALIAS is already used. $CONF_DIR already exists!${NC}"
      else
		# OK !!!
        break
      fi	
    fi  
  done
  
  PORT=""
  RPCPORT=""
  echo ""
  # echo "Enter port for node $ALIAS (Any valid free port matching config from steps before: i.E. 37234)"
  # read PORT
  
  if [ -z "$PORT" ]; then
    PORT=16100
	RPCPORT=17100
	PORT1=""
    for (( ; ; ))
    do
	  PORT1=$(netstat -peanut | grep -i $PORT)

	  if [ -z "$PORT1" ]; then
		break
	  else
		PORT=$[PORT + 1]
		RPCPORT=$[RPCPORT + 1]
	  fi
    done  
  fi
  echo "PORT "$PORT

  if [ -z "$RPCPORT" ]; then
    echo ""
    echo "Enter RPC Port (Any valid free port: i.E. 9234)"
    read RPCPORT
  fi
  
  echo "RPCPORT "$RPCPORT

  PRIVKEY=""
  echo ""
  # echo "Enter masternode private key for node $ALIAS"
  # read PRIVKEY

  CONF_FILE=${NAME}.conf
  
  if [[ "$COUNTER" -lt 2 ]]; then
    ALIASONE=$(echo $ALIAS)
  fi  
  echo "ALIASONE="$ALIASONE

  # Create scripts
  echo '#!/bin/bash' > ~/bin/${NAME}d_$ALIAS.sh
  echo "${NAME}d -daemon -conf=$CONF_DIR/${NAME}.conf -datadir=$CONF_DIR "'$*' >> ~/bin/${NAME}d_$ALIAS.sh
  echo "${NAME}-cli -conf=$CONF_DIR/${NAME}.conf -datadir=$CONF_DIR "'$*' > ~/bin/${NAME}-cli_$ALIAS.sh
  chmod 755 ~/bin/${NAME}*.sh

  mkdir -p $CONF_DIR
  echo "rpcuser=user"`shuf -i 100000-10000000 -n 1` >> ${NAME}.conf_TEMP
  echo "rpcpassword=pass"`shuf -i 100000-10000000 -n 1` >> ${NAME}.conf_TEMP
  echo "rpcallowip=127.0.0.1" >> ${NAME}.conf_TEMP
  echo "rpcport=$RPCPORT" >> ${NAME}.conf_TEMP
  echo "listen=1" >> ${NAME}.conf_TEMP
  echo "server=1" >> ${NAME}.conf_TEMP
  echo "daemon=1" >> ${NAME}.conf_TEMP
  echo "logtimestamps=1" >> ${NAME}.conf_TEMP
  echo "maxconnections=256" >> ${NAME}.conf_TEMP

  # echo "addnode=51.15.198.252" >> ${NAME}.conf_TEMP 
  # echo "addnode=51.15.206.123" >> ${NAME}.conf_TEMP 
  # echo "addnode=51.15.66.234" >> ${NAME}.conf_TEMP 
  # echo "addnode=51.15.86.224" >> ${NAME}.conf_TEMP 
  # echo "addnode=51.15.89.27" >> ${NAME}.conf_TEMP 
  # echo "addnode=51.15.57.193" >> ${NAME}.conf_TEMP 
  # echo "addnode=134.255.232.212" >> ${NAME}.conf_TEMP 
  # echo "addnode=185.239.238.237" >> ${NAME}.conf_TEMP 
  # echo "addnode=185.239.238.240" >> ${NAME}.conf_TEMP 
  # echo "addnode=134.255.232.212" >> ${NAME}.conf_TEMP 
  # echo "addnode=207.148.26.77" >> ${NAME}.conf_TEMP 
  # echo "addnode=207.148.19.239" >> ${NAME}.conf_TEMP 
  # echo "addnode=108.61.103.123" >> ${NAME}.conf_TEMP 
  # echo "addnode=185.239.238.89" >> ${NAME}.conf_TEMP 
  # echo "addnode=185.239.238.92" >> ${NAME}.conf_TEMP   

  echo "addnode=212.237.14.6" >> ${NAME}.conf_TEMP   
  echo "addnode=109.203.114.140" >> ${NAME}.conf_TEMP   
  echo "addnode=208.167.242.208" >> ${NAME}.conf_TEMP   
  echo "addnode=104.238.157.244" >> ${NAME}.conf_TEMP   
  echo "addnode=149.28.133.225" >> ${NAME}.conf_TEMP   
  echo "addnode=142.93.140.34" >> ${NAME}.conf_TEMP   
  echo "addnode=45.63.100.81" >> ${NAME}.conf_TEMP   
  echo "addnode=178.128.111.218" >> ${NAME}.conf_TEMP   
  echo "addnode=92.60.36.224" >> ${NAME}.conf_TEMP   
  echo "addnode=178.16.114.13" >> ${NAME}.conf_TEMP   
  echo "addnode=66.206.10.24" >> ${NAME}.conf_TEMP   
  echo "addnode=206.189.181.180" >> ${NAME}.conf_TEMP   
  echo "addnode=128.199.189.180" >> ${NAME}.conf_TEMP   
  echo "addnode=45.32.233.37" >> ${NAME}.conf_TEMP   
  echo "addnode=51.15.57.193" >> ${NAME}.conf_TEMP   
  echo "addnode=80.211.175.228" >> ${NAME}.conf_TEMP   

  echo "" >> ${NAME}.conf_TEMP
  echo "port=$PORT" >> ${NAME}.conf_TEMP
  
  if [ -z "$PRIVKEY" ]; then
    echo ""
  else
    echo "masternode=1" >> ${NAME}.conf_TEMP
    echo "masternodeprivkey=$PRIVKEY" >> ${NAME}.conf_TEMP
  fi

  sudo ufw allow $PORT/tcp
  mv ${NAME}.conf_TEMP $CONF_DIR/${NAME}.conf
 
  if [ -z "$PRIVKEY" ]; then
	PID=`ps -ef | grep -i $ALIASONE | grep -i ${NAME}d | grep -v grep | awk '{print $2}'`
	
	if [ -z "$PID" ]; then
      # start wallet
      sh ~/bin/${NAME}d_$ALIASONE.sh  
	  sleep 1
	fi
  
	for (( ; ; ))
	do  
	  echo "Please wait ..."
      sleep 3
	  PRIVKEY=$(~/bin/${NAME}-cli_${ALIASONE}.sh masternode genkey)
	  echo "PRIVKEY=$PRIVKEY"
	  if [ -z "$PRIVKEY" ]; then
	    echo "PRIVKEY is null"
	  else
	    break
      fi
	done
	
	sleep 1
	
	for (( ; ; ))
	do
		PID=`ps -ef | grep -i $ALIAS | grep -i ${NAME}d | grep -v grep | awk '{print $2}'`
		if [ -z "$PID" ]; then
		  echo ""
		else
		  #STOP 
		  ~/bin/${NAME}-cli_$ALIAS.sh stop
		fi
		echo "Please wait ..."
		sleep 3 # wait 3 seconds 
		PID=`ps -ef | grep -i $ALIAS | grep -i ${NAME}d | grep -v grep | awk '{print $2}'`
		echo "PID="$PID	
		
		if [ -z "$PID" ]; then
		  sleep 1 # wait 3 seconds 	
		  echo "masternode=1" >> $CONF_DIR/${NAME}.conf
		  echo "masternodeprivkey=$PRIVKEY" >> $CONF_DIR/${NAME}.conf
		  # sh ~/bin/${NAME}d_$ALIAS.sh		
		  break
	    fi
	done
  fi
  
  sleep 2
  PID=`ps -ef | grep -i $ALIAS | grep -i ${NAME}d | grep -v grep | awk '{print $2}'`
  echo "PID="$PID
  
  if [ -z "$PID" ]; then
     echo ""
  else
    ~/bin/${NAME}-cli_$ALIAS.sh stop
	sleep 3 # wait 3 seconds 
  fi	
  
  if [ -z "$PID" ]; then
    cd $CONF_DIR
    echo "Copy BLOCKCHAIN without conf files"
    wget http://167.86.97.235/zest/bootstrap/${NAMEALIAS}_bootstrap.zip -O bootstrap.zip
    # rm -R peers.dat 
	rm -R ./database
	rm -R ./blocks	
	rm -R ./sporks
	rm -R ./chainstate	
    unzip  bootstrap.zip
    rm ./bootstrap.zip
    sh ~/bin/${NAME}d_$ALIAS.sh		
    sleep 5 # wait 5 seconds 
  fi		  

  
  MNCONFIG=$(echo $ALIAS $IP:$PORT $PRIVKEY "txhash" "outputidx")
  echo $MNCONFIG >> ~/bin/masternode_config.txt
  
  if [[ ${REBOOTRESTART,,} =~ "y" ]] ; then
    (crontab -l 2>/dev/null; echo "@reboot sh ~/bin/${NAME}d_$ALIAS.sh") | crontab -
	(crontab -l 2>/dev/null; echo "@reboot sh /root/bin/${NAME}d_$ALIAS.sh") | crontab -
	sudo service cron reload
  fi
  
  COUNTER=$[COUNTER + 1]
done
echo ""
echo -e "${YELLOW}****************************************************************"
echo -e "**Copy/Paste lines below in Hot wallet masternode.conf file**"
echo -e "**and replace txhash and outputidx with data from masternode outputs command**"
echo -e "**in hot wallet console**"
echo -e "****************************************************************${NC}"
echo -e "${RED}"
cat ~/bin/masternode_config.txt
echo -e "${NC}"
echo "****************************************************************"
echo ""
