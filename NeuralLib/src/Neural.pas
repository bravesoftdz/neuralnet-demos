unit Neural;

////////////////////////////////////////////////////////////////////////////////
//
// TODO: Refactor Json saving out of these classes and to a (set of) formatting classes.
// These functions are now in violation of the SOLID principles.
//

interface

{$WARN SYMBOL_PLATFORM OFF}

uses
  System.Math, System.Generics.Collections, System.SysUtils, System.JSON;

type
  INeuronDataReader = interface
  ['{071B4AC5-B4A9-4803-A371-8C8BC5091FFE}']
    function GetId: integer;
    function GetType: TClass;
    function GetName: string;
    function GetBiasWeight: Extended;

    function GetSynapseCount: integer;
    procedure GetSynapse(Index: integer; out SourceNeuronId: integer; out SynapseWeight: extended);
  end;

  INeuralLayerDataReader = interface
  ['{A7EC9D53-D3B4-4D4E-903B-B1A527409C73}']
    function GetId: integer;
    function GetPreviousLayerId: integer;
    function GetNextLayerId: integer;
    function GetNeuronCount: integer;
    function GetNeuronReader(Index: integer): INeuronDataReader;
  end;

  INeuralNetworkDataReader = interface
  ['{A3249ECA-D1AE-47E4-9266-4F57BCDF3188}']
    function GetLearningRate: Extended;

    function GetInputLayerDataReader: INeuralLayerDataReader;
    function GetOutputLayerDataReader: INeuralLayerDataReader;

    function GetHiddenLayerCount: integer;
    function GetHiddenLayerDataReader(Index: integer): INeuralLayerDataReader;
  end;

  TNeuralNetwork = class;
  TNeuralLayer = class;
  TNeuron = class;
  TInputNeuron = class;

  TNeuron = class abstract
  strict private
    FId: integer;
    FName: string;
    FLayer: TNeuralLayer;
    FOutputValue: Extended;
    FIndex: integer;
    procedure SetLayer(const Value: TNeuralLayer);
  protected
    function CalcOutputValue: Extended; virtual; abstract;
  public
    constructor Create(const AId, AIndex: integer);
    destructor Destroy; override;

    procedure Sample;
    procedure SaveToJSONObject(AJsonObj: TJSONObject); virtual; abstract;
    procedure LoadData(ADataReader: INeuronDataReader); virtual;

    property OutputValue: Extended read FOutputValue;

    property Id: integer read FId;
    property Name: string read FName write FName;
    property Layer: TNeuralLayer read FLayer write SetLayer;
    property Index: integer read FIndex;
  end;

  TSynapseRec = record
    Weight: Extended;
    Neuron: TNeuron;
  end;

  TProcessingNeuron = class(TNeuron)
  strict private
    FInputValue: Extended;
    FActivationRate: Extended;
    FLocalGradient: Extended;
    FErrorValue: Extended;
    FSynapses: TArray<TSynapseRec>;
    FBias: Extended;
    FPrevBiasWeight: Extended;
    FBiasWeight: Extended;
  private
    procedure SetBiasWeight(const Value: Extended);
  protected
    function CalcSumOfInputs: Extended; virtual;
    function CalcOutputValue: Extended; override;
    procedure CalculateError; virtual;
    procedure SetErrorValue(AErrorValue: Extended);
    procedure CalculateLocalGradient; virtual;
    function Activation(AValue: Extended): Extended; virtual;
    function ActivationDash(AValue: Extended): Extended; virtual;
  public
    constructor Create(const AId, AIndex: integer);
    destructor Destroy; override;

    procedure ClearSynapses;
    procedure InitSynapses;
    procedure SetSynapseWeight(ASourceNeuron: TNeuron; AWeight: Extended);
    function GetSynapseWeight(ASourceNeuron: TNeuron): Extended;
    procedure AdjustWeights(const ALearningFactor: Extended);

    procedure SaveToJSONObject(AJsonObj: TJSONObject); override;
    procedure LoadData(ADataReader: INeuronDataReader); override;

    property LocalGradient: Extended read FLocalGradient;
    property ErrorValue: Extended read FErrorValue;
    property BiasWeight: Extended read FBiasWeight write SetBiasWeight;
  end;

  TInputNeuron = class(TNeuron)
  strict private
    FInputSample: Extended;
  protected
    function CalcOutputValue: Extended; override;
  public
    procedure SaveToJSONObject(AJsonObj: TJSONObject); override;
    property InputSample: Extended read FInputSample write FInputSample;
  end;

  TOutputNeuron = class(TProcessingNeuron)
  strict private
    FDesiredOutput: Extended;
  protected
    procedure CalculateError; override;
  public
    procedure SaveToJSONObject(AJsonObj: TJSONObject); override;

    property DesiredOutput: Extended read FDesiredOutput write FDesiredOutput;
  end;

  TNeuralLayer = class sealed
  strict private
    FNetwork: TNeuralNetwork;
    FId: integer;
    FNeurons: TList<TNeuron>;
    FPrevious: TNeuralLayer;
    FNext: TNeuralLayer;
    procedure SetId(const Value: integer);
    function GetNeuron(const idx: integer): TNeuron;
    function GetNeuronCount: integer;
    function LoadNeuron(ADataReader: INeuronDataReader): TNeuron;
  private
    function GetNext: TNeuralLayer;
    function GetPrevious: TNeuralLayer;
  public
    constructor Create(const ANetwork: TNeuralNetwork; const AId: integer);
    destructor Destroy; override;

    procedure Clear; virtual;

    function CreateNeuron(const ANewNeuronId: integer): TNeuron;
    procedure AddNeuron(const ANeuron: TNeuron);
    function GetNeuronByName(const AName: string): TNeuron;
    function GetNeuronById(const ANeuronId: integer): TNeuron;

    procedure CalculateErrorValues;
    procedure CalculateLocalGradients;
    procedure AdjustWeights(const ALearningFactor: Extended);

    function GetRandomNeuron: TNeuron;

    procedure SaveDataAsJSON(AJSONObj: TJSONObject);
    procedure LoadData(ADataReader: INeuralLayerDataReader);

    procedure Sample;

    property Id: integer read FId write SetId;
    property Neuron[const idx: integer]: TNeuron read GetNeuron;
    property Previous: TNeuralLayer read GetPrevious;
    property Next: TNeuralLayer read GetNext;
    property NeuronCount: integer read GetNeuronCount;
  end;

  TNeuralNetwork = class sealed
  private
    FNewNeuronId: integer;
    FInputLayer: TNeuralLayer;
    FOutputLayer: TNeuralLayer;
    FProcessingLayers: TList<TNeuralLayer>;
    FLearningFactor: Extended;
    FSumSquaredErrors: Extended;
    FTrackingPerformance: boolean;
    function LayerById(const ALayerId: integer): TNeuralLayer;
    function GetLayerByNum(const ALayerNum: integer): TNeuralLayer;
    function LoadHiddenLayer(ALayerDataReader: INeuralLayerDataReader): TNeuralLayer;
  public
    constructor Create(ANumHiddenLayers: integer);
    destructor Destroy; override;

    procedure Sample;
    procedure BackPropagate;

    procedure StartPerformanceCalculation;
    function EndPerformanceCalculation: Double;
    function CalculatePerformaceValue: Double;

    // Need to look up:
    // "Competitive coevolution through evolutionary complexification"

    function CreateInputNeuron(AName: string = ''): TInputNeuron;
    function CreateOutputNeuron(AName: string = ''): TOutputNeuron;

    function GetInputNeuron(const AName: string): TInputNeuron;
    function GetOutputNeuron(const AName: string): TOutputNeuron;

    function CreateNeuron(const ALayerNum: integer): TNeuron;
    procedure CreateNeurons(const ALayerNum, ANumberOfNeurons: integer; const ANeuronList: TList<TNeuron> = nil);
    procedure SetupRandomSynapses;

    procedure Clear;

    procedure SaveNeuralDataToJSON(AJSONObj: TJSONObject);
    procedure LoadData(ANeuralDataReader: INeuralNetworkDataReader);

    property LearningFactor: Extended read FLearningFactor write FLearningFactor;
    property TrackingPerformance: boolean read FTrackingPerformance;
  end;

