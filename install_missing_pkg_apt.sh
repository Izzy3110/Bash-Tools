#!/bin/bash

function join_by { local d=${1-} f=${2-}; if shift 2; then printf %s "$f" "${@/#/$d}"; fi; }

function check_pkg_installed {
    PACKAGE_NAME="${1}"
    PACKAGE_LINE=$(apt --installed list 2>/dev/null | grep "${PACKAGE_NAME}")
    if [[ ${#PACKAGE_LINE} -gt 0 ]]; then
        result_=0
    else
        result_=1
    fi
    echo $result_
}


LOG_FILE="/var/log/missing_apt.log"

ERRORS_COUNT=0
ACTION_POST_LOG_AFTER=0

if [[ $# -gt 1 ]]; then
    echo "> getting missing packages"
    declare -a myNotInstalledPkgs=()
    count=0
    for package in "$@"
    do 
        if [[ $package =~ "-a" ]];then 
            echo "option:output log after"
            ACTION_POST_LOG_AFTER=1
        else
            echo $package
            result_=$(check_pkg_installed $package)
            if [[ $result_ -ne 0 ]]; then
                myNotInstalledPkgs+=("${package}")
            fi
        fi
        # 
    done
    log_lines=0
    apt_str=$(join_by " " ${myNotInstalledPkgs[@]})
    if [[ ${#apt_str} -gt 0 ]]; then
        
        if [[ ! -f "${LOG_FILE}" ]]; then
            touch "${LOG_FILE}"
        fi
        
        apt install --simulate $apt_str 2>/dev/null 1>/dev/null
        if [[ $? -eq 0 ]]; then
            apt install $apt_str 2>/dev/null 1>/dev/null
            if [[ $? -eq 0 ]]; then
                echo "< installed missing packages"
                echo $(date +"%d.%m.%Y %T.%N")": installed $apt_str" >> ${LOG_FILE}
                log_lines=$((log_lines+1))
            fi
        else
            echo "not doing anything"
            ERRORS_COUNT=$((ERRORS_COUNT+1))
        fi
    else
        echo $(date +"%d.%m.%Y %T.%N")": no packages missing" >> ${LOG_FILE}
        log_lines=$((log_lines+1))
        echo "< no packages missing"
    fi
    echo $(date +"%d.%m.%Y %T.%N")": ${ERRORS_COUNT} errors detected" >> ${LOG_FILE}
    log_lines=$((log_lines+1))
    
else
    if [[ $# -gt 0 ]]; then
        echo $#
    fi
fi
    
if [[ $ACTION_POST_LOG_AFTER -eq 1 ]]; then
    tail -n $log_lines ${LOG_FILE}
fi
