unit MainWin;

interface

{$WARN SYMBOL_PLATFORM OFF}

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Neural, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtCtrls, System.Generics.Collections,
  Vcl.Imaging.pngimage;

const
  MaxRayLength = 750;
  LearningRate = 0.15;
  NumSensors = 50;
  TrainingSampleInterval = 2;
  MaxTrainingSamples = 4000;
  CarStartX = 120;
  CarStartY = 480;

type
  TSensorArrayValues = record
    MainForwardSensor: Extended;
    LeftSensors: Array[0..NumSensors-1] of Extended;
    RightSensors: Array[0..NumSensors-1] of Extended;
  end;
  TTrainingSample = record
    SensorValues: TSensorArrayValues;

    TurnRightNeuron: Double;
    TurnLeftNeuron: Double;
    SlowDownNeuron: Double;
    SpeedUpNeuron: Double;
  end;

  TMainWindow = class(TForm)
    imgRacetrack: TImage;
    imgRacecarSrc: TImage;
    imgRaceCar: TImage;
    tmrUpdateRacer: TTimer;
    imgLines: TImage;
    shpTurnLeft: TShape;
    shpTurnRight: TShape;
    shpSlowDown: TShape;
    shpSpeedUp: TShape;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    NetworkFileSaveDialog: TFileSaveDialog;
    NetworkFileLoadDialog: TFileOpenDialog;
    pnlTrainingMode: TPanel;
    imgPerfGraph: TImage;
    lblSampleCount: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure tmrUpdateRacerTimer(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormDestroy(Sender: TObject);
  private
    FNeuralNet: TNeuralNetwork;
    FAngle: Double;
    FCarPosX: single;
    FCarPosY: single;
    FGoLeft: Double;
    FGoRight: Double;
    FGoFast: double;
    FGoSlow: double;
    FCarSpeed: single;
    FMainForwardSensor: TInputNeuron;
    FLeftSensors: Array[0..NumSensors-1] of TInputNeuron;
    FRightSensors: Array[0..NumSensors-1] of TInputNeuron;

    FTurnRightNeuron: TOutputNeuron;
    FTurnLeftNeuron: TOutputNeuron;
    FSlowDownNeuron: TOutputNeuron;
    FSpeedUpNeuron: TOutputNeuron;
    FAutoDriving: Boolean;
    FOffRoad: boolean;
    FFrames: integer;
    FPerfList: TList<double>;
    FWorstPerf: double;
    FPerf: double;
    FTrainingSamples: TList<TTrainingSample>;
  public
    procedure Sample;
    procedure Train(AIndex: integer);
    procedure FeedInputNeurons(const SensorValues: TSensorArrayValues);
    procedure ShowOutputCorrectness;
    procedure MakeTrainingSample(ASensorValues: TSensorArrayValues);
    procedure SampleAndSteer(const ASensorArray: TSensorArrayValues);
    procedure SetupNeuralNet;
    procedure MoveCar;
    procedure PaintCar;
    procedure TakeSensorValues(var SensorArrayValues: TSensorArrayValues);
    procedure PaintSensorLine(SensorX, SensorY, LineEndX, LineEndY: single);
    function SenseCurbDistance(SensorX, SensorY, ang: single): integer;
    procedure SaveNeuralNetwork;
    procedure LoadNeuralNetwork;
    procedure DetectOffroad;
    procedure LoadTrack1;
    procedure LoadTrack2;
    procedure CalcPerformance;
    procedure UpdatePerfGraph;
  end;

var
  MainWindow: TMainWindow;

implementation

{$R *.dfm}

uses
  Vcl.Imaging.jpeg,
  System.Math,
  System.JSON,
  NeuralJSON;

procedure TMainWindow.CalcPerformance;
var
  P: double;
begin
  if FNeuralNet.TrackingPerformance then
  begin
    P := FNeuralNet.EndPerformanceCalculation;
    Assert(P <= 0);
    if FWorstPerf > P then
      FWorstPerf := P;

    FPerf := FPerf + P;
    if FFrames mod 250 = 0 then
    begin
      FPerfList.Add(FPerf / 50);
      FPerf := 0;
    end;

    while FPerfList.Count > 1000 do
      FPerfList.Delete(0);

    UpdatePerfGraph;
  end;

  FNeuralNet.StartPerformanceCalculation;
end;

procedure TMainWindow.DetectOffroad;
var
  c: TColor;
  r, g, b: byte;
  v: single;
begin
//  c := imgRacetrack.Canvas.Pixels[round(FCarPosX-2), round(FCarPosY-9)];
//  r := GetRValue(c);
//  g := GetGValue(c);
//  b := GetBValue(c);
//  v := (r + g + b) / 3;
//  FOffRoad := (v < 30);
end;

procedure TMainWindow.UpdatePerfGraph;
var
  x, y: integer;
begin
  if (FPerfList.Count = 0) or (FWorstPerf >= -0.00000000001) then
    exit;

  imgPerfGraph.Canvas.Brush.Color := clWhite;
  imgPerfGraph.Canvas.FillRect(Rect(0,0,imgPerfGraph.Width, imgPerfGraph.Height));
  y := round(FPerfList[0] / FWorstPerf * imgPerfGraph.Height);
  imgPerfGraph.Canvas.MoveTo(0, imgPerfGraph.Height - y);
  for x := 0 to FPerfList.Count - 1 do
  begin
    y := round(FPerfList[x] / FWorstPerf * imgPerfGraph.Height);
    imgPerfGraph.Canvas.LineTo(x, imgPerfGraph.Height - y);
  end;
end;

procedure TMainWindow.FeedInputNeurons(const SensorValues: TSensorArrayValues);
var
  i: integer;
begin
  FMainForwardSensor.InputSample := SensorValues.MainForwardSensor;

  for i := 0 to NumSensors - 1 do
  begin
    FLeftSensors[i].InputSample := SensorValues.LeftSensors[i];
    FRightSensors[i].InputSample := SensorValues.RightSensors[i];
  end;
end;

procedure TMainWindow.FormCreate(Sender: TObject);
begin
  FPerfList := TList<double>.Create;
  FTrainingSamples := TList<TTrainingSample>.Create;
  FWorstPerf := 0.000001;

  SetupNeuralNet;

  FCarPosX := 136;
  FCarPosY := 473;
  FAngle := 270;
  FCarSpeed := 1;

  FAutoDriving := true;
  FFrames := 0;
end;

procedure TMainWindow.FormDestroy(Sender: TObject);
begin
  FPerfList.Free;
  FTrainingSamples.Free;
end;

procedure PaintRotatedBitmap(Bmp: TBitmap; radians: single; DestDC: hDC);
var
  cosine, sine: single;
  x1, y1, x2, y2, x3, y3: integer;
  minx, miny, maxx, maxy: integer;
  w, h: integer;
  xFrm: XFORM;
begin
  cosine := cos(radians);
  sine := sin(radians);

  // Compute dimensions of the resulting bitmap
  // First get the coordinates of the 3 corners other than origin
  x1 := round(bmp.Height * sine);
  y1 := round(bmp.Height * cosine);
  x2 := round(bmp.Width * cosine + bmp.Height * sine);
  y2 := round(bmp.Height * cosine - bmp.Width * sine);
  x3 := round(bmp.Width * cosine);
  y3 := round(-bmp.Width * sine);

  minx := min(0,min(x1, min(x2,x3)));
  miny := min(0,min(y1, min(y2,y3)));
  maxx := max(0,max(x1, max(x2,x3)));
  maxy := max(0,max(y1, max(y2,y3)));

  w := maxx - minx;
  h := maxy - miny;

  // We will use world transform to rotate the bitmap
  SetGraphicsMode(destDC, GM_ADVANCED);
  xfrm.eM11 := cosine;
  xfrm.eM12 := -sine;
  xfrm.eM21 := sine;
  xfrm.eM22 := cosine;
  xfrm.eDx := -minx;
  xfrm.eDy := -miny;

  SetWorldTransform(destDC, xFrm);

  // Now do the actual rotating - a pixel at a time
  BitBlt(destDC, 0, 0, bmp.Width, bmp.Height, bmp.Canvas.Handle, 0, 0, SRCCOPY);
end;

procedure TMainWindow.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_SPACE then
  begin
    FAutoDriving := not FAutoDriving;
    pnlTrainingMode.Visible := not FAutoDriving;
    if not FAutoDriving then
      Caption := 'Neural Racer * TRAINING MODE *'
    else
      Caption := 'Neural Racer';

    FGoLeft := 0;
    FGoRight := 0;
    FGoFast := 0;
    FGoSlow := 0;
  end;

  if not FAutoDriving then
  begin
    if Key = VK_LEFT then
      FGoLeft := 1;

    if Key = VK_Right then
      FGoRight := 1;

    if Key = VK_Up then
      FGoFast := 1;

    if Key = VK_Down then
      FGoSlow := 1;
  end;
end;

procedure TMainWindow.FormKeyPress(Sender: TObject; var Key: Char);
var
  i: integer;
begin
  if UpCase(Key) = 'P' then
    tmrUpdateRacer.Enabled := not tmrUpdateRacer.Enabled;

  if UpCase(Key) = 'S' then
    SaveNeuralNetwork;

  if Upcase(Key) = 'L' then
    LoadNeuralNetwork;

  if Key = '1' then
    LoadTrack1;

  if Key = '2' then
    LoadTrack2;

  if Key = 'T' then
    for i := 0 to MaxTrainingSamples do
      Train(i);
end;

procedure TMainWindow.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if not FAutoDriving then
  begin
    if Key = VK_LEFT then
      FGoLeft := 0;

    if Key = VK_Right then
      FGoRight := 0;

    if Key = VK_Up then
      FGoFast := 0;

    if Key = VK_Down then
      FGoSlow := 0;
  end;
end;

procedure TMainWindow.LoadNeuralNetwork;
var
  fs: TFileStream;
  JSONDoc: TJSONObject;
  bytes: TBytes;
  i: integer;
begin
  if NetworkFileLoadDialog.Execute then
  begin
    fs := TFileStream.Create(NetworkFileLoadDialog.Filename, fmOpenRead);
    try
      JSONDoc := TJSONObject.Create;
      try
        SetLength(bytes, fs.Size);
        fs.Read(bytes, fs.Size);
        JSONDoc.Parse(bytes, 0);
        if (JSONDoc.GetValue('DocType').Value = 'NeuralNetworkConfiguration') and (JSONDoc.GetValue('Version').Value = '1.0') then
        begin
          FNeuralNet.LoadData(TJsonNeuralNetworkDataReader.Create(JSONDoc.GetValue('Data') as TJSONObject));

          FMainForwardSensor := FNeuralNet.GetInputNeuron('Main Fwd');
          for i := 0 to 20 do
          begin
            FLeftSensors[i] := FNeuralNet.GetInputNeuron('Left' + i.ToString);
            FRightSensors[i] := FNeuralNet.GetInputNeuron('Right' + i.ToString);
          end;

//          FMainForwardSensor := FNeuralNet.GetInputNeuron('Main forward sensor');
//
//          FLeftForwardSensor  := FNeuralNet.GetInputNeuron('Left forward sensor');
//          FRightForwardSensor := FNeuralNet.GetInputNeuron('Right forward sensor');
//          FRightCornerSensor1 := FNeuralNet.GetInputNeuron('Right corner sensor 1');
//          FRightCornerSensor2 := FNeuralNet.GetInputNeuron('Right corner sensor 2');
//          FLeftCornerSensor1  := FNeuralNet.GetInputNeuron('Left corner sensor 1');
//          FLeftCornerSensor2  := FNeuralNet.GetInputNeuron('Left corner sensor 2');
//          FLeftSideSensor1    := FNeuralNet.GetInputNeuron('Left side sensor 1');
//          FLeftSideSensor2    := FNeuralNet.GetInputNeuron('Left side sensor 2');
//          FLeftSideSensor3    := FNeuralNet.GetInputNeuron('Left side sensor 3');
//          FLeftSideSensor4    := FNeuralNet.GetInputNeuron('Left side sensor 4');
//          FLeftSideSensor5    := FNeuralNet.GetInputNeuron('Left side sensor 5');
//          FRightSideSensor1   := FNeuralNet.GetInputNeuron('Right side sensor 1');
//          FRightSideSensor2   := FNeuralNet.GetInputNeuron('Right side sensor 2');
//          FRightSideSensor3   := FNeuralNet.GetInputNeuron('Right side sensor 3');
//          FRightSideSensor4   := FNeuralNet.GetInputNeuron('Right side sensor 4');
//          FRightSideSensor5   := FNeuralNet.GetInputNeuron('Right side sensor 5');
//
//          FLeftRearSensor    := FNeuralNet.GetInputNeuron('Left rear sensor');
//          FRightRearSensor   := FNeuralNet.GetInputNeuron('Right rear sensor');

          FTurnRightNeuron := FNeuralNet.GetOutputNeuron('Turn right');
          FTurnLeftNeuron  := FNeuralNet.GetOutputNeuron('Turn left');
          FSlowDownNeuron  := FNeuralNet.GetOutputNeuron('Slow down');
          FSpeedUpNeuron   := FNeuralNet.GetOutputNeuron('Speed up');

          FNeuralNet.LearningFactor := LearningRate;
        end;
      finally
        JSONDoc.Free;
      end;
    finally
      fs.Free;
    end;
  end;
end;

procedure TMainWindow.LoadTrack1;
begin
  imgRacetrack.Picture.LoadFromFile('RaceTrack1.bmp');
end;

procedure TMainWindow.LoadTrack2;
begin
  imgRacetrack.Picture.LoadFromFile('RaceTrack2.bmp');
end;

procedure TMainWindow.MakeTrainingSample(ASensorValues: TSensorArrayValues);
var
  Sample: TTrainingSample;
begin
  Sample.SensorValues := ASensorValues;

  Sample.TurnRightNeuron := FGoRight;
  Sample.TurnLeftNeuron := FGoLeft;
  Sample.SlowDownNeuron := FGoSlow;
  Sample.SpeedUpNeuron := FGoFast;

  FTrainingSamples.Add(Sample);
  while FTrainingSamples.Count > MaxTrainingSamples do
    FTrainingSamples.Delete(0);

  lblSampleCount.Caption := FTrainingSamples.Count.ToString() + ' Samples';
end;

procedure TMainWindow.MoveCar;
var
  ang: single;
  s, c: single;
  x, y: single;
  spd: single;
begin
  if FOffRoad then
  begin
    FOffRoad := false;
    FCarPosX := CarStartX;
    FCarPosY := CarStartY;
    FAngle := 270;
    FCarSpeed := 1;
  end
  else
  begin
    FAngle := FAngle + FGoLeft;
    FAngle := FAngle - FGoRight;

    if FAngle < 0 then
      FAngle := FAngle + 360;
    if FAngle > 360 then
      FAngle := FAngle - 360;

    spd := FCarSpeed + 0.1;
    spd := spd + 1 * FGoFast;
    spd := spd - 0.5 * FGoSlow;

    FCarPosX := FCarPosX - Spd * sin(FAngle / 360 * 2 * pi);
    FCarPosY := FCarPosY - Spd * cos(FAngle / 360 * 2 * pi);
  end;

  ang := (FAngle) / 360 * 2 * pi;
  s := sin(ang);
  c := cos(ang);
  x := abs(imgRacecarSrc.Height * s) + abs(imgRacecarSrc.Width * c);
  y := abs(imgRacecarSrc.Width * s) + abs(imgRaceCarSrc.Height * c);

  imgRaceCar.Top := round(FCarPosY - y/2);
  imgRaceCar.Left := round(FCarPosX - x/2);
end;

procedure TMainWindow.PaintCar;
var
  ang: double;
begin
  imgRaceCar.Canvas.Brush.Color := clFuchsia;
  imgRaceCar.Canvas.FillRect(Rect(0, 0, imgRaceCar.Height, imgRaceCar.Width));

  ang := FAngle / 360 * 2 * pi;

  PaintRotatedBitmap(imgRacecarSrc.Picture.Bitmap, ang, imgRaceCar.Canvas.Handle);
end;

procedure TMainWindow.PaintSensorLine(SensorX, SensorY, LineEndX, LineEndY: single);
begin
  if FFrames mod TrainingSampleInterval = 0 then
    imgLines.Canvas.Pen.Color := clLime
  else
    imgLines.Canvas.Pen.Color := clRed;
  imgLines.Canvas.MoveTo(round(SensorX), round(SensorY));
  imgLines.Canvas.LineTo(round(LineEndX), round(LineEndY));
end;

procedure TMainWindow.Sample;
begin
  FNeuralNet.Sample;
end;

procedure TMainWindow.SampleAndSteer(const ASensorArray: TSensorArrayValues);
begin
  FeedInputNeurons(ASensorArray);
  FNeuralNet.Sample;

  FGoRight := FTurnRightNeuron.OutputValue;
  FGoLeft  := FTurnLeftNeuron.OutputValue;
  FGoSlow  := FSlowDownNeuron.OutputValue;
  FGoFast  := FSpeedUpNeuron.OutputValue;

  shpTurnLeft.Brush.Color := RGB(0, round(FGoLeft * 255), 0);
//  if FGoLeft then
//    shpTurnLeft.Brush.Color := clLime
//  else
//    shpTurnLeft.Brush.Color := clGreen;

  shpTurnRight.Brush.Color := RGB(0, round(FGoRight * 255), 0);
//  if FGoRight then
//    shpTurnRight.Brush.Color := clLime
//  else
//    shpTurnRight.Brush.Color := clGreen;

  shpSlowDown.Brush.Color := RGB(0, round(FGoSlow * 255), 0);
//  if FGoSlow then
//    shpSlowDown.Brush.Color := clLime
//  else
//    shpSlowDown.Brush.Color := clGreen;

  shpSpeedUp.Brush.Color := RGB(0, round(FGoFast * 255), 0);
//  if FGoFast then
//    shpSpeedUp.Brush.Color := clLime
//  else
//    shpSpeedUp.Brush.Color := clGreen;
end;

procedure TMainWindow.SaveNeuralNetwork;
var
  NeuralData, NeuralDoc: TJSONObject;
  fs: TFileStream;
  bytes: TArray<byte>;
begin
  if NetworkFileSaveDialog.Execute then
  begin
    NeuralDoc := TJSONObject.Create;
    try
      NeuralDoc.AddPair('DocType', 'NeuralNetworkConfiguration');
      NeuralDoc.AddPair('Version', '1.0');

      NeuralData := TJSONObject.Create;
      try
        FNeuralNet.SaveNeuralDataToJSON(NeuralData);
        NeuralDoc.AddPair('Data', NeuralData);
      except
        NeuralData.Free;
        raise;
      end;

      setLength(bytes, NeuralDoc.EstimatedByteSize);
      setLength(bytes, NeuralDoc.ToBytes(bytes, 0));

      fs := TFileStream.Create(NetworkFileSaveDialog.FileName, fmCreate);
      try
        fs.Write(Bytes, length(bytes));
      finally
        fs.Free;
      end;
    finally
      NeuralData.Free;
    end;
  end;
end;

function TMainWindow.SenseCurbDistance(SensorX, SensorY, ang: single): integer;
var
  sine, cosine: single;
  i: integer;
  function SenseCurbPixel(x, y: single): boolean;
  var
    c: TColor;
    r,g,b: byte;
    v: single;
  begin
    c := imgRacetrack.Canvas.Pixels[round(x), round(y)];
    r := GetRValue(c);
    g := GetGValue(c);
    b := GetBValue(c);
    v := (r + g + b) / 3;
    if v < 60 then
      exit(true)
    else
      exit(false);
  end;
begin
  sine := sin(ang);
  cosine := cos(ang);

  for i := 0 to MaxRayLength do
  begin
    if SenseCurbPixel(SensorX - sine * i, SensorY - cosine * i) then
      break;
  end;
  PaintSensorLine(SensorX, SensorY, SensorX - sine * i, SensorY - cosine * i);

  result := i;
end;

procedure TMainWindow.SetupNeuralNet;
var
  i: integer;
begin
  FNeuralNet := TNeuralNetwork.Create(2);
  FNeuralNet.LearningFactor := LearningRate;

  FMainForwardSensor := FNeuralNet.CreateInputNeuron('Main Fwd');
  for i := 0 to NumSensors - 1 do
  begin
    FLeftSensors[i] := FNeuralNet.CreateInputNeuron('Left' + i.ToString);
    FRightSensors[i] := FNeuralNet.CreateInputNeuron('Right' + i.ToString);
  end;

  FNeuralNet.CreateNeuron(1);
  FNeuralNet.CreateNeuron(1);
  FNeuralNet.CreateNeuron(1);
  FNeuralNet.CreateNeuron(1);
  FNeuralNet.CreateNeuron(1);
  FNeuralNet.CreateNeuron(1);
  FNeuralNet.CreateNeuron(1);
  FNeuralNet.CreateNeuron(1);
  FNeuralNet.CreateNeuron(1);
  FNeuralNet.CreateNeuron(1);
  FNeuralNet.CreateNeuron(1);
  FNeuralNet.CreateNeuron(1);
  FNeuralNet.CreateNeuron(1);
  FNeuralNet.CreateNeuron(1);
  FNeuralNet.CreateNeuron(1);
  FNeuralNet.CreateNeuron(1);
  FNeuralNet.CreateNeuron(1);
  FNeuralNet.CreateNeuron(1);
  FNeuralNet.CreateNeuron(1);
  FNeuralNet.CreateNeuron(1);
  FNeuralNet.CreateNeuron(1);
  FNeuralNet.CreateNeuron(1);
  FNeuralNet.CreateNeuron(1);
  FNeuralNet.CreateNeuron(1);
  FNeuralNet.CreateNeuron(1);
  FNeuralNet.CreateNeuron(1);
  FNeuralNet.CreateNeuron(1);
  FNeuralNet.CreateNeuron(1);
  FNeuralNet.CreateNeuron(1);
  FNeuralNet.CreateNeuron(1);
  FNeuralNet.CreateNeuron(1);
  FNeuralNet.CreateNeuron(1);
  FNeuralNet.CreateNeuron(1);
  FNeuralNet.CreateNeuron(1);
  FNeuralNet.CreateNeuron(1);
  FNeuralNet.CreateNeuron(1);
  FNeuralNet.CreateNeuron(1);
  FNeuralNet.CreateNeuron(1);
  FNeuralNet.CreateNeuron(1);
  FNeuralNet.CreateNeuron(1);
  FNeuralNet.CreateNeuron(1);
  FNeuralNet.CreateNeuron(1);
  FNeuralNet.CreateNeuron(1);
  FNeuralNet.CreateNeuron(1);
  FNeuralNet.CreateNeuron(1);
  FNeuralNet.CreateNeuron(1);
  FNeuralNet.CreateNeuron(1);
  FNeuralNet.CreateNeuron(1);
  FNeuralNet.CreateNeuron(1);
  FNeuralNet.CreateNeuron(1);
  FNeuralNet.CreateNeuron(1);
  FNeuralNet.CreateNeuron(1);
  FNeuralNet.CreateNeuron(1);
  FNeuralNet.CreateNeuron(1);
  FNeuralNet.CreateNeuron(1);
  FNeuralNet.CreateNeuron(1);
  FNeuralNet.CreateNeuron(1);
  FNeuralNet.CreateNeuron(1);
  FNeuralNet.CreateNeuron(1);
  FNeuralNet.CreateNeuron(1);

  FNeuralNet.CreateNeuron(2);
  FNeuralNet.CreateNeuron(2);
  FNeuralNet.CreateNeuron(2);
  FNeuralNet.CreateNeuron(2);
  FNeuralNet.CreateNeuron(2);
  FNeuralNet.CreateNeuron(2);
  FNeuralNet.CreateNeuron(2);
  FNeuralNet.CreateNeuron(2);
  FNeuralNet.CreateNeuron(2);
  FNeuralNet.CreateNeuron(2);
  FNeuralNet.CreateNeuron(2);
  FNeuralNet.CreateNeuron(2);
  FNeuralNet.CreateNeuron(2);

  FTurnRightNeuron := FNeuralNet.CreateOutputNeuron('Turn right');
  FTurnLeftNeuron  := FNeuralNet.CreateOutputNeuron('Turn left');
  FSlowDownNeuron  := FNeuralNet.CreateOutputNeuron('Slow down');
  FSpeedUpNeuron   := FNeuralNet.CreateOutputNeuron('Speed up');

  FNeuralNet.SetupRandomSynapses;
end;

procedure TMainWindow.ShowOutputCorrectness;
var
  distance: double;
begin
  Distance := ABS(FGoRight - FTurnRightNeuron.OutputValue);
  if Distance < 0.2 then
    shpTurnRight.Brush.Color := clLime
  else if Distance < 0.5 then
    shpTurnRight.Brush.Color := clGreen
  else
    shpTurnRight.Brush.Color := clMaroon;

  Distance := Abs(FGoLeft - FTurnLeftNeuron.OutputValue);
  if Distance < 0.2 then
    shpTurnLeft.Brush.Color := clLime
  else if Distance < 0.5 then
    shpTurnLeft.Brush.Color := clGreen
  else
    shpTurnLeft.Brush.Color := clMaroon;

  Distance := Abs(FGoSlow - FSlowDownNeuron.OutputValue);
  if Distance < 0.2 then
    shpSlowDown.Brush.Color := clLime
  else if Distance < 0.5 then
    shpSlowDown.Brush.Color := clGreen
  else
    shpSlowDown.Brush.Color := clMaroon;

  Distance := Abs(FGoFast - FSpeedUpNeuron.OutputValue);
  if Distance < 0.2 then
    shpSpeedUp.Brush.Color := clLime
  else if Distance < 0.5 then
    shpSpeedUp.Brush.Color := clGreen
  else
    shpSpeedUp.Brush.Color := clMaroon;
end;

procedure TMainWindow.TakeSensorValues(var SensorArrayValues: TSensorArrayValues);
var
  ang: single;
  sine, cosine: single;
  SensorX, SensorY: single;
  s: Extended;
  T: Extended;
  i: integer;
  function TakeSensorValue(AAngle: single): Extended;
  var
    V: Extended;
  begin
    V := SenseCurbDistance(SensorX, SensorY, ang + AAngle) / MaxRayLength;
    //V := Power(V, 1.5) * 1.5;
    result := V;
  end;
begin
  imgLines.Canvas.Brush.Color := clFuchsia;
  imgLines.Canvas.FillRect(imgLines.ClientRect);

  ang := FAngle / 360 * 2 * pi;
  sine := sin(ang);
  cosine := cos(ang);
  SensorX := Round(FCarPosX - sine * 8) - 8;
  SensorY := round(FCarPosY - cosine * 8) - 8;

  s := TakeSensorValue(0);
  T := s;
  SensorArrayValues.MainForwardSensor := s;

  for i := 0 to NumSensors - 1 do
  begin
    s := TakeSensorValue(i * 0.05 + 0.04);
    T := T + s;
    SensorArrayValues.LeftSensors[i] := s;
    s := TakeSensorValue(i * -0.05 - 0.04);
    T := T + s;
    SensorArrayValues.RightSensors[i] := s;
  end;
  T := T / (NumSensors * 2);
  FOffRoad := T < 0.001;
//  SensorArrayValues.MiddleMainForwardSensor := TakeSensorValue(0);
//  SensorArrayValues.LeftMainForwardSensor := TakeSensorValue(0.05);
//  SensorArrayValues.RightMainForwardSensor := TakeSensorValue(-0.05);
//
//  SensorArrayValues.LeftForwardSensor := TakeSensorValue(0.15);
//  SensorArrayValues.RightForwardSensor := TakeSensorValue(lblInput5, 'In 5 (R Fw)', -0.15);
//
//  SensorArrayValues.RightCornerSensor1 := TakeSensorValue(lblInput6, 'In 6 (Rc1)', -0.25);
//  SensorArrayValues.RightCornerSensor2 := TakeSensorValue(lblInput7, 'In 7 (Rc2)', -0.4);
//  SensorArrayValues.LeftCornerSensor2 := TakeSensorValue(lblInput8, 'In 8 (Lc2)', 0.4);
//  SensorArrayValues.LeftCornerSensor1 := TakeSensorValue(lblInput9, 'In 9 (Lc1)', 0.25);
//
//  SensorArrayValues.LeftSideSensor1 := TakeSensorValue(lblInput10, 'In 10 (Ls1)', 0.5);
//  SensorArrayValues.LeftSideSensor2 := TakeSensorValue(lblInput11, 'In 11 (Ls2)', 0.7);
//  SensorArrayValues.LeftSideSensor3 := TakeSensorValue(lblInput12, 'In 12 (Ls3)', 1);
//  SensorArrayValues.LeftSideSensor4 := TakeSensorValue(lblInput13, 'In 13 (Ls4)', 1.2);
//  SensorArrayValues.LeftSideSensor5 := TakeSensorValue(lblInput14, 'In 14 (Ls5)', 1.5);
//  SensorArrayValues.RightSideSensor5 := TakeSensorValue(lblInput15, 'In 15 (Rs5)', -1.5);
//  SensorArrayValues.RightSideSensor4 := TakeSensorValue(lblInput16, 'In 16 (Rs4)', -1.2);
//  SensorArrayValues.RightSideSensor3 := TakeSensorValue(lblInput17, 'In 17 (Rs3)', -1);
//  SensorArrayValues.RightSideSensor2 := TakeSensorValue(lblInput18, 'In 18 (Rs2)', -0.7);
//  SensorArrayValues.RightSideSensor1 := TakeSensorValue(lblInput19, 'In 19 (Rs1)', -0.5);
//
//  SensorArrayValues.LeftRearSensor := TakeSensorValue(lblInput20, 'In 20 (LR)', 1.9);
//  SensorArrayValues.RightRearSensor := TakeSensorValue(lblInput21, 'In 21 {RR)', -1.9);
end;

procedure TMainWindow.tmrUpdateRacerTimer(Sender: TObject);
var
  SensorArray: TSensorArrayValues;
  i: integer;
begin
  MoveCar;
  DetectOffroad;
  if FOffRoad then
  begin
    if (not FAutoDriving) and (FTrainingSamples.Count > 0) then
    begin
      for i := FTrainingSamples.Count - 1 downto max(0, FTrainingSamples.Count - 30) do
        FTrainingSamples.Delete(i);
    end;
    exit;
  end;

  PaintCar;
  TakeSensorValues(SensorArray);

  if FAutoDriving then
    SampleAndSteer(SensorArray)
  else
  begin
    inc(FFrames);

    //if FFrames mod TrainingSampleInterval = 0 then
    if (FGoLeft > 0.5) or (FGoRight > 0.5) or (FGoFast > 0.5) or (FGoSlow > 0.5) then
      MakeTrainingSample(SensorArray);

    FeedInputNeurons(SensorArray);
    Sample;
    ShowOutputCorrectness;

    if FTrainingSamples.Count > 0 then
      Train(FFrames mod FTrainingSamples.Count);

    if FFrames mod 2 = 0 then
      CalcPerformance;

    if FFrames > 100000 then
      FFrames := 0;
  end;
end;

procedure TMainWindow.Train(AIndex: integer);
var
  i: integer;
  Sample: TTrainingSample;
  b: byte;
begin
  i := AIndex;

  b := i and $FF;

  // By shifting some bits in the index, we can make sure the situations are not trained in exact sequence.
  // This prevents the neural network from overtraining a range of similar situations and "forgetting" about the rest. -TVe20170425
  i := i and $FFFFFF9C;
  i := i + (b and $1) shl 6;
  i := i + (b and $2) shl 4;
  i := i + (b and $20) shr 4;
  i := i + (b and $40) shr 6;

  // Because of the bit shifts, we might have ended up with an index that doesn't exist.
  i := i mod FTrainingSamples.Count;

  Sample := FTrainingSamples[i];
  FeedInputNeurons(Sample.SensorValues);

  FTurnRightNeuron.DesiredOutput := Sample.TurnRightNeuron;
  FTurnLeftNeuron.DesiredOutput  := Sample.TurnLeftNeuron;
  FSlowDownNeuron.DesiredOutput  := Sample.SlowDownNeuron;
  FSpeedUpNeuron.DesiredOutput   := Sample.SpeedUpNeuron;

  FNeuralNet.Sample;
  FNeuralNet.BackPropagate;
end;

end.
