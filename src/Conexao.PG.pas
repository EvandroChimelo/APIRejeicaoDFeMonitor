unit Conexao.PG;

interface

uses
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Def,
  FireDAC.Phys.Intf,
  FireDAC.Comp.Client,
  FireDAC.DApt,
  FireDAC.Phys.PG,
  FireDAC.Phys.PGWrapper,
  FireDAC.Stan.Async;


  function CrirConexao: TFDConnection;

implementation

function CrirConexao: TFDConnection;
begin
  Result := TFDConnection.Create(nil);
    Result.DriverName := 'PG';
    Result.Params.Values['User_Name'] := 'postgres';
    Result.Params.Values['Password'] := 'postgres';
    Result.Params.Values['Database'] := 'APIMonitoramento';
    Result.Params.Values['Server'] := 'localhost';
    Result.Params.Values['Port'] := '5433';
    Result.LoginPrompt := False;
end;

end.
