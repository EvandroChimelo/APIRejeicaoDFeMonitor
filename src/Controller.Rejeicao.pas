unit Controller.Rejeicao;

interface
uses
  System.SysUtils,
  Horse,
  System.JSON,
  System.Generics.Collections,
  Horse.Jhonson,
  Model.Rejeicao,
  DAO.Rejeicao;

type
  TRejeicaoController = class
  public
    class procedure RegistrarEndpoints;
  end;

implementation


{ TRejeicaoController }

class procedure TRejeicaoController.RegistrarEndpoints;
begin
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
              TRejeicaoDAO.Gravar(LRejeicao);
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
          Writeln('ERRO INTERNO: ' + E.ClassName + ' - ' + E.Message);
          Res.Status(500).Send('Erro ao processar a requisição: ' + E.Message);
        end;
      end;
    end);

end;

end.
