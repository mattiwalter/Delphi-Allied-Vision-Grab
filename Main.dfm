object Form2: TForm2
  Left = 0
  Top = 0
  Caption = 'Form2'
  ClientHeight = 781
  ClientWidth = 1022
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Image1: TImage
    Left = 8
    Top = 8
    Width = 641
    Height = 484
    Stretch = True
  end
  object Memo1: TMemo
    Left = 0
    Top = 516
    Width = 1022
    Height = 265
    Align = alBottom
    Lines.Strings = (
      'Memo1')
    ScrollBars = ssBoth
    TabOrder = 0
  end
  object GroupBox1: TGroupBox
    Left = 664
    Top = 8
    Width = 136
    Height = 305
    Caption = 'Actual Values'
    TabOrder = 1
    object LabeledEdit1: TLabeledEdit
      Left = 3
      Top = 80
      Width = 121
      Height = 21
      AutoSize = False
      EditLabel.Width = 44
      EditLabel.Height = 13
      EditLabel.Caption = 'Frame ID'
      TabOrder = 0
    end
    object LabeledEdit2: TLabeledEdit
      Left = 3
      Top = 120
      Width = 121
      Height = 21
      AutoSize = False
      EditLabel.Width = 31
      EditLabel.Height = 13
      EditLabel.Caption = 'Status'
      TabOrder = 1
    end
    object LabeledEdit3: TLabeledEdit
      Left = 3
      Top = 160
      Width = 121
      Height = 21
      AutoSize = False
      EditLabel.Width = 92
      EditLabel.Height = 13
      EditLabel.Caption = 'Payload size (Byte)'
      TabOrder = 2
    end
    object LabeledEdit4: TLabeledEdit
      Left = 3
      Top = 200
      Width = 121
      Height = 21
      AutoSize = False
      EditLabel.Width = 57
      EditLabel.Height = 13
      EditLabel.Caption = 'Pixel format'
      TabOrder = 3
    end
    object LabeledEdit5: TLabeledEdit
      Left = 3
      Top = 275
      Width = 121
      Height = 21
      AutoSize = False
      EditLabel.Width = 91
      EditLabel.Height = 13
      EditLabel.Caption = 'Frames per second'
      TabOrder = 4
    end
    object LabeledEdit6: TLabeledEdit
      Left = 3
      Top = 237
      Width = 121
      Height = 21
      AutoSize = False
      EditLabel.Width = 103
      EditLabel.Height = 13
      EditLabel.Caption = 'Frame dimension (Px)'
      TabOrder = 5
    end
    object LabeledEdit7: TLabeledEdit
      Left = 3
      Top = 40
      Width = 121
      Height = 21
      AutoSize = False
      EditLabel.Width = 66
      EditLabel.Height = 13
      EditLabel.Caption = 'Vimba Version'
      TabOrder = 6
    end
  end
  object GroupBox2: TGroupBox
    Left = 806
    Top = 8
    Width = 208
    Height = 201
    Caption = 'Target Values'
    TabOrder = 2
    object Label1: TLabel
      Left = 12
      Top = 24
      Width = 97
      Height = 13
      Caption = 'Exposure Value (uS)'
    end
    object Label2: TLabel
      Left = 12
      Top = 63
      Width = 21
      Height = 13
      Caption = 'Gain'
    end
    object Label7: TLabel
      Left = 12
      Top = 105
      Width = 93
      Height = 13
      Caption = 'Frame Rate (1/sec)'
    end
    object ScrollBar1: TScrollBar
      Left = 12
      Top = 40
      Width = 121
      Height = 17
      LargeChange = 1000
      Max = 150000
      PageSize = 0
      Position = 10
      TabOrder = 0
      OnChange = ScrollBar1Change
    end
    object Edit1: TEdit
      Left = 136
      Top = 40
      Width = 65
      Height = 21
      AutoSelect = False
      AutoSize = False
      TabOrder = 1
      Text = 'Edit1'
      OnKeyPress = Edit1to3KeyPress
    end
    object ScrollBar2: TScrollBar
      Left = 12
      Top = 82
      Width = 121
      Height = 17
      LargeChange = 10
      PageSize = 0
      Position = 20
      TabOrder = 2
      OnChange = ScrollBar2Change
    end
    object Edit2: TEdit
      Left = 136
      Top = 82
      Width = 65
      Height = 21
      AutoSelect = False
      AutoSize = False
      TabOrder = 3
      Text = 'Edit1'
      OnKeyPress = Edit1to3KeyPress
    end
    object ScrollBar5: TScrollBar
      Left = 12
      Top = 124
      Width = 121
      Height = 17
      Min = 1
      PageSize = 0
      Position = 50
      TabOrder = 4
      OnChange = ScrollBar5Change
    end
    object Edit3: TEdit
      Left = 136
      Top = 124
      Width = 65
      Height = 21
      AutoSelect = False
      AutoSize = False
      TabOrder = 5
      Text = 'Edit1'
      OnKeyPress = Edit1to3KeyPress
    end
    object Button1: TButton
      Left = 56
      Top = 160
      Width = 89
      Height = 25
      Caption = 'Apply Settings'
      TabOrder = 6
      OnClick = Button1Click
    end
  end
  object GroupBox3: TGroupBox
    Left = 664
    Top = 319
    Width = 136
    Height = 100
    Caption = 'Display size'
    TabOrder = 3
    object RadioButton1: TRadioButton
      Left = 16
      Top = 24
      Width = 113
      Height = 17
      Caption = 'Shrink to 50%'
      TabOrder = 0
    end
    object RadioButton2: TRadioButton
      Left = 16
      Top = 47
      Width = 113
      Height = 17
      Caption = 'Original size 100%'
      Checked = True
      TabOrder = 1
      TabStop = True
    end
    object RadioButton3: TRadioButton
      Left = 16
      Top = 70
      Width = 113
      Height = 17
      Caption = 'Zomm to 200%'
      TabOrder = 2
    end
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 500
    OnTimer = Timer1Timer
    Left = 840
    Top = 272
  end
end