implementation

{ TNeuralLayer }

procedure TNeuralLayer.AddNeuron(const ANeuron: TNeuron);
begin
  ANeuron.Layer := self;
  FNeurons.Add(ANeuron);
end;

procedure TNeuralLayer.AdjustWeights(const ALearningFactor: Extended);
var
  N: TNeuron;
begin
  for N in FNeurons do
    TProcessingNeuron(N).AdjustWeights(ALearningFactor);
end;

procedure TNeuralLayer.CalculateErrorValues;
var
  i: integer;
begin
  for i := 0 to FNeurons.Count - 1 do
    TProcessingNeuron(FNeurons[i]).CalculateError;
end;

procedure TNeuralLayer.CalculateLocalGradients;
var
  N: TNeuron;
begin
  for N in FNeurons do
    TProcessingNeuron(N).CalculateLocalGradient;
end;

procedure TNeuralLayer.Clear;
var
  Neuron: TNeuron;
begin
  for Neuron in FNeurons do
    Neuron.Free;
  FNeurons.Clear;
end;

constructor TNeuralLayer.Create(const ANetwork: TNeuralNetwork; const AId: integer);
begin
  inherited Create;

  FId := AId;
  FNetwork := ANetwork;
  FNeurons := TList<TNeuron>.Create;
