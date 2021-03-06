unit uRESTDWServerEvents;

{
  REST Dataware vers�o CORE.
  Criado por XyberX (Gilbero Rocha da Silva), o REST Dataware tem como objetivo o uso de REST/JSON
 de maneira simples, em qualquer Compilador Pascal (Delphi, Lazarus e outros...).
  O REST Dataware tamb�m tem por objetivo levar componentes compat�veis entre o Delphi e outros Compiladores
 Pascal e com compatibilidade entre sistemas operacionais.
  Desenvolvido para ser usado de Maneira RAD, o REST Dataware tem como objetivo principal voc� usu�rio que precisa
 de produtividade e flexibilidade para produ��o de Servi�os REST/JSON, simplificando o processo para voc� programador.

 Membros do Grupo :

 XyberX (Gilberto Rocha)    - Admin - Criador e Administrador do CORE do pacote.
 Ivan Cesar                 - Admin - Administrador do CORE do pacote.
 Joanan Mendon�a Jr. (jlmj) - Admin - Administrador do CORE do pacote.
 Giovani da Cruz            - Admin - Administrador do CORE do pacote.
 Alexandre Abbade           - Admin - Administrador do desenvolvimento de DEMOS, coordenador do Grupo.
 Alexandre Souza            - Admin - Administrador do Grupo de Organiza��o.
 Anderson Fiori             - Admin - Gerencia de Organiza��o dos Projetos
 Mizael Rocha               - Member Tester and DEMO Developer.
 Fl�vio Motta               - Member Tester and DEMO Developer.
 Itamar Gaucho              - Member Tester and DEMO Developer.
 Ico Menezes                - Member Tester and DEMO Developer.
}


interface

Uses
 SysUtils, Classes, uDWJSONObject, uDWConsts, uDWConstsData, uDWAbout,
 uRESTDWBase, uDWJSONTools{$IFNDEF FPC}
                           {$IF CompilerVersion > 21} // Delphi 2010 pra cima
                            {$IF Defined(HAS_FMX)} // Alteardo para IOS Brito
                              , System.json
                            {$ELSE}
                             , uDWJSON
                            {$IFEND}
                           {$ELSE}
                            , uDWJSON
                           {$IFEND}
                           {$ELSE}
                           , uDWJSON
                           {$ENDIF};

Const
 TServerEventsConst = '{"typeobject":"%s", "objectdirection":"%s", "objectvalue":"%s", "paramname":"%s", "encoded":"%s", "default":"%s"}';

Type
 TDWReplyEvent       = Procedure(Var   Params      : TDWParams;
                                 Var   Result      : String)          Of Object;
 TDWReplyEventByType = Procedure(Var   Params      : TDWParams;
                                 Var   Result      : String;
                                 Const RequestType : TRequestType)    Of Object;
 TDWAuthRequest      = Procedure(Const Params      : TDWParams;
                                 Var   Rejected    : Boolean;
                                 Var   ResultError : String)          Of Object;
 TObjectEvent        = Procedure(aSelf             : TComponent)      Of Object;
 TObjectExecute      = Procedure(Const aSelf       : TCollectionItem) Of Object;
 TOnBeforeSend       = Procedure(aSelf             : TComponent)      Of Object;

Type
 TDWReplyEventData = Class(TComponent)
 Private
  vReplyEvent         : TDWReplyEvent;
  vDWReplyEventByType : TDWReplyEventByType;
  vDWAuthRequest      : TDWAuthRequest;
  vBeforeExecute      : TObjectExecute;
 Public
  Property    OnReplyEvent       : TDWReplyEvent       Read vReplyEvent         Write vReplyEvent;
  Property    OnReplyEventByType : TDWReplyEventByType Read vDWReplyEventByType Write vDWReplyEventByType;
  Property    OnAuthRequest      : TDWAuthRequest      Read vDWAuthRequest      Write vDWAuthRequest;
  Property    OnBeforeExecute    : TObjectExecute      Read vBeforeExecute      Write vBeforeExecute;
End;

Type
 TDWParamMethod = Class;
 TDWParamMethod = Class(TCollectionItem)
 Private
  vTypeObject      : TTypeObject;
  vObjectDirection : TObjectDirection;
  vObjectValue     : TObjectValue;
  vDefaultValue,
  vParamName       : String;
  vEncoded         : Boolean;
 Public
  Function    GetDisplayName             : String;       Override;
  Procedure   SetDisplayName(Const Value : String);      Override;
  Constructor Create        (aCollection : TCollection); Override;
  Destructor  Destroy;                                   Override;
 Published
  Property TypeObject      : TTypeObject      Read vTypeObject      Write vTypeObject;
  Property ObjectDirection : TObjectDirection Read vObjectDirection Write vObjectDirection;
  Property ObjectValue     : TObjectValue     Read vObjectValue     Write vObjectValue;
  Property ParamName       : String           Read GetDisplayName   Write SetDisplayName;
  Property Encoded         : Boolean          Read vEncoded         Write vEncoded;
  Property DefaultValue    : String           Read vDefaultValue    Write vDefaultValue;
