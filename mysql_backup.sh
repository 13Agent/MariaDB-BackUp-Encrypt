#!/bin/bash
# /usr/local/bin/mysql_backup.sh

set -euo pipefail

DB_NAME="${1:-}"

PUBKEY="./public_key.pem"
BACKUP_DIR="DATABASE"


DATE_FORMAT='%Y%m%d'
CURRENT_DATE=$(date +"${DATE_FORMAT}")
CURRENT_TIME=$(date +"%H%M")


DATE=$(date +%Y%m%d-%H%M%S)
DUMP_ENC="$BACKUP_DIR/${CURRENT_DATE}/${CURRENT_TIME}/${DB_NAME}.${CURRENT_DATE}-${CURRENT_TIME}.sql.gz.enc"
KEY_ENC="$BACKUP_DIR/${CURRENT_DATE}/${CURRENT_TIME}/${DB_NAME}.${CURRENT_DATE}-${CURRENT_TIME}.key.enc"
DEFAULTS_FILE="./mysqldump-secure.cnf"


[ ! -d "$BACKUP_DIR/${CURRENT_DATE}/${CURRENT_TIME}" ] && mkdir -p "$BACKUP_DIR/${CURRENT_DATE}/${CURRENT_TIME}"


log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"; }

mkdir -p "$BACKUP_DIR"
chmod 700 "$BACKUP_DIR"

log "Генерируем AES ключ..."
AES_KEY=$(openssl rand -hex 32)
AES_IV=$(openssl rand -hex 16)

log "Дампим и шифруем базу..."
mysqldump \
    --defaults-file="$DEFAULTS_FILE" \
    --single-transaction \
    --quick \
    --lock-tables=false \
    "$DB_NAME" \
    | gzip \
    | openssl enc \
        -aes-256-cbc \
        -K "$AES_KEY" \
        -iv "$AES_IV" \
        -out "$DUMP_ENC"

log "Шифруем AES ключ через RSA (pkeyutl)..."
echo "$AES_KEY:$AES_IV" \
    | openssl pkeyutl \
        -encrypt \
        -pubin \
        -inkey "$PUBKEY" \
        -pkeyopt rsa_padding_mode:oaep \
        -pkeyopt rsa_oaep_md:sha256 \
        -out "$KEY_ENC"

# Контрольная сумма
sha256sum "$DUMP_ENC" > "$BACKUP_DIR/${CURRENT_DATE}/${CURRENT_TIME}/${DB_NAME}.${CURRENT_DATE}-${CURRENT_TIME}.sha256"

# Очищаем ключи
unset AES_KEY AES_IV

chmod 600 "$DUMP_ENC" "$KEY_ENC"

log "Готово: $(ls -lh $DUMP_ENC | awk '{print $5}')"
