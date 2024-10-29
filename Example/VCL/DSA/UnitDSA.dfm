object FormDSA: TFormDSA
  Left = 192
  Top = 109
  BorderStyle = bsDialog
  Caption = 'DSA Demo'
  ClientHeight = 519
  ClientWidth = 917
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object pgcDSA: TPageControl
    Left = 16
    Top = 16
    Width = 881
    Height = 481
    ActivePage = tsDSA
    TabOrder = 0
    object tsDSA: TTabSheet
      Caption = 'BigNumber DSA'
      ImageIndex = 1
      object lblDSAP: TLabel
        Left = 16
        Top = 60
        Width = 10
        Height = 13
        Caption = 'P:'
      end
      object lblDSAQ: TLabel
        Left = 16
        Top = 92
        Width = 11
        Height = 13
        Caption = 'Q:'
      end
      object lblDSAG: TLabel
        Left = 16
        Top = 124
        Width = 11
        Height = 13
        Caption = 'G:'
      end
      object lblDSAPriv: TLabel
        Left = 16
        Top = 220
        Width = 36
        Height = 13
        Caption = 'Private:'
      end
      object lblDSAPub: TLabel
        Left = 16
        Top = 252
        Width = 22
        Height = 13
        Caption = 'Pub:'
      end
      object bvl1: TBevel
        Left = 16
        Top = 160
        Width = 841
        Height = 25
        Shape = bsTopLine
      end
      object bvl2: TBevel
        Left = 16
        Top = 288
        Width = 841
        Height = 25
        Shape = bsTopLine
      end
      object lblDSAHash: TLabel
        Left = 8
        Top = 308
        Width = 47
        Height = 13
        Caption = 'Utf8 Text:'
      end
      object lblDSASignS: TLabel
        Left = 16
        Top = 372
        Width = 34
        Height = 13
        Caption = 'Sign S:'
      end
      object lblDSASignR: TLabel
        Left = 16
        Top = 340
        Width = 35
        Height = 13
        Caption = 'Sign R:'
      end
      object lblDSAHashType: TLabel
        Left = 328
        Top = 308
        Width = 28
        Height = 13
        Caption = 'Hash:'
      end
      object lblPrimeType: TLabel
        Left = 216
        Top = 24
        Width = 52
        Height = 13
        Caption = 'DSA Type:'
      end
      object btnGenDSAParam: TButton
        Left = 16
        Top = 16
        Width = 161
        Height = 25
        Caption = 'Generate DSA Parameters'
        TabOrder = 0
        OnClick = btnGenDSAParamClick
      end
      object edtDSAP: TEdit
        Left = 56
        Top = 56
        Width = 801
        Height = 21
        TabOrder = 3
      end
      object edtDSAQ: TEdit
        Left = 56
        Top = 88
        Width = 801
        Height = 21
        TabOrder = 4
      end
      object edtDSAG: TEdit
        Left = 56
        Top = 120
        Width = 801
        Height = 21
        TabOrder = 5
      end
      object btnVerifyDSAParam: TButton
        Left = 696
        Top = 16
        Width = 161
        Height = 25
        Caption = 'Verify DSA Parameters'
        TabOrder = 1
        OnClick = btnVerifyDSAParamClick
      end
      object btnGenDSAKeys: TButton
        Left = 16
        Top = 176
        Width = 161
        Height = 25
        Caption = 'Generate DSA Keys'
        TabOrder = 6
        OnClick = btnGenDSAKeysClick
      end
      object btnVerifyDSAKeys: TButton
        Left = 696
        Top = 176
        Width = 161
        Height = 25
        Caption = 'Verify DSA Keys'
        TabOrder = 7
        OnClick = btnVerifyDSAKeysClick
      end
      object edtDSAPriv: TEdit
        Left = 56
        Top = 216
        Width = 801
        Height = 21
        TabOrder = 8
      end
      object edtDSAPub: TEdit
        Left = 56
        Top = 248
        Width = 801
        Height = 21
        TabOrder = 9
      end
      object edtDSAText: TEdit
        Left = 56
        Top = 304
        Width = 257
        Height = 21
        TabOrder = 12
        Text = '6871AF087F975FF64048028880C0365C505506FF'
      end
      object btnDSASignHash: TButton
        Left = 520
        Top = 302
        Width = 161
        Height = 25
        Caption = 'DSA Sign Data'
        TabOrder = 10
        OnClick = btnDSASignHashClick
      end
      object btnDSAVerifyHash: TButton
        Left = 696
        Top = 302
        Width = 161
        Height = 25
        Caption = 'DSA Verify Data'
        TabOrder = 11
        OnClick = btnDSAVerifyHashClick
      end
      object edtDSASignS: TEdit
        Left = 56
        Top = 368
        Width = 801
        Height = 21
        TabOrder = 15
      end
      object edtDSASignR: TEdit
        Left = 56
        Top = 336
        Width = 801
        Height = 21
        TabOrder = 14
      end
      object cbbDSAHashType: TComboBox
        Left = 368
        Top = 304
        Width = 121
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 13
        Items.Strings = (
          'Auto'
          'MD5'
          'SHA1'
          'SHA224'
          'SHA256'
          'SM3')
      end
      object cbbDSAType: TComboBox
        Left = 280
        Top = 20
        Width = 121
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 2
        Items.Strings = (
          '1024-160'
          '2048-224'
          '2048-256'
          '3072-256')
      end
    end
  end
end