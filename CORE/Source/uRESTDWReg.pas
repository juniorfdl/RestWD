unit uRESTDWReg;

{$I uRESTDW.inc}

{
  REST Dataware versão CORE.
  Criado por XyberX (Gilbero Rocha da Silva), o REST Dataware tem como objetivo o uso de REST/JSON
 de maneira simples, em qualquer Compilador Pascal (Delphi, Lazarus e outros...).
  O REST Dataware também tem por objetivo levar componentes compatíveis entre o Delphi e outros Compiladores
 Pascal e com compatibilidade entre sistemas operacionais.
  Desenvolvido para ser usado de Maneira RAD, o REST Dataware tem como objetivo principal você usuário que precisa
 de produtividade e flexibilidade para produção de Serviços REST/JSON, simplificando o processo para você programador.

 Membros do Grupo :

 XyberX (Gilberto Rocha)    - Admin - Criador e Administrador do CORE do pacote.
 Ivan Cesar                 - Admin - Administrador do CORE do pacote.
 Joanan Mendonça Jr. (jlmj) - Admin - Administrador do CORE do pacote.
 Giovani da Cruz            - Admin - Administrador do CORE do pacote.
 Alexandre Abbade           - Admin - Administrador do desenvolvimento de DEMOS, coordenador do Grupo.
 Alexandre Souza            - Admin - Administrador do Grupo de Organização.
 Anderson Fiori             - Admin - Gerencia de Organização dos Projetos
 Mizael Rocha               - Member Tester and DEMO Developer.
 Flávio Motta               - Member Tester and DEMO Developer.
 Itamar Gaucho              - Member Tester and DEMO Developer.
 Ico Menezes                - Member Tester and DEMO Developer.
}


interface

uses
  {$IFDEF FPC}
    StdCtrls, ComCtrls, Forms, ExtCtrls, DBCtrls, DBGrids, Dialogs, Controls, Variants, TypInfo, FileCtrl,
    LResources, SysUtils, FormEditingIntf, PropEdits, lazideintf, ComponentEditors, Classes, uDWResponseTranslator,
    uRESTDWBase, uRESTDWPoolerDB, uDWDatamodule, uDWSqlEditor, uDWMassiveBuffer, uRESTDWServerEvents, uDWDataset, uRESTDWServerContext;
  {$ELSE}
   Windows, SysUtils, Variants, StrEdit, TypInfo, RTLConsts, uDWDataset,
   {$IFDEF COMPILER16_UP}
   UITypes,
   {$ENDIF}
   {$if CompilerVersion > 21}
    ToolsApi, vcl.Graphics, DMForm, DesignWindows, DesignEditors, DBReg, DSDesign,
    DesignIntf, ExptIntf, Classes, uDWResponseTranslator, uRESTDWBase, uRESTDWPoolerDB,
    uDWDatamodule, uDWMassiveBuffer, uRESTDWServerEvents, uRESTDWServerContext, Db, uDWSqlEditor,
    {$IF Defined(HAS_FMX)}
     {$IFDEF WINDOWS}
     dwISAPIRunner, dwCGIRunner,
     {$ENDIF}
    {$ELSE}
     dwISAPIRunner, dwCGIRunner,
    {$IFEND} ColnEdit;
   {$ELSE}
    ToolsApi, Graphics, DMForm, DesignWindows, DesignEditors, DBReg, DesignIntf,
    ExptIntf, Classes, uDWResponseTranslator, uRESTDWBase, uRESTDWPoolerDB,
    uDWDatamodule, uDWMassiveBuffer, uRESTDWServerEvents, uRESTDWServerContext, Db, DbTables,
    DSDesign, dwISAPIRunner, dwCGIRunner, uDWSqlEditor, ColnEdit;
   {$IFEND}
  {$ENDIF}

{$IFNDEF CLR}
Const
 varUString  = Succ(Succ(varString)); { Variant type code }
{$ENDIF}

Var
 EnabledAllTableDefs : Boolean = False;
 LoadAndStoreToForm  : Boolean = False;

{$IFNDEF FPC} //TODO
Type
 TDWDSDesigner = class(TDSDesigner)
Public
 Function DoCreateField(const FieldName : {$IFDEF COMPILER10_UP}WideString{$ELSE}String{$ENDIF}; Origin: String): TField; Override;
End;
{$ENDIF}

Type
 TAddFields = Procedure (All: Boolean) of Object;

