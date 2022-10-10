inherited ViewOrders: TViewOrders
  inherited PanelTop: TPanel
    inherited LabelTitle: TLabel
      Width = 700
      Height = 40
      Caption = 'Orders'
      ExplicitWidth = 700
    end
  end
  inherited PanelBottom: TPanel
    object Button1: TButton
      Left = 352
      Top = 6
      Width = 75
      Height = 25
      Action = acPersist
      TabOrder = 0
    end
  end
  object GridOrders: TDBGrid [2]
    Left = 0
    Top = 40
    Width = 800
    Height = 520
    Align = alClient
    DataSource = SourceMaster
    TabOrder = 2
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -12
    TitleFont.Name = 'Segoe UI'
    TitleFont.Style = []
    OnDblClick = GridOrdersDblClick
    Columns = <
      item
        Alignment = taCenter
        Expanded = False
        FieldName = 'ID'
        Title.Alignment = taCenter
        Title.Font.Charset = DEFAULT_CHARSET
        Title.Font.Color = clNavy
        Title.Font.Height = -13
        Title.Font.Name = 'Segoe UI'
        Title.Font.Style = [fsBold]
        Width = 60
        Visible = True
      end
      item
        Alignment = taCenter
        Expanded = False
        FieldName = 'OrderDate'
        Title.Alignment = taCenter
        Title.Caption = 'Date'
        Title.Font.Charset = DEFAULT_CHARSET
        Title.Font.Color = clNavy
        Title.Font.Height = -13
        Title.Font.Name = 'Segoe UI'
        Title.Font.Style = [fsBold]
        Width = 90
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'Customer.Name'
        Title.Alignment = taCenter
        Title.Caption = 'Customer'
        Title.Font.Charset = DEFAULT_CHARSET
        Title.Font.Color = clNavy
        Title.Font.Height = -13
        Title.Font.Name = 'Segoe UI'
        Title.Font.Style = [fsBold]
        Width = 200
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'GrandTotal'
        Title.Caption = 'Grand total'
        Title.Font.Charset = DEFAULT_CHARSET
        Title.Font.Color = clNavy
        Title.Font.Height = -13
        Title.Font.Name = 'Segoe UI'
        Title.Font.Style = [fsBold]
        Width = 90
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'Note'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        Title.Alignment = taCenter
        Title.Font.Charset = DEFAULT_CHARSET
        Title.Font.Color = clNavy
        Title.Font.Height = -13
        Title.Font.Name = 'Segoe UI'
        Title.Font.Style = [fsBold]
        Width = 300
        Visible = True
      end>
  end
  inherited ActionList1: TActionList
    object acPersist: TioViewAction
      Category = 'iORM-MVVM'
      Caption = 'acPersist'
      Enabled = True
      Visible = True
      VMActionName = 'acPersist'
    end
  end
  inherited MDSMaster: TioModelDataSet
    object MDSMasterID: TIntegerField
      FieldName = 'ID'
    end
    object MDSMasterOrderDate: TDateTimeField
      FieldName = 'OrderDate'
    end
    object MDSMasterNote: TStringField
      FieldName = 'Note'
      Size = 250
    end
    object MDSMasterCustomerName: TStringField
      FieldName = 'Customer.Name'
      Size = 250
    end
    object MDSMasterGrandTotal: TCurrencyField
      FieldName = 'GrandTotal'
    end
  end
end
