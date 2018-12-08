unit SysTypes;

{$I uRESTDW.inc}

Interface

Uses
  IdURI, IdGlobal, SysUtils, Classes, ServerUtils, uRESTDWBase, uDWConsts,
  uDWJSONObject, uDWConstsData, uDWMassiveBuffer, uRESTDWServerEvents, uSystemEvents;

Type
 TReplyEvent     = Procedure(SendType           : TSendEvent;
                             Context            : String;
                             Var Params         : TDWParams;
                             Var Result         : String;
                             AccessTag          : String) Of Object;
 TMassiveProcess = Procedure(Var MassiveDataset : TMassiveDatasetBuffer; Var Ignore : Boolean) Of Object;
 TMassiveEvent   = Procedure(Var MassiveDataset : TMassiveDatasetBuffer) Of Object;

Type
  TServerUtils = Class
    Class Function ParseRESTURL(Const Cmd: String;vEncoding : TEncodeSelect; Var UrlMethod, urlContext, mark : String): TDWParams;
    Class Function Result2JSON(wsResult: TResultErro): String;
    Class Function ParseWebFormsParams(Params: TStrings; Const URL, Query  : String;
                                       Var UrlMethod, urlContext, mark     : String;
                                       vEncoding: TEncodeSelect;MethodType : String = 'POST') : TDWParams;
    Class Function ParseDWParamsURL(Const Cmd: String;vEncoding: TEncodeSelect; Var ResultPR : TDWParams) : Boolean;
  End;

Type
  TServerMethods = Class(TComponent)
  Protected
   vClientWelcomeMessage : String;
   vReplyEvent     : TReplyEvent;
   vWelcomeMessage : TWelcomeMessage;
   vMassiveProcess : TMassiveProcess;
   vOnMassiveBegin,
   vOnMassiveAfterStartTransaction,
   vOnMassiveAfterBeforeCommit,
   vOnMassiveAfterAfterCommit,
   vOnMassiveEnd                 : TMassiveEvent;
   Function ReturnIncorrectArgs  : String;
   Function ReturnMethodNotFound : String;
  Public
   Encoding: TEncodeSelect;
   Constructor Create(aOwner: TComponent); Override;
   Destructor Destroy; Override;
   Procedure  SetClientWelcomeMessage(Value: String);
  Published
   Property OnReplyEvent     : TReplyEvent      Read vReplyEvent     Write vReplyEvent;
   Property OnWelcomeMessage : TWelcomeMessage  Read vWelcomeMessage Write vWelcomeMessage;
   Property OnMassiveProcess : TMassiveProcess  Read vMassiveProcess Write vMassiveProcess;
   Property OnMassiveBegin                 : TMassiveEvent    Read vOnMassiveBegin                 Write vOnMassiveBegin;
   Property OnMassiveAfterStartTransaction : TMassiveEvent    Read vOnMassiveAfterStartTransaction Write vOnMassiveAfterStartTransaction;
   Property OnMassiveAfterBeforeCommit     : TMassiveEvent    Read vOnMassiveAfterBeforeCommit     Write vOnMassiveAfterBeforeCommit;
   Property OnMassiveAfterAfterCommit      : TMassiveEvent    Read vOnMassiveAfterAfterCommit      Write vOnMassiveAfterAfterCommit;
   Property OnMassiveEnd                   : TMassiveEvent    Read vOnMassiveEnd                   Write vOnMassiveEnd;
  End;

implementation


{$IFDEF FPC}
Function URLDecode(const s: String): String;
var
   sAnsi,
   sUtf8    : String;
   sWide    : WideString;
   i, len   : Cardinal;
   ESC      : String[2];
   CharCode : integer;
   c        : char;
begin
   sAnsi := PChar(s);
   SetLength(sUtf8, Length(sAnsi));
   i := 1;
   len := 1;
   while (i <= Cardinal(Length(sAnsi))) do begin
      if (sAnsi[i] <> '%') then begin
         if (sAnsi[i] = '+') then begin
            c := ' ';
         end else begin
            c := sAnsi[i];
         end;
         sUtf8[len] := c;
         Inc(len);
      end else begin
         Inc(i);
         ESC := Copy(sAnsi, i, 2);
         Inc(i, 1);
         try
            CharCode := StrToInt('$' + ESC);
            c := Char(CharCode);
            sUtf8[len] := c;
            Inc(len);
         except end;
      end;
      Inc(i);
   end;
   Dec(len);
   SetLength(sUtf8, len);
   sWide := UTF8Decode(sUtf8);
   len := Length(sWide);
   Result := sWide;
