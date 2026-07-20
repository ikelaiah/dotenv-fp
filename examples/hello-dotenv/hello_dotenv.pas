program hello_dotenv;

{$mode objfpc}{$H+}{$J-}

uses
  SysUtils, Types, DotEnv;

var
  Env: TDotEnv;
  Errors: TStringDynArray;
  I: Integer;
begin
  Env := TDotEnv.Create;
  try
    Env.LoadRequired('.env');

    if not Env.ValidateSchema([
      TDotEnvSchemaItem.Create('APP_NAME'),
      TDotEnvSchemaItem.Create('APP_PORT', dvkInteger),
      TDotEnvSchemaItem.Create('APP_DEBUG', dvkBoolean)
    ], Errors) then
    begin
      WriteLn('Configuration needs attention:');
      for I := 0 to High(Errors) do
        WriteLn('  - ', Errors[I]);
      Halt(1);
    end;

    WriteLn('Hello from ', Env.GetRequired('APP_NAME'), '!');
    WriteLn('Port: ', Env.GetIntRequired('APP_PORT'));
    WriteLn('Debug: ', Env.GetBoolRequired('APP_DEBUG'));
  except
    on E: EDotEnvException do
    begin
      WriteLn(StdErr, 'Configuration error: ', E.Message);
      Halt(1);
    end;
  end;
end.