Type
 TPoolersList = Class(TStringProperty)
 Public
  Function  GetAttributes  : TPropertyAttributes; Override;
  Procedure GetValues(Proc : TGetStrProc);        Override;
  Procedure Edit;                                 Override;
End;

Type
 TServerEventsList = Class(TStringProperty)
 Public
  Function  GetAttributes  : TPropertyAttributes; Override;
  Procedure GetValues(Proc : TGetStrProc);        Override;
  Procedure Edit;                                 Override;
End;

type
 TDWServerEventsEditor = Class(TComponentEditor)
  Function  GetVerbCount       : Integer;  Override;
  Function  GetVerb     (Index : Integer): String; Override;
  Procedure ExecuteVerb(Index  : Integer); Override;
End;

Type
 TDWClientEventsEditor = Class(TComponentEditor)
  Function  GetVerbCount      : Integer;  Override;
  Function  GetVerb    (Index : Integer): String; Override;
  Procedure ExecuteVerb(Index : Integer); Override;
End;

Type
 TDWResponseTranslatorEditor = Class(TComponentEditor)
  Function  GetVerbCount      : Integer;  Override;
  Function  GetVerb    (Index : Integer): String; Override;
  Procedure ExecuteVerb(Index : Integer); Override;
End;

{$IFNDEF FPC}
Type
 TDSDesignerDW = Class(TDSDesigner)
 Private
 Public
  {$if CompilerVersion > 19}
  Function  DoCreateField(const FieldName: WideString; Origin: string): TField; override;
  {$ELSE}
  Function  DoCreateField(const FieldName: String; Origin: string): TField; override;
  {$IFEND}
  {$IFNDEF FPC}
  Function SupportsAggregates: Boolean; Override;
  Function SupportsInternalCalc: Boolean; Override;
  {$ENDIF}
End;

Type
 TRESTDWClientSQLEditor = Class(TComponentEditor)
 Private
 Public
  Procedure Edit; override;
  Function  GetVerbCount : Integer; Override;
  Function  GetVerb    (Index : Integer): String; Override;
  Procedure ExecuteVerb(Index : Integer); Override;
End;
{$ENDIF}

Procedure Register;

Implementation

uses uDWConsts, uDWConstsData, uDWPoolerMethod, uDWAbout;

{$IFNDEF FPC}
{$IFDEF  RTL240_UP}
Var
 AboutBoxServices : IOTAAboutBoxServices = nil;
 AboutBoxIndex    : Integer = 0;

procedure RegisterAboutBox;
Var
 ProductImage: HBITMAP;
Begin
 Supports(BorlandIDEServices,IOTAAboutBoxServices, AboutBoxServices);
 Assert(Assigned(AboutBoxServices), '');
 ProductImage  := LoadBitmap(FindResourceHInstance(HInstance), 'DW');
 AboutBoxIndex := AboutBoxServices.AddPluginInfo(DWSobreTitulo , DWSobreDescricao,
                                                 ProductImage, False, DWSobreLicencaStatus);
End;

procedure UnregisterAboutBox;
Begin
 If (AboutBoxIndex <> 0) and Assigned(AboutBoxServices) then
  Begin
   AboutBoxServices.RemovePluginInfo(AboutBoxIndex);
   AboutBoxIndex := 0;
   AboutBoxServices := nil;
  End;
End;

Procedure AddSplash;
Var
 bmp : TBitmap;
Begin
 bmp := TBitmap.Create;
 bmp.LoadFromResourceName(HInstance, 'DW');
 SplashScreenServices.AddPluginBitmap(DWDialogoTitulo, bmp.Handle, false, DWSobreLicencaStatus, '');
 bmp.Free;
End;
{$ENDIF}
{$ENDIF}

{$IFNDEF FPC}
procedure TRESTDWClientSQLEditor.Edit;
Begin
 {$IFNDEF FPC}
  {$IF CompilerVersion > 21}
   TRESTDWClientSQL(Component).SetInDesignEvents(True);
  {$IFEND}
 {$ENDIF}
 Try
  {$IFNDEF FPC}
   {$IF CompilerVersion < 21}
    TRESTDWClientSQL(Component).Close;
    TRESTDWClientSQL(Component).CreateDatasetFromList;
   {$IFEND}
  {$ENDIF}
  ShowFieldsEditor(Designer, TRESTDWClientSQL(Component), TDSDesignerDW);
 Finally
  {$IFNDEF FPC}
   {$IF CompilerVersion > 21}
   TRESTDWClientSQL(Component).SetInDesignEvents(False);
   {$IFEND}
  {$ENDIF}
 End;