End;

Type
 TDWParamsMethods = Class;
 TDWParamsMethods = Class(TOwnedCollection)
 Private
  fOwner      : TPersistent;
  Function    GetRec    (Index       : Integer) : TDWParamMethod;  Overload;
  Procedure   PutRec    (Index       : Integer;
                         Item        : TDWParamMethod);            Overload;
  Procedure   ClearList;
  Function    GetRecName(Index       : String)  : TDWParamMethod;  Overload;
  Procedure   PutRecName(Index       : String;
                         Item        : TDWParamMethod);            Overload;
 Public
  Constructor Create     (AOwner     : TPersistent;
                          aItemClass : TCollectionItemClass);
  Destructor  Destroy; Override;
  Procedure   Delete     (Index      : Integer);                   Overload;
  Function    Add        (Item       : TDWParamMethod) : Integer;  Overload;
  Property    Items      [Index      : Integer]   : TDWParamMethod Read GetRec     Write PutRec; Default;
  Property    ParamByName[Index      : String ]   : TDWParamMethod Read GetRecName Write PutRecName;
End;

Type
 TDWEvent = Class;
 TDWEvent = Class(TCollectionItem)
 Protected
 Private
  vDWRoutes                           : TDWRoutes;
  vJsonMode                           : TJsonMode;
  FName                               : String;
  vDWParams                           : TDWParamsMethods;
  vOwnerCollection                    : TCollection;
  DWReplyEventData                    : TDWReplyEventData;
  vBeforeExecute                      : TObjectExecute;
  Function  GetReplyEvent             : TDWReplyEvent;
  Procedure SetReplyEvent      (Value : TDWReplyEvent);
  Function  GetReplyEventByType       : TDWReplyEventByType;
  Procedure SetReplyEventByType(Value : TDWReplyEventByType);
  Function  GetAuthRequest            : TDWAuthRequest;
  Procedure SetAuthRequest     (Value : TDWAuthRequest);
 Public
  Function    GetDisplayName             : String;       Override;
  Procedure   SetDisplayName(Const Value : String);      Override;
  Procedure   Assign        (Source      : TPersistent); Override;
  Constructor Create        (aCollection : TCollection); Override;
  Function    GetNamePath  : String;                     Override;
  Destructor  Destroy; Override;
 Published
  Property    Routes             : TDWRoutes           Read vDWRoutes            Write vDWRoutes;
  Property    DWParams           : TDWParamsMethods    Read vDWParams            Write vDWParams;
  Property    JsonMode           : TJsonMode           Read vJsonMode            Write vJsonMode;
  Property    Name               : String              Read GetDisplayName       Write SetDisplayName;
  Property    OnReplyEvent       : TDWReplyEvent       Read GetReplyEvent        Write SetReplyEvent;
  Property    OnReplyEventByType : TDWReplyEventByType Read GetReplyEventByType  Write SetReplyEventByType;
  Property    OnAuthRequest      : TDWAuthRequest      Read GetAuthRequest       Write SetAuthRequest;
  Property    OnBeforeExecute    : TObjectExecute      Read vBeforeExecute       Write vBeforeExecute;
End;

Type
 TDWEventList = Class;
 TDWEventList = Class(TDWOwnedCollection)
 Protected
  vEditable   : Boolean;
  Function    GetOwner: TPersistent; override;
 Private
  fOwner      : TPersistent;
  Function    GetRec    (Index       : Integer) : TDWEvent;       Overload;
  Procedure   PutRec    (Index       : Integer;
                         Item        : TDWEvent);                 Overload;
  Procedure   ClearList;
  Function    GetRecName(Index       : String)  : TDWEvent;       Overload;
  Procedure   PutRecName(Index       : String;
                         Item        : TDWEvent);                 Overload;
//  Procedure   Editable  (Value : Boolean);
 Public
  Function    Add    : TCollectionItem;
  Constructor Create     (AOwner     : TPersistent;
                          aItemClass : TCollectionItemClass);
  Destructor  Destroy; Override;
  Function    ToJSON : String;
  Procedure   FromJSON   (Value      : String );
  Procedure   Delete     (Index      : Integer);                  Overload;
  Property    Items      [Index      : Integer]  : TDWEvent       Read GetRec     Write PutRec; Default;
  Property    EventByName[Index      : String ]  : TDWEvent       Read GetRecName Write PutRecName;
