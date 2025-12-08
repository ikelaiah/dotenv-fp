program TestRunner;

{$mode objfpc}{$H+}{$J-}

uses
  Classes,
  consoletestrunner,
  DotEnv.Test;

type
  TDotEnvTestRunner = class(TTestRunner)
  protected
  end;

var
  Application: TDotEnvTestRunner;

begin
  Application := TDotEnvTestRunner.Create(nil);
  Application.Initialize;
  Application.Title := 'DotEnv-FP Test Runner';
  Application.Run;
  Application.Free;
end.