end;

function TNeuralLayer.CreateNeuron(const ANewNeuronId: integer): TNeuron;
begin
  result := TProcessingNeuron.Create(ANewNeuronId, FNeurons.Count);
  try
    result.Layer := self;
    FNeurons.Add(result);
  except
    result.Free;
    raise;
  end;
end;

destructor TNeuralLayer.Destroy;
begin
  Clear;
  FNeurons.Free;

  inherited;
end;

function TNeuralLayer.GetNeuron(const idx: integer): TNeuron;
begin
  result := FNeurons[idx];
end;

function TNeuralLayer.GetNeuronById(const ANeuronId: integer): TNeuron;
var
  i: integer;
begin
  for i := 0 to FNeurons.Count - 1 do
    if FNeurons[i].Id = ANeuronId then
      exit(FNeurons[i]);
  result := nil;
end;

function TNeuralLayer.GetNeuronByName(const AName: string): TNeuron;
var
  i: integer;
begin
  for i := 0 to FNeurons.Count - 1 do
    if FNeurons[i].Name = AName then
      exit(FNeurons[i]);
  result := nil;
end;

function TNeuralLayer.GetNeuronCount: integer;
begin
  result := FNeurons.Count;
end;

function TNeuralLayer.GetNext: TNeuralLayer;
begin
  if not Assigned(FNext) then
    FNext := FNetwork.GetLayerByNum(FId + 1);
  result := FNext;
end;

function TNeuralLayer.GetPrevious: TNeuralLayer;
begin
  if not Assigned(FPrevious) then
    FPrevious := FNetwork.GetLayerByNum(FId - 1);
  result := FPrevious;
end;

function TNeuralLayer.GetRandomNeuron: TNeuron;
begin
  if FNeurons.Count = 0 then
    exit(nil);

  result := FNeurons[Random(FNeurons.Count)];
end;

procedure TNeuralLayer.LoadData(ADataReader: INeuralLayerDataReader);
var
  i, c: integer;
begin
  Clear;
  FId := ADataReader.GetId;

  i := ADataReader.GetPreviousLayerId;
  if i >= 0 then
    FPrevious := FNetwork.LayerById(i);

  i := ADataReader.GetNextLayerId;
  if i >= 0 then
    FNext := FNetwork.LayerById(i); // Problem: if the layer is not yet loaded at this point (not unlikely), then how will we get a reference?

  c := ADataReader.GetNeuronCount;
  for i := 0 to c - 1 do
    LoadNeuron(ADataReader.GetNeuronReader(i));
