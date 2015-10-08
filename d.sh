#! /bin/bash
# Decrypting archive with private cert and archive key.
#
# 0. Ask for archive location.
# 1. Ask for key location (default ./name.key.enc)
# 2. Ask for private key location (default ./private.pem)
# 3. Decrypt key with private key and password prompt
# 4. Decrypt archive with decrypted key
# 5. Delete decrypted key


PATH_TO_ARCH=""; FILE_NAME=""; PATH_TO_OUT=""; PATH_TO_KEY=""; PATH_TO_PEM=""; ANSWER="n"


# reset vars
function cleanup() {
    PATH_TO_ARCH=""; FILE_NAME=""; PATH_TO_OUT=""; PATH_TO_KEY=""; PATH_TO_PEM=""; ANSWER="n"
}


# set up all vars
function setup() {
    # enc'ted file location
    while [[ ! -f "$PATH_TO_ARCH" ]]; do
        if [[ ! -f "$PATH_TO_ARCH" ]] && [[ ! -z "$PATH_TO_ARCH" ]]; then echo "$PATH_TO_ARCH is not a file."; fi
        read -e -p "Absolute path to archive for decryption: " PATH_TO_ARCH
    done
    echo "---"

    # stripping file name
    FILE_NAME_ENC=$(basename ${PATH_TO_ARCH})
    FILE_NAME=${FILE_NAME_ENC%.enc}


    # path to output decrypted file
    while [[ -z "$PATH_TO_OUT" ]] || [[ -f ${PATH_TO_OUT} ]]; do
        read -e -p "Output file path: " PATH_TO_OUT
        if [[ -f ${PATH_TO_OUT} ]]; then echo "File: $PATH_TO_OUT already exists."; fi
    done
    echo "---"


    # enc'ted key location
    while [[ -z ${PATH_TO_KEY} ]] || [[ ! -f ${PATH_TO_KEY} ]]; do
        read -e -p "Absolute path to enc'ted key: " PATH_TO_KEY
        if [[ ! -f ${PATH_TO_KEY} ]]; then echo "$PATH_TO_KEY is not a file."; fi
    done
    echo "---"


    # private key location
    while [[ -z ${PATH_TO_PEM} ]] || [[ ! -f ${PATH_TO_PEM} ]]; do
        read -e -p "Absolute path to pem: [./private.pem] " PATH_TO_PEM
        # if read is "" than it means user wants default
        if [[ -z ${PATH_TO_PEM} ]]; then PATH_TO_PEM=${PATH_TO_PEM:=./private.pem}; fi
        if [[ ! -f ${PATH_TO_PEM} ]]; then echo "$PATH_TO_PEM is not a file."; fi
    done
    echo "---"


    echo "=================================="
    printf "File to decrypt. Path is:\t\t%s\n" ${PATH_TO_ARCH}
    printf "Enc'ted file name:\t%s\n" ${FILE_NAME_ENC}
    printf "File name is:\t\t%s\n" ${FILE_NAME}
    printf "Output file is:\t\t%s\n" ${PATH_TO_OUT}
    printf "Enc'ted key:\t\t%s\n" ${PATH_TO_KEY}
    printf "Key pem:\t\t%s\n" ${PATH_TO_PEM}
    echo "=================================="
}


# decrypt
function decrypt() {
    # decrypting key with private.pem
    echo "Decrypting aes key with rsa private key..."
    openssl rsautl -decrypt -inkey ${PATH_TO_PEM} -in ${PATH_TO_KEY} -out ${FILE_NAME}.key

    # chcking that the key was decrypted
    if [[ ! -f ${FILE_NAME}.key ]]; then echo "Error decrypting rsa key."; exit 1; fi

    # decrypting file with decrypted aes key
    echo "Decrypting file with aes key..."
    openssl enc -d -aes-256-cbc -in ${PATH_TO_ARCH} -out ${PATH_TO_OUT} -pass file:${FILE_NAME}.key

    # removing decrypted aes key
    echo "Removing decrypted aes key..."
    rm -f ${FILE_NAME}.key
}


# main
function run() {
    setup
    while [ "$ANSWER" != "y" ]; do
        read -p "Setup ok?[$ANSWER]" ANSWER
        ANSWER=${ANSWER:-n}
        if [ "${ANSWER}" = "y" ]; then
            decrypt
            echo "Decryption successful."
        else
            cleanup
            setup
        fi
    done
}


# start program
run

