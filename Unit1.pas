unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  WinInet,
  DBXJSON, Vcl.StdCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);

var
  NetHandle, hConnectHandle: HINTERNET;
  UrlHandle, hResourceHandle: HINTERNET;
  Buffer: array [0 .. 1023] of byte;
  BytesRead: dWord;
  StrBuffer: UTF8String;
  Retorno: UTF8String;
  Url: string;
  LJsonObj: TJSONObject;
  LRows, LElements, LItem: TJSONValue;
  access: string;
  dwErrorCode, dwerror: dWord;
  ipvvData: Pointer;
  lpvBufferLen, reserved: cardinal;
  ok: boolean;
  dwStatus: dWord;
  // dwStatus: array [0..512] of char;
  reply: string;

  function resend(): UTF8String;
  begin

    HttpSendRequest(hResourceHandle, nil, 0, nil, 0);

    // dwErrorCode stores the error code associated with the call to
    // HttpSendRequest.

    if Assigned(hResourceHandle) then
      dwErrorCode := ERROR_SUCCESS
    else
      dwErrorCode := GetLastError();

    dwerror := InternetErrorDlg(Application.Handle, hResourceHandle,
      dwErrorCode, FLAGS_ERROR_UI_FILTER_FOR_ERRORS or
      FLAGS_ERROR_UI_FLAGS_CHANGE_OPTIONS or FLAGS_ERROR_UI_FLAGS_GENERATE_DATA,
      ipvvData);

    if (dwerror = ERROR_INTERNET_FORCE_RETRY) then
      Result := resend;

    if Length(Result) = 0 then
    begin
      repeat
        InternetReadFile(hResourceHandle, @Buffer, SizeOf(Buffer), BytesRead);
        SetString(StrBuffer, PAnsiChar(@Buffer[0]), BytesRead);
        Result := Result + StrBuffer;
      until BytesRead = 0;
      if Length(Result) > 0 then
      begin
        ShowMessage(Result);
        Retorno := Result;
      end;
    end
    else
      Retorno := Result;
  end;
//
// procedure resend();
// begin
// HttpSendRequest(hResourceHandle, nil, 0, nil, 0);
// lpvBufferLen := sizeof(dwStatus);
//
// ok := HttpQueryInfo(hResourceHandle, HTTP_QUERY_FLAG_NUMBER or
// HTTP_QUERY_STATUS_CODE, @dwStatus, lpvBufferLen, reserved);
//
// if ok then
// showmessage('ok')
// else
// showmessage('not ok');
//
// // reply := dwStatus;
//
// if dwStatus = HTTP_STATUS_PROXY_AUTH_REQ then
// begin
// InternetSetOption(hResourceHandle, INTERNET_OPTION_PROXY_USERNAME,
// PChar('26586'), Length(PChar('26586')));
//
// InternetSetOption(hResourceHandle, INTERNET_OPTION_PROXY_PASSWORD,
// PChar('aq1sw2@A'), Length(PChar('aq1sw2@A')));
// resend;
// end
// else if dwStatus = HTTP_STATUS_DENIED then
// begin
// InternetSetOption(hResourceHandle, INTERNET_OPTION_USERNAME,
// PChar('26586'), Length(PChar('26586')));
// InternetSetOption(hResourceHandle, INTERNET_OPTION_PASSWORD,
// PChar('aq1sw2@A'), Length(PChar('aq1sw2@A')));
// resend;
// end;
// repeat
// InternetReadFile(hResourceHandle, @Buffer, sizeof(Buffer), BytesRead);
// SetString(StrBuffer, PAnsiChar(@Buffer[0]), BytesRead);
// Result := Result + StrBuffer;
// until BytesRead = 0;
// showmessage(Result);
// end;

begin

  Url := 'http://andrepraeiro.github.io/sage.json';
  Retorno := '';
  NetHandle := InternetOpen('Delphi 2009', INTERNET_OPEN_TYPE_PROXY,
    PChar('proxy.pjmt.local:3128'), nil, 0);
  if Assigned(NetHandle) then
    try

      hConnectHandle := InternetConnect(NetHandle,
        PChar('andrepraeiro.github.io'), INTERNET_INVALID_PORT_NUMBER, nil, nil,
        INTERNET_SERVICE_HTTP, 0, 0);

      if Assigned(hConnectHandle) then

        hResourceHandle := HttpOpenRequest(hConnectHandle, PChar('GET'),
          PChar('/sage.json'), nil, nil, nil, INTERNET_FLAG_KEEP_CONNECTION, 0);

      ok := HttpQueryInfo(hResourceHandle, HTTP_QUERY_FLAG_NUMBER or
        HTTP_QUERY_STATUS_CODE, @dwStatus, lpvBufferLen, reserved);

      Retorno := resend();

      // if Assigned(hResourceHandle) then
      //
      // UrlHandle := InternetOpenUrl(NetHandle, Pchar(Url), nil, 0,
      // INTERNET_FLAG_RELOAD, 0);
      // if Assigned(UrlHandle) then
      // try
      // repeat
      // InternetReadFile(UrlHandle, @Buffer, SizeOf(Buffer), BytesRead);
      // SetString(StrBuffer, PAnsiChar(@Buffer[0]), BytesRead);
      // Result := Result + StrBuffer;
      // until BytesRead = 0;
      // finally
      // InternetCloseHandle(UrlHandle);
      // end
      // else
      // raise Exception.CreateFmt('Cannot open URL %s', [Url]);
    finally

      InternetCloseHandle(NetHandle);
    end;

  // else
  // raise Exception.Create('Unable to initialize Wininet');
  // WriteLn(Result);
  LJsonObj := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(Retorno), 0)
    as TJSONObject;
  try
    LRows := LJsonObj.Get('97534937000189').JsonValue;
    if Assigned(LRows) then
    begin
      if Assigned(TJSONObject(LRows).Get('access')) then
        access := TJSONObject(LRows).Get('access').JsonValue.value;
      if Assigned(TJSONObject(LRows).Get('teste')) then
        ShowMessage(TJSONObject(LRows).Get('teste').JsonValue.value);
    end;
    ShowMessage('access: ' + access)
  finally
    LJsonObj.Free;
  end;
end;

end.