end;

procedure TRESTDWClientSQLEditor.ExecuteVerb(Index: Integer);
 Procedure EditFields(DataSet: TDataSet);
 begin
  {$IFNDEF FPC}
   {$IF CompilerVersion < 21}
    TRESTDWClientSQL(DataSet).Close;
    TRESTDWClientSQL(DataSet).CreateDatasetFromList;
   {$IFEND}
  {$ENDIF}
  ShowFieldsEditor(Designer, TRESTDWClientSQL(Component), TDSDesignerDW);
 End;
Begin
 Case Index of
  0 : EditFields(TDataSet(Component));
 End;
end;

Function TRESTDWClientSQLEditor.GetVerb(Index: Integer): String;
Begin
 Case Index Of
  0 : Result := 'Fields Edi&tor';
 End;
End;

Function TRESTDWClientSQLEditor.GetVerbCount: Integer;
Begin
 Result := 1;
End;

{$if CompilerVersion > 19}
Function  TDSDesignerDW.DoCreateField(const FieldName: WideString; Origin: string): TField;
{$ELSE}
Function  TDSDesignerDW.DoCreateField(const FieldName: String; Origin: string): TField;
{$IFEND}
Begin
 Result := Nil;
 Try
  If TRESTDWClientSQL(DataSet).FieldListCount > 0 Then
   Begin
//    {$IFNDEF FPC}
//     {$IF CompilerVersion > 21}
//      TRESTDWClientSQL(DataSet).SetInDesignEvents(True);
      Try
       TRESTDWClientSQL(DataSet).Close;
       TRESTDWClientSQL(DataSet).CreateDatasetFromList;
      Finally
//       TRESTDWClientSQL(DataSet).SetInDesignEvents(False);
      End;
//     {$IFEND}
//    {$ENDIF}
    If TRESTDWClientSQL(DataSet).FieldDefExist(FieldName) <> Nil Then
     Result := Inherited DoCreateField(FieldName, Origin);
   End;
 Finally
 End;
End;

Function TDSDesignerDW.SupportsAggregates: Boolean;
Begin
 Result := True;
End;

Function TDSDesignerDW.SupportsInternalCalc: Boolean;
Begin
 Result := True;
End;
{$ENDIF}

Function TPoolersList.GetAttributes : TPropertyAttributes;
Begin
  // editor, sorted list, multiple selection
 Result := [paValueList, paSortList];
End;

procedure TPoolersList.Edit;
Var
 vTempData : String;
Begin
 Inherited Edit;
 Try
  vTempData := GetValue;
  SetValue(vTempData);
 Finally
 End;
end;

Procedure TPoolersList.GetValues(Proc : TGetStrProc);
Var
 vLista : TStringList;
 I      : Integer;
Begin
 //Provide a list of Poolers
 vLista := Nil;
 With GetComponent(0) as TRESTDWDataBase Do
  Begin
   Try
    vLista := TRESTDWDataBase(GetComponent(0)).GetRestPoolers;
    For I := 0 To vLista.Count -1 Do
     Proc (vLista[I]);
   Except
   End;
   If vLista <> Nil Then
    vLista.Free;
  End;
End;

{Ico Testando }
{Editor de Proriedades de Componente para mostrar o AboutDW}
Type
 TDWAboutDialogProperty = class({$IFDEF FPC}TClassPropertyEditor{$ELSE}TPropertyEditor{$ENDIF})
Public
 Procedure Edit; override;
 Function  GetAttributes : TPropertyAttributes; Override;
 Function  GetValue      : String;              Override;
End;

Procedure TDWAboutDialogProperty.Edit;
Begin
 DWAboutDialog;
End;

Function TDWAboutDialogProperty.GetAttributes: TPropertyAttributes;
Begin
 Result := [paDialog, paReadOnly];
End;

Function TDWAboutDialogProperty.GetValue: String;
Begin
 Result := 'Version : '+ DWVERSAO;
End;

