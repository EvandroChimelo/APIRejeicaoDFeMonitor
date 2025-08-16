unit EnviaJSON;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, System.Net.HttpClient, System.JSON, Vcl.StdCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Memo: TMemo;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    procedure EnviarDadosParaAPI;

  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

{ TForm1 }

procedure TForm1.Button1Click(Sender: TObject);
begin
  EnviarDadosParaAPI;
end;

procedure TForm1.EnviarDadosParaAPI;
var
  HTTPClient: THTTPClient;
  JSON: TJSONObject;
  URL: string;
  Resposta: IHTTPResponse;
  JSONString: string;
begin
  HTTPClient := THTTPClient.Create;
  JSON := TJSONObject.Create;
  try

    Memo.Clear;

    // 1. Monta o objeto JSON
    JSON.AddPair('NomedoEmitente', 'Empresa Teste SA');
    JSON.AddPair('CNPJEmitente', '99.888.777/0001-66');
    JSON.AddPair('StatusdaRejeicao', '539');
    JSON.AddPair('DescricaodaRejeicao', 'Duplicidade de NF-e');
    JSON.AddPair('TotalizardorPorRejeicaoPorStatus', TJSONNumber.Create(25));
    JSON.AddPair('TotaldeReijeicaonatabela', TJSONNumber.Create(250));
    Memo.Lines.Add('1. Monta o objeto JSON');

    // 2. Define a URL da API
    URL := 'http://localhost:9000/rejeicoes';
    Memo.Lines.Add('2. Define a URL da API');

    // 3. Converte o objeto JSON para String
    JSONString := JSON.ToString;
    Memo.Lines.Add('3. Converte o objeto JSON para String');

    // 4. Envia a requisição POST com o JSON no corpo
    Resposta := HTTPClient.Post(URL, TStringStream.Create(JSONString, TEncoding.UTF8), nil);
    Memo.Lines.Add('4. Envia a requisição POST com o JSON no corpo');

    // 5. (Opcional) Verifica a resposta do servidor
    if Resposta.StatusCode = 201 then
      ShowMessage('Dados enviados com sucesso!')
    else
      ShowMessage('Erro ao enviar dados: ' + Resposta.StatusText);

  finally
    HTTPClient.Free;
    JSON.Free;
  end;
end;

end.
