unit MainWin;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Neural, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtCtrls, System.Generics.Collections;

type
  TMainWindow = class(TForm)
    btnSetupSynapses: TButton;
    btnSample: TButton;
    btnBackpropagate: TButton;
    btnHundredRuns: TButton;
    imgGraph: TImage;
    btnThousandRuns: TButton;
    CheckSine: TCheckBox;
    EditLearningRate: TEdit;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    chkSample1: TCheckBox;
    chkSample2: TCheckBox;
    chkSample3: TCheckBox;
    chkSample4: TCheckBox;
    chkSample5: TCheckBox;
    chkSample6: TCheckBox;
    pnlSample1: TPanel;
    lblActual1: TLabel;
    Label2: TLabel;
    EditInput1: TEdit;
    EditOutput1: TEdit;
    pnlSample2: TPanel;
    lblActual2: TLabel;
    Label3: TLabel;
    EditInput2: TEdit;
    EditOutput2: TEdit;
    pnlSample3: TPanel;
    lblActual3: TLabel;
    Label4: TLabel;
    EditInput3: TEdit;
    EditOutput3: TEdit;
    pnlSample4: TPanel;
    pnlSample5: TPanel;
    Label5: TLabel;
    lblActual4: TLabel;
    EditInput4: TEdit;
    EditOutput4: TEdit;
    pnlSample6: TPanel;
    Label1: TLabel;
    lblActual5: TLabel;
    EditInput5: TEdit;
    EditOutput5: TEdit;
    Label6: TLabel;
    lblActual6: TLabel;
    EditInput6: TEdit;
    EditOutput6: TEdit;
    lblPerf: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnSampleClick(Sender: TObject);
    procedure btnSetupSynapsesClick(Sender: TObject);
    procedure btnBackpropagateClick(Sender: TObject);
    procedure btnHundredRunsClick(Sender: TObject);
    procedure btnThousandRunsClick(Sender: TObject);
    procedure EditInput1Change(Sender: TObject);
    procedure EditInput2Change(Sender: TObject);
    procedure EditInput3Change(Sender: TObject);
    procedure EditInput4Change(Sender: TObject);
    procedure EditOutput1Change(Sender: TObject);
    procedure EditOutput2Change(Sender: TObject);
    procedure EditOutput3Change(Sender: TObject);
    procedure EditOutput4Change(Sender: TObject);
    procedure CheckSineClick(Sender: TObject);
    procedure EditInput5Change(Sender: TObject);
    procedure EditOutput5Change(Sender: TObject);
    procedure EditInput6Change(Sender: TObject);
    procedure EditOutput6Change(Sender: TObject);
    procedure EditLearningRateChange(Sender: TObject);
    procedure SampleCheckboxClick(Sender: TObject);
  private
    FNeuralNetwork: TNeuralNetwork;
    FInputNeuron: TInputNeuron;
    FOutputNeuron: TOutputNeuron;
    FInput1: Extended;
    FInput2: Extended;
    FInput3: Extended;
    FInput4: Extended;
    FInput5: Extended;
    FInput6: Extended;
    FDesired1: Extended;
    FDesired2: Extended;
    FDesired3: Extended;
    FDesired4: Extended;
    FDesired5: Extended;
    FDesired6: Extended;
    FActual1: Extended;
    FActual2: Extended;
    FActual3: Extended;
    FActual4: Extended;
    FActual5: Extended;
    FActual6: Extended;
    FCheckboxAssociations: TDictionary<TCheckBox, TPanel>;
    procedure SetupNetwork;
    function Sample(AInput, ADesired: Extended): Extended;
    procedure DrawSine;
    procedure DrawGraph;
    procedure BackPropagate;
    function BackPropagateSingleValue(AInput, ADesired: extended): Extended;
    procedure UpdateLabels;
  public
  end;

var
  MainWindow: TMainWindow;

implementation

{$R *.dfm}

function TryStrToFloat(AStr: string; var output: Extended): boolean;
begin
  AStr := StringReplace(AStr, '.', ',', [rfReplaceAll]);
  result := System.SysUtils.TryStrToFloat(AStr, output);
