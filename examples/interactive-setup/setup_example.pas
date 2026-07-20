program setup_example;

{$mode objfpc}{$H+}{$J-}

uses
  SysUtils, DotEnv;

procedure RunSetup;
var
  Env: TDotEnv;
  AppName, DatabaseUrl, Port, Debug: string;
begin
  WriteLn('=== dotenv-fp Interactive Setup ===');
  WriteLn;

  Env := TDotEnv.Create;
  if FileExists('.env') then
  begin
    Env.LoadRequired('.env');
    WriteLn('Loaded the existing local .env file.');
  end
  else
    WriteLn('No local .env file found; starting a new configuration.');
  WriteLn;

  AppName := Env.GetOrPrompt(
    'SETUP_APP_NAME', 'Enter application name', 'MyPascalApp');
  DatabaseUrl := Env.GetOrPrompt(
    'SETUP_DATABASE_URL', 'Enter database URL',
    'postgresql://localhost/myapp');
  Port := Env.GetOrPrompt(
    'SETUP_PORT', 'Enter application port', '3000');
  Debug := Env.GetOrPrompt(
    'SETUP_DEBUG', 'Enable debug mode? (true/false)', 'false');

  Env.ValidateSchemaRequired([
    TDotEnvSchemaItem.Create('SETUP_APP_NAME'),
    TDotEnvSchemaItem.Create('SETUP_DATABASE_URL'),
    TDotEnvSchemaItem.Create('SETUP_PORT', dvkInteger),
    TDotEnvSchemaItem.Create('SETUP_DEBUG', dvkBoolean)
  ]);

  WriteLn;
  WriteLn('Configuration summary:');
  WriteLn('  Application: ', AppName);
  WriteLn('  Database URL configured: ', DatabaseUrl <> '');
  WriteLn('  Port: ', Port);
  WriteLn('  Debug: ', Debug);
  WriteLn;

  if not Env.Save('.env') then
    raise EDotEnvException.Create('Unable to save .env');
  if not Env.GenerateExample('.env', '.env.example') then
    raise EDotEnvException.Create('Unable to generate .env.example');

  WriteLn('Saved .env atomically and generated .env.example.');
  WriteLn('Commit only .env.example; keep .env local and ignored.');
end;

begin
  try
    RunSetup;
  except
    on E: EDotEnvException do
    begin
      WriteLn(StdErr, 'Setup error: ', E.Message);
      Halt(1);
    end;
  end;
end.
