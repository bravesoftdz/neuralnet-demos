unit NeuralJSON;

interface

uses
  System.SysUtils, System.JSON, Neural;

type
  TJsonNeuralNetworkDataReader = class(TInterfacedObject, INeuralNetworkDataReader)
  private
    FNeuralDataJsonObject: TJSONObject;
    FInputLayerDataReader: INeuralLayerDataReader;
    FOutputLayerDataReader: INeuralLayerDataReader;
    FHiddenLayersJSONArray: TJSONArray;
    function GetHiddenLayersJsonArray: TJSONArray;
  protected
    { INeuralNetworkDataReader }
    function GetLearningRate: Extended;

    function GetInputLayerDataReader: INeuralLayerDataReader;
    function GetOutputLayerDataReader: INeuralLayerDataReader;

    function GetHiddenLayerCount: integer;
    function GetHiddenLayerDataReader(Index: integer): INeuralLayerDataReader;
  public
    constructor Create(AJsonObj: TJSONObject);
  end;

  TJsonNeuralLayerDataReader = class(TInterfacedObject, INeuralLayerDataReader)
  private
    FNeuralLayerJsonObject: TJSONObject;
    FNeuronsJsonArray: TJSONArray;
    function GetNeuronsJsonArray: TJSONArray;
  protected
    { INeuralLayerDataReader }
    function GetId: integer;
    function GetPreviousLayerId: integer;
    function GetNextLayerId: integer;
    function GetNeuronCount: integer;
    function GetNeuronReader(Index: integer): INeuronDataReader;
  public
    constructor Create(AJsonObj: TJSONObject);
  end;

  TJsonNeuronDataReader = class(TInterfacedObject, INeuronDataReader)
  private
    FNeuronJsonObject: TJSONObject;
    FSynapseArray: TJSONArray;
    function SynapseArray: TJSONArray;
  protected
    { INeuronDataReader }
    function GetId: integer;
    function GetType: TClass;
    function GetName: string;
    function GetBiasWeight: Extended;

    function GetSynapseCount: integer;
    procedure GetSynapse(Index: integer; out SourceNeuronId: integer; out SynapseWeight: extended);
  public
    constructor Create(AJSONObj: TJSONObject);
  end;

implementation

{ TJsonNeuralNetworkDataReader }

constructor TJsonNeuralNetworkDataReader.Create(AJsonObj: TJSONObject);
begin
  inherited Create;
  FNeuralDataJsonObject := AJsonObj;
end;

function TJsonNeuralNetworkDataReader.GetHiddenLayerCount: integer;
begin
  result := GetHiddenLayersJsonArray().Count;
end;

function TJsonNeuralNetworkDataReader.GetHiddenLayerDataReader(Index: integer): INeuralLayerDataReader;
begin
  result := TJsonNeuralLayerDataReader.Create(GetHiddenLayersJsonArray().Items[Index] as TJSONObject);
end;

function TJsonNeuralNetworkDataReader.GetHiddenLayersJsonArray: TJSONArray;
begin
  if not assigned(FHiddenLayersJSONArray) then
    FHiddenLayersJSONArray := FNeuralDataJsonObject.GetValue('HiddenLayers') as TJSONArray;
  result := FHiddenLayersJSONArray;
end;

function TJsonNeuralNetworkDataReader.GetInputLayerDataReader: INeuralLayerDataReader;
begin
  if not Assigned(FInputLayerDataReader) then
    FInputLayerDataReader := TJsonNeuralLayerDataReader.Create(FNeuralDataJsonObject.GetValue('InputLayer') as TJSONObject);

  result := FInputLayerDataReader;
end;

function TJsonNeuralNetworkDataReader.GetLearningRate: Extended;
begin
  result := StrToFloat(FNeuralDataJsonObject.GetValue('LearningRate').Value, GetJSONFormat);
end;

function TJsonNeuralNetworkDataReader.GetOutputLayerDataReader: INeuralLayerDataReader;
begin
  if not Assigned(FOutputLayerDataReader) then
    FOutputLayerDataReader := TJsonNeuralLayerDataReader.Create(FNeuralDataJsonObject.GetValue('OutputLayer') as TJSONObject);
  result := FOutputLayerDataReader;
