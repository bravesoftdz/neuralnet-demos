program NeuralTest02;

uses
  Vcl.Forms,
  MainWin in 'MainWin.pas' {MainWindow};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainWindow, MainWindow);
  Application.Run;
end.
