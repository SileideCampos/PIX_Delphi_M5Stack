program Pix;

uses
  System.StartUpCopy,
  FMX.Forms,
  Chave_Pix in 'Chave_Pix.pas' {FPix};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFPix, FPix);
  Application.Run;
end.