end;

procedure TMainWindow.btnSetupSynapsesClick(Sender: TObject);
begin
  FNeuralNetwork.SetupRandomSynapses;
end;

procedure TMainWindow.btnThousandRunsClick(Sender: TObject);
var
  i: integer;
begin
  for i := 0 to 999 do
    BackPropagate;
  UpdateLabels;
  DrawGraph;
end;

procedure TMainWindow.CheckSineClick(Sender: TObject);
begin
  editInput1.Text := '0';
  editInput2.Text := '0.25';
  editInput3.Text := '0.33333';
  editInput4.Text := '0.66667';
  editInput5.Text := '0.75';
  editInput6.Text := '1';

  EditOutput1.Text := '0.5';
  editOutput2.Text := '1';
  editOutput3.Text := '0.9330127';
  editOutput4.Text := '0.0669873';
  EditOutput5.Text := '0';
  EditOutput6.Text := '0.5';

  DrawGraph;
end;

procedure TMainWindow.SampleCheckboxClick(Sender: TObject);
var
  Panel: TPanel;
  Checkbox: TCheckbox;
  i: integer;
begin
  CheckBox := Sender as TCheckbox;
  Panel := FCheckboxAssociations.Items[Checkbox];
  Panel.Enabled := (Sender as TCheckbox).Checked;

  for i := 0 to Panel.ControlCount - 1 do
    Panel.Controls[i].Enabled := Panel.Enabled;
end;

procedure TMainWindow.DrawGraph;
var
  i: integer;
  o: extended;
  x1, x2: integer;
  y1, y2: integer;
  procedure DrawDesiredNode(AInputValue, ADesiredValue: extended);
  begin
    FInputNeuron.InputSample := AInputValue;
    x1 := round(AInputValue * imgGraph.Width) - 3;
    y1 := round(ADesiredValue * imgGraph.Height) - 3;
    x2 := x1 + 6;
    y2 := y1 + 6;
    imgGraph.Canvas.FillRect(Rect(x1, imgGraph.Height - y1, x2, imgGraph.Height - y2));
  end;
begin
  FInputNeuron.InputSample := 0;
  FNeuralNetwork.Sample;
  o := FOutputNeuron.OutputValue;

  x2 := 0;
  y2 := trunc(o * imgGraph.Height);

  imgGraph.Canvas.Brush.Color := clWhite;
  imgGraph.Canvas.FillRect(imgGraph.ClientRect);
  //imgGraph.Canvas.FillRect(Rect(0, 0, imgGraph.Width, imgGraph.Height));

  for i := 0 to 999 do
  begin
    FInputNeuron.InputSample := i / 1000;
    FNeuralNetwork.Sample;
    o := FOutputNeuron.OutputValue;

    x1 := x2;
    y1 := y2;

    x2 := trunc(i / 1000 * imgGraph.Width);
    y2 := trunc(o * imgGraph.Height);

    imgGraph.Canvas.MoveTo(x1, imgGraph.Height - y1);
    imgGraph.Canvas.LineTo(x2, imgGraph.Height - y2);
  end;

  imgGraph.Canvas.Brush.Color := clRed;
  if chkSample1.Checked then
    DrawDesiredNode(FInput1, FDesired1);
  if chkSample2.Checked then
    DrawDesiredNode(FInput2, FDesired2);
  if chkSample3.Checked then
    DrawDesiredNode(FInput3, FDesired3);
  if chkSample4.Checked then
    DrawDesiredNode(FInput4, FDesired4);
  if chkSample5.Checked then
    DrawDesiredNode(FInput5, FDesired5);
  if chkSample6.Checked then
    DrawDesiredNode(FInput6, FDesired6);

  if checkSine.Checked then
    DrawSine;
end;

procedure TMainWindow.DrawSine;
var
  x, y: integer;
  i: integer;
