object ioVMStdActionSelectDialog: TioVMStdActionSelectDialog
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Select Standard ViewModel Actions'
  ClientHeight = 380
  ClientWidth = 520
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poMainFormCenter
  TextHeight = 15
  object pnlBottom: TPanel
    Left = 0
    Top = 340
    Width = 520
    Height = 40
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    object btnOK: TBitBtn
      Left = 352
      Top = 6
      Width = 75
      Height = 28
      Caption = 'OK'
      Default = True
      Kind = bkOK
      TabOrder = 0
    end
    object btnCancel: TBitBtn
      Left = 435
      Top = 6
      Width = 75
      Height = 28
      Cancel = True
      Caption = 'Cancel'
      Kind = bkCancel
      TabOrder = 1
    end
  end
  object pnlClient: TPanel
    Left = 0
    Top = 0
    Width = 520
    Height = 340
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    object Splitter1: TSplitter
      Left = 185
      Top = 0
      Height = 340
      ExplicitLeft = 200
      ExplicitTop = 168
      ExplicitHeight = 100
    end
    object pnlCategories: TPanel
      Left = 0
      Top = 0
      Width = 185
      Height = 340
      Align = alLeft
      BevelOuter = bvNone
      Constraints.MinWidth = 40
      TabOrder = 0
      object lblCategories: TLabel
        Left = 0
        Top = 0
        Width = 185
        Height = 24
        Align = alTop
        AutoSize = False
        Caption = 'Categories'
        Layout = tlCenter
      end
      object lbCategories: TListBox
        Left = 0
        Top = 24
        Width = 185
        Height = 316
        Align = alClient
        BevelKind = bkFlat
        BorderStyle = bsNone
        Ctl3D = False
        ItemHeight = 15
        ParentCtl3D = False
        TabOrder = 0
        OnClick = lbCategoriesClick
      end
    end
    object pnlActionClasses: TPanel
      Left = 188
      Top = 0
      Width = 332
      Height = 340
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 1
      object lblActionClasses: TLabel
        Left = 0
        Top = 0
        Width = 332
        Height = 24
        Align = alTop
        AutoSize = False
        Caption = 'Action Classes'
        Layout = tlCenter
      end
      object clbActionClasses: TCheckListBox
        Left = 0
        Top = 24
        Width = 332
        Height = 316
        Align = alClient
        BevelKind = bkFlat
        BorderStyle = bsNone
        Ctl3D = False
        ItemHeight = 15
        ParentCtl3D = False
        TabOrder = 0
      end
    end
  end
end