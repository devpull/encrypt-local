#!/bin/bash

REG_FILE="${WORK_PATH}/reg/reg.lst"

function reg() {

    if [[ ! -d "${WORK_PATH}/reg" ]]; then
        mkdir -p ${WORK_PATH}/reg
    fi

    DATE=$(date +%d%m%Y)
    DTIME=$(date +%d.%m.%Y[%H:%M])

    echo "${DTIME} - $1" >> "${REG_FILE}"
}