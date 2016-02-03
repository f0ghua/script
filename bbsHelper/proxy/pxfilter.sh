#!/bin/bash
#
# This script delete the duplicate ips from the proxy list, so that we
# can use different ip for each click

E_WRONGARGS=65

arrayIpPool=()
arrayPx=()

ipExit="false"

case "$1" in
    "") echo "Usage: `basename $0` [proxy file]"; exit $E_WRONGARGS;;
    * ) proxyFile=$1;;
esac

while IFS=: read ip port; do

    for ipItem in ${arrayIpPool[@]};do
#        echo "ipItem = $ipItem, ip = $ip"
        if [[ $ipItem = "$ip" ]];then
#            echo "$ip has already in arrayIpPool"
            ipExit="true"
        fi
    done

    if [[ $ipExit != "true" ]];then
        arrayIpPool[${#arrayIpPool[*]}]=$ip
        arrayPx[${#arrayPx[*]}]="$ip:$port"
    fi
    ipExit="false"
    
done < $proxyFile

#echo "${arrayIpPool[@]}"
#echo "${arrayPx[@]}"
for proxy in ${arrayPx[@]};do
    echo "$proxy"
done
