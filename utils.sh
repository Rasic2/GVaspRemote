#!/usr/bin/env bash

function check_ip(){
	IP=$1
    VALID_CHECK=$(echo $IP|awk -F. '$1<=255 && $2<=255 && $3<=255 && $4<=255 {print "yes"}')
    if echo $IP | grep -E "^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$" > /dev/null; then
		if [[ $VALID_CHECK == "yes" ]]; then
        	export IPFLAG=1
        else
            export IPFLAG=0
        fi
    else
        export IPFLAG=0
    fi
}
