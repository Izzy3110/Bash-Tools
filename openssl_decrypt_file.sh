#!/bin/bash

if [[ $# -eq 0 ]]; then
	echo
	echo "Usage: $0 [password] [in-file]"
	echo
	echo
	exit
fi

dpkg -l openssl >/dev/null
if [[ $? -eq 1 ]]; then
	echo "no openssl"
fi

PASSWORD_="${1}"
FILE_="${2}"

SOURCE_PATH=$(realpath $FILE_)
SOURCE_DIR_=$(dirname $(realpath $FILE_))

TARGET_FILE=$(echo $(basename $(realpath $FILE_)))
TARGET_FILE=$(echo $TARGET_FILE | sed -r "s/\.wylenc//g")
TARGET_FILE="${TARGET_FILE}."$(date +%s%N | cut -b1-13)
TARGET_PATH=$SOURCE_DIR_/$TARGET_FILE

echo "${PASSWORD_}" | openssl enc -d -pass stdin -aes-256-cbc -iter 64 -in ${SOURCE_PATH} -out ${TARGET_PATH}
if [[ $? -eq 0 ]]; then
	echo "decrypted file: "$TARGET_PATH
fi

