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
    tbrInput1: TTrackBar;
    lblInput1: TLabel;
    btnHundredRuns: TButton;
    btnThousandRuns: TButton;
    btnTenRuns: TButton;
    btnLoadFile: TButton;
    FileOpenDialog1: TFileOpenDialog;
    imgActual: TImage;
    Label1: TLabel;
    imgDesired: TImage;
    Label2: TLabel;
    Button1: TButton;
    Button2: TButton;
    chkShowDesired: TCheckBox;
    lblPerf: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnSampleClick(Sender: TObject);
    procedure btnSetupSynapsesClick(Sender: TObject);
    procedure tbrInput1Change(Sender: TObject);
    procedure btnTenRunsClick(Sender: TObject);
    procedure btnHundredRunsClick(Sender: TObject);
    procedure btnThousandRunsClick(Sender: TObject);
    procedure btnLoadFileClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    FNeuralNetwork: TNeuralNetwork;
    FInputNeuron1: TInputNeuron;
    FInputNeuron2: TInputNeuron;
    FOutputNeurons: TList<TOutputNeuron>;
    FImages: Array[0..3] of TBitmap;
    procedure Train(ANumRuns: integer);
    procedure GetSelectedPicture;
    procedure SetupNeuralNet;
    procedure UpdateLabels;
  public
  end;

var
  MainWindow: TMainWindow;

implementation

{$R *.dfm}

uses
  Vcl.Imaging.jpeg;

procedure TMainWindow.btnSetupSynapsesClick(Sender: TObject);
begin
  FNeuralNetwork.SetupRandomSynapses;
end;

procedure TMainWindow.btnTenRunsClick(Sender: TObject);
begin
  Train(10);
  UpdateLabels;
end;

procedure TMainWindow.btnThousandRunsClick(Sender: TObject);
begin
  Train(1000);
  UpdateLabels;
end;

procedure TMainWindow.Button1Click(Sender: TObject);
begin
  GetSelectedPicture;
end;

procedure TMainWindow.Button2Click(Sender: TObject);
begin
  FImages[tbrInput1.Position].Free;
  FImages[tbrInput1.Position] := nil;
end;

procedure TMainWindow.btnHundredRunsClick(Sender: TObject);
begin
  Train(100);
  UpdateLabels;
end;

procedure TMainWindow.btnLoadFileClick(Sender: TObject);
var
  Pic: TPicture;
  Bitmap: TBitmap;
begin
  if FileOpenDialog1.Execute then
  begin
    FImages[tbrInput1.Position].Free;
    FImages[tbrInput1.Position] := TBitmap.Create;

    Pic := TPicture.Create;
    try
      Pic.LoadFromFile(FileOpenDialog1.FileName);
      Bitmap := FImages[tbrInput1.Position];
      Bitmap.Height := imgActual.Height;
      Bitmap.Width := imgActual.Width;
      Bitmap.Canvas.StretchDraw(Rect(0, 0, imgActual.Width, imgActual.Height), Pic.Graphic);
    finally
      Pic.Free;
    end;
  end;
end;

procedure TMainWindow.btnSampleClick(Sender: TObject);
begin
  Train(1);
  UpdateLabels;
end;

procedure TMainWindow.FormCreate(Sender: TObject);
var
  i: integer;
begin
  for i := 0 to 9 do
    FImages[i] := nil;

  SetupNeuralNet;
end;

procedure TMainWindow.FormDestroy(Sender: TObject);
begin
  FOutputNeurons.Free;
  FNeuralNetwork.Free;
end;

procedure TMainWindow.GetSelectedPicture;
var
  Bitmap: TBitmap;
  i: byte;
  x, y, w: integer;
  r, g, b: byte;
begin
  i := tbrInput1.Position;
  FInputNeuron1.InputSample := i and $01;
  FInputNeuron2.InputSample := (i and $02) shr 1;

  Bitmap := FImages[tbrInput1.Position];

  w := imgActual.Width;

  imgDesired.Canvas.StretchDraw(Rect(0, 0, imgDesired.Width, imgDesired.Height), Bitmap);
  //Assign(Bitmap.Canvas);
//  if chkShowDesired.Checked then
//    for x := 0 to w - 1 do
//      for y := 0 to imgActual.Height - 1 do
        //imgDesired.Canvas.Pixels[x, y] := Bitmap.Canvas.Pixels[x, y];

  FNeuralNetwork.Sample;

  for x := 0 to w - 1 do
    for y := 0 to imgActual.Height - 1 do
    begin
      r := trunc(FOutputNeurons[(x + w * y) * 3 + 0].OutputValue * 255);
      g := trunc(FOutputNeurons[(x + w * y) * 3 + 1].OutputValue * 255);
      b := trunc(FOutputNeurons[(x + w * y) * 3 + 2].OutputValue * 255);

      imgActual.Canvas.Pixels[x, y] := RGB(r, g, b);
    end;
end;

procedure TMainWindow.Train(ANumRuns: integer);
var
  i: integer;
  PicIdx: integer;
  x, y, w: integer;
  r, g, b: byte;
  Bitmap: TBitmap;
  Pixel: TColor;
begin
  w := imgActual.Width;
  for i := 0 to ANumRuns - 1 do
  begin
    for PicIdx := 0 to 3 do
    begin
      Bitmap := FImages[PicIdx];
      if Assigned(Bitmap) then
      begin
        FInputNeuron1.InputSample := PicIdx and $01;
        FInputNeuron2.InputSample := (PicIdx and $02) shr 1;

        FNeuralNetwork.Sample;

        for x := 0 to w - 1 do
          for y := 0 to imgActual.Height - 1 do
          begin
            Pixel := Bitmap.Canvas.Pixels[x, y];
            r := GetRValue(Pixel);
            g := GetGValue(Pixel);
            b := GetBValue(Pixel);

            FOutputNeurons[(x + w * y) * 3 + 0].DesiredOutput := r / 255;
            FOutputNeurons[(x + w * y) * 3 + 1].DesiredOutput := g / 255;
            FOutputNeurons[(x + w * y) * 3 + 2].DesiredOutput := b / 255;
          end;

        FNeuralNetwork.BackPropagate;
      end;
    end;
  end;

  GetSelectedPicture;
end;

procedure TMainWindow.UpdateLabels;
begin
  lblPerf.Caption := 'P: ' + FloatToStr(FNeuralNetwork.CalculatePerformaceValue);
end;

procedure TMainWindow.SetupNeuralNet;
var
  i: integer;
begin
  FNeuralNetwork := TNeuralNetwork.Create;
  FNeuralNetwork.LearningFactor := 0.125;

  //FNeuralNetwork.CreateNeuron(1);
  //FNeuralNetwork.CreateNeuron(1);
  for i := 0 to 25 {trunc(imgActual.Width * imgActual.Height / 32) - 1{} do
    FNeuralNetwork.CreateNeuron(1);

  FInputNeuron1 := FNeuralNetwork.CreateInputNeuron;
  FInputNeuron2 := FNeuralNetwork.CreateInputNeuron;

  FOutputNeurons := TList<TOutputNeuron>.Create;

  for i := 0 to imgActual.Width * imgActual.Height * 3 - 1 do
    FOutputNeurons.Add(FNeuralNetwork.CreateOutputNeuron);
end;

procedure TMainWindow.tbrInput1Change(Sender: TObject);
var
  i: byte;
begin
  i := tbrInput1.Position;
  lblInput1.Caption := 'Input: ' + i.ToString;

  FInputNeuron1.InputSample := i and $01;
  FInputNeuron2.InputSample := (i and $02) shr 1;
end;

end.
