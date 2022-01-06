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

if [[ $# -gt 1 ]]; then
    echo "> getting missing packages"
    declare -a myNotInstalledPkgs=()
    count=0
    for package in "$@"
    do 
        result_=$(check_pkg_installed $package)
        if [[ $result_ -ne 0 ]]; then
            myNotInstalledPkgs+=("${package}")
        fi
    done
    
    apt_str=$(join_by " " ${myNotInstalledPkgs[@]})
    if [[ ${#apt_str} -gt 0 ]]; then
        apt install --simulate $apt_str 2>/dev/null 1>/dev/null
        if [[ $? -eq 0 ]]; then
            apt install $apt_str 2>/dev/null 1>/dev/null
            if [[ $? -eq 0 ]]; then
                echo "< installed missing packages"
            fi
        else
            echo "not doing anything"
        fi
    else
        echo "< no packages missing"
    fi
else
    if [[ $# -gt 0 ]]; then
    echo $#
    fi
fi
    