end;
{$ENDIF}

Class Function TServerUtils.ParseRESTURL(Const Cmd: String;vEncoding: TEncodeSelect; Var UrlMethod, urlContext, mark : String): TDWParams;
Var
 vTempData,
  NewCmd,
  vArrayValues: String;
  ArraySize,
  iBar1,
  IBar2, Cont : Integer;
  JSONParam   : TJSONParam;
  Function CountExpression(Value: String; Expression: Char): Integer;
  Var
    I: Integer;
  Begin
    Result := 0;
    For I := 0 To Length(Value) - 1 Do
    Begin
      If Value[I] = Expression Then
        Inc(Result);
    End;
  End;
Begin
 Result       := Nil;
 JSONParam    := Nil;
 vArrayValues := '';
 If Pos('?', Cmd) > 0 Then
  Begin
   vArrayValues := Copy(Cmd, Pos('?', Cmd) + 1, Length(Cmd));
   NewCmd       := Copy(Cmd, InitStrPos, Pos('?', Cmd) - 1);
  End
 Else
  NewCmd     := Cmd;
 urlContext := '';
 UrlMethod  := '';
 If (CountExpression(NewCmd, '/') > 0) Then
  Begin
   ArraySize := CountExpression(NewCmd, '/');
   Result := TDWParams.Create;
   Result.Encoding := vEncoding;
   NewCmd := NewCmd + '/';
   iBar1 := Pos('/', NewCmd);
   Delete(NewCmd, 1, iBar1);
   For Cont := 0 to ArraySize - 1 Do
    Begin
     IBar2     := Pos('/', NewCmd);
     vTempData := TIdURI.URLDecode(Copy(NewCmd, 1, IBar2 - 1), GetEncodingID(vEncoding));
     If (Cont = ArraySize -1) or ((UrlMethod = '') and (Cont = ArraySize -1)) Then
      UrlMethod := Copy(NewCmd, 1, IBar2 - 1);
     If ((Cont = ArraySize -2) And (ArraySize > 1)) Or (UrlMethod = '') Then
      urlContext := vTempData;
     Delete(NewCmd, InitStrPos, IBar2 - FinalStrPos);
    End;
   ArraySize := CountExpression(vArrayValues, '&');
   If ArraySize = 0 Then
    Begin
     If Length(vArrayValues) > 0 Then
      ArraySize := 1;
    End
   Else
    ArraySize := ArraySize + 1;
   For Cont := 0 to ArraySize - 1 Do
    Begin
     IBar2     := Pos('&', vArrayValues);
     If IBar2 = 0 Then
      Begin
       IBar2    := Length(vArrayValues);
       vTempData := Copy(vArrayValues, InitStrPos, IBar2);
      End
     Else
      vTempData := Copy(vArrayValues, InitStrPos, IBar2 - 1);
      If Pos('dwmark:', vTempData) > 0 Then
       mark := Copy(vTempData, Pos('dwmark:', vTempData) + 7, Length(vTempData))
      Else
       Begin
        JSONParam := TJSONParam.Create(Result.Encoding);
        If Pos('=', vTempData) > 0 Then
         Begin
          JSONParam.ParamName := Copy(vTempData, InitStrPos, Pos('=', vTempData) - 1);
          Delete(vTempData, InitStrPos, Pos('=', vTempData));
          {$IFDEF FPC}
           vTempData          := URLDecode(vTempData);
          {$ELSE}
           vTempData          := TIdURI.URLDecode(vTempData, GetEncodingID(vEncoding));
          {$ENDIF}
          JSONParam.SetValue(vTempData);
         End
        Else
         Begin
          JSONParam.ParamName := Format('PARAM%d', [0]);
          JSONParam.SetValue(vTempData);
         End;
        Result.Add(JSONParam);
       End;
     Delete(vArrayValues, InitStrPos, IBar2 - FinalStrPos);
    End;
  End;
 //Alexandre Magno - 07/11/2017
// If Assigned(JSONParam) Then
//  FreeAndNil(JSONParam);
End;

