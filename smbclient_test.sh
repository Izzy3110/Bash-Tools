#!/bin/bash

INTERACTIVE=0

for arg in $@;
do
	echo "arg: "$arg
	myarg="${arg:1}"
	if [[ $myarg == "i" ]]; then
		INTERACTIVE=1
	fi
done

SMB_SERVER_ADDRESS="wylnas1.myqnapcloud.com"

USER_="${1}"
PASSWORD_="${2}"

ENCRYPTED_CREDENTAILS_FILE="/var/secure/cred.txt.enc"

DEFAULT_PASSWORD="qwert123"


if [[ $INTERACTIVE -eq 1 ]]; then
	read -s PASSWORD_
fi

# touch /tmp/cred.tmp
# buf_="username="$USER_"\n"
# buf_+="password="$PASSWORD_
# 
# echo -e $buf_ > /tmp/cred.tmp
# rm -rf /tmp/cred.tmp
if [[ ${#PASSWORD_} -eq 0 ]]; then
  PASSWORD_=$DEFAULT_PASSWORD
fi

if [[ $INTERACTIVE -eq 1 ]]; then
	CRED_FILE=$(/bin/bash decrypt_file.sh ${PASSWORD_} ${ENCRYPTED_CREDENTAILS_FILE})
else
	CRED_FILE=$(/bin/bash decrypt_file.sh ${PASSWORD_} ${ENCRYPTED_CREDENTAILS_FILE})
fi

smbclient -U $USER_ -A $CRED_FILE -L //${SMB_SERVER_ADDRESS} 2>&1 > /dev/null

ret_=$?
if [[ $ret_ -eq 0 ]]; then
	echo "decrypted ok"
	smbclient -U $USER_ -A $CRED_FILE -L //${SMB_SERVER_ADDRESS} 
fi

rm -rf $CRED_FILE
