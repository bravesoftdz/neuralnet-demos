object MainWindow: TMainWindow
  Left = 0
  Top = 0
  Caption = 'NeuralTest02'
  ClientHeight = 397
  ClientWidth = 500
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
  object lblInput1: TLabel
    Left = 163
    Top = 44
    Width = 56
    Height = 12
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = 'Picture nr: 1'
  end
  object imgRef1: TImage
    Left = 175
    Top = 115
    Width = 75
    Height = 114
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
  end
  object Label1: TLabel
    Left = 175
    Top = 98
    Width = 39
    Height = 12
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = 'Picture 1'
  end
  object lblNum1: TLabel
    Left = 278
    Top = 269
    Width = 48
    Height = 12
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = 'Number 1:'
  end
  object lblNum2: TLabel
    Left = 278
    Top = 293
    Width = 48
    Height = 12
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = 'Number 2:'
  end
  object lblNum3: TLabel
    Left = 278
    Top = 317
    Width = 48
    Height = 12
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = 'Number 3:'
  end
  object lblNum4: TLabel
    Left = 278
    Top = 341
    Width = 48
    Height = 12
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = 'Number 4:'
  end
  object imgTest: TImage
    Left = 175
    Top = 267
    Width = 75
    Height = 114
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
  end
  object Label2: TLabel
    Left = 175
    Top = 250
    Width = 52
    Height = 12
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = 'Test Picture'
  end
  object imgRef2: TImage
    Left = 255
    Top = 115
    Width = 75
    Height = 114
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
  end
  object imgRef3: TImage
    Left = 335
    Top = 115
    Width = 75
    Height = 114
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
  end
  object imgRef4: TImage
    Left = 415
    Top = 115
    Width = 75
    Height = 114
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
  end
  object Label3: TLabel
    Left = 255
    Top = 98
    Width = 39
    Height = 12
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = 'Picture 2'
  end
  object Label4: TLabel
    Left = 335
    Top = 98
    Width = 39
    Height = 12
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = 'Picture 3'
  end
  object Label5: TLabel
    Left = 415
    Top = 98
    Width = 39
    Height = 12
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = 'Picture 4'
  end
  object lblPerf: TLabel
    Left = 278
    Top = 369
    Width = 24
    Height = 12
    Caption = 'P = ?'
  end
  object btnSetupSynapses: TButton
    Left = 7
    Top = 42
    Width = 103
    Height = 19
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = 'Setup Synapses'
    TabOrder = 0
    OnClick = btnSetupSynapsesClick
  end
  object btnSample: TButton
    Left = 7
    Top = 65
    Width = 56
    Height = 19
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = 'Train'
    TabOrder = 1
    OnClick = btnSampleClick
  end
  object tbrInput1: TTrackBar
    Left = 163
    Top = 6
    Width = 187
    Height = 34
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Max = 3
    TabOrder = 2
    OnChange = tbrInput1Change
  end
  object btnHundredRuns: TButton
    Left = 7
    Top = 138
    Width = 145
    Height = 19
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = '100 x Training'
    TabOrder = 3
    OnClick = btnHundredRunsClick
  end
  object btnThousandRuns: TButton
    Left = 7
    Top = 161
    Width = 145
    Height = 19
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = '1000 x Training'
    TabOrder = 4
    OnClick = btnThousandRunsClick
  end
  object btnTenRuns: TButton
    Left = 7
    Top = 115
    Width = 145
    Height = 19
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = '10 x Training'
    TabOrder = 5
    OnClick = btnTenRunsClick
  end
  object btnLoadFile: TButton
    Left = 379
    Top = 6
    Width = 113
    Height = 19
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = 'Load training picture'
    TabOrder = 6
    OnClick = btnLoadFileClick
  end
  object Button2: TButton
    Left = 379
    Top = 29
    Width = 56
    Height = 19
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = 'Unload'
    TabOrder = 7
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 8
    Top = 295
    Width = 75
    Height = 25
    Caption = 'Test'
    TabOrder = 8
    OnClick = Button3Click
  end
  object Button4: TButton
    Left = 8
    Top = 264
    Width = 98
    Height = 25
    Caption = 'Load test picture'
    TabOrder = 9
    OnClick = Button4Click
  end
  object FileOpenDialog1: TFileOpenDialog
    FavoriteLinks = <>
    FileTypes = <>
    Options = []
    Left = 331
    Top = 48
  end
end
