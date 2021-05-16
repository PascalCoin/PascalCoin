unit URegURI;

interface

// Skybuck: Part of PIP-0026 implementation

type
  TUriRecord = record
    Descrip: String;
    Protocol: String; // only letters or nombers .. no spaces ..
    Path: String; // complete path for application to be opened
                     //when appuri:// is called
    Icon: string; // icon file or executable file with icon
  end;

  function RegisterAppURI(URIReg: TUriRecord): boolean;
  function UnRegisterAppURI(protocol: string): boolean;

implementation

uses Registry, windows, ShlObj, dialogs;

function RegisterAppURI(URIReg: TUriRecord): boolean;
const
  root = '\Software\Classes\';
var
  Reg : TRegistry;
begin
  result := false;
  reg := TRegistry.Create;

  try
    try
      reg.RootKey := HKEY_CURRENT_USER;
      if reg.Openkey(root + URIReg.Protocol, True) then
      begin
        reg.WriteString('', 'URL:'+URIReg.Descrip);
        reg.WriteString('URL Protocol', '');

        if reg.Openkey(root + URIReg.Protocol + '\DefaultIcon', True) then
          reg.WriteString('', URIReg.Icon);

        if reg.Openkey(root + URIReg.Protocol + '\shell', True) and
          reg.Openkey(root + URIReg.Protocol + '\shell\open', True) and
          reg.Openkey(root + URIReg.Protocol + '\shell\open\command', True) then
          reg.WriteString('', '"'+URIReg.Path + '" "%1" "%2" "%3" "%4" "%5" "%6" "%7" "%8" "%9"');
      end;
      reg.CloseKey;

      reg.RootKey := HKEY_CURRENT_USER;
      if reg.Openkey('\Software\Microsoft\Internet Explorer\ProtocolExecute\' + URIReg.Protocol, True) then
      begin
        reg.WriteInteger('WarnOnOpen', 0);
      end;
      reg.CloseKey;

    //can cause problems…
      SHChangeNotify(SHCNE_ASSOCCHANGED, SHCNF_IDLIST, nil, nil);
      result := true;
    except
//      showmessage('No se pudo realizar el registro.'#13'Asegurese de ejecutar la aplicación con permisos de Administrador');
      showmessage('Registration failed. '#13' Make sure to run the application with Administrator permissions');
      result := false;
    end;
  finally
    reg.free;
  end;
end;

function UnRegisterAppURI(protocol: string): boolean;
const
  root = '\Software\Classes\';
var
  Reg : TRegistry;
begin
  result := false;
  reg := TRegistry.Create;
  try
    reg.RootKey := HKEY_CLASSES_ROOT;
    result := reg.DeleteKey(root+protocol);

    reg.RootKey := HKEY_CURRENT_USER;
    reg.DeleteKey('\Software\Microsoft\Internet Explorer\ProtocolExecute\' + Protocol);
  finally
    reg.Free;
  end;
end;

end.
