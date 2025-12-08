unit DotEnv.Test;

{$mode objfpc}{$H+}{$J-}

interface

uses
  Classes, SysUtils, fpcunit, testregistry, DotEnv;

type
  TTestDotEnv = class(TTestCase)
  private
    FEnv: TDotEnv;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure Test01_BasicParsing_SimpleKeyValue;
    procedure Test02_BasicParsing_TrimmedValue;
    procedure Test03_BasicParsing_EmptyValue;
    procedure Test04_BasicParsing_IntegerValue;
    procedure Test05_QuotedValues_DoubleQuoted;
    procedure Test06_QuotedValues_SingleQuoted;
    procedure Test07_QuotedValues_EscapeSequences;
    procedure Test08_Comments_LineComment;
    procedure Test09_Comments_InlineComment;
    procedure Test10_Comments_HashInQuotes;
    procedure Test11_ExportPrefix_Stripped;
    procedure Test12_ExportPrefix_NormalKey;
    procedure Test13_Interpolation_BaseValue;
    procedure Test14_Interpolation_BraceSyntax;
    procedure Test15_Interpolation_DollarSyntax;
    procedure Test16_Interpolation_Nested;
    procedure Test17_MultiLine_Value;
    procedure Test18_MultiLine_KeyAfter;
    procedure Test19_TypeConversion_Integer;
    procedure Test20_TypeConversion_Float;
    procedure Test21_TypeConversion_BoolTrue;
    procedure Test22_TypeConversion_BoolYes;
    procedure Test23_TypeConversion_BoolOne;
    procedure Test24_TypeConversion_BoolFalse;
    procedure Test25_TypeConversion_Array;
    procedure Test26_Defaults_ExistingKey;
    procedure Test27_Defaults_MissingKey;
    procedure Test28_Defaults_MissingInt;
    procedure Test29_Defaults_MissingBool;
    procedure Test30_Validation_AllPresent;
    procedure Test31_Validation_MissingKey;
    procedure Test32_Validation_GetMissing;
    procedure Test33_Required_ExistingKey;
    procedure Test34_Required_MissingKeyException;
    procedure Test35_Prefix_Applied;
    procedure Test36_Prefix_OriginalNotPresent;
    procedure Test37_Has_ExistingKey;
    procedure Test38_Has_EmptyKey;
    procedure Test39_Has_MissingKey;
    procedure Test40_Count;
    
    // Additional edge case tests
    procedure Test41_BasicParsing_KeyWithUnderscore;
    procedure Test42_BasicParsing_KeyWithNumbers;
    procedure Test43_BasicParsing_ValueWithEquals;
    procedure Test44_BasicParsing_OnlyKey;
    procedure Test45_BasicParsing_WhitespaceOnlyLine;
    procedure Test46_QuotedValues_EmptyDoubleQuoted;
    procedure Test47_QuotedValues_EmptySingleQuoted;
    procedure Test48_QuotedValues_QuoteInValue;
    procedure Test49_QuotedValues_PreserveLeadingSpaces;
    procedure Test50_QuotedValues_PreserveTrailingSpaces;
    procedure Test51_EscapeSequences_Tab;
    procedure Test52_EscapeSequences_CarriageReturn;
    procedure Test53_EscapeSequences_Backslash;
    procedure Test54_EscapeSequences_SingleQuoteNoEscape;
    procedure Test55_Comments_OnlyComment;
    procedure Test56_Comments_CommentAfterEmpty;
    procedure Test57_Interpolation_UndefinedVariable;
    procedure Test58_Interpolation_SystemEnvVariable;
    procedure Test59_Interpolation_PartialBrace;
    procedure Test60_Interpolation_EmptyBrace;
    procedure Test61_Interpolation_DisabledOption;
    procedure Test62_MultiLine_SingleQuote;
    procedure Test63_MultiLine_EmptyLines;
    procedure Test64_TypeConversion_NegativeInt;
    procedure Test65_TypeConversion_InvalidInt;
    procedure Test66_TypeConversion_NegativeFloat;
    procedure Test67_TypeConversion_ScientificFloat;
    procedure Test68_TypeConversion_BoolOn;
    procedure Test69_TypeConversion_BoolOff;
    procedure Test70_TypeConversion_BoolNo;
    procedure Test71_TypeConversion_BoolZero;
    procedure Test72_TypeConversion_BoolInvalid;
    procedure Test73_TypeConversion_ArrayEmpty;
    procedure Test74_TypeConversion_ArraySingleItem;
    procedure Test75_TypeConversion_ArrayCustomSeparator;
    procedure Test76_TypeConversion_ArrayWithSpaces;
    procedure Test77_Required_IntMissing;
    procedure Test78_Required_IntInvalid;
    procedure Test79_Required_BoolMissing;
    procedure Test80_Required_FloatMissing;
    procedure Test81_Required_FloatInvalid;
    procedure Test82_LoadFile_NotFound;
    procedure Test83_LoadFile_Multiple;
    procedure Test84_LoadFile_OverrideOrder;
    procedure Test85_Options_OverrideTrue;
    procedure Test86_Options_VerboseMode;
    procedure Test87_Keys_ReturnsAllKeys;
    procedure Test88_Values_ReturnsAllValues;
    procedure Test89_AsArray_ReturnsPairs;
    procedure Test90_ToString_FormatsCorrectly;
    procedure Test91_ExportPrefix_WithSpaces;
    procedure Test92_Unicode_BasicSupport;
    procedure Test93_LargeFile_ManyVariables;
    procedure Test94_DuplicateKeys_LastWins;
    procedure Test95_SetToEnv_AddsValue;
    procedure Test96_GetFromEnv_SystemVariable;
  end;

