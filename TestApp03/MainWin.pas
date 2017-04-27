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
    imgRef1: TImage;
    Label1: TLabel;
    Button2: TButton;
    lblNum1: TLabel;
    lblNum2: TLabel;
    lblNum3: TLabel;
    lblNum4: TLabel;
    Button3: TButton;
    Button4: TButton;
    imgTest: TImage;
    Label2: TLabel;
    imgRef2: TImage;
    imgRef3: TImage;
    imgRef4: TImage;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
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
    procedure Button2Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    FNeuralNetwork: TNeuralNetwork;
    FInputNeurons: TList<TInputNeuron>;
    FOutputNeuron1: TOutputNeuron;
    FOutputNeuron2: TOutputNeuron;
    FOutputNeuron3: TOutputNeuron;
    FOutputNeuron4: TOutputNeuron;
    FImages: Array[0..3] of TBitmap;
    procedure Train(ANumRuns: integer);
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
end;

procedure TMainWindow.btnThousandRunsClick(Sender: TObject);
begin
  Train(1000);
end;

procedure TMainWindow.Button2Click(Sender: TObject);
begin
  FImages[tbrInput1.Position].Free;
  FImages[tbrInput1.Position] := nil;
end;

procedure TMainWindow.Button3Click(Sender: TObject);
var
  Pic: TPicture;
  Bitmap: TBitmap;
  x, y, w: integer;
  Pixel: TColor;
  R, G, B: Byte;
begin
  //Bitmap := TBitmap.Create;
  //try
  Bitmap := imgTest.Picture.Bitmap;
    //Bitmap.Height := imgActual.Height;
    //Bitmap.Width := imgActual.Width;
    //Bitmap.Canvas.StretchDraw(Rect(0, 0, imgTest.Width, imgTest.Height), Pic.Graphic);

    w := imgTest.Width;
    for x := 0 to w - 1 do
      for y := 0 to imgTest.Height - 1 do
      begin
        Pixel := Bitmap.Canvas.Pixels[x, y];
        r := GetRValue(Pixel);
        g := GetGValue(Pixel);
        b := GetBValue(Pixel);

        FInputNeurons[(x + w * y) * 3 + 0].InputSample := r / 255;
        FInputNeurons[(x + w * y) * 3 + 1].InputSample := g / 255;
        FInputNeurons[(x + w * y) * 3 + 2].InputSample := b / 255;
      end;

    FNeuralNetwork.Sample;

    lblNum1.Caption := 'Number 1: ' + Round(FOutputNeuron1.OutputValue * 100).ToString + '%';
    lblNum2.Caption := 'Number 2: ' + Round(FOutputNeuron2.OutputValue * 100).ToString + '%';
    lblNum3.Caption := 'Number 3: ' + Round(FOutputNeuron3.OutputValue * 100).ToString + '%';
    lblNum4.Caption := 'Number 4: ' + Round(FOutputNeuron4.OutputValue * 100).ToString + '%';

  //finally
  //  Bitmap.Free;
  //end;
end;

procedure TMainWindow.Button4Click(Sender: TObject);
var
  Pic: TPicture;
  Bitmap: TBitmap;
  x, y, w: integer;
  Pixel: TColor;
  R, G, B: Byte;
begin
  if FileOpenDialog1.Execute then
  begin
    Pic := TPicture.Create;
    try
      Pic.LoadFromFile(FileOpenDialog1.FileName);
      Bitmap := TBitmap.Create;
      try
        Bitmap.Height := imgTest.Height;
        Bitmap.Width := imgTest.Width;
        Bitmap.Canvas.StretchDraw(Rect(0, 0, imgTest.Width, imgTest.Height), Pic.Graphic);

        imgTest.Canvas.Draw(0, 0, Bitmap);

        w := imgTest.Width;
        for x := 0 to w - 1 do
          for y := 0 to imgTest.Height - 1 do
          begin
            Pixel := Bitmap.Canvas.Pixels[x, y];
            r := GetRValue(Pixel);
            g := GetGValue(Pixel);
            b := GetBValue(Pixel);

            FInputNeurons[(x + w * y) * 3 + 0].InputSample := r / 255;
            FInputNeurons[(x + w * y) * 3 + 1].InputSample := g / 255;
            FInputNeurons[(x + w * y) * 3 + 2].InputSample := b / 255;
          end;

        FNeuralNetwork.Sample;

        lblNum1.Caption := 'Number 1: ' + Round(FOutputNeuron1.OutputValue * 100).ToString + '%';
        lblNum2.Caption := 'Number 2: ' + Round(FOutputNeuron2.OutputValue * 100).ToString + '%';
        lblNum3.Caption := 'Number 3: ' + Round(FOutputNeuron3.OutputValue * 100).ToString + '%';
        lblNum4.Caption := 'Number 4: ' + Round(FOutputNeuron4.OutputValue * 100).ToString + '%';
      finally
        Bitmap.Free;
      end;
    finally
      Pic.Free;
    end;
  end;