end;

{ TJsonNeuralLayerDataReader }

constructor TJsonNeuralLayerDataReader.Create(AJsonObj: TJSONObject);
begin
  inherited Create;
  FNeuralLayerJsonObject := AJsonObj;
end;

function TJsonNeuralLayerDataReader.GetId: integer;
begin
  result := (FNeuralLayerJsonObject.GetValue('Id') as TJSONNumber).AsInt;
end;

function TJsonNeuralLayerDataReader.GetNeuronCount: integer;
begin
  result := GetNeuronsJsonArray().Count;
end;

function TJsonNeuralLayerDataReader.GetNeuronReader(Index: integer): INeuronDataReader;
begin
  result := TJsonNeuronDataReader.Create(GetNeuronsJsonArray().Items[Index] as TJSONObject);
end;

function TJsonNeuralLayerDataReader.GetNeuronsJsonArray: TJSONArray;
begin
  if not Assigned(FNeuronsJsonArray) then
    FNeuronsJsonArray := FNeuralLayerJsonObject.GetValue('Neurons') as TJSONArray;
  result := FNeuronsJsonArray;
end;

function TJsonNeuralLayerDataReader.GetNextLayerId: integer;
var
  Value: TJSONValue;
begin
  Value := FNeuralLayerJsonObject.GetValue('NextLayerId');
  if Assigned(Value) then
    result := (Value as TJSONNumber).AsInt
  else
    result := -1;
end;

function TJsonNeuralLayerDataReader.GetPreviousLayerId: integer;
var
  Value: TJSONValue;
begin
  Value := FNeuralLayerJsonObject.GetValue('PreviousLayerId');
  if Assigned(Value) then
    result := (Value as TJSONNumber).AsInt
  else
    result := -1;
end;

{ TJsonNeuronDataReader }

constructor TJsonNeuronDataReader.Create(AJSONObj: TJSONObject);
begin
  inherited Create;
  FNeuronJsonObject := AJSONObj;
end;

function TJsonNeuronDataReader.GetBiasWeight: Extended;
var
  v: string;
begin
  v := FNeuronJsonObject.GetValue('BiasWeight').Value;
  result := StrToFloat(v, GetJSONFormat);
end;

function TJsonNeuronDataReader.GetId: integer;
begin
  result := (FNeuronJsonObject.GetValue('Id') as TJSONNumber).AsInt;
end;

function TJsonNeuronDataReader.GetName: string;
var
  v: TJSONValue;
begin
  v := FNeuronJsonObject.GetValue('Name');
  if Assigned(v) then
    result := v.Value
  else
    result := '';
end;

procedure TJsonNeuronDataReader.GetSynapse(Index: integer; out SourceNeuronId: integer; out SynapseWeight: extended);
var
  Syn: TJSONObject;
  v: string;
begin
  Syn := SynapseArray().Items[Index] as TJSONObject;
  SourceNeuronId := (Syn.GetValue('NeuronId') as TJSONNumber).AsInt;
  v := Syn.GetValue('Weight').Value;
  SynapseWeight := StrToFloat(v, GetJSONFormat);
end;

function TJsonNeuronDataReader.GetSynapseCount: integer;
begin
  result := SynapseArray().count;
end;

function TJsonNeuronDataReader.GetType: TClass;
var
  typ: string;
begin
  typ := FNeuronJsonObject.GetValue('Type').Value;
  if typ = 'Input' then
    result := TInputNeuron
  else if typ = 'Output' then
    result := TOutputNeuron
  else if typ = 'Processing' then
    result := TProcessingNeuron
  else
    result := nil;
end;

function TJsonNeuronDataReader.SynapseArray: TJSONArray;
begin
  if not Assigned(FSynapseArray) then
    FSynapseArray := FNeuronJsonObject.GetValue('Synapses') as TJSONArray;
  result := FSynapseArray;
end;

end.
