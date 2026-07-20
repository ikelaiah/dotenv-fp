# Hello dotenv-fp

This is the recommended first example for beginners. It strictly loads the
root `.env`, validates all configuration problems together, and reads
namespaced typed values.

From the repository root:

```bash
cp .env.example .env
bash ./build-examples.sh
./examples-bin/hello_dotenv
```

Windows PowerShell:

```powershell
Copy-Item .env.example .env
./build-examples.ps1
.\examples-bin\hello_dotenv.exe
```

Expected output:

```text
Hello from My First Pascal App!
Port: 3000
Debug: TRUE
```

The `APP_` prefix prevents unrelated process variables such as `PORT` and
`DEBUG` from overriding the example.
