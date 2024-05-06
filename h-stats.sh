. `dirname $BASH_SOURCE`/h-manifest.conf

get_cpu_temps () {
  local t_core=`cpu-temp`
  local i=0
  local l_num_cores=$1
  local l_temp=
  for (( i=0; i < ${l_num_cores}; i++ )); do
    l_temp+="$t_core "
  done
  echo ${l_temp[@]} | tr " " "\n" | jq -cs '.'
}

get_cpu_fans () {
  local t_fan=0
  local i=0
  local l_num_cores=$1
  local l_fan=
  for (( i=0; i < ${l_num_cores}; i++ )); do
    l_fan+="$t_fan "
  done
  echo ${l_fan[@]} | tr " " "\n" | jq -cs '.'
}

get_cpu_bus_numbers () {
  local i=0
  local l_num_cores=$1
  local l_numbers=
  for (( i=0; i < ${l_num_cores}; i++ )); do
    l_numbers+="null "
  done
  echo ${l_numbers[@]} | tr " " "\n" | jq -cs '.'
}


get_miner_uptime(){
  local a=0
  let a=`stat --format='%Y' ${CUSTOM_LOG_BASENAME}.log`-`stat --format='%Y' ${CUSTOM_CONFIG_FILENAME}`
  echo $a
}

get_log_time_diff(){
  local a=0
  let a=`date +%s`-`stat --format='%Y' ${CUSTOM_LOG_BASENAME}.log`
  echo $a
}

diffTime=$(get_log_time_diff)
maxDelay=250



if [ "$diffTime" -lt "$maxDelay" ]; then
  ver="$CUSTOM_VERSION"
  hs_units="khs"
  algo="$ALGO"

  uptime=$(get_miner_uptime)
  [[ $uptime -lt 60 ]] && head -n 50 $CUSTOM_LOG_BASENAME.log > ${CUSTOM_LOG_BASENAME}_head.log

  
CR=$(printf "\r")
ESC=$(printf "\e")

ac=`sed "s/$ESC\[[^Gm]*[Gm]//g;s/$ESC%G//g;s/$CR//g" ${CUSTOM_LOG_BASENAME}.log | tail -n100 | grep -w "Accepted" | awk '{print $9}' | tail -n1`
rj=`sed "s/$ESC\[[^Gm]*[Gm]//g;s/$ESC%G//g;s/$CR//g" ${CUSTOM_LOG_BASENAME}.log | tail -n100 | grep -w "Rejected" | awk '{print $12}' | tail -n1`



cuda=`cat ${CUSTOM_LOG_BASENAME}.log | tail -n100 | grep -w "CUDA" | awk '{ print $1}' | tail -n1`
if [[ $cuda == "CUDA" ]]; then
GPU_STATS_JSON=`cat $GPU_STATS_JSON`

# fill some arrays from gpu-stats
temps=(`echo "$GPU_STATS_JSON" | jq -r ".temp[]"`)
fans=(`echo "$GPU_STATS_JSON" | jq -r ".fan[]"`)
powers=(`echo "$GPU_STATS_JSON" | jq -r ".power[]"`)
busids=(`echo "$GPU_STATS_JSON" | jq -r ".busids[]"`)
brands=(`echo "$GPU_STATS_JSON" | jq -r ".brand[]"`)
indexes=()

# filter arrays by $TYPE


