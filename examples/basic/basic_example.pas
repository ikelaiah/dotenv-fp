program basic_example;

{$mode objfpc}{$H+}{$J-}

uses
  Types, DotEnv;

var
  Env: TDotEnv;
  Errors, Hosts: TStringDynArray;
  I: Integer;

begin
  WriteLn('=== dotenv-fp Basic API Tour ===');
  WriteLn;

  Env := TDotEnv.Create;
  try
    Env.LoadRequired('.env');

    if not Env.ValidateSchema([
      TDotEnvSchemaItem.Create('BASIC_APP_NAME'),
      TDotEnvSchemaItem.Create('BASIC_PORT', dvkInteger),
      TDotEnvSchemaItem.Create('BASIC_DEBUG', dvkBoolean),
      TDotEnvSchemaItem.Create('BASIC_ALLOWED_HOSTS'),
      TDotEnvSchemaItem.Create('BASIC_GREETING'),
      TDotEnvSchemaItem.Create('BASIC_SECRET_KEY')
    ], Errors) then
    begin
      WriteLn(StdErr, 'Configuration needs attention:');
      for I := 0 to High(Errors) do
        WriteLn(StdErr, '  - ', Errors[I]);
      Halt(1);
    end;

    WriteLn('Application: ', Env.GetRequired('BASIC_APP_NAME'));
    WriteLn('Port: ', Env.GetIntRequired('BASIC_PORT'));
    WriteLn('Debug: ', Env.GetBoolRequired('BASIC_DEBUG'));
    WriteLn('Greeting: ', Env.GetRequired('BASIC_GREETING'));
    WriteLn('Secret configured: ', Env.Has('BASIC_SECRET_KEY'));

    Hosts := Env.GetArray('BASIC_ALLOWED_HOSTS');
    WriteLn('Allowed hosts:');
    for I := 0 to High(Hosts) do
      WriteLn('  - ', Hosts[I]);

    WriteLn;
    WriteLn('Safe diagnostic view:');
    WriteLn(Env.ToRedactedString);
  except
    on E: EDotEnvException do
    begin
      WriteLn(StdErr, 'Configuration error: ', E.Message);
      Halt(1);
    end;
  end;
end.