end;

function TNeuralLayer.LoadNeuron(ADataReader: INeuronDataReader): TNeuron;
var
  NeuronId: integer;
  N: TNeuron;
  NeuronType: TClass;
begin
  NeuronId := ADataReader.GetId;
  N := GetNeuronById(NeuronId);
  if not Assigned(N) then
  begin
    NeuronType := ADataReader.GetType;

    if NeuronType = TInputNeuron then
      N := TInputNeuron.Create(NeuronId, FNeurons.Count)
    else if NeuronType = TOutputNeuron then
      N := TOutputNeuron.Create(NeuronId, FNeurons.Count)
    else if NeuronType = TProcessingNeuron then
      N := TProcessingNeuron.Create(NeuronId, FNeurons.Count);

    try
      N.Layer := self;
      N.LoadData(ADataReader);
      FNeurons.Add(N);
    except
      N.Free;
      raise;
    end;
  end;
  result := N;
end;

procedure TNeuralLayer.Sample;
var
  Neuron: TNeuron;
begin
  for Neuron in FNeurons do
    Neuron.Sample;
end;

procedure TNeuralLayer.SaveDataAsJSON(AJSONObj: TJSONObject);
var
  JsonNeuronArray: TJSONArray;
  Neuron: TNeuron;
  JsonNeuron: TJsonObject;
begin
  AJSONObj.AddPair('Id', TJSONNumber.Create(FID));
  if Assigned(FPrevious) then
    AJSONObj.AddPair('PreviousLayerId', TJSONNumber.Create(FPrevious.Id));

  if Assigned(FNext) then
    AJSONObj.AddPair('NextLayerId', TJSONNumber.Create(FNext.Id));

  JsonNeuronArray := TJSONArray.Create;
  try
    for Neuron in FNeurons do
    begin
      JsonNeuron := TJsonObject.Create;
      try
        Neuron.SaveToJSONObject(JsonNeuron);
        JsonNeuronArray.AddElement(JsonNeuron);
      except
        JsonNeuron.Free;
        raise;
      end;
    end;

    AJSONObj.AddPair('Neurons', JsonNeuronArray);
  except
    JsonNeuronArray.Free;
    raise;
  end;
end;

procedure TNeuralLayer.SetId(const Value: integer);
begin
  FId := Value;
end;

{ TNeuron }

constructor TNeuron.Create(const AId, AIndex: integer);
begin
  inherited Create;
  FId := AId;
  FIndex := AIndex;
end;

destructor TNeuron.Destroy;
begin
  FId := -1;
  FLayer := nil;
  FIndex := -1;

  inherited;
end;

procedure TNeuron.LoadData(ADataReader: INeuronDataReader);
begin
  FId := ADataReader.GetId;
  FName := ADataReader.GetName;
end;

procedure TNeuron.Sample;
begin
  FOutputValue := CalcOutputValue;
end;

procedure TNeuron.SetLayer(const Value: TNeuralLayer);
begin
  FLayer := Value;
end;

{ TProcessingNeuron }

procedure TProcessingNeuron.CalculateError;
var
  NextLayer: TNeuralLayer;
  i: integer;
  N: TProcessingNeuron;
  E: Extended;
begin
  NextLayer := Layer.Next;
  E := 0;
  for i := 0 to NextLayer.NeuronCount - 1 do
  begin
    N := TProcessingNeuron(NextLayer.Neuron[i]);
    E := E + N.LocalGradient * N.GetSynapseWeight(self);
  end;
  FErrorValue := E;
end;

procedure TProcessingNeuron.CalculateLocalGradient;
begin
  FLocalGradient := ActivationDash(FInputValue) * FErrorValue;
end;

procedure TProcessingNeuron.ClearSynapses;
var
  i: integer;
