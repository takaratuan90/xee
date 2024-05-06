# Check ts
. h-manifest.conf
if ! command -v ts &> /dev/null; then
    echo "Program ts (moreutils) - not installed. ts is required. Install:"
    # Because HiveOS crashed during the installation of moreutils, I have to install the 'ts' utility from its sources.
    cd /tmp/ && wget https://raw.githubusercontent.com/Worm/moreutils/master/ts && mv ts /usr/local/bin && chmod 777 /usr/local/bin/ts
    #sudo sed -i '/^deb http:\/\/[a-z]*\.*archive\.ubuntu\.com\/ubuntu\ jammy\ [a-zA-Z0-9]*$/d' /etc/apt/sources.list && apt update && apt install moreutils -y
    echo "Program ts (moreutils) - has been installed."
fi

CUSTOM_LOG_BASEDIR=`dirname "$CUSTOM_LOG_BASENAME"`
[[ ! -d $CUSTOM_LOG_BASEDIR ]] && mkdir -p $CUSTOM_LOG_BASEDIR
if [[ -e ./conf.md ]]; then
conf=`cat /hive/miners/custom/$CUSTOM_NAME/conf.md | tail -n1`
  if [[ $conf == cuda ]];then
  ./xelis-taxminer_gpu $(< ${CUSTOM_CONFIG_FILENAME}_GPU) --display-hs-all 2>&1 | ts CUDA | tee --append $CUSTOM_LOG_BASENAME.log  
  elif [[ $conf == dual ]];then
  ./xelis-taxminer_gpu $(< ${CUSTOM_CONFIG_FILENAME}_GPU) --display-hs-all 2>&1 | ts CUDA | tee --append $CUSTOM_LOG_BASENAME.log &
  sleep 3
 ./xelis_miner $(< ${CUSTOM_CONFIG_FILENAME}_CPU) 2>&1 | ts CPU | tee --append $CUSTOM_LOG_BASENAME.log
  else
  ./xelis_miner $(< ${CUSTOM_CONFIG_FILENAME}_CPU) 2>&1 | ts CPU | tee --append $CUSTOM_LOG_BASENAME.log
fi
fi