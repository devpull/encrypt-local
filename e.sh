#! /bin/bash

# inc
. ./log.sh
# ARCH_DIR=""
# ENCR_DIR=""
. ./conf.sh

log "+++ Session start"

# encrypt files list
cd ${ARCH_DIR}
ARCH_LST=$(find -iregex ".*\.\(zip\|tar\.gz\)")
echo $'Found archives:\n'"$ARCH_LST"

# checking directory with archives
if [[ -z ${ARCH_LST// } ]]; then
    log "No files to encrypt"
    exit 0
fi

# iterating
for ARCH in ${ARCH_LST}; do

    echo "arch $ARCH"
    # get filename
    FILE_NAME=$(basename ${ARCH})
    echo "filename: ${FILE_NAME}"
    # get file destination path in enc folders mirror
    DEST_FILE=$(echo ${ARCH} | sed -e 's/\.\///')
    echo "dest file: $DEST_FILE"

    DEST_FILE_FULL_PATH=$(dirname ${ENCR_DIR}/${DEST_FILE})
    echo ""
    echo "fullpath: $DEST_FILE_FULL_PATH"
    echo ""
    mkdir -p ${DEST_FILE_FULL_PATH}

    # enc
    log "Starting to enc ${ARCH_DIR}/${FILE_NAME} to ${ENCR_DIR}/${FILE_NAME}.enc"
    # 1. gen key for archive
    openssl rand -base64 32 -out ${FILE_NAME}.key
    echo "key: ${WORK_PATH}/${FILE_NAME}.key"
    # 2. enc archive with key
    openssl enc -aes-256-cbc -salt -in "${ARCH_DIR}/${DEST_FILE}" -out "${ENCR_DIR}/${DEST_FILE}.enc" -pass file:${FILE_NAME}.key
    # 3. enc key for that archive
    openssl rsautl -encrypt -inkey ${WORK_PATH}/public.pem -pubin -in "${FILE_NAME}.key" -out "${DEST_FILE_FULL_PATH}/${FILE_NAME}.key.enc"
    # 4. removinng unenc'ted key
    rm -f ${FILE_NAME}.key

    log "${ARCH} to ${ARCH_DIR}/${FILE_NAME} to ${ENCR_DIR}/${FILE_NAME}.enc encted successfuly."

done

log "--- Ending session."