unit URegisterURI;

interface

// Skybuck: Part of PIP-0026 implementation

function RegisterURIWithWindows7 : boolean;

implementation

uses
  URegURI,
  UConst;

 // should work for windows 7
function RegisterURIWithWindows7 : boolean;
var
  vURIRecord : TUriRecord;
begin
  result := false;

  with vURIRecord do
  begin
    Descrip := CT_URI_Description;
    Protocol := CT_URI_Protocol;
    Path := ParamStr(0);
    Icon := ParamStr(0);
  end;

  if RegisterAppURI( vURIRecord ) then
  begin
   result := true;
  end;
end;

end.