End;

Type
 TDWServerEvents = Class(TDWComponent)
 Protected
 Private
  vIgnoreInvalidParams : Boolean;
  vEventList           : TDWEventList;
  vAccessTag,
  vServerContext       : String;
  vOnCreate            : TObjectEvent;
 Public
  Destructor  Destroy; Override;
  Constructor Create(AOwner : TComponent);Override; //Cria o Componente
  Procedure   CreateDWParams(EventName    : String;
                             Var DWParams : TDWParams);
 Published
  Property    IgnoreInvalidParams : Boolean      Read vIgnoreInvalidParams Write vIgnoreInvalidParams;
  Property    Events              : TDWEventList Read vEventList           Write vEventList;
  Property    AccessTag           : String       Read vAccessTag           Write vAccessTag;
  Property    ContextName         : String       Read vServerContext       Write vServerContext;
  Property    OnCreate            : TObjectEvent Read vOnCreate            Write vOnCreate;
End;

Type
 { TDWClientEvents }
 TDWClientEvents = Class(TDWComponent)
 Protected
 Private
  vServerEventName  : String;
  vEditParamList,
  vGetEvents        : Boolean;
  vEventList        : TDWEventList;
  vRESTClientPooler : TRESTClientPooler;
  vOnBeforeSend     : TOnBeforeSend;
  Procedure GetOnlineEvents(Value  : Boolean);
  Procedure SetEventList   (aValue : TDWEventList);
//  Procedure SetEditParamList(Value : Boolean);
 Public
  Destructor  Destroy; Override;
  Constructor Create        (AOwner    : TComponent);Override; //Cria o Componente
  Procedure   CreateDWParams(EventName : String; Var DWParams     : TDWParams);
  Function    SendEvent     (EventName : String; Var DWParams     : TDWParams;
                             Var Error : String) : Boolean; Overload;
  Function    SendEvent     (EventName : String; Var DWParams     : TDWParams;
                             Var Error : String; Var NativeResult : String) : Boolean; Overload;
  Procedure   ClearEvents;
  Property    GetEvents        : Boolean           Read vGetEvents        Write GetOnlineEvents;
 Published
  Property    ServerEventName  : String            Read vServerEventName  Write vServerEventName;
  Property    RESTClientPooler : TRESTClientPooler Read vRESTClientPooler Write vRESTClientPooler;
  Property    Events           : TDWEventList      Read vEventList        Write SetEventList;
  Property    OnBeforeSend     : TOnBeforeSend     Read vOnBeforeSend     Write vOnBeforeSend; // Add Evento por Ico Menezes
End;

implementation

{ TDWEvent }

Function TDWEvent.GetNamePath: String;
Begin
 Result := vOwnerCollection.GetNamePath + FName;
End;

constructor TDWEvent.Create(aCollection: TCollection);
begin
  inherited;
  vDWParams             := TDWParamsMethods.Create(aCollection, TDWParamMethod);
  vJsonMode             := jmDataware;
  DWReplyEventData      := TDWReplyEventData.Create(Nil);
  vOwnerCollection      := aCollection;
  FName                 := 'dwevent' + IntToStr(aCollection.Count);
  DWReplyEventData.Name := FName;
  vDWRoutes             := [crAll];
end;

destructor TDWEvent.Destroy;
begin
  vDWParams.Free;
  DWReplyEventData.Free;
  inherited;
end;

Function TDWEvent.GetAuthRequest: TDWAuthRequest;
Begin
 Result := DWReplyEventData.OnAuthRequest;
End;

Function TDWEvent.GetDisplayName: String;
Begin
 Result := DWReplyEventData.Name;
End;

Procedure TDWEvent.Assign(Source: TPersistent);
begin
 If Source is TDWEvent then
  Begin
   FName       := TDWEvent(Source).Name;
   vDWParams   := TDWEvent(Source).DWParams;
   DWReplyEventData.OnBeforeExecute := TDWEvent(Source).OnBeforeExecute;
   DWReplyEventData.OnReplyEvent := TDWEvent(Source).OnReplyEvent;
  End
 Else
  Inherited;
End;

Function TDWEvent.GetReplyEvent: TDWReplyEvent;
Begin
 Result := DWReplyEventData.OnReplyEvent;
End;

Function TDWEvent.GetReplyEventByType : TDWReplyEventByType;
Begin
 Result := DWReplyEventData.OnReplyEventByType;
End;

