#!/bin/bash
# decrypt_backup.sh
#./decrypt_backup.sh \
#    dump_20240506.key.enc \
#    dump_20240506.sql.gz.enc \
#    dump.sql
#

PRIVATE_KEY="./private.pem"
KEY_ENC="$1"
DUMP_ENC="$2"
OUTPUT="$3"

if [ -z "$KEY_ENC" ] || [ -z "$DUMP_ENC" ] || [ -z "$OUTPUT" ]; then
    echo "Использование: decrypt_backup.sh <key.enc> <dump.enc> <output.sql>"
    exit 1
fi

echo ">>> Расшифровываем AES ключ..."
KEY_IV=$(openssl pkeyutl \
    -decrypt \
    -inkey "$PRIVATE_KEY" \
    -in "$KEY_ENC" \
    -pkeyopt rsa_padding_mode:oaep \
    -pkeyopt rsa_oaep_md:sha256)

AES_KEY=$(echo "$KEY_IV" | cut -d: -f1)
AES_IV=$(echo "$KEY_IV"  | cut -d: -f2)

echo ">>> Расшифровываем дамп..."
openssl enc -d \
    -aes-256-cbc \
    -K "$AES_KEY" \
    -iv "$AES_IV" \
    -in "$DUMP_ENC" \
    | gunzip > "$OUTPUT"

unset AES_KEY AES_IV KEY_IV

echo ">>> Готово: $OUTPUT"
echo "    Размер: $(du -h $OUTPUT | cut -f1)"
head -3 "$OUTPUT"