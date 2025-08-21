program APIMonitoramentoRejeicaoDFe;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  System.Rtti,
  Horse,
  Horse.Jhonson,
  Model.Rejeicao in 'src\Model.Rejeicao.pas',
  Conexao.PG in 'src\Conexao.PG.pas',
  DAO.Rejeicao in 'src\DAO.Rejeicao.pas',
  Controller.Rejeicao in 'src\Controller.Rejeicao.pas';

procedure RegisterClassForRTTI;
begin
  TRttiContext.Create.GetType(TRejeicao);
end;

begin
  try
  // Registrar a classe para RTTI
  RegisterClassForRTTI;

  THorse.Use(Jhonson);

  TRejeicaoController.RegistrarEndpoints;

  // Inicia o servidor na porta 9000
  THorse.Listen(9000,
    procedure
    begin
      Writeln('Servidor da API rodando na porta 9000...');
    end);
  except
  on E: exception do
    writeln(E.ClassName, ': ', e.Message);
  end;
end.
