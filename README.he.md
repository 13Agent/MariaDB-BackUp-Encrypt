# MariaDB Backup Encrypt

> גיבויים מוצפנים של MariaDB/MySQL באמצעות AES-256 + RSA.

[English](README.md) · [Русский](README.ru.md)

## קבצים

| קובץ | תיאור |
|------|-------|
| `mysql_backup.sh` | יצירת גיבוי מוצפן של מסד הנתונים |
| `decrypt_backup.sh` | פענוח גיבוי (לינוקס) |
| `decrypt_backup.ps1` | פענוח גיבוי (חלונות) |
| `mysqldump-secure.cnf` | קובץ הגדרות חיבור למסד הנתונים |

## התחלה מהירה

### 1. התקנת OpenSSL

**לינוקס:** `sudo apt install openssl` / `sudo yum install openssl`

**חלונות:** הורידו מ-[slproweb.com](https://slproweb.com/products/Win32OpenSSL.html) והוסיפו ל-PATH.

### 2. יצירת מפתחות RSA

```bash
openssl genpkey -algorithm RSA -out private.pem -pkeyopt rsa_keygen_bits:4096
openssl rsa -pubout -in private.pem -out public_key.pem
chmod 600 private.pem
```

### 3. הגדרת חיבור למסד הנתונים

ערכו את `mysqldump-secure.cnf`:

```ini
[client]
user = root
password = הסיסמה_שלכם
```

### 4. יצירת גיבוי

```bash
./mysql_backup.sh שם_מסד_הנתונים
```

תיקיית הפלט: `DATABASE/YYYYMMDD/HHMM/` עם הקבצים:
- `*.sql.gz.enc` — גיבוי מוצפן
- `*.key.enc` — מפתח AES מוצפן ב-RSA
- `*.sha256` — סכום ביקורת

### 5. פענוח

**לינוקס:**
```bash
./decrypt_backup.sh key.enc dump.sql.gz.enc dump.sql
```

**חלונות:**
```powershell
.\decrypt_backup.ps1 key.enc dump.sql.gz.enc dump.sql
```

## תוכנית הצפנה

```
mysqldump → gzip → AES-256-CBC → *.sql.gz.enc
                    מפתח AES → RSA-4096 (OAEP/SHA-256) → *.key.enc
```

## אבטחה

- `mysqldump-secure.cnf` מכיל סיסמה בטקסט גלוי — אין לשמור אותו במאגר
- `private.pem` אסור שייחשף — שמרו אותו במערכת מאובטחת