begin
  x := 0;
  y := round(0.5 * imgGraph.Height);

  imgGraph.Canvas.MoveTo(x, imgGraph.Height - y);

  imgGraph.Canvas.Pen.Color := clRed;
  for i := 1 to 999 do
  begin
    x := trunc(i / 1000 * imgGraph.Width);
    y := trunc((sin(i / 1000 * 2 * Pi) / 2 + 0.5) * imgGraph.Height);

    imgGraph.Canvas.LineTo(x, imgGraph.Height - y);
  end;
  imgGraph.Canvas.Pen.Color := clBlack;
end;

procedure TMainWindow.EditInput1Change(Sender: TObject);
begin
  TryStrToFloat(EditInput1.Text, FInput1);
end;

procedure TMainWindow.EditInput2Change(Sender: TObject);
begin
  TryStrToFloat(EditInput2.Text, FInput2);
end;

procedure TMainWindow.EditInput3Change(Sender: TObject);
begin
  TryStrToFloat(EditInput3.Text, FInput3);
end;

procedure TMainWindow.EditInput4Change(Sender: TObject);
begin
  TryStrToFloat(EditInput4.Text, FInput4);
end;

procedure TMainWindow.EditInput5Change(Sender: TObject);
begin
  TryStrToFloat(EditInput5.Text, FInput5);
end;

procedure TMainWindow.EditInput6Change(Sender: TObject);
begin
  TryStrToFloat(EditInput6.Text, FInput6);
end;

procedure TMainWindow.EditLearningRateChange(Sender: TObject);
var
  LearningRate: Extended;
begin
  if TryStrToFloat(EditLearningRate.Text, LearningRate) then
    FNeuralNetwork.LearningFactor := LearningRate;
end;

procedure TMainWindow.EditOutput1Change(Sender: TObject);
begin
  TryStrToFloat(EditOutput1.Text, FDesired1);
end;

procedure TMainWindow.EditOutput2Change(Sender: TObject);
begin
  TryStrToFloat(EditOutput2.Text, FDesired2);
end;

procedure TMainWindow.EditOutput3Change(Sender: TObject);
begin
  TryStrToFloat(EditOutput3.Text, FDesired3);
end;

procedure TMainWindow.EditOutput4Change(Sender: TObject);
begin
  TryStrToFloat(EditOutput4.Text, FDesired4);
end;

procedure TMainWindow.EditOutput5Change(Sender: TObject);
begin
  TryStrToFloat(EditOutput5.Text, FDesired5);
end;

procedure TMainWindow.EditOutput6Change(Sender: TObject);
begin
  TryStrToFloat(EditOutput6.Text, FDesired6);
end;

procedure TMainWindow.btnSampleClick(Sender: TObject);
begin
  if chkSample1.Checked then
    FActual1 := Sample(FInput1, FDesired1);

  if chkSample2.Checked then
    FActual2 := Sample(FInput2, FDesired2);

  if chkSample3.Checked then
    FActual3 := Sample(FInput3, FDesired3);

  if chkSample4.Checked then
    FActual4 := Sample(FInput4, FDesired4);

  if chkSample5.Checked then
    FActual5 := Sample(FInput5, FDesired5);

  if chkSample6.Checked then
    FActual6 := Sample(FInput6, FDesired6);

  UpdateLabels;

  DrawGraph;
end;

procedure TMainWindow.BackPropagate;
begin
  if chkSample1.Checked then
    FActual1 := BackPropagateSingleValue(FInput1, FDesired1);

  if chkSample2.Checked then
    FActual2 := BackPropagateSingleValue(FInput2, FDesired2);

  if chkSample3.Checked then
    FActual3 := BackPropagateSingleValue(FInput3, FDesired3);

  if chkSample4.Checked then
    FActual4 := BackPropagateSingleValue(FInput4, FDesired4);

  if chkSample5.Checked then
    FActual5 := BackPropagateSingleValue(FInput5, FDesired5);

  if chkSample6.Checked then
    FActual6 := BackPropagateSingleValue(FInput6, FDesired6);
end;

function TMainWindow.BackPropagateSingleValue(AInput, ADesired: extended): Extended;
begin
  FInputNeuron.InputSample := AInput;
  FOutputNeuron.DesiredOutput := ADesired;
  FNeuralNetwork.Sample;
  FNeuralNetwork.BackPropagate;
  FNeuralNetwork.Sample;
  result := FOutputNeuron.OutputValue;