begin
  for i := 0 to Length(FSynapses) - 1 do
  begin
    FSynapses[i].Neuron := nil;
    FSynapses[i].Weight := 0;
  end;

  SetLength(FSynapses, 0);
end;

constructor TProcessingNeuron.Create(const AId, AIndex: integer);
begin
  inherited Create(AId, AIndex);

  FBias := -1;
  FActivationRate := -1;
end;

destructor TProcessingNeuron.Destroy;
begin
  ClearSynapses;
  FPrevBiasWeight := 0;
  FBiasWeight := 0;
  inherited;
end;

function TProcessingNeuron.GetSynapseWeight(ASourceNeuron: TNeuron): Extended;
begin
  result := FSynapses[ASourceNeuron.Index].Weight;
end;

procedure TProcessingNeuron.InitSynapses;
var
  i: integer;
  PrevLayer: TNeuralLayer;
begin
  PrevLayer := Layer.Previous;
  SetLength(FSynapses, PrevLayer.NeuronCount);
  for i := 0 to PrevLayer.NeuronCount -1 do
  begin
    FSynapses[i].Weight := 0;
    FSynapses[i].Neuron := PrevLayer.Neuron[i];
  end;
end;

procedure TProcessingNeuron.LoadData(ADataReader: INeuronDataReader);
var
  i, c: integer;
  NeuronId: integer;
  weight: Extended;
begin
  inherited;

  FBiasWeight := ADataReader.GetBiasWeight;

  c := ADataReader.GetSynapseCount;
  SetLength(FSynapses, c);

  for i := 0 to c - 1 do
  begin
    ADataReader.GetSynapse(i, NeuronId, weight);
    FSynapses[i].Neuron := Layer.Previous.GetNeuronById(NeuronId);
    FSynapses[i].Weight := weight;
  end;
end;

function TProcessingNeuron.Activation(AValue: Extended): Extended;
begin
  if FActivationRate * AValue < -500 then
    result := 1
  else if FActivationRate * AValue > 500 then
    result := 0
  else
    result := 1 / (1 + exp(FActivationRate * AValue));
end;

function TProcessingNeuron.ActivationDash(AValue: Extended): Extended;
var
  Phi: Extended;
begin
  //Phi := Activation(AValue);
  Phi := OutputValue;
  result := Phi * (1 - Phi);
end;

procedure TProcessingNeuron.AdjustWeights(const ALearningFactor: Extended);
var
  i: integer;
  DeltaW: Extended;
begin
  for i := 0 to Length(FSynapses) - 1 do
  begin
    DeltaW := -1 * ALearningFactor * FLocalGradient * FSynapses[i].Neuron.OutputValue;
    FSynapses[i].Weight := FSynapses[i].Weight + DeltaW;
  end;

  //CurBias := FBiasWeight;
  //FBiasWeight := FBiasWeight + AMobilityFactor * FPrevBiasWeight + ALearningFactor * FLocalGradient * 1; // 1 being the bias value, but I figured I don't need to create a whole neuron and synapse for it..
  FBiasWeight := FBiasWeight + ALearningFactor * FLocalGradient;
  //FPrevBiasWeight := CurBias;
end;

function TProcessingNeuron.CalcOutputValue: Extended;
begin
  FInputValue := CalcSumOfInputs;
  result := Activation(FInputValue);
end;

function TProcessingNeuron.CalcSumOfInputs: Extended;
var
  i: integer;
begin
  result := -1 * FBiasWeight;
  for i := 0 to Length(FSynapses) - 1 do
    result := result + FSynapses[i].Neuron.OutputValue * FSynapses[i].Weight;
end;

procedure TProcessingNeuron.SaveToJSONObject(AJsonObj: TJSONObject);
var
  JsonSynapseArray: TJSONArray;
  synapse: TSynapseRec;
  JsonSynapse: TJSONObject;
