#! /bin/bash
# inc
# ARCH_DIR=""
# ENCR_DIR=""
. ./conf.sh
. ./log.sh
. ./reg.sh


log "+++ Session start"
echo "======================"
log "Source path: ${ARCH_DIR}"
log "Enc path: ${ENCR_DIR}"
log "Work path: ${WORK_PATH}"
echo "======================"


# encrypt files list
cd ${ARCH_DIR}
log "PWD: `pwd`"
ARCH_LST=$(find -iregex ".*\.\(zip\|tar\.gz\)")
log $'Found archives:\n'"$ARCH_LST"


# checking directory with archives
if [[ -z ${ARCH_LST// } ]]; then
    log "No files to encrypt"
    exit 0
fi


# iterating
for ARCH in ${ARCH_LST}; do

    log "arch $ARCH"
    log "Calc md5sum...wait..."

    MD5FULL=$(md5sum ${ARCH})
    MD5=(${MD5FULL})
    log "<--md5: $MD5"
    log "<--reg_file: $REG_FILE"
    if grep "${MD5}" "${REG_FILE}";then
        log "Already enc'ted $ARCH md5sum: $MD5 Continuing."
        continue
    fi

    # get filename
    FILE_NAME=$(basename ${ARCH})
    log "filename: ${FILE_NAME}"

    # get file destination path in enc folders mirror
    DEST_FILE=$(echo ${ARCH} | sed -e 's/\.\///')
    log "dest file: $DEST_FILE"

    DEST_FILE_FULL_PATH=$(dirname ${ENCR_DIR}/${DEST_FILE})
    log "fullpath: $DEST_FILE_FULL_PATH"

    if [[ ! -d ${DEST_FILE_FULL_PATH} ]]; then
        mkdir -p ${DEST_FILE_FULL_PATH}
    fi

    # enc
    log "Starting to enc ${ARCH_DIR}/${FILE_NAME} to ${ENCR_DIR}/${FILE_NAME}.enc"
    # 1. gen key for archive
    KEY_PATH=./${FILE_NAME}.key
    openssl rand -base64 32 -out ${KEY_PATH}
    # 2. enc archive with key
    openssl enc -aes-256-cbc -salt -in "${ARCH_DIR}/${DEST_FILE}" -out "${ENCR_DIR}/${DEST_FILE}.enc" -pass file:${KEY_PATH}
    # 3. enc key for that archive
    openssl rsautl -encrypt -inkey ${WORK_PATH}/public.pem -pubin -in ${KEY_PATH} -out "${DEST_FILE_FULL_PATH}/${FILE_NAME}.key.enc"
    # 4. removinng unenc'ted key
    rm -f ${KEY_PATH}.key

    log "${ARCH} to ${ARCH_DIR}/${FILE_NAME} to ${ENCR_DIR}/${FILE_NAME}.enc encted successfuly."

    # register
    log "--^Registering $MD5FULL"
    reg "$MD5FULL"

done


log "--- Ending session."