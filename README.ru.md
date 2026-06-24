# MariaDB Backup Encrypt

> Шифрованное резервное копирование MariaDB/MySQL с использованием AES-256 + RSA.

## Состав

| Файл | Назначение |
|------|-----------|
| `mysql_backup.sh` | Создание зашифрованного дампа БД |
| `decrypt_backup.sh` | Расшифровка дампа (Linux) |
| `decrypt_backup.ps1` | Расшифровка дампа (Windows) |
| `mysqldump-secure.cnf` | Конфиг для подключения к БД |

## Быстрый старт

### 1. Установка OpenSSL

**Linux:** `sudo apt install openssl` / `sudo yum install openssl`

**Windows:** Скачать с [slproweb.com](https://slproweb.com/products/Win32OpenSSL.html) и добавить в PATH.

### 2. Генерация RSA-ключей

```bash
openssl genpkey -algorithm RSA -out private.pem -pkeyopt rsa_keygen_bits:4096
openssl rsa -pubout -in private.pem -out public_key.pem
chmod 600 private.pem
```

### 3. Настройка подключения к БД

Отредактируйте `mysqldump-secure.cnf`:

```ini
[client]
user = root
password = ваш_пароль
```

### 4. Создание бэкапа

```bash
./mysql_backup.sh имя_базы
```

Результат — папка `DATABASE/YYYYMMDD/HHMM/` с файлами:
- `*.sql.gz.enc` — зашифрованный дамп
- `*.key.enc` — зашифрованный RSA AES-ключ
- `*.sha256` — контрольная сумма

### 5. Расшифровка

**Linux:**
```bash
./decrypt_backup.sh key.enc dump.sql.gz.enc dump.sql
```

**Windows:**
```powershell
.\decrypt_backup.ps1 key.enc dump.sql.gz.enc dump.sql
```

## Схема шифрования

```
mysqldump → gzip → AES-256-CBC → *.sql.gz.enc
                    AES-ключ → RSA-4096 (OAEP/SHA-256) → *.key.enc
```

## Безопасность

- `mysqldump-secure.cnf` содержит пароль в открытом виде — не сохраняйте его в репозиторий
- `private.pem` ни в коем случае не должен быть скомпрометирован — храните офлайн
