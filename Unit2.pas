unit Unit2;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  WinInet,
  DBXJSON, Vcl.StdCtrls;

type
  TForm2 = class(TForm)
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

const
  MaxHeadSize = 16384;
  { see http://stackoverflow.com/questions/686217/maximum-on-http-header-values }

const
  BUFSIZE = 4096;

implementation

{$R *.dfm}

procedure TForm2.Button1Click(Sender: TObject);

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
  // dwStatus: Pointer;
  reply: string;
  user, pass: PChar;
  struct_ipi: TInternetProxyInfo;
  tx: PChar;
  sStatusText: string;
  iStatusLength: cardinal;

  procedure SetRequestHeader(sName, sValue: string);
  var
    sHeader: string;
  begin
    sHeader := sName + ': ' + sValue;
    HttpAddRequestHeaders(hResourceHandle, PChar(sHeader), Length(sHeader),
      HTTP_ADDREQ_FLAG_ADD);
  end;

  function QueryInfo(flag: cardinal): PChar;
  var
    r: PWideString;
    l: cardinal;
    sRespHeader: string;
  begin
    ok := HttpSendRequest(hResourceHandle, nil, 0, nil, 0);
    reserved := 0;
    l := MaxHeadSize;
    SetLength(sRespHeader, l);
    ok := HttpQueryInfo(hResourceHandle, flag, PChar(sRespHeader), l, reserved);
    SetLength(sRespHeader, l div SizeOf(Char));
    Result := PChar(sRespHeader);
  end;

  function resend(flags: cardinal): string;
  var
    iStatusIndex: cardinal;
  begin
    ok := HttpSendRequest(hResourceHandle, nil, 0, nil, 0);
    dwStatus := 0;
    lpvBufferLen := SizeOf(dwStatus);
    reserved := 0;

    ok := HttpQueryInfo(hResourceHandle, flags, @dwStatus, lpvBufferLen,
      reserved);

    GetLastError();

    tx := QueryInfo(HTTP_QUERY_RAW_HEADERS_CRLF);

    if dwStatus = HTTP_STATUS_PROXY_AUTH_REQ then
    begin
      flags := HTTP_QUERY_FLAG_NUMBER or HTTP_QUERY_STATUS_CODE;
      user := '26586';
      pass := 'aq1sw2@A';

      ok := InternetSetOption(hResourceHandle, INTERNET_OPTION_PROXY_USERNAME,
        PChar(user), Length(user) + 1);

      ok := InternetSetOption(hResourceHandle, INTERNET_OPTION_PROXY_PASSWORD,
        PChar(pass), Length(pass) + 1);

      if (dwStatus >= 300) then
      begin
        iStatusIndex := 0;
        for iStatusIndex := 0 to 10 do
        begin
          SetLength(sStatusText, BUFSIZE);
          iStatusLength := Length(sStatusText);
          if HttpQueryInfo(hResourceHandle, HTTP_QUERY_STATUS_TEXT,
            @sStatusText[1], iStatusLength, iStatusIndex) then
          begin
            SetLength(sStatusText, iStatusLength div SizeOf(Char));
            ShowMessage(sStatusText);
          end;
        end;
      end;

      // ok := InternetSetOption(hResourceHandle, INTERNET_OPTION_USERNAME,
      // @user, Length(user) + 1);
      //
      // ok := InternetSetOption(hResourceHandle, INTERNET_OPTION_PASSWORD,
      // @pass, Length(pass) + 1);
      //

      // ok := InternetSetOption(hConnectHandle,
      // INTERNET_OPTION_PROXY_SETTINGS_CHANGED, nil, 0);
      //
      // ok := InternetSetOption(hConnectHandle,
      // INTERNET_OPTION_SETTINGS_CHANGED, nil, 0);

      // if ok then
      //
      // showmessage('ok')
      // else
      // showmessage('not ok');
      repeat
        InternetReadFile(hResourceHandle, @Buffer, SizeOf(Buffer), BytesRead);
        SetString(StrBuffer, PAnsiChar(@Buffer[0]), BytesRead);
        Result := Result + StrBuffer;
      until BytesRead = 0;
      ShowMessage(Result);

      resend(flags);
    end
    else if dwStatus = HTTP_STATUS_DENIED then
    begin
      InternetSetOption(hResourceHandle, INTERNET_OPTION_USERNAME,
        PChar('26586'), Length(PChar('26586')));
      InternetSetOption(hResourceHandle, INTERNET_OPTION_PASSWORD,
        PChar('aq1sw2@A'), Length(PChar('aq1sw2@A')));
      resend(flags);
    end;
    repeat
      InternetReadFile(hResourceHandle, @Buffer, SizeOf(Buffer), BytesRead);
      SetString(StrBuffer, PAnsiChar(@Buffer[0]), BytesRead);
      Result := Result + StrBuffer;
    until BytesRead = 0;
    ShowMessage(Result);
  end;

begin

  Url := 'https://andrepraeiro.github.io/sage.json';
  Retorno := '';
  NetHandle := InternetOpen('Delphi 2009', INTERNET_OPEN_TYPE_PROXY,
    'proxy.pjmt.local:3128', '', 0);
  if Assigned(NetHandle) then
    try

      hConnectHandle := InternetConnect(NetHandle,
        PChar('andrepraeiro.github.io'), INTERNET_INVALID_PORT_NUMBER, '26586',
        'aq1sw2@A', INTERNET_SERVICE_HTTP, 0, 0);

      if Assigned(hConnectHandle) then

        hResourceHandle := HttpOpenRequest(hConnectHandle, PChar('GET'),
          PChar('/sage.json'), PChar('HTTP/1.1'), nil, nil,
          INTERNET_FLAG_KEEP_CONNECTION or INTERNET_FLAG_RELOAD or
          INTERNET_FLAG_DONT_CACHE or INTERNET_FLAG_SECURE, 0);

      ok := HttpQueryInfo(hResourceHandle, HTTP_QUERY_FLAG_NUMBER or
        HTTP_QUERY_STATUS_CODE, @dwStatus, lpvBufferLen, reserved);

      Retorno := resend(HTTP_QUERY_FLAG_NUMBER or HTTP_QUERY_STATUS_CODE);

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
  // LJsonObj := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(Retorno), 0)
  // as TJSONObject;
  // try
  // LRows := LJsonObj.Get('97534937000189').JsonValue;
  // if Assigned(LRows) then
  // begin
  // if Assigned(TJSONObject(LRows).Get('access')) then
  // access := TJSONObject(LRows).Get('access').JsonValue.value;
  // if Assigned(TJSONObject(LRows).Get('teste')) then
  // showmessage(TJSONObject(LRows).Get('teste').JsonValue.value);
  // end;
  // showmessage('access: ' + access)
  // finally
  // LJsonObj.Free;
  // end;
end;

end.
