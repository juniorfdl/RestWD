object FrmDWSqlEditor: TFrmDWSqlEditor
  Left = 472
  Top = 153
  Width = 602
  Height = 484
  BorderWidth = 5
  Caption = 'RESTDWClientSQL Editor'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object PnlSQL: TPanel
    Left = 0
    Top = 0
    Width = 584
    Height = 208
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object PnlButton: TPanel
      Left = 489
      Top = 0
      Width = 95
      Height = 208
      Align = alRight
      BevelOuter = bvNone
      TabOrder = 0
      object BtnExecute: TButton
        Left = 8
        Top = 20
        Width = 80
        Height = 25
        Caption = 'Execute'
        TabOrder = 0
        OnClick = BtnExecuteClick
      end
    end
    object PageControl: TPageControl
      Left = 0
      Top = 0
      Width = 489
      Height = 208
      ActivePage = TabSheetSQL
      Align = alClient
      TabOrder = 1
      object TabSheetSQL: TTabSheet
        BorderWidth = 5
        Caption = 'SQL Command'
        object Memo: TMemo
          Left = 0
          Top = 0
          Width = 471
          Height = 170
          Align = alClient
          ScrollBars = ssBoth
          TabOrder = 0
        end
      end
    end
  end
  object PnlAction: TPanel
    Left = 0
    Top = 402
    Width = 584
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    DesignSize = (
      584
      41)
    object BtnOk: TButton
      Left = 412
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Ok'
      Default = True
      ModalResult = 1
      TabOrder = 0
      OnClick = BtnOkClick
    end
    object BtnCancelar: TButton
      Left = 493
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Cancel = True
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 1
      OnClick = BtnCancelarClick
    end
  end
  object PageControlResult: TPageControl
    Left = 0
    Top = 208
    Width = 584
    Height = 194
    ActivePage = TabSheetTable
    Align = alBottom
    TabOrder = 2
    object TabSheetTable: TTabSheet
      BorderWidth = 5
      Caption = 'RecordSet'
      object DBGridRecord: TDBGrid
        Left = 0
        Top = 0
        Width = 566
        Height = 156
        Align = alClient
        TabOrder = 0
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -11
        TitleFont.Name = 'Tahoma'
        TitleFont.Style = []
      end
    end
  end
end