Procedure TDWEvent.SetAuthRequest(Value : TDWAuthRequest);
Begin
 DWReplyEventData.OnAuthRequest := Value;
End;

Procedure TDWEvent.SetDisplayName(Const Value: String);
Begin
 If Trim(Value) = '' Then
  Raise Exception.Create('Invalid Event Name')
 Else
  Begin
   FName := Value;
   DWReplyEventData.Name := FName;
   Inherited;
  End;
End;

procedure TDWEvent.SetReplyEvent(Value: TDWReplyEvent);
begin
 DWReplyEventData.OnReplyEvent := Value;
end;

Procedure TDWEvent.SetReplyEventByType(Value: TDWReplyEventByType);
Begin
 DWReplyEventData.OnReplyEventByType := Value;
End;

Function TDWEventList.Add : TCollectionItem;
Begin
 Result := Nil;
 If vEditable Then
  Result := TDWEvent(Inherited Add);
End;

procedure TDWEventList.ClearList;
Var
 I : Integer;
 vOldEditable : Boolean;
Begin
 vOldEditable := vEditable;
 vEditable    := True;
 Try
  For I := Count - 1 Downto 0 Do
   Delete(I);
 Finally
  Self.Clear;
  vEditable := vOldEditable;
 End;
End;

Constructor TDWEventList.Create(AOwner     : TPersistent;
                                aItemClass : TCollectionItemClass);
Begin
 Inherited Create(AOwner, TDWEvent);
 Self.fOwner := AOwner;
 vEditable   := True;
End;

procedure TDWEventList.Delete(Index: Integer);
begin
 If (Index < Self.Count) And (Index > -1) And (vEditable) Then
  TOwnedCollection(Self).Delete(Index);
end;

destructor TDWEventList.Destroy;
begin
 ClearList;
 inherited;
end;

{
procedure TDWEventList.Editable(Value: Boolean);
begin
 vEditable := Value;
end;
}

{$IFDEF Defined(HAS_FMX)}
Procedure TDWEventList.FromJSON(Value : String);
Var
 bJsonOBJ,
 bJsonOBJb,
 bJsonOBJc    : system.json.TJsonObject;

 bJsonArray,
 bJsonArrayB,
 bJsonArrayC  : system.json.TJsonArray;

 I, X, Y      : Integer;
 vDWEvent     : TDWEvent;
 vDWParamMethod : TDWParamMethod;
Begin
 Try
  bJsonArray  := TJSONObject.ParseJSONValue(Value) as TJSONArray;
  For I := 0 to bJsonArray.count -1 Do
   Begin
    bJsonOBJ := bJsonArray.get(I) as TJsonobject;
    Try
     bJsonArrayB := bJsonOBJ.getvalue('serverevents') as Tjsonarray;
     For X := 0 To bJsonArrayB.count -1 Do
      Begin
       bJsonOBJb := bJsonArrayB.get(X) as TJsonObject;
       If EventByName[bJsonOBJb.getvalue('eventname').value] = Nil Then
        vDWEvent  := TDWEvent(Self.Add)
       Else
        vDWEvent  := EventByName[bJsonOBJb.getvalue('eventname').value];
       vDWEvent.Name := bJsonOBJb.getvalue('eventname').value;
       If bJsonOBJb.getvalue('params').ToString <> '' Then
        Begin
         bJsonArrayC    := bJsonOBJb.getvalue('params') as Tjsonarray;
         Try
          For Y := 0 To bJsonArrayC.count -1 do
           Begin
            bJsonOBJc                      := bJsonArrayC.get(Y) as TJsonobject;
            If vDWEvent.vDWParams.ParamByName[bJsonOBJc.getvalue('paramname').value] = Nil Then
             vDWParamMethod                := TDWParamMethod(vDWEvent.vDWParams.Add)
            Else
             vDWParamMethod                := vDWEvent.vDWParams.ParamByName[bJsonOBJc.getvalue('paramname').value];
            vDWParamMethod.TypeObject      := GetObjectName(bJsonOBJc.getvalue('typeobject').value);
            vDWParamMethod.ObjectDirection := GetDirectionName(bJsonOBJc.getvalue('objectdirection').value);
            vDWParamMethod.ObjectValue     := GetValueType(bJsonOBJc.getvalue('objectvalue').value);
            vDWParamMethod.ParamName       := bJsonOBJc.getvalue('paramname').value;
            vDWParamMethod.Encoded         := StringToBoolean(bJsonOBJc.getvalue('encoded').value);
            If Trim(bJsonOBJc.getvalue('default').value) <> '' Then
             vDWParamMethod.DefaultValue   := DecodeStrings(bJsonOBJc.getvalue('default').value{$IFDEF FPC}, csUndefined{$ENDIF});
           End;
         Finally
          bJsonArrayC.Free;
         End;
        End
       Else
        vDWEvent.vDWParams.ClearList;
      End;
    Finally
     bJsonArrayB.Free;
    End;
   End;
 Finally
  bJsonArray.Free;
 End;
