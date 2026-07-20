# Environment-aware Loading

This self-contained example demonstrates `LoadForEnvironment()` with base,
development, and production configurations.

The program creates non-secret dotenv files inside a unique temporary
directory, switches there for the demonstration, and removes the directory on
exit. It does not create or overwrite configuration in the repository.

Build all examples from the repository root:

```bash
bash ./build-examples.sh
./examples-bin/environment_example
```

On Windows PowerShell:

```powershell
./build-examples.ps1
.\examples-bin\environment_example.exe
```

Set `APP_ENV=development` or `NODE_ENV=production` before running to exercise
auto-detection. Explicit development and production loads are always shown.

For real applications, commit only `.env.example` templates. Keep actual
dotenv files ignored and use a secret manager for production credentials.