Class Function TServerUtils.ParseDWParamsURL(Const Cmd: String;vEncoding: TEncodeSelect; Var ResultPR : TDWParams) : Boolean;
Var
 vTempData,
 vArrayValues: String;
 ArraySize,
 IBar2, Cont : Integer;
 JSONParam   : TJSONParam;
 vParamList  : TStringList;
 Function CountExpression(Value: String; Expression: Char): Integer;
 Var
  I : Integer;
 Begin
  Result := 0;
  For I := 0 To Length(Value) - 1 Do
   Begin
    If Value[I] = Expression Then
     Inc(Result);
   End;
 End;
Begin
 vArrayValues := Cmd;
 vParamList      := TStringList.Create;
 vParamList.Text := vArrayValues;
 If vParamList.Count <= 1 Then
  Begin
   Result := Pos('=', vArrayValues) > 0;
   If Result Then
    Begin
     If Not Assigned(ResultPR) Then
      Begin
       ResultPR := TDWParams.Create;
       ResultPR.Encoding := vEncoding;
      End;
     JSONParam  := Nil;
     ArraySize := CountExpression(vArrayValues, '&');
     If ArraySize = 0 Then
      Begin
       If Length(vArrayValues) > 0 Then
        ArraySize := 1;
      End
     Else
      ArraySize := ArraySize + 1;
     For Cont := 0 to ArraySize - 1 Do
      Begin
       IBar2     := Pos('&', vArrayValues);
       If IBar2 = 0 Then
        Begin
         IBar2    := Length(vArrayValues);
         vTempData := Copy(vArrayValues, 1, IBar2);
        End
       Else
        vTempData := Copy(vArrayValues, 1, IBar2 - 1);
       JSONParam := TJSONParam.Create(ResultPR.Encoding);
       If Pos('=', vTempData) > InitStrPos Then
        Begin
         JSONParam.ParamName := Copy(vTempData, InitStrPos, Pos('=', vTempData) - 1);
         Delete(vTempData, InitStrPos, Pos('=', vTempData));
         JSONParam.SetValue(TIdURI.URLDecode(StringReplace(vTempData, '+', ' ', [rfReplaceAll]), GetEncodingID(ResultPR.Encoding)));
        End
       Else
        Begin
         JSONParam.ParamName := Format('PARAM%d', [0]);
         JSONParam.SetValue(TIdURI.URLDecode(StringReplace(vTempData, '+', ' ', [rfReplaceAll]), GetEncodingID(ResultPR.Encoding)));
        End;
       ResultPR.Add(JSONParam);
       Delete(vArrayValues, InitStrPos, IBar2 - FinalStrPos);
      End;
    End;
  End
 Else
  Begin
   Result   := True;
   For Cont := 0 to vParamList.Count - 1 Do
    Begin
     JSONParam := TJSONParam.Create(ResultPR.Encoding);
     JSONParam.ParamName := vParamList.Names[cont];
     JSONParam.SetValue(vParamList.Values[vParamList.Names[cont]]);
     ResultPR.Add(JSONParam);
    End;
  End;
 vParamList.Free;
End;

Class Function TServerUtils.ParseWebFormsParams(Params: TStrings;
  const URL, Query: String; Var UrlMethod, urlContext, mark: String;vEncoding: TEncodeSelect;
  MethodType : String = 'POST'): TDWParams;
Var
  I: Integer;
  vTempValue,
  Cmd: String;
  JSONParam: TJSONParam;
  vParams : TStringList;
  Uri : TIdURI;
Begin
  // Extrai nome do ServerMethod
 Result := TDWParams.Create;
 Result.Encoding := vEncoding;
  If Pos('?', URL) > 0 Then
   Begin
    Cmd := URL;
    I := Pos('?', Cmd);
    UrlMethod := StringReplace(Copy(Cmd, 1, I - 1), '/', '', [rfReplaceAll]);
    Delete(Cmd, 1, I);