end;

procedure TMainWindow.btnBackpropagateClick(Sender: TObject);
begin
  BackPropagate;
  UpdateLabels;
  DrawGraph;
end;

procedure TMainWindow.btnHundredRunsClick(Sender: TObject);
var
  i: integer;
begin
  for i := 0 to 99 do
    Backpropagate;
  UpdateLabels;
  DrawGraph;
end;

procedure TMainWindow.FormCreate(Sender: TObject);
begin
  SetupNetwork;

  FCheckboxAssociations := TDictionary<TCheckBox, TPanel>.Create;
  FCheckboxAssociations.Add(chkSample1, pnlSample1);
  FCheckboxAssociations.Add(chkSample2, pnlSample2);
  FCheckboxAssociations.Add(chkSample3, pnlSample3);
  FCheckboxAssociations.Add(chkSample4, pnlSample4);
  FCheckboxAssociations.Add(chkSample5, pnlSample5);
  FCheckboxAssociations.Add(chkSample6, pnlSample6);

  imgGraph.Canvas.Brush.Color := clWhite;
  imgGraph.Canvas.FillRect(imgGraph.ClientRect);

  TryStrToFloat(EditInput1.Text, FInput1);
  TryStrToFloat(EditInput2.Text, FInput2);
  TryStrToFloat(EditInput3.Text, FInput3);
  TryStrToFloat(EditInput4.Text, FInput4);
  TryStrToFloat(EditInput5.Text, FInput5);
  TryStrToFloat(EditInput6.Text, FInput6);

  TryStrToFloat(EditOutput1.Text, FDesired1);
  TryStrToFloat(EditOutput2.Text, FDesired2);
  TryStrToFloat(EditOutput3.Text, FDesired3);
  TryStrToFloat(EditOutput4.Text, FDesired4);
  TryStrToFloat(EditOutput5.Text, FDesired5);
  TryStrToFloat(EditOutput6.Text, FDesired6);
end;

procedure TMainWindow.FormDestroy(Sender: TObject);
begin
  FNeuralNetwork.Free;
  FCheckboxAssociations.Free;
end;

function TMainWindow.Sample(AInput, ADesired: Extended): Extended;
begin
  FInputNeuron.InputSample := AInput;
  FOutputNeuron.DesiredOutput := ADesired;
  FNeuralNetwork.Sample;
  result := FOutputNeuron.OutputValue;
end;

procedure TMainWindow.SetupNetwork;
begin
  FNeuralNetwork := TNeuralNetwork.Create;
  FNeuralNetwork.LearningFactor := 0.5;

  FInputNeuron := FNeuralNetwork.CreateInputNeuron;

  FNeuralNetwork.CreateNeuron(1);
  FNeuralNetwork.CreateNeuron(1);
  FNeuralNetwork.CreateNeuron(1);
  FNeuralNetwork.CreateNeuron(1);
  FNeuralNetwork.CreateNeuron(1);
  FNeuralNetwork.CreateNeuron(1);
  FNeuralNetwork.CreateNeuron(1);
  FNeuralNetwork.CreateNeuron(1);
  FNeuralNetwork.CreateNeuron(1);
  FNeuralNetwork.CreateNeuron(1);
  FNeuralNetwork.CreateNeuron(1);
  FNeuralNetwork.CreateNeuron(1);

  FOutputNeuron := FNeuralNetwork.CreateOutputNeuron;
end;

procedure TMainWindow.UpdateLabels;
begin
  lblActual1.Caption := 'Actual: ' + FActual1.ToString;

  lblActual2.Caption := 'Actual: ' + FActual2.ToString;

  lblActual3.Caption := 'Actual: ' + FActual3.ToString;

  lblActual4.Caption := 'Actual: ' + FActual4.ToString;

  lblActual5.Caption := 'Actual: ' + FActual5.ToString;

  lblActual6.Caption := 'Actual: ' + FActual6.ToString;

  lblPerf.Caption := 'P: ' + FloatToStr(FNeuralNetwork.CalculatePerformaceValue);
end;

end.
