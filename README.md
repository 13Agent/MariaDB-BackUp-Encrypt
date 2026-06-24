# MariaDB Backup Encrypt

> Encrypted MariaDB/MySQL backups using AES-256 + RSA.

[Русский](README.ru.md) · [עברית](README.he.md)

## Files

| File | Description |
|------|-------------|
| `mysql_backup.sh` | Creates encrypted database dump |
| `decrypt_backup.sh` | Decrypts backup (Linux) |
| `decrypt_backup.ps1` | Decrypts backup (Windows) |
| `mysqldump-secure.cnf` | Database connection config |

## Quick Start

### 1. Install OpenSSL

**Linux:** `sudo apt install openssl` / `sudo yum install openssl`

**Windows:** Download from [slproweb.com](https://slproweb.com/products/Win32OpenSSL.html) and add to PATH.

### 2. Generate RSA keys

```bash
openssl genpkey -algorithm RSA -out private.pem -pkeyopt rsa_keygen_bits:4096
openssl rsa -pubout -in private.pem -out public_key.pem
chmod 600 private.pem
```

### 3. Configure DB connection

Edit `mysqldump-secure.cnf`:

```ini
[client]
user = root
password = your_password
```

### 4. Create backup

```bash
./mysql_backup.sh database_name
```

Output folder: `DATABASE/YYYYMMDD/HHMM/` with files:
- `*.sql.gz.enc` — encrypted dump
- `*.key.enc` — RSA-encrypted AES key
- `*.sha256` — checksum

### 5. Decrypt

**Linux:**
```bash
./decrypt_backup.sh key.enc dump.sql.gz.enc dump.sql
```

**Windows:**
```powershell
.\decrypt_backup.ps1 key.enc dump.sql.gz.enc dump.sql
```

## Encryption scheme

```
mysqldump → gzip → AES-256-CBC → *.sql.gz.enc
                    AES key → RSA-4096 (OAEP/SHA-256) → *.key.enc
```

## Security notes

- `mysqldump-secure.cnf` stores plaintext password — keep it safe and never commit it
- `private.pem` must never be exposed; keep it offline or in secure storage