gpu_count=${#busids[@]}
for (( i=0; i < $gpu_count; i++)); do
	if [[ "${brands[$i]}" == "nvidia" && "$TYPE" == "cuda" ]]; then
	  indexes+=($i)
	  continue
	else # remove arrays data
		unset temps[$i]
		unset fans[$i]
		unset powers[$i]
		unset busids[$i]
		unset brands[$i]
	fi
done

 else
 gpu_count=0
 fi
 
  cpu_temp=$(cpu-temp)
  [[ -z $cpu_temp ]] && cpu_temp=null



echo ----------
  echo cpu_count: $cpu_count
  echo gpu_count: $gpu_count
  echo gpu_stats: $gpu_stats
  echo cpu_indexes_array: $cpu_indexes_array
  echo ---------- 
  




if [[ $gpu_count -eq 0 ]]; then
    # CPU
    hs[0]=$khs
    temp[0]=$cpu_temp
    fan[0]=""
    bus_numbers[0]="null"
else
    # GPUs
    gpu_temp=$(jq '.temp' <<< $gpu_stats)
    gpu_fan=$(jq '.fan' <<< $gpu_stats)
    gpu_bus=$(jq '.busids' <<< $gpu_stats)
  	if [[ $cpu_indexes_array != '[]' ]]; then
      #remove Internal Gpus
  		gpu_temp=$(jq -c "del(.$cpu_indexes_array)" <<< $gpu_temp) &&
  		gpu_fan=$(jq -c "del(.$cpu_indexes_array)" <<< $gpu_fan) &&
  		gpu_bus=$(jq -c "del(.$cpu_indexes_array)" <<< $gpu_bus)
    fi
    for (( i=0; i < ${gpu_count}; i++ )); do
      hs[$i]=`sed "s/$ESC\[[^Gm]*[Gm]//g;s/$ESC%G//g;s/$CR//g" ${CUSTOM_LOG_BASENAME}.log | tail -n100 | grep -w "CUDA" | grep -w "GPU #$i" | awk '{print $6/1000}' | tail -n1`
      [[ -z ${hs[$i]} ]] && hs[$i]=0     
      temp[$i]=$(jq .[$i] <<< $gpu_temp)
      fan[$i]=$(jq .[$i] <<< $gpu_fan)
      busid=$(jq .[$i] <<< $gpu_bus)
      bus_numbers[$i]=`echo $busid | cut -d ":" -f1 | cut -c2- | awk -F: '{ printf "%d\n",("0x"$1) }'`
      gpu_hs_tot=`sed "s/$ESC\[[^Gm]*[Gm]//g;s/$ESC%G//g;s/$CR//g" ${CUSTOM_LOG_BASENAME}.log | tail -n100 | grep -w "CUDA" | grep -w "Total hashrate" | awk '{print $5/1000}' | tail -n1`
    done
fi
cpu=`cat ${CUSTOM_LOG_BASENAME}.log | tail -n100 | grep -w "CPU" | awk '{print $1}' | tail -n1`
if [[ $cpu == "CPU" ]]; then
      hash_cpu=`sed "s/$ESC\[[^Gm]*[Gm]//g;s/$ESC%G//g;s/$CR//g" ${CUSTOM_LOG_BASENAME}.log | tail -n100 | grep -w "CPU" | awk '{print $15}' | tail -n1`
      if [[ $hash_cpu == "H/s" ]]; then
        cpu_hs=`sed "s/$ESC\[[^Gm]*[Gm]//g;s/$ESC%G//g;s/$CR//g" ${CUSTOM_LOG_BASENAME}.log | tail -n100 | grep -w "CPU" | awk '{print $14/1000}' | tail -n1`
        hs[$gpu_count]=`sed "s/$ESC\[[^Gm]*[Gm]//g;s/$ESC%G//g;s/$CR//g" ${CUSTOM_LOG_BASENAME}.log | tail -n100 | grep -w "CPU" | awk '{print $14/1000}' | tail -n1`
      elif [[ $hash_cpu == "KH/s" ]]; then
        cpu_hs=`sed "s/$ESC\[[^Gm]*[Gm]//g;s/$ESC%G//g;s/$CR//g" ${CUSTOM_LOG_BASENAME}.log | tail -n100 | grep -w "CPU" | awk '{print $14}' | tail -n1`
        hs[$gpu_count]=`sed "s/$ESC\[[^Gm]*[Gm]//g;s/$ESC%G//g;s/$CR//g" ${CUSTOM_LOG_BASENAME}.log | tail -n100 | grep -w "CPU" | awk '{print $14}' | tail -n1`
      fi
    temp[$gpu_count]="$cpu_temp"
    fan[$gpu_count]=""
    bus_numbers[$gpu_count]="null"
fi


[[ -z $cpu_hs ]] && cpu_hs=0
[[ -z $gpu_hs_tot ]] && gpu_hs_tot=0

khs=$(bc <<<"$gpu_hs_tot+$cpu_hs")

  stats=$(jq -nc \
            --arg khs "$khs" \
            --arg hs_units "$hs_units" \
            --argjson hs "`echo ${hs[@]} | tr " " "\n" | jq -cs '.'`" \
            --argjson temp "`echo ${temp[@]} | tr " " "\n" | jq -cs '.'`" \
            --argjson fan "`echo ${fan[@]} | tr " " "\n" | jq -cs '.'`" \
            --arg uptime "$uptime" \
            --arg ver "$ver" \
            --arg ac "$ac" --arg rj "$rj" \
            --arg algo "$algo" \
            --argjson bus_numbers "`echo ${bus_numbers[@]} | tr " " "\n" | jq -cs '.'`" \
            '{$hs, $hs_units, $temp, $fan, $uptime, $ver, ar: [$ac, $rj], $algo, $bus_numbers}')

else
  stats=""
  khs=0
fi

# debug output

 echo KHS:   $khs
 echo AC \ RJ: $ac \ $rj
 echo Output: $stats
