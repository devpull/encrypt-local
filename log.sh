#!/bin/bash

# log file by date
FILE_DATE=./log/$(date +%d%m%Y)

# log
# redirect stout & asterr to log file
# from: http://serverfault.com/questions/103501/how-can-i-fully-log-all-bash-scripts-actions
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>>${FILE_DATE}.log 2>&1

function log() {

    if [[ ! -d "${WORK_PATH}/log" ]]; then
        mkdir -p ${WORK_PATH}/log
    fi

    DATE=$(date +%d%m%Y)
    DTIME=$(date +%d.%m.%Y[%H:%M])

    echo "${DTIME} - $1" >> "${WORK_PATH}/${FILE_DATE}.log"
}