End;
{$ELSE}
Procedure TDWEventList.FromJSON(Value : String);
Var
 bJsonOBJ,
 bJsonOBJb,
 bJsonOBJc    : {$IFDEF Defined(HAS_FMX)}system.json.TJsonObject;
                {$ELSE}       udwjson.TJsonObject;{$ENDIF}
 bJsonArray,
 bJsonArrayB,
 bJsonArrayC  : {$IFDEF Defined(HAS_FMX)}system.json.TJsonArray;
                {$ELSE}       udwjson.TJsonArray;{$ENDIF}
 I, X, Y      : Integer;
 vDWEvent     : TDWEvent;
 vDWParamMethod : TDWParamMethod;
Begin
 Try
  bJsonArray  := Tjsonarray.Create(Value);
  For I := 0 to bJsonArray.length -1 Do
   Begin
    bJsonOBJ := bJsonArray.getJSONObject(I);
    Try
     bJsonArrayB := Tjsonarray.Create(bJsonOBJ.get('serverevents').tostring);
     For X := 0 To bJsonArrayB.length -1 Do
      Begin
       bJsonOBJb := bJsonArrayB.getJSONObject(X);
       If EventByName[bJsonOBJb.get('eventname').tostring] = Nil Then
        vDWEvent  := TDWEvent(Self.Add)
       Else
        vDWEvent  := EventByName[bJsonOBJb.get('eventname').tostring];
       vDWEvent.Name := bJsonOBJb.get('eventname').tostring;
       vDWEvent.JsonMode := GetJSONModeName(bJsonOBJb.get('jsonmode').tostring);
       If bJsonOBJb.get('params').toString <> '' Then
        Begin
         bJsonArrayC    := Tjsonarray.Create(bJsonOBJb.get('params').toString);
         Try
          For Y := 0 To bJsonArrayC.length -1 do
           Begin
            bJsonOBJc                      := bJsonArrayC.getJSONObject(Y);
            If vDWEvent.vDWParams.ParamByName[bJsonOBJc.get('paramname').toString] = Nil Then
             vDWParamMethod                := TDWParamMethod(vDWEvent.vDWParams.Add)
            Else
             vDWParamMethod                := vDWEvent.vDWParams.ParamByName[bJsonOBJc.get('paramname').toString];
            vDWParamMethod.TypeObject      := GetObjectName(bJsonOBJc.get('typeobject').toString);
            vDWParamMethod.ObjectDirection := GetDirectionName(bJsonOBJc.get('objectdirection').toString);
            vDWParamMethod.ObjectValue     := GetValueType(bJsonOBJc.get('objectvalue').toString);
            vDWParamMethod.ParamName       := bJsonOBJc.get('paramname').toString;
            vDWParamMethod.Encoded         := StringToBoolean(bJsonOBJc.get('encoded').toString);
            If Trim(bJsonOBJc.get('default').toString) <> '' Then
             vDWParamMethod.DefaultValue   := DecodeStrings(bJsonOBJc.get('default').toString{$IFDEF FPC}, csUndefined{$ENDIF});
           End;
         Finally
          bJsonArrayC.Free;
         End;
        End
       Else
        vDWEvent.vDWParams.ClearList;
      End;
    Finally
     bJsonArrayB.Free;
    End;
   End;
 Finally
  bJsonArray.Free;
 End;
End;
{$ENDIF}

Function TDWEventList.GetOwner: TPersistent;
Begin
 Result:= fOwner;
End;

function TDWEventList.GetRec(Index: Integer): TDWEvent;
begin
 Result := TDWEvent(Inherited GetItem(Index));
end;

function TDWEventList.GetRecName(Index: String): TDWEvent;
Var
 I : Integer;
Begin
 Result := Nil;
 For I := 0 To Self.Count - 1 Do
  Begin
   If (Uppercase(Index) = Uppercase(Self.Items[I].FName)) Then
    Begin
     Result := TDWEvent(Self.Items[I]);
     Break;
    End;
  End;
End;

procedure TDWEventList.PutRec(Index: Integer; Item: TDWEvent);
begin
 If (Index < Self.Count) And (Index > -1) And (vEditable) Then
  SetItem(Index, Item);
end;

procedure TDWEventList.PutRecName(Index: String; Item: TDWEvent);
Var
 I : Integer;
