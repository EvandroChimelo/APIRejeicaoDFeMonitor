unit Model.Rejeicao;


interface

uses
  System.JSON.Serializers;

type
  [JSONOwned]
  TRejeicao = class
  private
    [JSONName('nomedoEmitente')]
    FNomedoEmitente: string;
    [JSONName('cnpjemitente')]
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
implementation

end.
