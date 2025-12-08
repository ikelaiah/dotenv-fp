{
  DEPRECATED: This file is kept for backwards compatibility.
  Please use TestRunner.pas instead for running tests with FPCUnit.
  
  Compile and run TestRunner.pas:
    fpc TestRunner.pas
    ./TestRunner --all
}
program test_dotenv;

{$mode objfpc}{$H+}

uses
  SysUtils;

begin
  WriteLn('========================================');
  WriteLn('  DEPRECATED TEST FILE');
  WriteLn('========================================');
  WriteLn;
  WriteLn('This test file has been replaced by FPCUnit tests.');
  WriteLn;
  WriteLn('To run tests, compile and execute TestRunner:');
  WriteLn('  fpc TestRunner.pas');
  WriteLn('  ./TestRunner --all');
  WriteLn;
  WriteLn('Or for specific formats:');
  WriteLn('  ./TestRunner --format=plain');
  WriteLn('  ./TestRunner --format=xml');
  WriteLn;
  ExitCode := 0;
end.