Begin
 If (vEditable) Then
  Begin
   For I := 0 To Self.Count - 1 Do
    Begin
     If (Uppercase(Index) = Uppercase(Self.Items[I].FName)) Then
      Begin
       Self.Items[I] := Item;
       Break;
      End;
    End;
  End;
End;

Function TDWEventList.ToJSON: String;
Var
 A, I : Integer;
 vTagEvent,
 vParamsLines,
 vParamLine,
 vEventsLines : String;
Begin
 Result := '';
 vEventsLines := '';
 For I := 0 To Count -1 Do
  Begin
   vTagEvent    := Format('{"eventname":"%s"', [Items[I].FName]);
   vTagEvent    := vTagEvent + Format(', "jsonmode":"%s"', [GetJSONModeName(Items[I].vJsonMode)]);
   vTagEvent    := vTagEvent + ', "params":[%s]}';
   vParamsLines := '';
   For A := 0 To Items[I].vDWParams.Count -1 Do
    Begin
     vParamLine := Format(TServerEventsConst,
                          [GetObjectName(Items[I].vDWParams[A].vTypeObject),
                           GetDirectionName(Items[I].vDWParams[A].vObjectDirection),
                           GetValueType(Items[I].vDWParams[A].vObjectValue),
                           Items[I].vDWParams[A].vParamName,
                           BooleanToString(Items[I].vDWParams[A].vEncoded),
                           EncodeStrings(Items[I].vDWParams[A].vDefaultValue{$IFDEF FPC}, csUndefined{$ENDIF})]);
     If vParamsLines = '' Then
      vParamsLines := vParamLine
     Else
      vParamsLines := vParamsLines + ', ' + vParamLine;
    End;
   If vEventsLines = '' Then
    vEventsLines := vEventsLines + Format(vTagEvent, [vParamsLines])
   Else
    vEventsLines := vEventsLines + Format(', ' + vTagEvent, [vParamsLines]);
  End;
 Result := Format('{"serverevents":[%s]}', [vEventsLines]);
End;

Procedure TDWServerEvents.CreateDWParams(EventName    : String;
                                         Var DWParams : TDWParams);
Var
 dwParam : TJSONParam;
 I       : Integer;
 vFound  : Boolean;
Begin
// DWParams := Nil;
 If vEventList.EventByName[EventName] <> Nil Then
  Begin
   If Not Assigned(DWParams) Then
    DWParams := TDWParams.Create;
   DWParams.JsonMode := vEventList.EventByName[EventName].JsonMode;
   For I := 0 To vEventList.EventByName[EventName].vDWParams.Count -1 Do
    Begin
     vFound  := DWParams.ItemsString[vEventList.EventByName[EventName].vDWParams.Items[I].ParamName] <> Nil;
     If Not(vFound) Then
      Begin
       dwParam                := TJSONParam.Create(DWParams.Encoding);
//     Else
//      dwParam                := DWParams.ItemsString[vEventList.EventByName[EventName].vDWParams.Items[I].ParamName];
       dwParam.ParamName       := vEventList.EventByName[EventName].vDWParams.Items[I].ParamName;
       dwParam.ObjectDirection := vEventList.EventByName[EventName].vDWParams.Items[I].ObjectDirection;
       dwParam.ObjectValue     := vEventList.EventByName[EventName].vDWParams.Items[I].ObjectValue;
       dwParam.Encoded         := vEventList.EventByName[EventName].vDWParams.Items[I].Encoded;
       dwParam.JsonMode        := DWParams.JsonMode;
       If (vEventList.EventByName[EventName].vDWParams.Items[I].DefaultValue <> '')  And
          (Trim(dwParam.AsString) = '') Then
        dwParam.Value           := vEventList.EventByName[EventName].vDWParams.Items[I].DefaultValue;
       DWParams.Add(dwParam);
      End;
    End;
  End
 Else
  DWParams := Nil;
End;

Constructor TDWServerEvents.Create(AOwner : TComponent);
Begin
 Inherited;
 vEventList := TDWEventList.Create(Self, TDWEvent);
 vIgnoreInvalidParams := False;
 If Assigned(vOnCreate) Then
  vOnCreate(Self);
End;

Destructor TDWServerEvents.Destroy;
Begin
 vEventList.Free;
 Inherited;
End;

procedure TDWParamsMethods.ClearList;
Var
 I : Integer;
Begin
 For I := Count - 1 Downto 0 Do
  Begin
   Delete(I);
  End;
 Self.Clear;
End;

constructor TDWParamsMethods.Create(AOwner     : TPersistent;
                                    aItemClass : TCollectionItemClass);