//    I := Pos('?', Cmd);
   End
  Else
   Begin
    Cmd := URL + '/';
    I := Pos('/', Cmd);
    Delete(Cmd, 1, I);
    UrlMethod := '';
    urlContext := '';
    While Pos('/', Cmd) > 0 Do
     Begin
      I := Pos('/', Cmd);
      If (urlContext = '') Or
         ((urlContext <> '') And (UrlMethod <> '')) Then
       Begin
        urlContext := UrlMethod;
        UrlMethod  := Copy(Cmd, 1, I - 1);
       End
      Else If UrlMethod = '' Then
       UrlMethod := Copy(Cmd, 1, I - 1);
      Delete(Cmd, 1, I);
     End;
    If UrlMethod = '' Then
     Begin
      UrlMethod  := urlContext;
      urlContext := '';
     End;
   End;
  // Extrai Parametros
  If (Params.Count > 0) And (MethodType = 'POST') Then
   Begin
    For I := 0 To Params.Count - 1 Do
     Begin
      If Pos('dwmark:', Params[I]) > 0 Then
       mark := Copy(Params[I], Pos('dwmark:', Params[I]) + 7, Length(Params[I]))
      Else
       Begin
        JSONParam := TJSONParam.Create(Result.Encoding);
        JSONParam.ObjectDirection := odIN;
        If Pos('{"ObjectType":"toParam", "Direction":"', Params[I]) > 0 Then
         Begin
          If Pos('=', Params[I]) > 0 Then
           JSONParam.FromJSON(Trim(Copy(Params[I], Pos('=', Params[I]) + 1, Length(Params[I]))))
          Else
           JSONParam.FromJSON(Params[I]);
         End
        Else
         Begin
          JSONParam.ParamName := Copy(Params[I], 1, Pos('=', Params[I]) - 1);
          JSONParam.AsString  := Trim(Copy(Params[I], Pos('=', Params[I]) + 1, Length(Params[I])));
          If JSONParam.AsString = '' Then
           Begin
  //          JSONParam.ObjectDirection := odOut; //Observar
            JSONParam.Encoded         := False;
           End;
         End;
        Result.Add(JSONParam);
       End;
     End;
   End
  Else
   Begin
    vParams := TStringList.Create;
    vParams.Delimiter := '&';
    {$IFNDEF FPC}{$if CompilerVersion > 21}vParams.StrictDelimiter := true;{$IFEND}{$ENDIF}
    If pos(UrlMethod + '/', Cmd) > 0 Then
     Cmd := StringReplace(UrlMethod + '/', Cmd, '', [rfReplaceAll]);
    If (Params.Count > 0) And (Pos('?', URL) = 0) then
     Cmd := Cmd + Params.Text
    Else
     Cmd := Cmd + Query;
    Uri := TIdURI.Create(Cmd);
    Try
     vParams.DelimitedText := Uri.Params;
     If vParams.count = 0 Then
      If Trim(Cmd) <> '' Then
       vParams.DelimitedText := StringReplace(Cmd, #13#10, '&', [rfReplaceAll]); //Alterações enviadas por "joaoantonio19"
       //vParams.Add(Cmd);
    Finally
     Uri.Free;
     For I := 0 To vParams.Count - 1 Do
      Begin
       If Pos('dwmark:', vParams[I]) > 0 Then
        mark := Copy(vParams[I], Pos('dwmark:', vParams[I]) + 7, Length(vParams[I]))
       Else
        Begin
         JSONParam                 := TJSONParam.Create(Result.Encoding);
         JSONParam.ParamName       := Trim(Copy(vParams[I], 1, Pos('=', vParams[I]) - 1));
         JSONParam.AsString        := Trim(Copy(vParams[I],    Pos('=', vParams[I]) + 1, Length(vParams[I])));
         JSONParam.ObjectDirection := odIN;
         Result.Add(JSONParam);
        End;
      End;
     vParams.Free;
    End;
   End;
End;

Class Function TServerUtils.Result2JSON(wsResult: TResultErro): String;
Begin
  Result := '{"STATUS":"' + wsResult.Status + '","MENSSAGE":"' +
    wsResult.MessageText + '"}';
End;

constructor TServerMethods.Create(aOwner: TComponent);
begin
  inherited;
end;

destructor TServerMethods.Destroy;
begin
  inherited;
end;

Function TServerMethods.ReturnIncorrectArgs: String;
Var
  wsResult: TResultErro;
Begin
  wsResult.Status := '-1';
  wsResult.MessageText := 'Total de argumentos menor que o esperado';
  Result := TServerUtils.Result2JSON(wsResult);
End;

Function TServerMethods.ReturnMethodNotFound: String;
Var
  wsResult: TResultErro;
Begin
  wsResult.Status := '-2';
  wsResult.MessageText := 'Metodo nao encontrado';
  Result := TServerUtils.Result2JSON(wsResult);
End;

procedure TServerMethods.SetClientWelcomeMessage(Value: String);
begin
 vClientWelcomeMessage := Value;
end;

end.

