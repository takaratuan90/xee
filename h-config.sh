#!/usr/bin/env bash

if [[ $CUSTOM_URL != "" ]];
then
    address=$CUSTOM_URL
else
    address=`127.0.0.1:8080`
fi
eval "rm -rf ${CUSTOM_CONFIG_FILENAME}_CPU"
eval "rm -rf ${CUSTOM_CONFIG_FILENAME}_GPU"
if [[ ! -z $CUSTOM_USER_CONFIG ]]; then

echo "${CUSTOM_USER_CONFIG}" > "${CUSTOM_CONFIG_FILENAME}"
nv=`cat ${CUSTOM_CONFIG_FILENAME} | tail -n10 | grep 'nvtool' | tail -n1`
if [[ $nv != "" ]];then
eval $nv 
fi
oc_cpu=`grep -oP "n \K\d+" "${CUSTOM_CONFIG_FILENAME}" | tail -n1`
if [[ $oc_cpu != "" ]];then
Settings_cpu="-n $oc_cpu"
fi
oc_cpu2=`cat ${CUSTOM_CONFIG_FILENAME} | tail -n10 | grep 'threads' | tail -n1`
if [[ $oc_cpu2 != "" ]];then
Settings_cpu=$oc_cpu2
fi
oc_gpu=`cat ${CUSTOM_CONFIG_FILENAME} | tail -n10 | grep 'boost' | tail -n1`
if [[ $oc_gpu != "" ]];then
Settings_gpu=$oc_gpu
fi
fi

eval "rm -rf /hive/miners/custom/$CUSTOM_NAME/conf.md"
echo "$CUSTOM_PASS" > "/hive/miners/custom/$CUSTOM_NAME/conf.md"

if [[ $CUSTOM_TEMPLATE == *.* ]];then
  username=`echo $CUSTOM_TEMPLATE | cut -d . -f 2`
  wallet=`echo $CUSTOM_TEMPLATE | cut -d . -f 1`
  echo -e "--wallet $wallet  --host $address $Settings_gpu --worker ${username}-gpu" > "${CUSTOM_CONFIG_FILENAME}_GPU" 
  echo -e "-m $wallet --daemon-address $address ${Settings_cpu} -w ${username}-cpu" > "${CUSTOM_CONFIG_FILENAME}_CPU"
  else
  echo -e "--wallet $CUSTOM_TEMPLATE --host $address $Settings_gpu --worker rig-gpu" > "${CUSTOM_CONFIG_FILENAME}_GPU" 
  echo -e "-m $CUSTOM_TEMPLATE --daemon-address $address ${Settings_cpu} -w rig-cpu" > "${CUSTOM_CONFIG_FILENAME}_CPU" 
  fi