Procedure Register;
Begin
 {$IFNDEF FPC}
  RegisterNoIcon([TServerMethodDataModule]);
  RegisterCustomModule(TServerMethodDataModule, TCustomModule); //TDataModuleDesignerCustomModule);
 {$ELSE}
  FormEditingHook.RegisterDesignerBaseClass(TServerMethodDataModule);
 {$ENDIF}
 RegisterComponents('REST Dataware - Service',     [TRESTServicePooler,
                                                    {$IFDEF FPC}
                                                    {$ELSE}
                                                     TDWISAPIRunner,
                                                     TDWCGIRunner,
                                                    {$ENDIF}
                                                    TRESTServiceCGI,
                                                    TDWServerEvents, TDWClientEvents, TRESTClientPooler,
                                                    TRESTDWServiceNotification]);
 RegisterComponents('REST Dataware - Webpascal',   [TDWServerContext, TDWContextRules]);
 RegisterComponents('REST Dataware - Tools',       [TDWClientREST,      TDWResponseTranslator]);
 RegisterComponents('REST Dataware - CORE - DB',   [TRESTDWPoolerDB,    TRESTDWDataBase,   TRESTDWClientSQL, TDWMemtable,     TDWMassiveSQLCache,
                                                    TRESTDWStoredProc,  TRESTDWPoolerList, TDWMassiveCache]);
 {$IFNDEF FPC}
  RegisterPropertyEditor(TypeInfo(TDWAboutInfo),   Nil, 'AboutInfo', TDWAboutDialogProperty);
  RegisterPropertyEditor(TypeInfo(TDWAboutInfoDS), Nil, 'AboutInfo', TDWAboutDialogProperty);
 {$ELSE}
  RegisterPropertyEditor(TypeInfo(TDWAboutInfo),   Nil, 'AboutInfo', TDWAboutDialogProperty);
  RegisterPropertyEditor(TypeInfo(TDWAboutInfoDS), Nil, 'AboutInfo', TDWAboutDialogProperty);
 {$ENDIF}
 RegisterPropertyEditor(TypeInfo(String),       TRESTDWDataBase,  'PoolerName',      TPoolersList);
 RegisterPropertyEditor(TypeInfo(String),       TDWClientEvents,  'ServerEventName', TServerEventsList);
 RegisterPropertyEditor(TypeInfo(TStrings),     TRESTDWClientSQL, 'SQL',             TDWSQLEditor);
 RegisterComponentEditor(TDWServerEvents,       TDWServerEventsEditor);
 RegisterComponentEditor(TDWClientEvents,       TDWClientEventsEditor);
 RegisterComponentEditor(TDWResponseTranslator, TDWResponseTranslatorEditor);
 {$IFNDEF FPC}
 RegisterComponentEditor(TRESTDWClientSQL, TRESTDWClientSQLEditor);
 {$ENDIF}
End;

{ TDWServerEventsEditor }

procedure TDWServerEventsEditor.ExecuteVerb(Index: Integer);
begin
 Inherited;
 Case Index of
  0 : Begin
       {$IFNDEF FPC}
        ShowCollectionEditor(Designer, Component, (Component as TDWServerEvents).Events, 'Events');
       {$ELSE}
        TCollectionPropertyEditor.ShowCollectionEditor(TDWServerEvents(Component).Events, Component, 'Events');
       {$ENDIF}
      End;
 End;
End;

Function TDWServerEventsEditor.GetVerb(Index: Integer): String;
Begin
 Case Index of
  0 : Result := 'Events &List';
 End;
End;

function TDWServerEventsEditor.GetVerbCount: Integer;
begin
  Result := 1;
end;

Procedure TDWClientEventsEditor.ExecuteVerb(Index: Integer);
Begin
 Inherited;
 Case Index of
  // Procedure in the unit ColnEdit.pas
   0 : Begin
        {$IFNDEF FPC}
         ShowCollectionEditor(Designer, Component, TDWClientEvents(Component).Events, 'Events');
        {$ELSE}
         TCollectionPropertyEditor.ShowCollectionEditor(TDWClientEvents(Component).Events,Component, 'Events');
        {$ENDIF}
       End;
   1 : (Component as TDWClientEvents).GetEvents := True;
   2 : (Component as TDWClientEvents).ClearEvents;
 End;
End;

Function TDWClientEventsEditor.GetVerb(Index: Integer): string;
Begin
 Case Index of
  0 : Result := 'Events &List';
  1 : Result := '&Get Server Events';
  2 : Result := '&Clear Client Events';
 End;
End;

Function TDWClientEventsEditor.GetVerbCount: Integer;
Begin
 Result := 3;
