#!/bin/bash

/bin/bash install_missing_pkg_apt.sh gawk ping4 -a

PATH="/root"
input="${PATH}/ntp_server_de.lst"
myArrayUrls=()
I_=0
while IFS= read -r line
do
  # echo "$I_ $line"
  echo " ----------------------------------------------- "
  addr=$(echo $line | /usr/bin/gawk '{ print $2 }')
  myArrayUrls+=("$addr")
  I_=$((I_+1))
done < "${input}"

echo ${#myArrayUrls[@]}
for url in ${myArrayUrls[@]}; do
  echo $url
  ping_results=$(/usr/bin/ping4 -W 3 -c 1 $addr 2>&1)
  # I_P=0
  
  ipv4_addr=""
  icmp_seq_=""
  time_=""
  unit_=""
  
  IFS=$'\n'
  I_P=0
  for line_ in ${ping_results};
  do
#    echo "### ${I_P}: ${line_}"
    if [[ $I_P -eq 0 ]]; then
        ipv4_addr=$(echo $line_ | /usr/bin/gawk '{ print $3 }' | /usr/bin/tr -d '()')
    elif [[ $I_P -eq 1 ]]; then
        echo $line_
        icmp_seq_=$(echo $line_ | /usr/bin/gawk '{ print $6 }' | /usr/bin/gawk -F'=' '{ print $2 }')
        time_=$(echo $line_ | /usr/bin/gawk '{ print $8 }' | /usr/bin/gawk -F'=' '{ print $2 }')
        unit_=$(echo $line_ | /usr/bin/gawk '{ print $9 }')
    elif [[ $I_P -eq 3 ]]; then
        transmitted_p=$(echo $line_ | /usr/bin/gawk '{ print $1 }')
        received_p=$(echo $line_ | /usr/bin/gawk '{ print $4 }')
        loss_percent=$(echo $line_ | /usr/bin/gawk '{ print $6 }')
        time_ms=$(echo $line_ | /usr/bin/gawk '{ print $10 }')
        echo $time_ms
    elif [[ $I_P -eq 4 ]]; then
        echo $line_ | /usr/bin/gawk '{ print $4 }' | /usr/bin/gawk -F"/" '{ print $1 }'
        echo $line_ | /usr/bin/gawk '{ print $4 }' | /usr/bin/gawk -F"/" '{ print $2 }'
        
        
    else
        echo "### ${I_P}: ${line_}"
    fi
    I_P=$((I_P+1))
  done
  echo "##################"
done
