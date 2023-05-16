#!/usr/bin/env bash

SrcDir=`realpath $0 | xargs dirname`
KeysDir=${SrcDir}/keys

source $SrcDir/color.sh
source $SrcDir/utils.sh

# Parse Args
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

# Locate identify files
ip=`echo ${remote_file} | awk -F_ '{print $1}'`
user=`echo ${remote_file} | awk -F_ '{print $2}'`
port=22

check_ip $ip
if [ $IPFLAG -eq 0 ];then
	ip=`grep $ip ${KeysDir}/config 2>/dev/null | awk '{print $2}'`
	port=`grep $ip ${KeysDir}/config 2>/dev/null | awk '{print $3}'`
	check_ip $ip
	if [ $IPFLAG -eq 0 ];then
		echo
		echo -e "${RED}  !!!! Error: The key format is not right!${RESET}"
		echo
		exit
	fi
fi

ssh_identify=${KeysDir}/${ip}_${user}
host=${ip}:${port}

# Start Process
echo
echo -e "----------------->${RED} GVasp Remote Process Tool ${RESET}<-------------------------"
echo
echo -e "+-----------------------+---------------------------------------------+"
printf  "|${RED}  input command       ${RESET} | ${GREEN} %24s                  ${RESET} |\n" "$gvasp_command"
printf  "|${RED}  remote host         ${RESET} | ${GREEN} %18s (Host) %8s (USER) ${RESET} |\n" "$host" "$user"
echo -e "+-----------------------+---------------------------------------------+"

WorkDir=`pwd`
DirRemoveHOME=${WorkDir//$HOME}

# process the gvasp_command
echo
echo -e "${BOLD}#---> GVasp output${RESET}"
eval $gvasp_command
echo -e "${BOLD}<---# End GVasp output${RESET}"
echo

echo -e "${BOLD}#---> Mapping Directory:${RESET} ${BLUE}\$HOME${DirRemoveHOME}${RESET}"
ssh $user@$ip -i ${ssh_identify} -p $port -o PubkeyAcceptedKeyTypes=+ssh-dss "echo \${HOME}${DirRemoveHOME} > ~/.gvasp_remote; mkdir -p \${HOME}${DirRemoveHOME};"
scp -i ${ssh_identify} -P $port -o PubkeyAcceptedKeyTypes=+ssh-dss $user@$ip:~/.gvasp_remote . > /dev/null
target_directory=`cat .gvasp_remote`
rm -rf .gvasp_remote

echo
echo -e "${BOLD}#---> Transfer files${RESET}"
echo
scp -i ${ssh_identify} -P $port -o PubkeyAcceptedKeyTypes=+ssh-dss ./* $user@$ip:$target_directory
echo
echo -e "${BOLD}<---# End Transfer files${RESET}"

ssh -i ${ssh_identify} -p $port -o PubkeyAcceptedKeyTypes=+ssh-dss $user@$ip "rm -rf ~/.gvasp_remote;"
echo

