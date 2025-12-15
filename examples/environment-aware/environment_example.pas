program environment_example;

{$mode objfpc}{$H+}{$J-}

(*
  ==========================================================================
  environment_example.pas - Demonstrates LoadForEnvironment()
  ==========================================================================

  This example shows how to use the new LoadForEnvironment() method
  to automatically load environment-specific configuration files.

  Common pattern:
    - .env                 (base configuration, committed to Git)
    - .env.development     (development overrides, committed to Git)
    - .env.production      (production overrides, committed to Git)
    - .env.local           (local overrides, NOT committed, in .gitignore)

  Usage:
    1. Create test .env files
    2. Run with different environments:
       - Set APP_ENV=development
       - Set APP_ENV=production
       - Or pass environment directly

  ==========================================================================
*)

uses
  Classes, DotEnv, SysUtils, Types;

procedure CreateTestEnvFiles;
var
  Lines: TStringList;
begin
  Lines := TStringList.Create;
  try
    // Create .env (base configuration)
    Lines.Clear;
    Lines.Add('# Base configuration');
    Lines.Add('APP_NAME=MyApp');
    Lines.Add('DATABASE_URL=postgres://localhost/mydb');
    Lines.Add('PORT=3000');
    Lines.Add('DEBUG=false');
    Lines.SaveToFile('.env');

    // Create .env.development (development overrides)
    Lines.Clear;
    Lines.Add('# Development environment');
    Lines.Add('DATABASE_URL=postgres://localhost/mydb_dev');
    Lines.Add('DEBUG=true');
    Lines.Add('LOG_LEVEL=verbose');
    Lines.SaveToFile('.env.development');

    // Create .env.production (production overrides)
    Lines.Clear;
    Lines.Add('# Production environment');
    Lines.Add('DATABASE_URL=postgres://prod-server/mydb_prod');
    Lines.Add('PORT=8080');
    Lines.Add('DEBUG=false');
    Lines.Add('LOG_LEVEL=error');
    Lines.SaveToFile('.env.production');

    WriteLn('✓ Created test .env files');
    WriteLn;
  finally
    Lines.Free;
  end;
end;

procedure DemonstrateEnvironment(const Environment: string);
var
  Env: TDotEnv;
  LoadedFiles: TStringDynArray;
  I: Integer;
begin
  WriteLn('===========================================');
  WriteLn('Loading for environment: ', Environment);
  WriteLn('===========================================');

  Env := TDotEnv.Create;

  // LoadForEnvironment will load .env first, then .env.{environment}
  if Env.LoadForEnvironment(Environment) then
  begin
    WriteLn('Loaded ', Env.Count, ' configuration variables');
    WriteLn;
    WriteLn('Configuration:');
    WriteLn('  APP_NAME     : ', Env.Get('APP_NAME'));
    WriteLn('  DATABASE_URL : ', Env.Get('DATABASE_URL'));
    WriteLn('  PORT         : ', Env.Get('PORT'));
    WriteLn('  DEBUG        : ', Env.Get('DEBUG'));
    WriteLn('  LOG_LEVEL    : ', Env.Get('LOG_LEVEL', '(not set)'));
    WriteLn;

    WriteLn('Files loaded:');
    LoadedFiles := Env.LoadedFiles;
    for I := 0 to High(LoadedFiles) do
      WriteLn('  - ', LoadedFiles[I]);
  end
  else
    WriteLn('✗ Failed to load configuration');

  WriteLn;
end;

var
  CurrentEnv: string;
  Env: TDotEnv;

begin
  WriteLn('===========================================');
  WriteLn('  dotenv-fp v1.1.0 - Environment Example');
  WriteLn('===========================================');
  WriteLn;

  // Create test environment files
  CreateTestEnvFiles;

  // Demonstrate loading different environments
  DemonstrateEnvironment('development');
  DemonstrateEnvironment('production');

  // Demonstrate auto-detection (will use APP_ENV or NODE_ENV if set)
  WriteLn('===========================================');
  WriteLn('Auto-detection (using APP_ENV or NODE_ENV)');
  WriteLn('===========================================');

  CurrentEnv := GetEnvironmentVariable('APP_ENV');
  if CurrentEnv = '' then
    CurrentEnv := GetEnvironmentVariable('NODE_ENV');
  if CurrentEnv = '' then
    CurrentEnv := '(none - will load only .env)';
  WriteLn('Detected environment: ', CurrentEnv);
  WriteLn;

  Env := TDotEnv.Create;
  Env.LoadForEnvironment();  // Auto-detect
  WriteLn('Loaded ', Env.Count, ' variables');
  WriteLn;

  WriteLn('===========================================');
  WriteLn('Example complete!');
  WriteLn('===========================================');
  WriteLn;
  WriteLn('Try setting APP_ENV environment variable:');
  WriteLn('  SET APP_ENV=development (Windows)');
  WriteLn('  export APP_ENV=development (Linux/Mac)');
  WriteLn;
  WriteLn('Then run this example again to see auto-detection work!');
end.
