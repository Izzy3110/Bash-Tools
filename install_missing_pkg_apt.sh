#!/bin/bash


LOG_FILE="/var/log/missing_apt.log"

ERRORS_COUNT=0
ACTION_POST_LOG_AFTER=0
ACTION_DONT_LOG=0

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


function usage {
  cat << EOF # remove the space between << and EOF, this is due to web plugin issue
Usage: $(basename "${BASH_SOURCE[0]}") [-h] [-a] package_name [package_name...]

Check for missing apt-packages and install them if missing

Available options:

-h, --help      Print this help and exit
-d              Don't log to file
-a              Print created last lines of log-file after
EOF
  exit
}

if [[ $# -gt 1 ]]; then
    echo "> getting missing packages"
    declare -a myNotInstalledPkgs=()
    count=0
    for package in "$@"
    do 
        if [[ $package =~ "-a" ]];then 
            ACTION_POST_LOG_AFTER=1
        else
            if [[ $package =~ "-d" ]];then 
                ACTION_DONT_LOG=1
            else
                result_=$(check_pkg_installed $package)
                if [[ $result_ -ne 0 ]]; then
                    myNotInstalledPkgs+=("${package}")
                fi
            fi
        fi 
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
                if [[ $ACTION_DONT_LOG -eq 0 ]]; then
                    echo $(date +"%d.%m.%Y %T.%N")": installed $apt_str" >> ${LOG_FILE}
                    log_lines=$((log_lines+1))
                fi
            fi
        else
            echo "not doing anything"
            ERRORS_COUNT=$((ERRORS_COUNT+1))
        fi
    else
        if [[ $ACTION_DONT_LOG -eq 0 ]]; then
            echo $(date +"%d.%m.%Y %T.%N")": no packages missing" >> ${LOG_FILE}
            log_lines=$((log_lines+1))
        fi
        echo "< no packages missing"
    fi
    if [[ $ACTION_DONT_LOG -eq 0 ]]; then
        echo $(date +"%d.%m.%Y %T.%N")": ${ERRORS_COUNT} errors detected" >> ${LOG_FILE}
        log_lines=$((log_lines+1))
    fi
    
else
    usage
fi
    
if [[ $ACTION_POST_LOG_AFTER -eq 1 ]]; then
    tail -n $log_lines ${LOG_FILE}
fi