implementation

procedure TTestDotEnv.SetUp;
begin
  FEnv := TDotEnv.Create;
end;

procedure TTestDotEnv.TearDown;
begin
  // Advanced record, no cleanup needed
end;

procedure TTestDotEnv.Test01_BasicParsing_SimpleKeyValue;
begin
  FEnv.LoadFromString('SIMPLE=value');
  CheckEquals('value', FEnv.Get('SIMPLE'), 'Simple key-value');
end;

procedure TTestDotEnv.Test02_BasicParsing_TrimmedValue;
begin
  FEnv.LoadFromString('WITH_SPACES = value with spaces ');
  CheckEquals('value with spaces', FEnv.Get('WITH_SPACES'), 'Trimmed value');
end;

procedure TTestDotEnv.Test03_BasicParsing_EmptyValue;
begin
  FEnv.LoadFromString('EMPTY=');
  CheckEquals('', FEnv.Get('EMPTY'), 'Empty value');
end;

procedure TTestDotEnv.Test04_BasicParsing_IntegerValue;
begin
  FEnv.LoadFromString('NUMBER=42');
  CheckEquals(42, FEnv.GetInt('NUMBER'), 'Integer value');
end;

procedure TTestDotEnv.Test05_QuotedValues_DoubleQuoted;
begin
  FEnv.LoadFromString('DOUBLE="hello world"');
  CheckEquals('hello world', FEnv.Get('DOUBLE'), 'Double quoted');
end;

procedure TTestDotEnv.Test06_QuotedValues_SingleQuoted;
begin
  FEnv.LoadFromString('SINGLE=''hello world''');
  CheckEquals('hello world', FEnv.Get('SINGLE'), 'Single quoted');
end;