End;

{$IFNDEF FPC}
Function TDWDSDesigner.DoCreateField(Const FieldName : {$IFDEF COMPILER10_UP}WideString{$ELSE}String{$ENDIF};Origin: string): TField;
Begin
 (DataSet As TDWCustomDataSet).DesignNotify(FieldName, 0);
 Result  := Inherited DoCreateField(FieldName, Origin);
 (DataSet As TDWCustomDataSet).DesignNotify(FieldName, 104);
End;
{$ENDIF}

{ TDWResponseTranslatorEditor }

procedure TDWResponseTranslatorEditor.ExecuteVerb(Index: Integer);
begin
  inherited;
 Case Index of
   0 : (Component as TDWResponseTranslator).GetFieldDefs;
   1 : (Component as TDWResponseTranslator).FieldDefs.Clear;
 End;
end;

Function TDWResponseTranslatorEditor.GetVerb(Index: Integer): String;
Begin
 Case Index of
  0 : Result := 'Get &FieldsDefs';
  1 : Result := '&C&lear FieldsDefs';
 End;
End;

Function TDWResponseTranslatorEditor.GetVerbCount: Integer;
Begin
 Result := 2;
End;

{ TServerEventsList }

procedure TServerEventsList.Edit;
Var
 vTempData : String;
Begin
 Inherited Edit;
 Try
  vTempData := GetValue;
  SetValue(vTempData);
 Finally
 End;
End;

Function TServerEventsList.GetAttributes: TPropertyAttributes;
begin
  // editor, sorted list, multiple selection
 Result := [paValueList, paSortList];
end;

procedure TServerEventsList.GetValues(Proc: TGetStrProc);
Var
 vLista : TStringList;
 I      : Integer;
 Function GetRestPoolers : TStringList;
 Var
  vTempList     : TStringList;
  vConnection   : TDWPoolerMethodClient;
  I             : Integer;
  vRESTClientPooler : TRESTClientPooler;
 Begin
  If TDWClientEvents(GetComponent(0)).RESTClientPooler <> Nil Then
   Begin
    vRESTClientPooler          := TDWClientEvents(GetComponent(0)).RESTClientPooler;
    vConnection                := TDWPoolerMethodClient.Create(Nil);
    vConnection.WelcomeMessage := vRESTClientPooler.WelcomeMessage;
    vConnection.Host           := vRESTClientPooler.Host;
    vConnection.Port           := vRESTClientPooler.Port;
    vConnection.Compression    := vRESTClientPooler.DataCompression;
    vConnection.TypeRequest    := vRESTClientPooler.TypeRequest;
    vConnection.AccessTag      := vRESTClientPooler.AccessTag;
    Result := TStringList.Create;
    Try
     vTempList := vConnection.GetServerEvents(vRESTClientPooler.UrlPath,
                                              vRESTClientPooler.RequestTimeOut,
                                              vRESTClientPooler.UserName,
                                              vRESTClientPooler.Password);
     Try
      For I := 0 To vTempList.Count -1 do
       Result.Add(vTempList[I]);
     Finally
      If Assigned(vTempList) Then
       vTempList.Free;
     End;
    Except
     On E : Exception do
      Begin
       Raise Exception.Create(E.Message);
      End;
    End;
    FreeAndNil(vConnection);
   End;
 End;
Begin
 //Provide a list of Poolers
 vLista := Nil;
 With GetComponent(0) as TDWClientEvents Do
  Begin
   vLista := GetRestPoolers;
   Try
    For I := 0 To vLista.Count -1 Do
     Proc (vLista[I]);
   Except
   End;
   FreeAndNil(vLista);
  End;
End;

initialization
 {$IFNDEF FPC}
 {$IFDEF  RTL240_UP}
	RegisterAboutBox;
  AddSplash;
 {$ENDIF}
 {$ENDIF}
 {$IFDEF FPC}
 {$I resteasyobjectscore.lrs}
 {$ELSE}
 {$if CompilerVersion < 21}
  {$R ..\Packages\Delphi\D7\RestEasyObjectsCORE.dcr}
 {$IFEND}
 UnlistPublishedProperty(TRESTDWClientSQL, 'CachedUpdates');
 {$ENDIF}

Finalization
 {$IFNDEF FPC}
 {$IFDEF  RTL240_UP}
	UnregisterAboutBox;
 {$ENDIF}
 {$ENDIF}

end.