begin
 Inherited Create(AOwner, TDWParamMethod);
 Self.fOwner := AOwner;
end;

Function TDWParamsMethods.Add(Item : TDWParamMethod): Integer;
Var
 vItem : ^TDWParamMethod;
Begin
 New(vItem);
 vItem^ := Item;
 Result := TList(Self).Add(vItem);
End;

procedure TDWParamsMethods.Delete(Index: Integer);
begin
 If (Index < Self.Count) And (Index > -1) Then
  TOwnedCollection(Self).Delete(Index);
end;

destructor TDWParamsMethods.Destroy;
begin
 ClearList;
 Inherited;
end;

Function TDWParamsMethods.GetRec(Index: Integer): TDWParamMethod;
Begin
 Result := TDWParamMethod(inherited GetItem(Index));
End;

function TDWParamsMethods.GetRecName(Index: String): TDWParamMethod;
Var
 I : Integer;
Begin
 Result := Nil;
 For I := 0 To Self.Count - 1 Do
  Begin
   If (Uppercase(Index) = Uppercase(Self.Items[I].vParamName)) Then
    Begin
     Result := TDWParamMethod(Self.Items[I]);
     Break;
    End;
  End;
End;

procedure TDWParamsMethods.PutRec(Index: Integer; Item: TDWParamMethod);
begin
 If (Index < Self.Count) And (Index > -1) Then
  SetItem(Index, Item);
end;

procedure TDWParamsMethods.PutRecName(Index: String; Item: TDWParamMethod);
Var
 I : Integer;
Begin
 For I := 0 To Self.Count - 1 Do
  Begin
   If (Uppercase(Index) = Uppercase(Self.Items[I].vParamName)) Then
    Begin
     Self.Items[I] := Item;
     Break;
    End;
  End;
End;

Constructor TDWParamMethod.Create(aCollection: TCollection);
Begin
 Inherited;
 vTypeObject      := toParam;
 vObjectDirection := odINOUT;
 vObjectValue     := ovString;
 vParamName       := 'dwparam' + IntToStr(aCollection.Count);
 vEncoded         := True;
 vDefaultValue    := '';
End;

Destructor TDWParamMethod.Destroy;
Begin
 Inherited;
End;

function TDWParamMethod.GetDisplayName: String;
begin
 Result := vParamName;
end;

procedure TDWParamMethod.SetDisplayName(const Value: String);
begin
 If Trim(Value) = '' Then
  Raise Exception.Create('Invalid Param Name')
 Else
  Begin
   vParamName := Trim(Value);
   Inherited;
  End;
end;

{ TDWClientEvents }

constructor TDWClientEvents.Create(AOwner: TComponent);
begin
 Inherited;
 vEventList     := TDWEventList.Create(Self, TDWEvent);
 vGetEvents     := False;
 vEditParamList := True;
end;

procedure TDWClientEvents.CreateDWParams(EventName: String;
  Var DWParams: TDWParams);
Var
 dwParam : TJSONParam;
 I       : Integer;
 vFound  : Boolean;
Begin
 If vEventList.EventByName[EventName] <> Nil Then
  Begin
//   If (Not Assigned(DWParams)) or (dwParams = nil) Then
   DWParams := TDWParams.Create;
   DWParams.Encoding := vRESTClientPooler.Encoding;
   For I := 0 To vEventList.EventByName[EventName].vDWParams.Count -1 Do
    Begin
     vFound  := DWParams.ItemsString[vEventList.EventByName[EventName].vDWParams.Items[I].ParamName] <> Nil;
     If Not(vFound) Then
      dwParam                := TJSONParam.Create(DWParams.Encoding)
     Else
      dwParam                := DWParams.ItemsString[vEventList.EventByName[EventName].vDWParams.Items[I].ParamName];
     dwParam.ParamName       := vEventList.EventByName[EventName].vDWParams.Items[I].ParamName;
     dwParam.ObjectDirection := vEventList.EventByName[EventName].vDWParams.Items[I].ObjectDirection;
     dwParam.ObjectValue     := vEventList.EventByName[EventName].vDWParams.Items[I].ObjectValue;
     dwParam.Encoded         := vEventList.EventByName[EventName].vDWParams.Items[I].Encoded;
     dwParam.JsonMode        := jmDataware;
     If (vEventList.EventByName[EventName].vDWParams.Items[I].DefaultValue <> '') And
        (Trim(dwParam.AsString) = '') Then
      dwParam.Value           := vEventList.EventByName[EventName].vDWParams.Items[I].DefaultValue;
     If Not(vFound) Then
      DWParams.Add(dwParam);
    End;
  End
 Else
  DWParams := Nil;
End;