procedure TTestDotEnv.Test07_QuotedValues_EscapeSequences;
begin
  FEnv.LoadFromString('ESCAPE="line1\nline2"');
  CheckEquals('line1' + #10 + 'line2', FEnv.Get('ESCAPE'), 'Escape sequences');
end;

procedure TTestDotEnv.Test08_Comments_LineComment;
begin
  FEnv.LoadFromString(
    '# This is a comment' + LineEnding +
    'KEY1=value1'
  );
  CheckEquals('value1', FEnv.Get('KEY1'), 'After line comment');
end;

procedure TTestDotEnv.Test09_Comments_InlineComment;
begin
  FEnv.LoadFromString('KEY2=value2 # inline comment');
  CheckEquals('value2', FEnv.Get('KEY2'), 'Inline comment stripped');
end;

procedure TTestDotEnv.Test10_Comments_HashInQuotes;
begin
  FEnv.LoadFromString('KEY3="value3 # not a comment"');
  CheckEquals('value3 # not a comment', FEnv.Get('KEY3'), 'Comment in quotes preserved');
end;

procedure TTestDotEnv.Test11_ExportPrefix_Stripped;
begin
  FEnv.LoadFromString('export EXPORTED=yes');
  CheckEquals('yes', FEnv.Get('EXPORTED'), 'Export prefix stripped');
end;

procedure TTestDotEnv.Test12_ExportPrefix_NormalKey;
begin
  FEnv.LoadFromString('NORMAL=also yes');
  CheckEquals('also yes', FEnv.Get('NORMAL'), 'Normal key works');
end;

procedure TTestDotEnv.Test13_Interpolation_BaseValue;
begin
  FEnv.LoadFromString(
    'BASE=hello' + LineEnding +
    'USES_BASE=${BASE} world'
  );
  CheckEquals('hello', FEnv.Get('BASE'), 'Base value');
end;

procedure TTestDotEnv.Test14_Interpolation_BraceSyntax;
begin
  FEnv.LoadFromString(
    'BASE=hello' + LineEnding +
    'USES_BASE=${BASE} world'
  );
  CheckEquals('hello world', FEnv.Get('USES_BASE'), 'Brace interpolation');
end;

procedure TTestDotEnv.Test15_Interpolation_DollarSyntax;
begin
  FEnv.LoadFromString(
    'BASE=hello' + LineEnding +
    'USES_BASE2=$BASE world'
  );
  CheckEquals('hello world', FEnv.Get('USES_BASE2'), 'Dollar interpolation');
end;

procedure TTestDotEnv.Test16_Interpolation_Nested;
begin
  FEnv.LoadFromString(
    'BASE=hello' + LineEnding +
    'USES_BASE=${BASE} world' + LineEnding +
    'NESTED=${USES_BASE}!'
  );
  CheckEquals('hello world!', FEnv.Get('NESTED'), 'Nested interpolation');
end;

procedure TTestDotEnv.Test17_MultiLine_Value;
begin
  FEnv.LoadFromString(
    'MULTI="line1' + LineEnding +
    'line2' + LineEnding +
    'line3"'
  );
  CheckEquals('line1' + #10 + 'line2' + #10 + 'line3', FEnv.Get('MULTI'), 'Multi-line value');
end;

procedure TTestDotEnv.Test18_MultiLine_KeyAfter;
begin
  FEnv.LoadFromString(
    'MULTI="line1' + LineEnding +
    'line2' + LineEnding +
    'line3"' + LineEnding +
    'AFTER=works'
  );
  CheckEquals('works', FEnv.Get('AFTER'), 'Key after multi-line');
end;

procedure TTestDotEnv.Test19_TypeConversion_Integer;
begin
  FEnv.LoadFromString('INT=123');
  CheckEquals(123, FEnv.GetInt('INT'), 'Integer conversion');
end;

procedure TTestDotEnv.Test20_TypeConversion_Float;
begin
  FEnv.LoadFromString('FLOAT=3.14');
  CheckTrue(Abs(FEnv.GetFloat('FLOAT') - 3.14) < 0.001, 'Float conversion');
end;

procedure TTestDotEnv.Test21_TypeConversion_BoolTrue;
begin
  FEnv.LoadFromString('BOOL_TRUE=true');
  CheckTrue(FEnv.GetBool('BOOL_TRUE'), 'Bool true');
end;

procedure TTestDotEnv.Test22_TypeConversion_BoolYes;
begin
  FEnv.LoadFromString('BOOL_YES=yes');
  CheckTrue(FEnv.GetBool('BOOL_YES'), 'Bool yes');
end;

procedure TTestDotEnv.Test23_TypeConversion_BoolOne;
begin
  FEnv.LoadFromString('BOOL_ONE=1');
  CheckTrue(FEnv.GetBool('BOOL_ONE'), 'Bool 1');
end;

procedure TTestDotEnv.Test24_TypeConversion_BoolFalse;
begin
  FEnv.LoadFromString('BOOL_FALSE=false');
  CheckFalse(FEnv.GetBool('BOOL_FALSE'), 'Bool false');
end;

procedure TTestDotEnv.Test25_TypeConversion_Array;
begin
  FEnv.LoadFromString('ARRAY=a,b,c,d');
  CheckEquals(4, Length(FEnv.GetArray('ARRAY')), 'Array length');
end;

procedure TTestDotEnv.Test26_Defaults_ExistingKey;
begin
  FEnv.LoadFromString('EXISTS=yes');
  CheckEquals('yes', FEnv.Get('EXISTS', 'no'), 'Existing key ignores default');
end;

procedure TTestDotEnv.Test27_Defaults_MissingKey;
begin
  FEnv.LoadFromString('EXISTS=yes');
  CheckEquals('default', FEnv.Get('MISSING', 'default'), 'Missing key uses default');
end;

procedure TTestDotEnv.Test28_Defaults_MissingInt;
begin
  FEnv.LoadFromString('EXISTS=yes');
  CheckEquals(42, FEnv.GetInt('MISSING_INT', 42), 'Missing int uses default');
end;

procedure TTestDotEnv.Test29_Defaults_MissingBool;
begin
  FEnv.LoadFromString('EXISTS=yes');
  CheckTrue(FEnv.GetBool('MISSING_BOOL', True), 'Missing bool uses default');
end;

procedure TTestDotEnv.Test30_Validation_AllPresent;
begin
  FEnv.LoadFromString(
    'KEY1=value1' + LineEnding +
    'KEY2=value2'
  );
  CheckTrue(FEnv.Validate(['KEY1', 'KEY2']), 'All keys present');
end;

procedure TTestDotEnv.Test31_Validation_MissingKey;
begin
  FEnv.LoadFromString(
    'KEY1=value1' + LineEnding +
    'KEY2=value2'
  );
  CheckFalse(FEnv.Validate(['KEY1', 'KEY3']), 'Missing key detected');
end;

procedure TTestDotEnv.Test32_Validation_GetMissing;
var
  Missing: TStringArray;
begin
  FEnv.LoadFromString(
    'KEY1=value1' + LineEnding +
    'KEY2=value2'
  );
  Missing := FEnv.GetMissing(['KEY1', 'KEY2', 'KEY3', 'KEY4']);
  CheckEquals(2, Length(Missing), 'Correct missing count');
end;

procedure TTestDotEnv.Test33_Required_ExistingKey;
begin
  FEnv.LoadFromString('EXISTS=yes');
  CheckEquals('yes', FEnv.GetRequired('EXISTS'), 'Required existing key');
end;

procedure TTestDotEnv.Test34_Required_MissingKeyException;
var
  ExceptionRaised: Boolean;
begin
  FEnv.LoadFromString('EXISTS=yes');
  ExceptionRaised := False;
  try
    FEnv.GetRequired('MISSING');
  except
    on E: EDotEnvMissingKey do
      ExceptionRaised := True;
  end;
  CheckTrue(ExceptionRaised, 'Exception raised for missing required key');
end;

procedure TTestDotEnv.Test35_Prefix_Applied;
var
  Options: TDotEnvOptions;
begin
  Options := TDotEnvOptions.Default;
  Options.Prefix := 'APP_';
  FEnv := TDotEnv.CreateWithOptions(Options);
  FEnv.LoadFromString('KEY=value');
  CheckEquals('value', FEnv.Get('APP_KEY'), 'Prefix applied');
end;

procedure TTestDotEnv.Test36_Prefix_OriginalNotPresent;
var
  Options: TDotEnvOptions;
begin
  Options := TDotEnvOptions.Default;
  Options.Prefix := 'APP_';
  FEnv := TDotEnv.CreateWithOptions(Options);
  FEnv.LoadFromString('KEY=value');
  CheckEquals('', FEnv.Get('KEY'), 'Original key not present');
end;

procedure TTestDotEnv.Test37_Has_ExistingKey;
begin
  FEnv.LoadFromString('EXISTS=yes');
  CheckTrue(FEnv.Has('EXISTS'), 'Has existing key');
end;

procedure TTestDotEnv.Test38_Has_EmptyKey;
begin
  FEnv.LoadFromString('EMPTY=');
  CheckTrue(FEnv.Has('EMPTY'), 'Has empty key');
end;

procedure TTestDotEnv.Test39_Has_MissingKey;
begin
  FEnv.LoadFromString('EXISTS=yes');
  CheckFalse(FEnv.Has('MISSING'), 'Does not have missing key');
end;

procedure TTestDotEnv.Test40_Count;
begin
  FEnv.LoadFromString(
    'KEY1=value1' + LineEnding +
    'KEY2=value2' + LineEnding +
    'KEY3=value3'
  );
  CheckEquals(3, FEnv.Count, 'Correct count');
end;

procedure TTestDotEnv.Test41_BasicParsing_KeyWithUnderscore;
begin
  FEnv.LoadFromString('MY_VAR_NAME=value');
  CheckEquals('value', FEnv.Get('MY_VAR_NAME'), 'Key with underscores');
end;

procedure TTestDotEnv.Test42_BasicParsing_KeyWithNumbers;
begin
  FEnv.LoadFromString('VAR123=value');
  CheckEquals('value', FEnv.Get('VAR123'), 'Key with numbers');
end;

procedure TTestDotEnv.Test43_BasicParsing_ValueWithEquals;
begin
  FEnv.LoadFromString('URL=https://example.com?foo=bar&baz=qux');
  CheckEquals('https://example.com?foo=bar&baz=qux', FEnv.Get('URL'), 'Value containing equals signs');
end;

procedure TTestDotEnv.Test44_BasicParsing_OnlyKey;
begin
  FEnv.LoadFromString('ONLY_KEY');
  CheckEquals('', FEnv.Get('ONLY_KEY'), 'Line with only key (no equals) should be ignored');
  CheckFalse(FEnv.Has('ONLY_KEY'), 'Key without equals should not exist');
end;

procedure TTestDotEnv.Test45_BasicParsing_WhitespaceOnlyLine;
begin
  FEnv.LoadFromString(
    'KEY1=value1' + LineEnding +
    '   ' + LineEnding +
    'KEY2=value2'
  );
  CheckEquals('value1', FEnv.Get('KEY1'), 'Key before whitespace line');
  CheckEquals('value2', FEnv.Get('KEY2'), 'Key after whitespace line');
  CheckEquals(2, FEnv.Count, 'Whitespace lines ignored');
end;

procedure TTestDotEnv.Test46_QuotedValues_EmptyDoubleQuoted;
begin
  FEnv.LoadFromString('EMPTY=""');
  CheckEquals('', FEnv.Get('EMPTY'), 'Empty double quoted value');
  CheckTrue(FEnv.Has('EMPTY'), 'Empty quoted key exists');
end;

procedure TTestDotEnv.Test47_QuotedValues_EmptySingleQuoted;
begin
  FEnv.LoadFromString('EMPTY=''''');
  CheckEquals('', FEnv.Get('EMPTY'), 'Empty single quoted value');
end;

procedure TTestDotEnv.Test48_QuotedValues_QuoteInValue;
begin
  FEnv.LoadFromString('MSG="He said \"hello\""');
  CheckEquals('He said "hello"', FEnv.Get('MSG'), 'Escaped quotes in value');
end;

procedure TTestDotEnv.Test49_QuotedValues_PreserveLeadingSpaces;
begin
  FEnv.LoadFromString('SPACED="   leading"');
  CheckEquals('   leading', FEnv.Get('SPACED'), 'Leading spaces preserved in quotes');
end;

procedure TTestDotEnv.Test50_QuotedValues_PreserveTrailingSpaces;
begin
  FEnv.LoadFromString('SPACED="trailing   "');
  CheckEquals('trailing   ', FEnv.Get('SPACED'), 'Trailing spaces preserved in quotes');
end;

procedure TTestDotEnv.Test51_EscapeSequences_Tab;
begin
  FEnv.LoadFromString('TAB="col1\tcol2"');
  CheckEquals('col1' + #9 + 'col2', FEnv.Get('TAB'), 'Tab escape sequence');
end;

procedure TTestDotEnv.Test52_EscapeSequences_CarriageReturn;
begin
  FEnv.LoadFromString('CR="line1\rline2"');
  CheckEquals('line1' + #13 + 'line2', FEnv.Get('CR'), 'Carriage return escape');
end;

procedure TTestDotEnv.Test53_EscapeSequences_Backslash;
begin
  FEnv.LoadFromString('PATH="C:\\Users\\test"');
  CheckEquals('C:\Users\test', FEnv.Get('PATH'), 'Backslash escape');
end;

procedure TTestDotEnv.Test54_EscapeSequences_SingleQuoteNoEscape;
begin
  FEnv.LoadFromString('RAW=''no\nescape''');
  CheckEquals('no\nescape', FEnv.Get('RAW'), 'Single quotes preserve backslash literally');
end;

procedure TTestDotEnv.Test55_Comments_OnlyComment;
begin
  FEnv.LoadFromString('# Just a comment');
  CheckEquals(0, FEnv.Count, 'Only comment line results in no keys');
end;

procedure TTestDotEnv.Test56_Comments_CommentAfterEmpty;
begin
  FEnv.LoadFromString(
    '' + LineEnding +
    '# comment' + LineEnding +
    '' + LineEnding +
    'KEY=value'
  );
  CheckEquals(1, FEnv.Count, 'Empty lines and comments handled');
  CheckEquals('value', FEnv.Get('KEY'), 'Key after empty and comment');
end;

procedure TTestDotEnv.Test57_Interpolation_UndefinedVariable;
begin
  FEnv.LoadFromString('REF=${UNDEFINED}');
  CheckEquals('', FEnv.Get('REF'), 'Undefined variable interpolates to empty');
end;

procedure TTestDotEnv.Test58_Interpolation_SystemEnvVariable;
var
  PathValue: string;
begin
  // PATH should exist on all systems
  PathValue := SysUtils.GetEnvironmentVariable('PATH');
  if PathValue <> '' then
  begin
    FEnv.LoadFromString('MYPATH=${PATH}');
    CheckEquals(PathValue, FEnv.Get('MYPATH'), 'System env variable interpolation');
  end
  else
    Ignore('PATH environment variable not set');
end;

procedure TTestDotEnv.Test59_Interpolation_PartialBrace;
begin
  FEnv.LoadFromString('PARTIAL=${INCOMPLETE');
  // Should not crash, behavior may vary
  CheckTrue(True, 'Partial brace does not crash');
end;

procedure TTestDotEnv.Test60_Interpolation_EmptyBrace;
begin
  FEnv.LoadFromString('EMPTY=${}');
  CheckEquals('', FEnv.Get('EMPTY'), 'Empty brace interpolates to empty');
end;

procedure TTestDotEnv.Test61_Interpolation_DisabledOption;
var
  Options: TDotEnvOptions;
begin
  Options := TDotEnvOptions.Default;
  Options.Interpolate := False;
  FEnv := TDotEnv.CreateWithOptions(Options);
  FEnv.LoadFromString(
    'BASE=hello' + LineEnding +
    'REF=${BASE}'
  );
  CheckEquals('${BASE}', FEnv.Get('REF'), 'Interpolation disabled preserves literal');
end;

procedure TTestDotEnv.Test62_MultiLine_SingleQuote;
begin
  FEnv.LoadFromString(
    'MULTI=''line1' + LineEnding +
    'line2' + LineEnding +
    'line3'''
  );
  CheckEquals('line1' + #10 + 'line2' + #10 + 'line3', FEnv.Get('MULTI'), 'Multi-line with single quotes');
end;

procedure TTestDotEnv.Test63_MultiLine_EmptyLines;
begin
  FEnv.LoadFromString(
    'MULTI="line1' + LineEnding +
    '' + LineEnding +
    'line3"'
  );
  CheckEquals('line1' + #10 + '' + #10 + 'line3', FEnv.Get('MULTI'), 'Multi-line with empty line');
end;

procedure TTestDotEnv.Test64_TypeConversion_NegativeInt;
begin
  FEnv.LoadFromString('NEG=-42');
  CheckEquals(-42, FEnv.GetInt('NEG'), 'Negative integer');
end;

procedure TTestDotEnv.Test65_TypeConversion_InvalidInt;
begin
  FEnv.LoadFromString('INVALID=notanumber');
  CheckEquals(99, FEnv.GetInt('INVALID', 99), 'Invalid int uses default');
end;

procedure TTestDotEnv.Test66_TypeConversion_NegativeFloat;
begin
  FEnv.LoadFromString('NEG=-3.14');
  CheckTrue(Abs(FEnv.GetFloat('NEG') - (-3.14)) < 0.001, 'Negative float');
end;

procedure TTestDotEnv.Test67_TypeConversion_ScientificFloat;
begin
  FEnv.LoadFromString('SCI=1.5e10');
  CheckTrue(Abs(FEnv.GetFloat('SCI') - 1.5e10) < 1e6, 'Scientific notation float');
end;

procedure TTestDotEnv.Test68_TypeConversion_BoolOn;
begin
  FEnv.LoadFromString('FLAG=on');
  CheckTrue(FEnv.GetBool('FLAG'), 'Bool "on" is true');
end;

procedure TTestDotEnv.Test69_TypeConversion_BoolOff;
begin
  FEnv.LoadFromString('FLAG=off');
  CheckFalse(FEnv.GetBool('FLAG', True), 'Bool "off" is false');
end;

procedure TTestDotEnv.Test70_TypeConversion_BoolNo;
begin
  FEnv.LoadFromString('FLAG=no');
  CheckFalse(FEnv.GetBool('FLAG', True), 'Bool "no" is false');
end;

procedure TTestDotEnv.Test71_TypeConversion_BoolZero;
begin
  FEnv.LoadFromString('FLAG=0');
  CheckFalse(FEnv.GetBool('FLAG', True), 'Bool "0" is false');
end;

procedure TTestDotEnv.Test72_TypeConversion_BoolInvalid;
begin
  FEnv.LoadFromString('FLAG=maybe');
  // When key exists but value is not a recognized boolean, it returns False
  // The default is only used when the key is MISSING, not when value is invalid
  CheckFalse(FEnv.GetBool('FLAG'), 'Invalid bool string returns false');
  CheckFalse(FEnv.GetBool('FLAG', True), 'Invalid bool ignores default (key exists)');
end;

procedure TTestDotEnv.Test73_TypeConversion_ArrayEmpty;
var
  Arr: TStringArray;
begin
  FEnv.LoadFromString('EMPTY=');
  Arr := FEnv.GetArray('EMPTY');
  CheckEquals(0, Length(Arr), 'Empty value gives empty array');
end;

procedure TTestDotEnv.Test74_TypeConversion_ArraySingleItem;
var
  Arr: TStringArray;
begin
  FEnv.LoadFromString('SINGLE=onlyone');
  Arr := FEnv.GetArray('SINGLE');
  CheckEquals(1, Length(Arr), 'Single item array');
  CheckEquals('onlyone', Arr[0], 'Single item value');
end;

procedure TTestDotEnv.Test75_TypeConversion_ArrayCustomSeparator;
var
  Arr: TStringArray;
begin
  FEnv.LoadFromString('LIST=a;b;c');
  Arr := FEnv.GetArray('LIST', ';');
  CheckEquals(3, Length(Arr), 'Custom separator array length');
  CheckEquals('b', Arr[1], 'Custom separator middle item');
end;

procedure TTestDotEnv.Test76_TypeConversion_ArrayWithSpaces;
var
  Arr: TStringArray;
begin
  FEnv.LoadFromString('LIST=a, b , c');
  Arr := FEnv.GetArray('LIST');
  CheckEquals(3, Length(Arr), 'Array with spaces');
  CheckEquals('b', Arr[1], 'Spaces trimmed from array items');
end;

procedure TTestDotEnv.Test77_Required_IntMissing;
var
  ExceptionRaised: Boolean;
begin
  FEnv.LoadFromString('OTHER=value');
  ExceptionRaised := False;
  try
    FEnv.GetIntRequired('MISSING_INT');
  except
    on E: EDotEnvMissingKey do
      ExceptionRaised := True;
  end;
  CheckTrue(ExceptionRaised, 'Exception for missing required int');
end;

procedure TTestDotEnv.Test78_Required_IntInvalid;
var
  ExceptionRaised: Boolean;
begin
  FEnv.LoadFromString('BAD_INT=notanumber');
  ExceptionRaised := False;
  try
    FEnv.GetIntRequired('BAD_INT');
  except
    on E: EDotEnvParseError do
      ExceptionRaised := True;
  end;
  CheckTrue(ExceptionRaised, 'Exception for invalid required int');
end;

procedure TTestDotEnv.Test79_Required_BoolMissing;
var
  ExceptionRaised: Boolean;
begin
  FEnv.LoadFromString('OTHER=value');
  ExceptionRaised := False;
  try
    FEnv.GetBoolRequired('MISSING_BOOL');
  except
    on E: EDotEnvMissingKey do
      ExceptionRaised := True;
  end;
  CheckTrue(ExceptionRaised, 'Exception for missing required bool');
end;

procedure TTestDotEnv.Test80_Required_FloatMissing;
var
  ExceptionRaised: Boolean;
begin
  FEnv.LoadFromString('OTHER=value');
  ExceptionRaised := False;
  try
    FEnv.GetFloatRequired('MISSING_FLOAT');
  except
    on E: EDotEnvMissingKey do
      ExceptionRaised := True;
  end;
  CheckTrue(ExceptionRaised, 'Exception for missing required float');
end;

procedure TTestDotEnv.Test81_Required_FloatInvalid;
var
  ExceptionRaised: Boolean;
begin
  FEnv.LoadFromString('BAD_FLOAT=notafloat');
  ExceptionRaised := False;
  try
    FEnv.GetFloatRequired('BAD_FLOAT');
  except
    on E: EDotEnvParseError do
      ExceptionRaised := True;
  end;
  CheckTrue(ExceptionRaised, 'Exception for invalid required float');
end;

procedure TTestDotEnv.Test82_LoadFile_NotFound;
var
  Result: Boolean;
begin
  Result := FEnv.Load('nonexistent_file_12345.env');
  CheckFalse(Result, 'Load returns false for missing file');
end;

procedure TTestDotEnv.Test83_LoadFile_Multiple;
begin
  FEnv.LoadFromString('KEY1=first');
  FEnv.LoadFromString('KEY2=second');
  CheckEquals('first', FEnv.Get('KEY1'), 'First load preserved');
  CheckEquals('second', FEnv.Get('KEY2'), 'Second load added');
  CheckEquals(2, FEnv.Count, 'Both loads counted');
end;

procedure TTestDotEnv.Test84_LoadFile_OverrideOrder;
begin
  FEnv.LoadFromString('KEY=original');
  FEnv.LoadFromString('KEY=overwritten');
  CheckEquals('overwritten', FEnv.Get('KEY'), 'Later load overrides');
end;

procedure TTestDotEnv.Test85_Options_OverrideTrue;
var
  Options: TDotEnvOptions;
begin
  Options := TDotEnvOptions.Default;
  Options.Override := True;
  FEnv := TDotEnv.CreateWithOptions(Options);
  FEnv.LoadFromString('KEY=value');
  CheckEquals('value', FEnv.Get('KEY'), 'Override option works');
end;

procedure TTestDotEnv.Test86_Options_VerboseMode;
var
  Options: TDotEnvOptions;
begin
  Options := TDotEnvOptions.Default;
  Options.Verbose := True;
  FEnv := TDotEnv.CreateWithOptions(Options);
  FEnv.LoadFromString('KEY=value');
  // Just ensure it doesn't crash
  CheckEquals('value', FEnv.Get('KEY'), 'Verbose mode works');
end;

procedure TTestDotEnv.Test87_Keys_ReturnsAllKeys;
var
  K: TStringArray;
begin
  FEnv.LoadFromString(
    'ALPHA=1' + LineEnding +
    'BETA=2' + LineEnding +
    'GAMMA=3'
  );
  K := FEnv.Keys;
  CheckEquals(3, Length(K), 'Keys returns correct count');
end;

procedure TTestDotEnv.Test88_Values_ReturnsAllValues;
var
  V: TStringArray;
begin
  FEnv.LoadFromString(
    'A=one' + LineEnding +
    'B=two' + LineEnding +
    'C=three'
  );
  V := FEnv.Values;
  CheckEquals(3, Length(V), 'Values returns correct count');
end;

procedure TTestDotEnv.Test89_AsArray_ReturnsPairs;
var
  Pairs: TDotEnvPairArray;
begin
  FEnv.LoadFromString(
    'X=10' + LineEnding +
    'Y=20'
  );
  Pairs := FEnv.AsArray;
  CheckEquals(2, Length(Pairs), 'AsArray returns correct count');
  CheckTrue((Pairs[0].Key = 'X') or (Pairs[1].Key = 'X'), 'Contains key X');
end;

procedure TTestDotEnv.Test90_ToString_FormatsCorrectly;
var
  S: string;
begin
  FEnv.LoadFromString('SINGLE=value');
  S := FEnv.ToString;
  CheckTrue(Pos('SINGLE=value', S) > 0, 'ToString contains key=value');
end;

procedure TTestDotEnv.Test91_ExportPrefix_WithSpaces;
begin
  FEnv.LoadFromString('export   SPACED=value');
  CheckEquals('value', FEnv.Get('SPACED'), 'Export with extra spaces');
end;

procedure TTestDotEnv.Test92_Unicode_BasicSupport;
begin
  FEnv.LoadFromString('GREETING=こんにちは');
  CheckEquals('こんにちは', FEnv.Get('GREETING'), 'Unicode value');
end;

procedure TTestDotEnv.Test93_LargeFile_ManyVariables;
var
  Content: string;
  I: Integer;
begin
  Content := '';
  for I := 1 to 100 do
    Content := Content + 'VAR' + IntToStr(I) + '=value' + IntToStr(I) + LineEnding;
  FEnv.LoadFromString(Content);
  CheckEquals(100, FEnv.Count, 'Large file with 100 variables');
  CheckEquals('value50', FEnv.Get('VAR50'), 'Middle variable accessible');
  CheckEquals('value100', FEnv.Get('VAR100'), 'Last variable accessible');
end;

procedure TTestDotEnv.Test94_DuplicateKeys_LastWins;
begin
  FEnv.LoadFromString(
    'DUP=first' + LineEnding +
    'DUP=second' + LineEnding +
    'DUP=third'
  );
  CheckEquals('third', FEnv.Get('DUP'), 'Last duplicate wins');
  CheckEquals(1, FEnv.Count, 'Duplicates not counted separately');
end;

procedure TTestDotEnv.Test95_SetToEnv_AddsValue;
begin
  FEnv.SetToEnv('DYNAMIC', 'runtime_value');
  CheckEquals('runtime_value', FEnv.Get('DYNAMIC'), 'SetToEnv adds value');
  CheckTrue(FEnv.Has('DYNAMIC'), 'SetToEnv key exists');
end;

procedure TTestDotEnv.Test96_GetFromEnv_SystemVariable;
var
  PathValue: string;
begin
  PathValue := FEnv.GetFromEnv('PATH', 'default');
  // PATH should exist on all systems
  if SysUtils.GetEnvironmentVariable('PATH') <> '' then
    CheckTrue(PathValue <> 'default', 'GetFromEnv reads system variable')
  else
    CheckEquals('default', PathValue, 'GetFromEnv uses default when missing');
end;

initialization
  RegisterTest(TTestDotEnv);

end.