begin
  if ClassType = TProcessingNeuron then
    AJsonObj.AddPair('Type', 'Processing');
  AJsonObj.AddPair('Id', TJsonNumber.Create(ID));
  AJsonObj.AddPair('Name', Name);
  AJsonObj.AddPair('Index', TJsonNumber.Create(Index));

  AJsonObj.AddPair('BiasWeight', TJSONString.Create(FloatToStr(FBiasWeight, GetJSONFormat)));
  JsonSynapseArray := TJSONArray.Create;
  try
    for Synapse in FSynapses do
    begin
      JsonSynapse := TJsonObject.Create;
      try
        JsonSynapse.AddPair('NeuronId', TJSONNumber.Create(Synapse.Neuron.ID));
        JsonSynapse.AddPair('Weight', TJSONString.Create(FloatToStr(Synapse.Weight, GetJSONFormat)));
        JsonSynapseArray.AddElement(JSonSynapse);
      except
        JsonSynapse.Free;
        raise;
      end;
    end;
    AJsonObj.AddPair('Synapses', JsonSynapseArray);
  except
    JsonSynapseArray.Free;
    raise;
  end;
end;

procedure TProcessingNeuron.SetBiasWeight(const Value: Extended);
begin
  FBiasWeight := Value;
  FPrevBiasWeight := Value;
end;

procedure TProcessingNeuron.SetErrorValue(AErrorValue: Extended);
begin
  FErrorValue := AErrorValue;
end;

procedure TProcessingNeuron.SetSynapseWeight(ASourceNeuron: TNeuron; AWeight: Extended);
begin
  FSynapses[ASourceNeuron.Index].Weight := AWeight;
end;

{ TNeuralNetwork }

procedure TNeuralNetwork.BackPropagate;
var
  L: integer;
  Layer: TNeuralLayer;
  i: integer;
begin
  FOutputLayer.CalculateErrorValues;

  if FTrackingPerformance then
    for i := 0 to FOutputLayer.NeuronCount - 1 do
      FSumSquaredErrors := FSumSquaredErrors + Power(TOutputNeuron(FOutputLayer.Neuron[i]).ErrorValue, 2);

  FOutputLayer.CalculateLocalGradients;
  for L := FProcessingLayers.Count -1 downto 0 do
  begin
    Layer := FProcessingLayers[L];
    Layer.CalculateErrorValues;
    Layer.CalculateLocalGradients;
  end;

  FOutputLayer.AdjustWeights(FLearningFactor);
  for L := FProcessingLayers.Count -1 downto 0 do
  begin
    Layer := FProcessingLayers[L];
    Layer.AdjustWeights(FLearningFactor);
  end;
end;

function TNeuralNetwork.CalculatePerformaceValue: Double;
var
  N: TOutputNeuron;
  i: integer;
  SumSquaredErrors: double;
begin
  SumSquaredErrors := 0;
  for i := 0 to FOutputLayer.NeuronCount - 1 do
  begin
    N := FOutputLayer.Neuron[i] as TOutputNeuron;
    SumSquaredErrors := SumSquaredErrors + Power(N.ErrorValue, 2);
  end;
  result := SumSquaredErrors / -2;
end;

procedure TNeuralNetwork.Clear;
var
  i: integer;
begin
  FOutputLayer.Clear;

  for i := FProcessingLayers.Count - 1 to 0 do
    FProcessingLayers[i].Free;
  FProcessingLayers.Clear;

  FInputLayer.Clear;
end;

constructor TNeuralNetwork.Create(ANumHiddenLayers: integer);
var
  i: integer;
begin
  inherited Create;

  FNewNeuronId := 1;
  FTrackingPerformance := false;

  FInputLayer := TNeuralLayer.Create(self, 0);

  FProcessingLayers := TList<TNeuralLayer>.Create;
  for i := 1 to ANumHiddenLayers do
    FProcessingLayers.Add(TNeuralLayer.Create(self, i));

  FOutputLayer := TNeuralLayer.Create(self, 3);
end;

