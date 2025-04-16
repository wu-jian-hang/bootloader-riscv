#!/bin/bash

PRIVATE_KEY="private_key.pem"
PUBLIC_KEY_DER="public_key.der"

if [ ! -f "$PRIVATE_KEY" ]; then
    echo "RSA key not found, generate a pair of key..."
    openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:2048 -out private_key.pem >/dev/null 2>&1
    openssl rsa -in private_key.pem -pubout -out public_key.pem >/dev/null 2>&1
    openssl rsa -in public_key.pem -pubin -outform der -out public_key.der >/dev/null 2>&1
fi

if [ "$#" -lt 1 ]; then
    echo "Usage: \$0 <file1> <file2> ... <fil N>"
    exit 1
fi

for INPUT_FILE in "$@"; do
    if [ ! -f "$INPUT_FILE" ]; then
        echo "Error: file '$INPUT_FILE' not found, skip..."
        continue
    fi

    OUTPUT_FILE="${INPUT_FILE}.sig"

    openssl dgst -sha256 -sign private_key.pem -out "${OUTPUT_FILE}" "${INPUT_FILE}" >/dev/null 2>&1
done

for INPUT_FILE in "$@"; do
    if [ ! -f "$INPUT_FILE" ]; then
        echo "Error: file '$INPUT_FILE' not found, skip..."
        continue
    fi

    OUTPUT_FILE="${INPUT_FILE}.sig"
    HASH_NAME="${INPUT_FILE}.dgst"

    openssl dgst -sha256 -out "$HASH_NAME" "$INPUT_FILE" >/dev/null 2>&1
    if ! openssl dgst -sha256 -verify public_key.pem -signature "$OUTPUT_FILE" "$INPUT_FILE" >/dev/null 2>&1; then
        echo "verify failed: ${INPUT_FILE}"
    fi

    rm "$HASH_NAME"
done


