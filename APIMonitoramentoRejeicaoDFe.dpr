program APIMonitoramentoRejeicaoDFe;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  System.JSON,
  System.Rtti,
  System.Generics.Collections,
  Horse,
  Horse.Jhonson,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Error,
  FireDAC.UI.Intf,
  FireDAC.Phys.Intf,
  FireDAC.Stan.Def,
  FireDAC.Stan.Pool,
  FireDAC.Stan.Async,
  FireDAC.Phys,
  FireDAC.Phys.PG,
  FireDAC.Phys.PGDef,
  FireDAC.VCLUI.Wait,
  Data.DB,
  FireDAC.Comp.Client,
  FireDAC.Comp.DataSet,
  FireDAC.DApt,
  Uconexao.PG in 'Uconexao.PG.pas';

type
  [JSONOwned]
  TRejeicao = class
  private
    [JSONName('nomedoEmitente')]
    FNomedoEmitente: string;
    [JSONName('cnpJEmitente')]
    FCNPJEmitente: string;
    [JSONName('statusdaRejeicao')]
    FStatusdaRejeicao: string;
    [JSONName('descricaodaRejeicao')]
    FDescricaodaRejeicao: string;
    [JSONName('totalizardorPorRejeicaoPorStatus')]
    FTotalizardorPorRejeicaoPorStatus: Integer;
    [JSONName('totaldeReijeicaonatabela')]
    FTotaldeReijeicaonatabela: Integer;
  public
    property NomedoEmitente: string read FNomedoEmitente write FNomedoEmitente;
    property CNPJEmitente: string read FCNPJEmitente write FCNPJEmitente;
    property StatusdaRejeicao: string read FStatusdaRejeicao write FStatusdaRejeicao;
    property DescricaodaRejeicao: string read FDescricaodaRejeicao write FDescricaodaRejeicao;
    property TotalizardorPorRejeicaoPorStatus: Integer read FTotalizardorPorRejeicaoPorStatus write FTotalizardorPorRejeicaoPorStatus;
    property TotaldeReijeicaonatabela: Integer read FTotaldeReijeicaonatabela write FTotaldeReijeicaonatabela;
  end;

// Registrar a classe para evitar eliminação pelo linker
procedure RegisterClassForRTTI;
begin
  TRttiContext.Create.GetType(TRejeicao);
end;

// Função para persistir os dados no banco PostgreSQL
procedure GravarNoBanco(const ARejeicao: TRejeicao);
var
  LConexao: TFDConnection;
  LQuery: TFDQuery;
begin
  LConexao := TFDConnection.Create(nil);
  LQuery := TFDQuery.Create(nil);
  try
    LConexao.DriverName := 'PG';
    LConexao.Params.Values['User_Name'] := 'postgres';
    LConexao.Params.Values['Password'] := 'postgres';
    LConexao.Params.Values['Database'] := 'APIMonitoramento';
    LConexao.Params.Values['Server'] := 'localhost';
    LConexao.Params.Values['Port'] := '5433';

    LConexao.Connected := True;
    LQuery.Connection := LConexao;

    LQuery.SQL.Text :=
      'INSERT INTO Rejeicoes (nome_emitente, cnpj_emitente, status_rejeicao, descricao_rejeicao, total_por_status, total_geral) ' +
      'VALUES (:nome, :cnpj, :status, :descricao, :total_status, :total_geral)';

    LQuery.ParamByName('nome').AsString := ARejeicao.NomedoEmitente;
    LQuery.ParamByName('cnpj').AsString := ARejeicao.CNPJEmitente;
    LQuery.ParamByName('status').AsString := ARejeicao.StatusdaRejeicao;
    LQuery.ParamByName('descricao').AsString := ARejeicao.DescricaodaRejeicao;
    LQuery.ParamByName('total_status').AsInteger := ARejeicao.TotalizardorPorRejeicaoPorStatus;
    LQuery.ParamByName('total_geral').AsInteger := ARejeicao.TotaldeReijeicaonatabela;

    LQuery.ExecSQL;
  finally
    LConexao.Free;
    LQuery.Free;
  end;
end;

begin
  // Registrar a classe para RTTI
  RegisterClassForRTTI;

  THorse.Use(Jhonson);

  // Endpoint para receber um array de rejeições
  THorse.Post('/rejeicoes',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    var
      LJSONArray: TJSONArray;
      LJSONObject: TJSONObject;
      LRejeicao: TRejeicao;
      I: Integer;
    begin
      try
        // Obter o corpo da requisição como TJSONArray
        LJSONArray := Req.Body<TJSONArray>;
        try
          // Processar cada objeto no array
          for I := 0 to LJSONArray.Count - 1 do
          begin
            LJSONObject := LJSONArray.Items[I] as TJSONObject;
            LRejeicao := TRejeicao.Create;
            try
              // Desserializar manualmente o JSON para TRejeicao
              LRejeicao.NomedoEmitente := LJSONObject.GetValue<string>('nomedoEmitente', '');
              LRejeicao.CNPJEmitente := LJSONObject.GetValue<string>('cnpJEmitente', '');
              LRejeicao.StatusdaRejeicao := LJSONObject.GetValue<string>('statusdaRejeicao', '');
              LRejeicao.DescricaodaRejeicao := LJSONObject.GetValue<string>('descricaodaRejeicao', '');
              LRejeicao.TotalizardorPorRejeicaoPorStatus := LJSONObject.GetValue<Integer>('totalizardorPorRejeicaoPorStatus', 0);
              LRejeicao.TotaldeReijeicaonatabela := LJSONObject.GetValue<Integer>('totaldeReijeicaonatabela', 0);

              // Gravar no banco
              GravarNoBanco(LRejeicao);
            finally
              LRejeicao.Free;
            end;
          end;

          // Retorna status 201 (Created) se tudo deu certo
          Res.Status(201).Send('Rejeições recebidas e salvas com sucesso!');
        finally
          //LJSONArray.Free;
        end;
      except
        on E: Exception do
        begin
          Res.Status(500).Send('Erro ao processar a requisição: ' + E.Message);
        end;
      end;
    end);

  // Inicia o servidor na porta 9000
  THorse.Listen(9000,
    procedure
    begin
      Writeln('Servidor da API rodando na porta 9000...');
    end);
end.
