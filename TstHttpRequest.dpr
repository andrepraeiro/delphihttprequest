program TstHttpRequest;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils,
  WinInet,
  Windows,
  DBXJSON;

var
  NetHandle: HINTERNET;
  UrlHandle: HINTERNET;
  Buffer: array [0 .. 1023] of byte;
  BytesRead: dWord;
  StrBuffer: UTF8String;
  Result: UTF8String;
  Url: string;
  LJsonObj: TJSONObject;
  LRows, LElements, LItem: TJSONValue;
  access: string;

begin

  Url := 'http://andrepraeiro.github.io/sage.json';
  Result := '';
  NetHandle := InternetOpen('Delphi 2009', INTERNET_OPEN_TYPE_PRECONFIG,
    nil, nil, 0);
  if Assigned(NetHandle) then
    try
      UrlHandle := InternetOpenUrl(NetHandle, PChar(Url), nil, 0,
        INTERNET_FLAG_RELOAD, 0);
      if Assigned(UrlHandle) then
        try
          repeat
            InternetReadFile(UrlHandle, @Buffer, SizeOf(Buffer), BytesRead);
            SetString(StrBuffer, PAnsiChar(@Buffer[0]), BytesRead);
            Result := Result + StrBuffer;
          until BytesRead = 0;
        finally
          InternetCloseHandle(UrlHandle);
        end
      else
        raise Exception.CreateFmt('Cannot open URL %s', [Url]);
    finally
      InternetCloseHandle(NetHandle);
    end
  else
    raise Exception.Create('Unable to initialize Wininet');
  WriteLn(Result);
  LJsonObj := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(Result), 0)
    as TJSONObject;
  try
    LRows := LJsonObj.Get('97534937000189').JsonValue;
    if Assigned(LRows) then
    begin
      if Assigned(TJSONObject(LRows).Get('access')) then
        access := TJSONObject(LRows).Get('access').JsonValue.value;
      if Assigned(TJSONObject(LRows).Get('teste')) then
        WriteLn(TJSONObject(LRows).Get('teste').JsonValue.value);
    end;
    WriteLn('access: ' + access)
  finally
    LJsonObj.Free;
  end;
  Read(Result);

end.
