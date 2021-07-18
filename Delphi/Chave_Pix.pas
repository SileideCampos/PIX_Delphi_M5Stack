unit Chave_Pix;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Edit, System.ImageList, FMX.ImgList,
  FMX.Objects, FMX.Layouts, IdBaseComponent, IdComponent, IdUDPBase, IdUDPClient;

type
  TFPix = class(TForm)
    edtChave: TEdit;
    edtEstabelecimento: TEdit;
    edtCidade: TEdit;
    edtValor: TEdit;
    btnPix: TButton;
    ImageList1: TImageList;
    Layout1: TLayout;
    Rectangle1: TRectangle;
    RoundRect2: TRoundRect;
    Image1: TImage;
    StyleBook1: TStyleBook;
    ImgQRCode: TImage;
    udp: TIdUDPClient;
    lblCodigoPix: TLabel;
    procedure btnPixClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure edtValorKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
  private
    function gerarCrc16(pTexto: string): Word;
    procedure gerarCodigoPix;
    procedure configUDP;
    function formataCampoValor(pValor: string): string;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FPix: TFPix;

implementation

{$R *.fmx}

const
  cFormatIndicator = '000201';
  cAccountInformation = '26';
  cCodeGui = '0014';
  cGui = 'BR.GOV.BCB.PIX';
  cCodeKeyAccount = '01';
  cMerchantCategoryCode = '52040000';
  cTransactionCurrency = '5303986';
  cCodeValor = '54';
  cCountryCode = '5802BR';
  cCodeMerchantName = '59';
  cCodeMerchantCity = '60';
  cAddDataFieldTemplate = '62070503***';
  cCRC16 = '6304';

procedure TFPix.FormCreate(Sender: TObject);
begin
  configUDP;
end;

procedure TFPix.configUDP;
begin
  udp.Host := '192.168.43.12';
  udp.Port := 8888;
  udp.Active := True;
end;

procedure TFPix.btnPixClick(Sender: TObject);
begin
  gerarCodigoPix;
end;

procedure TFPix.gerarCodigoPix;
var
  lCodigoPix: string;
begin
  lCodigoPix :=
  cFormatIndicator +
  cAccountInformation +
    FormatFloat('00', Length(cGui) +8+ Length(edtChave.Text))+
    cCodeGui+
    cGui +
    cCodeKeyAccount+
    FormatFloat('00', Length(edtChave.Text)) +
    edtChave.Text+
  cMerchantCategoryCode+
  cTransactionCurrency;

  if ((not edtValor.Text.IsEmpty) and
      (StringReplace(edtValor.Text, '.', ',', []).ToDouble>0)) then
    lCodigoPix := lCodigoPix +
                  cCodeValor +
                  FormatFloat('00', Length(edtValor.Text)) +
                  formataCampoValor(edtValor.Text);

  lCodigoPix := lCodigoPix +
  cCountryCode+
  cCodeMerchantName +
  FormatFloat('00', Length(edtEstabelecimento.Text)) +
  edtEstabelecimento.Text+
  cCodeMerchantCity +
  FormatFloat('00', Length(edtCidade.Text)) +
  edtCidade.Text+
  cAddDataFieldTemplate +
  cCRC16;

  lCodigoPix := lCodigoPix + IntToHex(gerarCrc16(lCodigoPix), 4);
  lblCodigoPix.Text := lCodigoPix;

  udp.Send(lCodigoPix);
end;

function TFPix.gerarCrc16(pTexto: string): Word;
const
  cPolynom = $1021;
  cInit = $FFFF;
var
  litext, lipoly: Integer;
begin
  Result := cInit;
  for litext := 1 to length(pTexto) do
  begin
    Result := Result xor (ord(pTexto[litext]) shl 8);
    for lipoly := 0 to 7 do
    begin
      if (Result and $8000) <> 0 then
        Result := (Result shl 1) xor cPolynom
      else
        Result := Result shl 1;
    end;
  end;
  Result := Result and $FFFF;
end;

procedure TFPix.edtValorKeyUp(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
  if CharInSet(KeyChar, ['0' .. '9']) then
  begin
    edtValor.Text := formataCampoValor(edtValor.Text);
    edtValor.SelStart := length(edtValor.Text);
  end;
end;

function TFPix.formataCampoValor(pValor: string): string;
begin
  if not (pValor.IsEmpty) then
  begin
    pValor     := StringReplace( pValor, '.', '',[rfReplaceAll]);
    pValor     := FormatCurr('##0.00', StrToCurr(pValor)/100);
    pValor     := StringReplace(pValor, ',', '.', []);
  end;
  Result := pValor;
end;

end.
