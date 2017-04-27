object MainWindow: TMainWindow
  Left = 0
  Top = 0
  Caption = 'Curve fitting'
  ClientHeight = 543
  ClientWidth = 668
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -10
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 12
  object imgGraph: TImage
    Left = 103
    Top = 344
    Width = 556
    Height = 171
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
  end
  object Label7: TLabel
    Left = 36
    Top = 274
    Width = 59
    Height = 12
    Caption = 'Learning rate'
  end
  object Label8: TLabel
    Left = 349
    Top = 520
    Width = 80
    Height = 19
    Caption = 'Input value'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object Label9: TLabel
    Left = 101
    Top = 520
    Width = 9
    Height = 19
    Caption = '0'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object Label10: TLabel
    Left = 653
    Top = 520
    Width = 9
    Height = 19
    Caption = '1'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object Label11: TLabel
    Left = 3
    Top = 416
    Width = 91
    Height = 19
    Caption = 'Output value'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object Label12: TLabel
    Left = 85
    Top = 503
    Width = 9
    Height = 19
    Caption = '0'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object Label13: TLabel
    Left = 85
    Top = 336
    Width = 9
    Height = 19
    Caption = '1'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object lblPerf: TLabel
    Left = 36
    Top = 303
    Width = 24
    Height = 12
    Caption = 'P = ?'
  end
  object chkSample1: TCheckBox
    Left = 200
    Top = 19
    Width = 26
    Height = 17
    Checked = True
    State = cbChecked
    TabOrder = 7
    OnClick = SampleCheckboxClick
  end
  object btnSetupSynapses: TButton
    Left = 36
    Top = 18
    Width = 117
    Height = 19
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = 'Randomize Synapses'
    TabOrder = 0
    OnClick = btnSetupSynapsesClick
  end
  object btnSample: TButton
    Left = 36
    Top = 41
    Width = 56
    Height = 19
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = 'Sample'
    TabOrder = 1
    OnClick = btnSampleClick
  end
  object btnBackpropagate: TButton
    Left = 36
    Top = 65
    Width = 103
    Height = 18
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = 'Back Propagate'
    TabOrder = 2
    OnClick = btnBackpropagateClick
  end
  object btnHundredRuns: TButton
    Left = 36
    Top = 138
    Width = 145
    Height = 19
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = '100 x Sample && Backpropagate'
    TabOrder = 3
    OnClick = btnHundredRunsClick
  end
  object btnThousandRuns: TButton
    Left = 36
    Top = 161
    Width = 145
    Height = 19
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = '1000 x Sample && Backpropagate'
    TabOrder = 4
    OnClick = btnThousandRunsClick
  end
  object CheckSine: TCheckBox
    Left = 36
    Top = 215
    Width = 45
    Height = 17
    Caption = 'Sine'
    TabOrder = 5
    OnClick = CheckSineClick
  end
  object EditLearningRate: TEdit
    Left = 36
    Top = 248
    Width = 85
    Height = 20
    TabOrder = 6
    Text = '0.5'
    OnChange = EditLearningRateChange
  end
  object chkSample2: TCheckBox
    Left = 200
    Top = 74
    Width = 26
    Height = 17
    TabOrder = 8
    OnClick = SampleCheckboxClick
  end
  object chkSample3: TCheckBox
    Left = 200
    Top = 129
    Width = 26
    Height = 17
    TabOrder = 9
    OnClick = SampleCheckboxClick
  end
  object chkSample4: TCheckBox
    Left = 200
    Top = 184
    Width = 26
    Height = 17
    TabOrder = 10
    OnClick = SampleCheckboxClick
  end
  object chkSample5: TCheckBox
    Left = 200
    Top = 239
    Width = 26
    Height = 17
    TabOrder = 11
    OnClick = SampleCheckboxClick
  end
  object chkSample6: TCheckBox
    Left = 200
    Top = 295
    Width = 26
    Height = 17
    TabOrder = 12
    OnClick = SampleCheckboxClick
  end
  object pnlSample1: TPanel
    Left = 232
    Top = 8
    Width = 281
    Height = 49
    BevelInner = bvRaised
    BevelOuter = bvLowered
    ShowCaption = False
    TabOrder = 13
    object lblActual1: TLabel
      Left = 152
      Top = 31
      Width = 93
      Height = 12
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = 'Desired output value'
    end
    object Label2: TLabel
      Left = 112
      Top = 12
      Width = 21
      Height = 12
      Caption = '==>'
    end
    object EditInput1: TEdit
      Left = 8
      Top = 9
      Width = 81
      Height = 20
      TabOrder = 0
      Text = '0.0'
      OnChange = EditInput1Change
    end
    object EditOutput1: TEdit
      Left = 152
      Top = 9
      Width = 121
      Height = 20
      TabOrder = 1
      Text = '1'
      OnChange = EditOutput1Change
    end
  end
  object pnlSample2: TPanel
    Left = 232
    Top = 63
    Width = 281
    Height = 49
    BevelInner = bvRaised
    BevelOuter = bvLowered
    Enabled = False
    ShowCaption = False
    TabOrder = 14
    object lblActual2: TLabel
      Left = 152
      Top = 31
      Width = 93
      Height = 12
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = 'Desired output value'
      Enabled = False
    end
    object Label3: TLabel
      Left = 112
      Top = 12
      Width = 21
      Height = 12
      Caption = '==>'
      Enabled = False
    end
    object EditInput2: TEdit
      Left = 8
      Top = 9
      Width = 81
      Height = 20
      Enabled = False
      TabOrder = 0
      Text = '0.3'
      OnChange = EditInput2Change
    end
    object EditOutput2: TEdit
      Left = 152
      Top = 9
      Width = 121
      Height = 20
      Enabled = False
      TabOrder = 1
      Text = '0'
      OnChange = EditOutput2Change
    end
  end
  object pnlSample3: TPanel
    Left = 232
    Top = 118
    Width = 281
    Height = 49
    BevelInner = bvRaised
    BevelOuter = bvLowered
    Enabled = False
    ShowCaption = False
    TabOrder = 15
    object lblActual3: TLabel
      Left = 152
      Top = 31
      Width = 93
      Height = 12
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = 'Desired output value'
      Enabled = False
    end
    object Label4: TLabel
      Left = 112
      Top = 12
      Width = 21
      Height = 12
      Caption = '==>'
      Enabled = False
    end
    object EditInput3: TEdit
      Left = 8
      Top = 9
      Width = 81
      Height = 20
      Enabled = False
      TabOrder = 0
      Text = '0.5'
      OnChange = EditInput3Change
    end
    object EditOutput3: TEdit
      Left = 152
      Top = 9
      Width = 121
      Height = 20
      Enabled = False
      TabOrder = 1
      Text = '1'
      OnChange = EditOutput3Change
    end
  end
  object pnlSample4: TPanel
    Left = 232
    Top = 173
    Width = 281
    Height = 49
    BevelInner = bvRaised
    BevelOuter = bvLowered
    Enabled = False
    ShowCaption = False
    TabOrder = 16
    object Label5: TLabel
      Left = 112
      Top = 12
      Width = 21
      Height = 12
      Caption = '==>'
      Enabled = False
    end
    object lblActual4: TLabel
      Left = 152
      Top = 31
      Width = 93
      Height = 12
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = 'Desired output value'
      Enabled = False
    end
    object EditInput4: TEdit
      Left = 8
      Top = 9
      Width = 81
      Height = 20
      Enabled = False
      TabOrder = 0
      Text = '0.7'
      OnChange = EditInput4Change
    end
    object EditOutput4: TEdit
      Left = 152
      Top = 9
      Width = 121
      Height = 20
      Enabled = False
      TabOrder = 1
      Text = '0'
      OnChange = EditOutput4Change
    end
  end
  object pnlSample5: TPanel
    Left = 232
    Top = 228
    Width = 281
    Height = 50
    BevelInner = bvRaised
    BevelOuter = bvLowered
    Enabled = False
    ShowCaption = False
    TabOrder = 17
    object Label1: TLabel
      Left = 112
      Top = 12
      Width = 21
      Height = 12
      Caption = '==>'
      Enabled = False
    end
    object lblActual5: TLabel
      Left = 152
      Top = 31
      Width = 93
      Height = 12
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = 'Desired output value'
      Enabled = False
    end
    object EditInput5: TEdit
      Left = 8
      Top = 9
      Width = 81
      Height = 20
      Enabled = False
      TabOrder = 0
      Text = '0.85'
      OnChange = EditInput5Change
    end
    object EditOutput5: TEdit
      Left = 152
      Top = 9
      Width = 121
      Height = 20
      Enabled = False
      TabOrder = 1
      Text = '0'
      OnChange = EditOutput5Change
    end
  end
  object pnlSample6: TPanel
    Left = 232
    Top = 284
    Width = 281
    Height = 50
    BevelInner = bvRaised
    BevelOuter = bvLowered
    Enabled = False
    ShowCaption = False
    TabOrder = 18
    object Label6: TLabel
      Left = 112
      Top = 12
      Width = 21
      Height = 12
      Caption = '==>'
      Enabled = False
    end
    object lblActual6: TLabel
      Left = 152
      Top = 31
      Width = 93
      Height = 12
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = 'Desired output value'
      Enabled = False
    end
    object EditInput6: TEdit
      Left = 8
      Top = 9
      Width = 81
      Height = 20
      Enabled = False
      TabOrder = 0
      Text = '1.0'
      OnChange = EditInput6Change
    end
    object EditOutput6: TEdit
      Left = 152
      Top = 9
      Width = 121
      Height = 20
      Enabled = False
      TabOrder = 1
      Text = '1'
      OnChange = EditOutput6Change
    end
  end
end
