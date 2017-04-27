object MainWindow: TMainWindow
  Left = 0
  Top = 0
  Caption = 'NeuralTest02'
  ClientHeight = 265
  ClientWidth = 781
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
    Left = 192
    Top = 44
    Width = 52
    Height = 12
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = 'Input value'
  end
  object imgActual: TImage
    Left = 204
    Top = 115
    Width = 75
    Height = 114
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
  end
  object Label1: TLabel
    Left = 204
    Top = 98
    Width = 28
    Height = 12
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = 'Actual'
  end
  object imgDesired: TImage
    Left = 308
    Top = 115
    Width = 75
    Height = 114
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
  end
  object Label2: TLabel
    Left = 308
    Top = 98
    Width = 33
    Height = 12
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = 'Desired'
  end
  object lblPerf: TLabel
    Left = 436
    Top = 140
    Width = 24
    Height = 12
    Caption = 'P = ?'
  end
  object btnSetupSynapses: TButton
    Left = 36
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
    Left = 36
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
    Left = 192
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
    Left = 36
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
    Left = 36
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
    Left = 36
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
    Left = 408
    Top = 6
    Width = 79
    Height = 19
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = 'Load file'
    TabOrder = 6
    OnClick = btnLoadFileClick
  end
  object Button1: TButton
    Left = 192
    Top = 61
    Width = 103
    Height = 19
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = 'Get Selected Picture'
    TabOrder = 7
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 408
    Top = 29
    Width = 56
    Height = 19
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = 'Unload'
    TabOrder = 8
    OnClick = Button2Click
  end
  object chkShowDesired: TCheckBox
    Left = 308
    Top = 81
    Width = 91
    Height = 13
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = 'Show Desired'
    Checked = True
    State = cbChecked
    TabOrder = 9
  end
  object FileOpenDialog1: TFileOpenDialog
    FavoriteLinks = <>
    FileTypes = <>
    Options = []
    Left = 440
    Top = 80
  end
end
