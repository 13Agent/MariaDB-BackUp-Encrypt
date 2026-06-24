# MariaDB Backup Encrypt

> Encrypted MariaDB/MySQL backups using AES-256 + RSA.

---

## English

### Files

| File | Description |
|------|-------------|
| `mysql_backup.sh` | Creates encrypted database dump |
| `decrypt_backup.sh` | Decrypts backup (Linux) |
| `decrypt_backup.ps1` | Decrypts backup (Windows) |
| `mysqldump-secure.cnf` | Database connection config |

### Quick Start

**1. Install OpenSSL**

Linux: `sudo apt install openssl` / `sudo yum install openssl`

Windows: Download from [slproweb.com](https://slproweb.com/products/Win32OpenSSL.html) and add to PATH.

**2. Generate RSA keys**

```bash
openssl genpkey -algorithm RSA -out private.pem -pkeyopt rsa_keygen_bits:4096
openssl rsa -pubout -in private.pem -out public_key.pem
chmod 600 private.pem
```

**3. Configure DB connection**

Edit `mysqldump-secure.cnf`:

```ini
[client]
user = root
password = your_password
```

**4. Create backup**

```bash
./mysql_backup.sh database_name
```

Output folder: `DATABASE/YYYYMMDD/HHMM/` with files:
- `*.sql.gz.enc` — encrypted dump
- `*.key.enc` — RSA-encrypted AES key
- `*.sha256` — checksum

**5. Decrypt**

Linux:
```bash
./decrypt_backup.sh key.enc dump.sql.gz.enc dump.sql
```

Windows:
```powershell
.\decrypt_backup.ps1 key.enc dump.sql.gz.enc dump.sql
```

### Encryption scheme

```
mysqldump → gzip → AES-256-CBC → *.sql.gz.enc
                    AES key → RSA-4096 (OAEP/SHA-256) → *.key.enc
```

---

## Русский

### Состав

| Файл | Назначение |
|------|-----------|
| `mysql_backup.sh` | Создание зашифрованного дампа БД |
| `decrypt_backup.sh` | Расшифровка дампа (Linux) |
| `decrypt_backup.ps1` | Расшифровка дампа (Windows) |
| `mysqldump-secure.cnf` | Конфиг для подключения к БД |

### Быстрый старт

**1. Установка OpenSSL**

Linux: `sudo apt install openssl` / `sudo yum install openssl`

Windows: Скачать с [slproweb.com](https://slproweb.com/products/Win32OpenSSL.html) и добавить в PATH.

**2. Генерация RSA-ключей**

```bash
openssl genpkey -algorithm RSA -out private.pem -pkeyopt rsa_keygen_bits:4096
openssl rsa -pubout -in private.pem -out public_key.pem
chmod 600 private.pem
```

**3. Настройка подключения к БД**

Отредактируйте `mysqldump-secure.cnf`:

```ini
[client]
user = root
password = ваш_пароль
```

**4. Создание бэкапа**

```bash
./mysql_backup.sh имя_базы
```

Результат — папка `DATABASE/YYYYMMDD/HHMM/` с файлами:
- `*.sql.gz.enc` — зашифрованный дамп
- `*.key.enc` — зашифрованный RSA AES-ключ
- `*.sha256` — контрольная сумма

**5. Расшифровка**

Linux:
```bash
./decrypt_backup.sh key.enc dump.sql.gz.enc dump.sql
```

Windows:
```powershell
.\decrypt_backup.ps1 key.enc dump.sql.gz.enc dump.sql
```

### Схема шифрования

```
mysqldump → gzip → AES-256-CBC → *.sql.gz.enc
                    AES-ключ → RSA-4096 (OAEP/SHA-256) → *.key.enc
```

---

## עברית

### קבצים

| קובץ | תיאור |
|------|-------|
| `mysql_backup.sh` | יצירת גיבוי מוצפן של מסד הנתונים |
| `decrypt_backup.sh` | פענוח גיבוי (לינוקס) |
| `decrypt_backup.ps1` | פענוח גיבוי (חלונות) |
| `mysqldump-secure.cnf` | קובץ הגדרות חיבור למסד הנתונים |

### התחלה מהירה

**1. התקנת OpenSSL**

לינוקס: `sudo apt install openssl` / `sudo yum install openssl`

חלונות: הורידו מ-[slproweb.com](https://slproweb.com/products/Win32OpenSSL.html) והוסיפו ל-PATH.

**2. יצירת מפתחות RSA**

```bash
openssl genpkey -algorithm RSA -out private.pem -pkeyopt rsa_keygen_bits:4096
openssl rsa -pubout -in private.pem -out public_key.pem
chmod 600 private.pem
```

**3. הגדרת חיבור למסד הנתונים**

ערכו את `mysqldump-secure.cnf`:

```ini
[client]
user = root
password = הסיסמה_שלכם
```

**4. יצירת גיבוי**

```bash
./mysql_backup.sh שם_מסד_הנתונים
```

תיקיית הפלט: `DATABASE/YYYYMMDD/HHMM/` עם הקבצים:
- `*.sql.gz.enc` — גיבוי מוצפן
- `*.key.enc` — מפתח AES מוצפן ב-RSA
- `*.sha256` — סכום ביקורת

**5. פענוח**

לינוקס:
```bash
./decrypt_backup.sh key.enc dump.sql.gz.enc dump.sql
```

חלונות:
```powershell
.\decrypt_backup.ps1 key.enc dump.sql.gz.enc dump.sql
```

### תוכנית הצפנה

```
mysqldump → gzip → AES-256-CBC → *.sql.gz.enc
                    מפתח AES → RSA-4096 (OAEP/SHA-256) → *.key.enc
```
