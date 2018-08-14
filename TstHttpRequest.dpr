program TstHttpRequest;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils,
  WinInet,
  Windows,
  DBXJSON;

var
  NetHandle, hConnectHandle: HINTERNET;
  UrlHandle, hResourceHandle: HINTERNET;
  hwnd: HWND;
  Buffer: array [0 .. 1023] of byte;
  BytesRead: dWord;
  StrBuffer: UTF8String;
  Result: UTF8String;
  Url: string;
  LJsonObj: TJSONObject;
  LRows, LElements, LItem: TJSONValue;
  access: string;
  dwErrorCode, dwerror: dWord;

procedure resend();
begin

  HttpSendRequest(hResourceHandle, nil, 0, nil, 0);

  // dwErrorCode stores the error code associated with the call to
  // HttpSendRequest.

  if Assigned(hResourceHandle) then
    dwErrorCode := ERROR_SUCCESS
  else
    dwErrorCode := GetLastError();

  dwerror := InternetErrorDlg(, hResourceHandle, dwErrorCode,
    FLAGS_ERROR_UI_FILTER_FOR_ERRORS or FLAGS_ERROR_UI_FLAGS_CHANGE_OPTIONS or
    FLAGS_ERROR_UI_FLAGS_GENERATE_DATA, nil);

  if (dwerror = ERROR_INTERNET_FORCE_RETRY) then
    resend;

  // Insert code to read the data from the hResourceHandle
  // at this point.
end;

begin

  Url := 'http://andrepraeiro.github.io/sage.json';
  Result := '';
  NetHandle := InternetOpen('Delphi 2009', INTERNET_OPEN_TYPE_PRECONFIG,
    nil, nil, 0);
  if Assigned(NetHandle) then
    try

      hConnectHandle = InternetConnect(NetHandle,
        Pchar('andrepraeiro.github.io'), INTERNET_INVALID_PORT_NUMBER, nil, nil,
        INTERNET_SERVICE_HTTP, 0, 0);

      if Assigned(hConnectHandle) then

        hResourceHandle = HttpOpenRequest(hConnectHandle, Pchar('GET'),
          Pchar('/sage.json'), nil, nil, nil, INTERNET_FLAG_KEEP_CONNECTION, 0);

      Resend();

//      if Assigned(hResourceHandle) then
//
//        UrlHandle := InternetOpenUrl(NetHandle, Pchar(Url), nil, 0,
//          INTERNET_FLAG_RELOAD, 0);
//      if Assigned(UrlHandle) then
//        try
//          repeat
//            InternetReadFile(UrlHandle, @Buffer, SizeOf(Buffer), BytesRead);
//            SetString(StrBuffer, PAnsiChar(@Buffer[0]), BytesRead);
//            Result := Result + StrBuffer;
//          until BytesRead = 0;
//        finally
//          InternetCloseHandle(UrlHandle);
//        end
//      else
//        raise Exception.CreateFmt('Cannot open URL %s', [Url]);
//    finally
//      InternetCloseHandle(NetHandle);
//    end
//  else
//    raise Exception.Create('Unable to initialize Wininet');
//  WriteLn(Result);
//  LJsonObj := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(Result), 0)
//    as TJSONObject;
//  try
//    LRows := LJsonObj.Get('97534937000189').JsonValue;
//    if Assigned(LRows) then
//    begin
//      if Assigned(TJSONObject(LRows).Get('access')) then
//        access := TJSONObject(LRows).Get('access').JsonValue.value;
//      if Assigned(TJSONObject(LRows).Get('teste')) then
//        WriteLn(TJSONObject(LRows).Get('teste').JsonValue.value);
//    end;
//    WriteLn('access: ' + access)
//  finally
//    LJsonObj.Free;
//  end;
  Read(Result);

end.