destructor TDWClientEvents.Destroy;
begin
 vEventList.Free;
 Inherited;
end;

procedure TDWClientEvents.GetOnlineEvents(Value: Boolean);
Var
 RESTClientPoolerExec : TRESTClientPooler;
 vResult,
 lResponse            : String;
 JSONParam            : TJSONParam;
 DWParams             : TDWParams;
Begin
 If Assigned(vRESTClientPooler) Then
  RESTClientPoolerExec := vRESTClientPooler
 Else
  Exit;
 DWParams                        := TDWParams.Create;
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'dwservereventname';
 JSONParam.ObjectDirection       := odIn;
 JSONParam.AsString              := vServerEventName;
 DWParams.Add(JSONParam);
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'Error';
 JSONParam.ObjectDirection       := odInOut;
 JSONParam.AsBoolean             := False;
 DWParams.Add(JSONParam);
 JSONParam                       := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'MessageError';
 JSONParam.ObjectDirection       := odInOut;
 JSONParam.AsString              := '';
 DWParams.Add(JSONParam);
 JSONParam                     := TJSONParam.Create(RESTClientPoolerExec.Encoding);
 JSONParam.ParamName             := 'Result';
 JSONParam.ObjectDirection       := odOut;
 JSONParam.AsString              := '';
 DWParams.Add(JSONParam);
 Try
  Try
   lResponse := RESTClientPoolerExec.SendEvent('GetEvents', DWParams);
   If (lResponse <> '') And
      (Uppercase(lResponse) <> Uppercase('HTTP/1.1 401 Unauthorized')) Then
    Begin
     If Not DWParams.ItemsString['error'].AsBoolean Then
      Begin
       vResult := DWParams.ItemsString['Result'].Value;
       If Trim(vResult) <> '' Then //Carreta o ParamList
        vEventList.FromJSON(Trim(vResult));
      End
     Else
      Raise Exception.Create(DWParams.ItemsString['MessageError'].AsString);
    End
   Else
    Begin
     If (lResponse = '') Then
      lResponse  := Format('Unresolved Host : ''%s''', [RESTClientPoolerExec.Host])
     Else If (Uppercase(lResponse) <> Uppercase('HTTP/1.1 401 Unauthorized')) Then
      lResponse  := Format('Unauthorized Username : ''%s''', [RESTClientPoolerExec.UserName]);
     Raise Exception.Create(lResponse);
     lResponse   := '';
    End;
  Except
   On E : Exception Do
    Begin
     Raise Exception.Create(E.Message);
    End;
  End;
 Finally
  If Not Assigned(RESTClientPooler) Then
   FreeAndNil(RESTClientPoolerExec);
  FreeAndNil(DWParams);
 End;
End;

{
procedure TDWClientEvents.SetEditParamList(Value: Boolean);
begin
 vEditParamList := Value;
 vEventList.Editable(vEditParamList);
end;
}

Function TDWClientEvents.SendEvent(EventName: String; Var DWParams: TDWParams;
                                   Var Error: String; Var NativeResult : String): Boolean;
Var
 vJsonMode : TJsonMode;
Begin
 Error := '';
 // Add por Ico Menezes
 If Assigned(vOnBeforeSend) Then
   vOnBeforeSend(Self);
 If vRESTClientPooler <> Nil Then
  Begin
   vJsonMode    := vEventList.EventByName[EventName].vJsonMode;
   Try
    NativeResult := vRESTClientPooler.SendEvent(EventName, DWParams, sePOST, vJsonMode, vServerEventName);
   Except
    On E : Exception Do
    Begin
     Error := E.Message;
    End;
   End;
  End;
End;

Function TDWClientEvents.SendEvent(EventName: String;
                                   Var DWParams: TDWParams;
                                   Var Error: String): Boolean;
Var
 vJsonMode : TJsonMode;
Begin
 // Add por Ico Menezes
 If Assigned(vOnBeforeSend) Then
   vOnBeforeSend(Self);
 If vRESTClientPooler <> Nil Then
  Begin
   vJsonMode    := vEventList.EventByName[EventName].vJsonMode;
   Error := vRESTClientPooler.SendEvent(EventName, DWParams, sePOST, vJsonMode, vServerEventName);
   If Error = TReplyOK Then
    Error := '';
  End;
End;

procedure TDWClientEvents.ClearEvents;
begin
 vEventList.ClearList;
end;

procedure TDWClientEvents.SetEventList(aValue : TDWEventList);
begin
 If vEditParamList Then
  vEventList := aValue;
end;

Initialization
 RegisterClass(TDWServerEvents);
 RegisterClass(TDWClientEvents);
end.
