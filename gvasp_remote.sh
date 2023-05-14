#!/usr/bin/env bash

SrcDir=`realpath $0 | xargs dirname`
source $SrcDir/color.sh

gvasp_command=""
key_flag=0
remote_file=""
for arg in $@
do
	if [ $arg == "--key" ];then
		key_flag=1
	fi

	if [ $key_flag -eq 0 ];then
		gvasp_command="$gvasp_command $arg"
    else
		remote_file="$arg"
	fi
done

ip=`ls ${remote_file} | awk -F_ '{print $1}'`
user=`ls ${remote_file} | awk -F_ '{print $2}'`

echo
echo -e "${RED}  The input command is  : ${GREEN} $gvasp_command         ${RESET}"
echo -e "${RED}  The remote address is : ${GREEN}  $ip (IP) $user (USER) ${RESET}"

WorkDir=`pwd`
DirRemoveHOME=${WorkDir//$HOME}

ssh $user@$ip -i ${ip}_${user} "echo \${HOME}${DirRemoveHOME};"