end;

procedure TMainWindow.btnHundredRunsClick(Sender: TObject);
begin
  Train(100);
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
      Bitmap.Height := imgRef1.Height;
      Bitmap.Width := imgRef1.Width;
      Bitmap.Canvas.StretchDraw(Rect(0, 0, imgRef1.Width, imgRef1.Height), Pic.Graphic);

      case tbrInput1.Position of
        0: imgRef1.Canvas.Draw(0, 0, Bitmap);
        1: imgRef2.Canvas.Draw(0, 0, Bitmap);
        2: imgRef3.Canvas.Draw(0, 0, Bitmap);
        3: imgRef4.Canvas.Draw(0, 0, Bitmap);
      end;

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
  for i := 0 to 3 do
    FImages[i] := nil;

  SetupNeuralNet;
end;

procedure TMainWindow.FormDestroy(Sender: TObject);
begin
  FInputNeurons.Free;
  FNeuralNetwork.Free;
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
  w := imgRef1.Width;
  for i := 0 to ANumRuns - 1 do
  begin
    for PicIdx := 0 to 3 do
    begin
      Bitmap := FImages[PicIdx];
      if Assigned(Bitmap) then
      begin
        for x := 0 to w - 1 do
          for y := 0 to imgRef1.Height - 1 do
          begin
            Pixel := Bitmap.Canvas.Pixels[x, y];
            r := GetRValue(Pixel);
            g := GetGValue(Pixel);
            b := GetBValue(Pixel);

            FInputNeurons[(x + w * y) * 3 + 0].InputSample := r / 255;
            FInputNeurons[(x + w * y) * 3 + 1].InputSample := g / 255;
            FInputNeurons[(x + w * y) * 3 + 2].InputSample := b / 255;
          end;

        FNeuralNetwork.Sample;

        if PicIdx = 0 then
          FOutputNeuron1.DesiredOutput := 1 else FOutputNeuron1.DesiredOutput := 0;
        if PicIdx = 1 then
          FOutputNeuron2.DesiredOutput := 1 else FOutputNeuron2.DesiredOutput := 0;
        if PicIdx = 2 then
          FOutputNeuron3.DesiredOutput := 1 else FOutputNeuron3.DesiredOutput := 0;
        if PicIdx = 3 then
          FOutputNeuron4.DesiredOutput := 1 else FOutputNeuron4.DesiredOutput := 0;

        FNeuralNetwork.BackPropagate;
      end;
    end;
  end;
end;

procedure TMainWindow.UpdateLabels;
begin
  lblPerf.Caption := 'P: ' + FloatToStr(FNeuralNetwork.CalculatePerformaceValue);
end;

procedure TMainWindow.SetupNeuralNet;
var
  i: integer;
begin
  FNeuralNetwork := TNeuralNetwork.Create(2);
  FNeuralNetwork.LearningFactor := 0.05;

  for i := 0 to 1000 do
    FNeuralNetwork.CreateNeuron(1);

  for i := 0 to 100 do
    FNeuralNetwork.CreateNeuron(2);

  FInputNeurons := TList<TInputNeuron>.Create;

  for i := 0 to imgRef1.Width * imgRef1.Height * 3 - 1 do
    FInputNeurons.Add(FNeuralNetwork.CreateInputNeuron);

  FOutputNeuron1 := FNeuralNetwork.CreateOutputNeuron;
  FOutputNeuron2 := FNeuralNetwork.CreateOutputNeuron;
  FOutputNeuron3 := FNeuralNetwork.CreateOutputNeuron;
  FOutputNeuron4 := FNeuralNetwork.CreateOutputNeuron;

  FNeuralNetwork.SetupRandomSynapses;
end;

procedure TMainWindow.tbrInput1Change(Sender: TObject);
var
  i: byte;
begin
  i := tbrInput1.Position;
  lblInput1.Caption := 'Picture nr: ' + (i+1).ToString;
end;

end.