function TNeuralNetwork.CreateInputNeuron(AName: string = ''): TInputNeuron;
begin
  result := TInputNeuron.Create(FNewNeuronId, FInputLayer.NeuronCount);
  try
    result.Name := AName;
    FInputLayer.AddNeuron(result);
  except
    result.Free;
    raise;
  end;
  inc(FNewNeuronId);
end;

function TNeuralNetwork.CreateNeuron(const ALayerNum: integer): TNeuron;
var
  Layer: TNeuralLayer;
begin
  Layer := LayerById(ALayerNum);
  result := Layer.CreateNeuron(FNewNeuronId);
  inc(FNewNeuronId);
end;

procedure TNeuralNetwork.CreateNeurons(const ALayerNum, ANumberOfNeurons: integer; const ANeuronList: TList<TNeuron>);
var
  Layer: TNeuralLayer;
  i: integer;
  N: TNeuron;
begin
  Layer := LayerById(ALayerNum);
  for i := 0 to ANumberOfNeurons - 1 do
  begin
    N := Layer.CreateNeuron(FNewNeuronId);
    if Assigned(ANeuronList) then
      ANeuronList.Add(N);
    inc(FNewNeuronId);
  end;
end;

function TNeuralNetwork.CreateOutputNeuron(AName: string = ''): TOutputNeuron;
begin
  result := TOutputNeuron.Create(FNewNeuronId, FOutputLayer.NeuronCount);
  try
    result.Name := AName;
    FOutputLayer.AddNeuron(result);
  except
    result.Free;
    raise;
  end;
  inc(FNewNeuronId);
end;

destructor TNeuralNetwork.Destroy;
begin
  Clear;

  FOutputLayer.Free;

  FProcessingLayers.Free;

  FInputLayer.Free;

  inherited;
end;

function TNeuralNetwork.EndPerformanceCalculation: Double;
begin
  FTrackingPerformance := false;
  result := FSumSquaredErrors / -2;
end;

function TNeuralNetwork.GetInputNeuron(const AName: string): TInputNeuron;
begin
  result := FInputLayer.GetNeuronByName(AName) as TInputNeuron;
end;

function TNeuralNetwork.GetLayerByNum(const ALayerNum: integer): TNeuralLayer;
var
  LayerIdx: integer;
begin
  LayerIdx := ALayerNum - 1;

  if LayerIdx = -1 then
    result := FInputLayer
  else if LayerIdx = FProcessingLayers.Count then
    result := FOutputLayer
  else if (LayerIdx >= 0) and (LayerIdx < FProcessingLayers.Count) then
    result := FProcessingLayers[LayerIdx]
  else
    result := nil;
end;

function TNeuralNetwork.GetOutputNeuron(const AName: string): TOutputNeuron;
begin
  result := FOutputLayer.GetNeuronByName(AName) as TOutputNeuron;
end;

procedure TNeuralNetwork.SaveNeuralDataToJSON(AJSONObj: TJSONObject);
var
  il: TJSONObject;
  ol: TJSONObject;
  layers: TJSONArray;
  neurallayer: TNeuralLayer;
  jsonlayer: TJSONObject;
begin
  AJSONObj.AddPair('LearningRate', TJSONString.Create(FloatToStr(FLearningFactor, GetJSONFormat)));

  il := TJSONObject.Create;
  try
    FInputLayer.SaveDataAsJSON(il);
    AJSONObj.AddPair('InputLayer', il);
  except
    il.Free;
    raise;
  end;

  layers := TJSONArray.Create();
  try
    for neurallayer in FProcessingLayers do
    begin
      jsonlayer := TJSONObject.Create;
      try
        neurallayer.SaveDataAsJSON(jsonlayer);
        layers.AddElement(jsonlayer);
      except
        jsonlayer.free;
        raise;
      end;
    end;

    AJSONObj.AddPair('HiddenLayers', layers);
  except
    layers.Free;
    raise;
  end;

  ol := TJSONObject.Create;
  try
    FOutputLayer.SaveDataAsJSON(ol);
    AJSONObj.AddPair('OutputLayer', ol);
  except
    il.Free;
    raise;
  end;
