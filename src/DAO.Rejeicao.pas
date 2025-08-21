unit DAO.Rejeicao;

interface

uses
  System.SysUtils,
  System.Rtti,
  data.DB,
  FireDAC.comp.Client,
  Model.Rejeicao,
  Conexao.PG,
  Horse,
  Horse.Jhonson;

type
  TRejeicaoDAO = class
  public
    class procedure Gravar(const ARejeicao: TRejeicao);
  end;

implementation

{ TRejeicaoDAO }
// Registrar a classe para evitar eliminação pelo linker

class procedure TRejeicaoDAO.Gravar(const ARejeicao: TRejeicao);
var
  LConexao: TFDConnection;
  LQuery: TFDQuery;
  LEmitenteID: Integer;
begin
  LConexao := Conexao.PG.CrirConexao;
  LQuery := TFDQuery.Create(nil);
  try
    LConexao.Connected := True;
    LQuery.Connection := LConexao;

    LConexao.StartTransaction;
      try
        //verifica se o emitente ja existe validando o CNPJ
        LQuery.SQL.Text := 'SELECT id FROM emitente WHERE cnpjcpf_emitente = :cnpjcpf_emitente';
        LQuery.ParamByName('cnpjcpf_emitente').AsString := ARejeicao.CNPJEmitente;
        LQuery.Open;

        if LQuery.IsEmpty then
        begin
        //Se o CNPJ não e exite, insere na tabela e retorna o ID
        LQuery.Close;
        LQuery.SQL.Text := 'INSERT INTO emitente(nome, cnpjcpf_emitente) VALUES (:nome, :cnpjcpf_emitente) RETURNING id';
        LQuery.ParamByName('nome').AsString := ARejeicao.NomedoEmitente;
        LQuery.ParamByName('cnpjcpf_emitente').AsString := ARejeicao.CNPJEmitente;
        LQuery.Open;
        LEmitenteID := LQuery.FieldByName('id').AsInteger;
        end
        else
        begin
          LEmitenteID := LQuery.FieldByName('id').AsInteger;
        end;

          LQuery.Close;

          //insere na tabela de rejeições usando o ID do emitente
          LQuery.SQL.Text := 'INSERT INTO Rejeicoes (gid_emitente, status_rejeicao, descricao_rejeicao, total_por_status) ' +
                           'VALUES (:gid_emitente, :status_rejeicao, :descricao_rejeicao, :total_por_status)';

          LQuery.ParamByName('gid_emitente').AsInteger := LEmitenteID;
          LQuery.ParamByName('status_rejeicao').AsString := ARejeicao.StatusdaRejeicao;
          LQuery.ParamByName('descricao_rejeicao').AsString := ARejeicao.DescricaodaRejeicao;
          LQuery.ParamByName('total_por_status').AsInteger := ARejeicao.TotalizardorPorRejeicaoPorStatus;

          LQuery.ExecSQL;

          //se não deu nada de errado commit
          LConexao.Commit;
      except
         on E: Exception do
         begin
           //Se deu erro, desfaz tudo
           LConexao.Rollback;
           raise;
         end;
      end;

  finally
    LConexao.Free;
    LQuery.Free;
  end;

end;

end.
