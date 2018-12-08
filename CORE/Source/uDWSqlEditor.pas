{
 Esse editor SQL foi desenvolvido para integrar mais um recurso ao pacote de
 componentes REST Dataware, a intenção é ajudar na produtividade.
 Desenvolvedor : Julio César Andrade dos Anjos/Gilberto Rocha da Silva
 Data : 19/02/2018
}

unit uDWSqlEditor;

interface

uses
  SysUtils, Dialogs, Forms, ExtCtrls, StdCtrls, ComCtrls, DBGrids, uRESTDWPoolerDB, DB{$IFNDEF FPC}, Grids{$ENDIF}, Controls,
  Classes,{$IFDEF FPC}FormEditingIntf, PropEdits, lazideintf{$ELSE}DesignEditors, DesignIntf{$ENDIF};

 Type
  TFrmDWSqlEditor = class(TForm)
    PnlSQL: TPanel;
    PnlButton: TPanel;
    BtnExecute: TButton;
    PageControl: TPageControl;
    TabSheetSQL: TTabSheet;
    Memo: TMemo;
    PnlAction: TPanel;
    BtnOk: TButton;
    BtnCancelar: TButton;
    PageControlResult: TPageControl;
    TabSheetTable: TTabSheet;
    DBGridRecord: TDBGrid;
    procedure FormDestroy(Sender: TObject);
    procedure BtnExecuteClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure BtnCancelarClick(Sender: TObject);
    procedure BtnOkClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
 Private
  { Private declarations }
  DataSource       : TDataSource;
  RESTDWDatabase   : TRESTDWDatabase;
  RESTDWClientSQL,
  RESTDWClientSQLB : TRESTDWClientSQL;
  vOldSQL          : String;
 Public
  { Public declarations }
  Procedure SetClientSQL(Value : TRESTDWClientSQL);
 End;

 Type
  TDWSQLEditor = Class(TStringProperty)
 Public
  Function  GetAttributes        : TPropertyAttributes; Override;
  Procedure Edit;                                       Override;
  Function  GetValue             : String;              Override;
 End;

Var
 FrmDWSqlEditor : TFrmDWSqlEditor;

Implementation

{$IFDEF FPC}
{$R *.lfm}
{$ELSE}
{$R *.dfm}
{$ENDIF}

Function TDWSQLEditor.GetValue : String;
Begin
 Result := Trim(TRESTDWClientSQL(GetComponent(0)).SQL.Text);
 If Trim(Result) = '' Then
  Result := 'Click here to set SQL...'
End;

Procedure TDWSQLEditor.Edit;
Var
 objObj : TRESTDWClientSQL;
Begin
 FrmDWSqlEditor := TFrmDWSqlEditor.Create(Application);
 Try
  objObj        := TRESTDWClientSQL(GetComponent(0));
  FrmDWSqlEditor.SetClientSQL(objObj);
  FrmDWSqlEditor.ShowModal;
 Finally
  FrmDWSqlEditor.Free;
 End;
End;

Function TDWSQLEditor.GetAttributes: TPropertyAttributes;
Begin
 Result := [paDialog, paReadonly];
End;

procedure TFrmDWSqlEditor.BtnCancelarClick(Sender: TObject);
begin
 RESTDWClientSQL.SQL.Text := vOldSQL;
end;

Procedure TFrmDWSqlEditor.BtnExecuteClick(Sender: TObject);
Begin
 Screen.Cursor := crHourGlass;
 Try
  RESTDWClientSQLB.Close;
  RESTDWClientSQLB.SQL.Clear;
  RESTDWClientSQLB.SQL.Add(Memo.Lines.Text);
  RESTDWClientSQLB.Open;
 Finally
  Screen.Cursor := crDefault;
 End;
End;

procedure TFrmDWSqlEditor.BtnOkClick(Sender: TObject);
begin
 RESTDWClientSQL.SQL.Text := Memo.Text;
end;

procedure TFrmDWSqlEditor.FormCreate(Sender: TObject);
begin
 RESTDWClientSQLB          := TRESTDWClientSQL.Create(Self);
 RESTDWDatabase            := TRESTDWDatabase.Create(Self);
 RESTDWClientSQLB.DataBase := RESTDWDatabase;
end;

procedure TFrmDWSqlEditor.FormDestroy(Sender: TObject);
Begin
 RESTDWClientSQLB.Active := False;
 FreeAndNil(RESTDWClientSQLB);
 RESTDWDatabase.Active   := False;
 FreeAndNil(RESTDWDatabase);
 FreeAndNil(DataSource);
End;

procedure TFrmDWSqlEditor.FormShow(Sender: TObject);
begin
 DataSource                := TDataSource.Create(Self);
 DataSource.DataSet        := RESTDWClientSQLB;
 DBGridRecord.DataSource   := DataSource;
 PnlButton.Visible         := False;
 PageControlResult.Visible := PnlButton.Visible;
 If RESTDWClientSQL <> Nil Then
  Begin
   PnlButton.Visible         := RESTDWClientSQL.DataBase <> Nil;
   PageControlResult.Visible := PnlButton.Visible;
  End;
end;

Procedure TFrmDWSqlEditor.SetClientSQL(Value: TRESTDWClientSQL);
Begin
 RESTDWClientSQL           := Value;
 vOldSQL                   := RESTDWClientSQL.SQL.Text;
 Memo.Lines.Text           := vOldSQL;
 If RESTDWClientSQL.DataBase <> Nil Then
  Begin
   RESTDWDatabase.AccessTag             := RESTDWClientSQL.DataBase.AccessTag;
   RESTDWDatabase.Encoding              := RESTDWClientSQL.DataBase.Encoding;
   RESTDWDatabase.Context               := RESTDWClientSQL.DataBase.Context;
   RESTDWDatabase.EncodeStrings         := RESTDWClientSQL.DataBase.EncodeStrings;
   RESTDWDatabase.Compression           := RESTDWClientSQL.DataBase.Compression;
   RESTDWDatabase.Login                 := RESTDWClientSQL.DataBase.Login;
   RESTDWDatabase.ParamCreate           := RESTDWClientSQL.DataBase.ParamCreate;
   RESTDWDatabase.Password              := RESTDWClientSQL.DataBase.Password;
   RESTDWDatabase.PoolerName            := RESTDWClientSQL.DataBase.PoolerName;
   RESTDWDatabase.PoolerPort            := RESTDWClientSQL.DataBase.PoolerPort;
   RESTDWDatabase.PoolerService         := RESTDWClientSQL.DataBase.PoolerService;
   RESTDWDatabase.PoolerURL             := RESTDWClientSQL.DataBase.PoolerURL;
   RESTDWDatabase.Proxy                 := RESTDWClientSQL.DataBase.Proxy;
   RESTDWDatabase.ProxyOptions.Server   := RESTDWClientSQL.DataBase.ProxyOptions.Server;
   RESTDWDatabase.ProxyOptions.Port     := RESTDWClientSQL.DataBase.ProxyOptions.Port;
   RESTDWDatabase.ProxyOptions.Login    := RESTDWClientSQL.DataBase.ProxyOptions.Login;
   RESTDWDatabase.ProxyOptions.Password := RESTDWClientSQL.DataBase.ProxyOptions.Password;
   RESTDWDatabase.RequestTimeOut        := RESTDWClientSQL.DataBase.RequestTimeOut;
   RESTDWDatabase.TypeRequest           := RESTDWClientSQL.DataBase.TypeRequest;
  End;
End;

end.