end;

function TNeuralNetwork.LayerById(const ALayerId: integer): TNeuralLayer;
var
  Layer: TNeuralLayer;
begin
  for Layer in FProcessingLayers do
    if Layer.Id = ALayerId then
      exit(Layer);

  result := nil;
end;

procedure TNeuralNetwork.LoadData(ANeuralDataReader: INeuralNetworkDataReader);
var
  i: integer;
  c: integer;
begin
  Clear;

  FLearningFactor := ANeuralDataReader.GetLearningRate;

  FInputLayer.LoadData(ANeuralDataReader.GetInputLayerDataReader);

  c := ANeuralDataReader.GetHiddenLayerCount;
  for i := 0 to c - 1 do
    LoadHiddenLayer(ANeuralDataReader.GetHiddenLayerDataReader(i));

  FOutputLayer.LoadData(ANeuralDataReader.GetOutputLayerDataReader);
end;

function TNeuralNetwork.LoadHiddenLayer(ALayerDataReader: INeuralLayerDataReader): TNeuralLayer;
var
  LayerId: integer;
  Layer: TNeuralLayer;
begin
  LayerId := ALayerDataReader.GetId;
  Layer := LayerById(LayerId);

  if not Assigned(Layer) then
  begin
    Layer := TNeuralLayer.Create(self, LayerId);
    try
      Layer.LoadData(ALayerDataReader);
      FProcessingLayers.Add(Layer);
    except
      Layer.Free;
      raise;
    end;
  end
  else
    Layer.LoadData(ALayerDataReader);

  result := Layer;
end;

procedure TNeuralNetwork.Sample;
var
  Layer: TNeuralLayer;
begin
  FInputLayer.Sample;

  for Layer in FProcessingLayers do
    Layer.Sample;

  FOutputLayer.Sample;
end;

procedure TNeuralNetwork.SetupRandomSynapses;
var
  LayerIdx: integer;
  SourceLayer, TargetLayer: TNeuralLayer;
  SourceNeuron, TargetNeuron: TProcessingNeuron;
  SrcIdx, TgtIdx: integer;
begin
  for LayerIdx := 1 to FProcessingLayers.Count + 1 do
  begin
    TargetLayer := GetLayerByNum(LayerIdx);
    SourceLayer := TargetLayer.Previous;

    for TgtIdx := 0 to TargetLayer.NeuronCount - 1 do
    begin
      TargetNeuron := TProcessingNeuron(TargetLayer.Neuron[TgtIdx]);
      TargetNeuron.ClearSynapses;
      TargetNeuron.InitSynapses;

      TargetNeuron.BiasWeight := (Random(100000) / 50000) - 1;

      for SrcIdx := 0 to SourceLayer.NeuronCount - 1 do
      begin
        SourceNeuron := TProcessingNeuron(SourceLayer.Neuron[SrcIdx]);

        TargetNeuron.SetSynapseWeight(SourceNeuron, (Random(100000) / 50000) - 1);
      end;
    end;
  end;
end;

procedure TNeuralNetwork.StartPerformanceCalculation;
begin
  FTrackingPerformance := true;
  FSumSquaredErrors := 0;
end;

{ TOutputNeuron }

procedure TOutputNeuron.CalculateError;
begin
  SetErrorValue(OutputValue - FDesiredOutput);
end;

procedure TOutputNeuron.SaveToJSONObject(AJsonObj: TJSONObject);
begin
  AJsonObj.AddPair('Type', 'Output');
  inherited;
end;

{ TInputNeuron }

function TInputNeuron.CalcOutputValue: Extended;
begin
  result := FInputSample;
end;

procedure TInputNeuron.SaveToJSONObject(AJsonObj: TJSONObject);
begin
  AJsonObj.AddPair('Type', 'Input');
  AJsonObj.AddPair('Id', TJsonNumber.Create(ID));
  AJsonObj.AddPair('Name', Name);
  AJsonObj.AddPair('Index', TJsonNumber.Create(Index));
end;

end.
