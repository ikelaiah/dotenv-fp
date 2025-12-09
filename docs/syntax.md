# 📝 .env File Syntax Guide

This guide covers all the syntax features supported by dotenv-fp.

## Basic Syntax

```bash
# Simple key-value pairs
KEY=value
DATABASE_URL=postgresql://localhost/mydb
PORT=3000
```

**Rules:**
- Keys are case-sensitive (`PORT` ≠ `port`)
- Keys can contain letters, numbers, and underscores
- No spaces around the `=` sign
- Values are trimmed of leading/trailing whitespace (unless quoted)

---

## Comments

```bash
# This is a comment (full line)
DATABASE_URL=postgresql://localhost/mydb  # Inline comment

# Empty lines are ignored

```

---

## Quoted Values

### Double Quotes

Preserve spaces and allow escape sequences:

```bash
MESSAGE="Hello, World!"
PATH="C:\Users\My Name\Documents"
MULTIWORD="This has   multiple   spaces"
```

### Single Quotes

Literal strings — no escape processing:

```bash
REGEX='^\d{3}-\d{4}$'
TEMPLATE='Hello ${NAME}'  # ${NAME} stays literal
```

### Unquoted Values

Simple values without special characters:

```bash
HOST=localhost
PORT=3000
DEBUG=true
```

---

## Variable Interpolation

Reference other variables using `${VAR}` or `$VAR`:

```bash
# Define base values
APP_NAME=MyApp
APP_VERSION=1.0.0
BASE_URL=https://api.example.com

# Reference them
APP_TITLE=${APP_NAME} v${APP_VERSION}
API_USERS=${BASE_URL}/users
API_HEALTH=$BASE_URL/health

# Works with system environment variables too
HOME_CONFIG=${HOME}/.myapp/config
USER_CACHE=${USERPROFILE}/.cache
```

**Resolution order:**
1. Variables defined earlier in the same file
2. System environment variables

**Note:** Single-quoted values don't interpolate:
```bash
LITERAL='${NOT_REPLACED}'  # Stays as '${NOT_REPLACED}'
```

---

## Multi-line Values

Use quotes for values spanning multiple lines:

```bash
PRIVATE_KEY="-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEA0Z3VS5JJcds3xfn/ygWyF8PbnGy
...more lines...
-----END RSA PRIVATE KEY-----"

SQL_QUERY="SELECT *
FROM users
WHERE active = true
ORDER BY created_at"

JSON_CONFIG='{
  "host": "localhost",
  "port": 3000,
  "debug": true
}'
```

---

## Export Prefix

For shell compatibility, the `export` keyword is supported and ignored:

```bash
export DATABASE_URL=postgresql://localhost/mydb
export PORT=3000
```

This allows the same `.env` file to be sourced in shell scripts:
```bash
source .env
echo $DATABASE_URL
```

---

## Arrays / Lists

Store comma-separated values and parse with `GetArray()`:

```bash
ALLOWED_HOSTS=localhost,127.0.0.1,example.com
FEATURES=auth,logging,cache,metrics
PORTS=3000,3001,3002
```

```pascal
var
  Hosts: TStringArray;
  I: Integer;
begin
  Hosts := Env.GetArray('ALLOWED_HOSTS');
  for I := 0 to High(Hosts) do
    WriteLn(Hosts[I]);
end;
```

Custom separators:
```bash
TAGS=web;api;backend
```
```pascal
Tags := Env.GetArray('TAGS', ';');  // Split by semicolon
```

---

## Boolean Values

The following are recognized as truthy/falsy:

| Truthy | Falsy |
|--------|-------|
| `true` | `false` |
| `True` | `False` |
| `TRUE` | `FALSE` |
| `yes` | `no` |
| `Yes` | `No` |
| `YES` | `NO` |
| `1` | `0` |
| `on` | `off` |
| `On` | `Off` |
| `ON` | `OFF` |

```bash
DEBUG=true
FEATURE_ENABLED=yes
USE_CACHE=1
MAINTENANCE_MODE=off
```

---

## Special Characters

### In Double Quotes

```bash
# Spaces preserved
MESSAGE="Hello   World"

# Special characters
SYMBOLS="!@#$%^&*()"
```

### In Single Quotes

```bash
# Everything is literal
REGEX='^\d+$'
DOLLAR='$100'
```

### Unquoted (Escape or Avoid)

```bash
# Simple values only
SIMPLE=no_special_chars
```

---

## Complete Example

```bash
# ===========================================
# Application Configuration
# ===========================================

# App identity
APP_NAME=MyAwesomeApp
APP_VERSION=1.0.0
APP_TITLE="${APP_NAME} v${APP_VERSION}"

# Server settings
HOST=0.0.0.0
PORT=3000
DEBUG=true

# Database
DATABASE_HOST=localhost
DATABASE_PORT=5432
DATABASE_NAME=myapp_dev
DATABASE_URL="postgresql://${DATABASE_HOST}:${DATABASE_PORT}/${DATABASE_NAME}"

# Security (never commit real values!)
SECRET_KEY="change-me-in-production"
API_KEY='sk_test_abc123'

# Features
ALLOWED_HOSTS=localhost,127.0.0.1
ENABLED_FEATURES=auth,logging,cache

# Multi-line certificate
SSL_CERT="-----BEGIN CERTIFICATE-----
MIIC+zCCAeOgAwIBAgIJALZT...
-----END CERTIFICATE-----"

# Shell compatible
export SHELL_VAR=works_in_bash_too
```

---

## Best Practices

1. **Never commit secrets** — Use `.env.example` with placeholder values
2. **Use quotes for complex values** — Spaces, special chars, multi-line
3. **Group related variables** — Use comments to organize sections
4. **Use meaningful names** — `DATABASE_URL` not `DB`
5. **Provide defaults in code** — Don't rely on `.env` for non-sensitive defaults
