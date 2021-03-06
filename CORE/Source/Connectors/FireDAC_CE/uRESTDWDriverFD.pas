unit uRestDWDriverFD;

interface

uses System.SysUtils,          System.Classes,          Data.DBXJSON,
     FireDAC.Stan.Intf,        FireDAC.Stan.Option,     FireDAC.Stan.Param,
     FireDAC.Stan.Error,       FireDAC.DatS,            FireDAC.Stan.Async,
     FireDAC.DApt,             FireDAC.UI.Intf,         FireDAC.Stan.Def,
     FireDAC.Stan.Pool,        FireDAC.Comp.Client,     FireDAC.Comp.UI,
     FireDAC.Comp.DataSet,     FireDAC.DApt.Intf,       Data.DB,
     uDWConsts, uDWConstsData, uRestDWPoolerDB,         udwjson,
     uDWJSONInterface,         uDWJSONObject,           uDWMassiveBuffer,
     Variants,                 uDWDatamodule,           SysTypes, uSystemEvents;

Type
 TRESTDWDriverFD   = Class(TRESTDWDriver)
 Private
  vFDConnectionBack,
  vFDConnection                 : TFDConnection;
  Procedure SetConnection(Value : TFDConnection);
  Function  GetConnection       : TFDConnection;
 Public
  Function ApplyUpdates         (Massive,
                                 SQL              : String;
                                 Params           : TDWParams;
                                 Var Error        : Boolean;
                                 Var MessageError : String)          : TJSONValue;Override;
  Procedure ApplyUpdates_MassiveCache(MassiveCache : String;
                                      Var Error    : Boolean;
                                      Var MessageError  : String);Override;
  Function ExecuteCommand       (SQL              : String;
                                 Var Error        : Boolean;
                                 Var MessageError : String;
                                 Execute          : Boolean = False) : String;Overload;Override;
  Function ExecuteCommand       (SQL              : String;
                                 Params           : TDWParams;
                                 Var Error        : Boolean;
                                 Var MessageError : String;
                                 Execute          : Boolean = False) : String;Overload;Override;
  Function InsertMySQLReturnID  (SQL              : String;
                                 Var Error        : Boolean;
                                 Var MessageError : String) : Integer;Overload;Override;
  Function InsertMySQLReturnID  (SQL              : String;
                                 Params           : TDWParams;
                                 Var Error        : Boolean;
                                 Var MessageError : String) : Integer;Overload;Override;
  Procedure ExecuteProcedure    (ProcName         : String;
                                 Params           : TDWParams;
                                 Var Error        : Boolean;
                                 Var MessageError : String);Override;
  Procedure ExecuteProcedurePure(ProcName         : String;
                                 Var Error        : Boolean;
                                 Var MessageError : String);Override;
  Function  OpenDatasets        (DatasetsLine     : String;
                                 Var Error        : Boolean;
                                 Var MessageError : String) : TJSONValue;Override;
  Procedure Close;Override;
  Class Procedure CreateConnection(Const ConnectionDefs : TConnectionDefs;
                                   Var   Connection     : TObject);        Override;
  Procedure PrepareConnection     (Var   ConnectionDefs : TConnectionDefs);Override;
 Published
  Property Connection : TFDConnection Read GetConnection Write SetConnection;
End;



Procedure Register;

implementation

Uses uDWJSONTools;


Procedure Register;
Begin
 RegisterComponents('REST Dataware - CORE - Drivers', [TRESTDWDriverFD]);
End;

Procedure TRESTDWDriverFD.ApplyUpdates_MassiveCache(MassiveCache     : String;
                                                    Var Error        : Boolean;
                                                    Var MessageError : String);
Var
 vTempQuery     : TFDQuery;
 vStringStream  : TMemoryStream;
 bPrimaryKeys   : TStringList;
 vFieldType     : TFieldType;
 vMassiveLine   : Boolean;
 Function GetParamIndex(Params : TFDParams; ParamName : String) : Integer;
 Var
  I : Integer;
 Begin
  Result := -1;
  For I := 0 To Params.Count -1 Do
   Begin
    If UpperCase(Params[I].Name) = UpperCase(ParamName) Then
     Begin
      Result := I;
      Break;
     End;
   End;
 End;
 Function LoadMassive(Massive : String; Var Query : TFDQuery) : Boolean;
 Var
  MassiveDataset : TMassiveDatasetBuffer;
  A, X           : Integer;
  bJsonArray     : udwjson.TJsonArray;
  Procedure PrepareData(Var Query      : TFDQuery;
                        MassiveDataset : TMassiveDatasetBuffer;
                        Var vError     : Boolean;
                        Var ErrorMSG   : String);
  Var
   vLineSQL,
   vFields,
   vParamsSQL : String;
   I          : Integer;
   Procedure SetUpdateBuffer;
   Var
    X : Integer;
   Begin
    If I = 0 Then
     Begin
      bPrimaryKeys := MassiveDataset.PrimaryKeys;
      Try
       For X := 0 To bPrimaryKeys.Count -1 Do
        Begin
         If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [{$IFNDEF FPC}{$if CompilerVersion > 21} // Delphi 2010 pra baixo
                                                                       ftFixedChar, ftFixedWideChar,{$IFEND}{$ENDIF}
                                                                       ftString,    ftWideString]    Then
          Begin
           If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).Size > 0 Then
            Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).Value := Copy(MassiveDataset.AtualRec.PrimaryValues[X].Value, 1, Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).Size)
           Else
            Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).Value := MassiveDataset.AtualRec.PrimaryValues[X].Value;
          End
         Else
          Begin
           If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [ftUnknown] Then
            Begin
             If Not (ObjectValueToFieldType(MassiveDataset.Fields.FieldByName(bPrimaryKeys[X]).FieldType) in [ftUnknown]) Then
              Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType := ObjectValueToFieldType(MassiveDataset.Fields.FieldByName(bPrimaryKeys[X]).FieldType)
             Else
              Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType := ftString;
            End;
           If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [ftInteger, ftSmallInt, ftWord, ftLongWord, ftLargeint] Then
            Begin
             If Trim(MassiveDataset.AtualRec.PrimaryValues[X].Value) <> '' Then
              Begin
                // Alterado por: Alexandre Magno - 04/11/2017
                If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [ftLongWord, ftLargeint] Then
                  Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).AsLargeInt := StrToInt64(MassiveDataset.AtualRec.PrimaryValues[X].Value)
                else If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType = ftSmallInt Then
                  Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).AsSmallInt := StrToInt(MassiveDataset.AtualRec.PrimaryValues[X].Value)
                Else
                  Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).AsInteger  := StrToInt(MassiveDataset.AtualRec.PrimaryValues[X].Value);

                // Como estava Anteriormente
                //If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType = ftSmallInt Then
                //  Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).AsSmallInt := StrToInt(MassiveDataset.AtualRec.PrimaryValues[X].Value)
                //Else
                //  Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).AsInteger  := StrToInt(MassiveDataset.AtualRec.PrimaryValues[X].Value);
              End;
            End
           Else If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [ftFloat,   ftCurrency, ftSingle, ftBCD, ftFMTBcd] Then
            Begin
             If Trim(MassiveDataset.AtualRec.PrimaryValues[X].Value) <> '' Then
              Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).AsFloat  := StrToFloat(BuildFloatString(MassiveDataset.AtualRec.PrimaryValues[X].Value));
            End
           Else If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] Then
            Begin
             If Trim(MassiveDataset.AtualRec.PrimaryValues[X].Value) <> '' Then
              Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).AsDateTime  := UnixToDateTime(StrToInt64(MassiveDataset.AtualRec.PrimaryValues[X].Value))
             Else
              Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).AsDateTime  := Null;
            End  //Tratar Blobs de Parametros...
           Else If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [ftBytes, ftVarBytes, ftBlob,
                                                                              ftGraphic, ftOraBlob, ftOraClob,
                                                                              ftMemo {$IFNDEF FPC}
                                                                                       {$IF CompilerVersion > 21}
                                                                                       , ftWideMemo
                                                                                       {$IFEND}
                                                                                      {$ENDIF}] Then
            Begin
             vStringStream := TMemoryStream.Create;
             Try
              MassiveDataset.AtualRec.PrimaryValues[X].SaveToStream(vStringStream);
              vStringStream.Position := 0;
              If vStringStream.Size > 0 Then
               Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).LoadFromStream(vStringStream, ftBlob);
             Finally
              FreeAndNil(vStringStream);
             End;
            End
           Else
            Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).Value := MassiveDataset.AtualRec.PrimaryValues[X].Value;
          End;
        End;
       Finally
        FreeAndNil(bPrimaryKeys);
       End;
      End;
    If Query.Params[I].DataType in [{$IFNDEF FPC}{$if CompilerVersion > 21} // Delphi 2010 pra baixo
                          ftFixedChar, ftFixedWideChar,{$IFEND}{$ENDIF}
                          ftString,    ftWideString]    Then
     Begin
      If Query.Params[I].Size > 0 Then
       Query.Params[I].Value := Copy(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value, 1, Query.Params[I].Size)
      Else
       Query.Params[I].Value := MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value;
     End
    Else
     Begin
      If Query.Params[I].DataType in [ftUnknown] Then
       Begin
        If Not (ObjectValueToFieldType(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).FieldType) in [ftUnknown]) Then
         Query.Params[I].DataType := ObjectValueToFieldType(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).FieldType)
        Else
         Query.Params[I].DataType := ftString;
       End;
      If Query.Params[I].DataType in [ftInteger, ftSmallInt, ftWord, ftLongWord, ftLargeint] Then
       Begin
        If (Trim(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value) <> '') And
           (Trim(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value) <> 'null') Then
         Begin
           // Alterado por: Alexandre Magno - 04/11/2017
           If Query.Params[I].DataType in [ftLongWord, ftLargeint] Then
             Query.Params[I].AsLargeInt := StrToInt64(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value)
           else If Query.Params[I].DataType = ftSmallInt Then
             Query.Params[I].AsSmallInt := StrToInt(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value)
           Else
             Query.Params[I].AsInteger  := StrToInt(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value);

           // Como estava Anteriormente
           //If Query.Params[I].DataType = ftSmallInt Then
           //  Query.Params[I].AsSmallInt := StrToInt(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value)
           //Else
           //  Query.Params[I].AsInteger  := StrToInt(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value);
         End;
       End
      Else If Query.Params[I].DataType in [ftFloat,   ftCurrency, ftSingle, ftBCD, ftFMTBcd] Then
       Begin
        If (Trim(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value) <> '') And
           (Trim(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value) <> 'null') Then
         Query.Params[I].AsFloat  := StrToFloat(BuildFloatString(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value));
       End
      Else If Query.Params[I].DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] Then
       Begin
        If (Trim(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value) <> '') And
           (Trim(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value) <> 'null') Then
         Query.Params[I].AsDateTime  := UnixToDateTime(StrToInt64(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value))
        Else
         Query.Params[I].Clear;
       End  //Tratar Blobs de Parametros...
      Else If Query.Params[I].DataType in [ftBytes, ftVarBytes, ftBlob,
                                           ftGraphic, ftOraBlob, ftOraClob,
                                           ftMemo {$IFNDEF FPC}
                                                   {$IF CompilerVersion > 21}
                                                   , ftWideMemo
                                                   {$IFEND}
                                                  {$ENDIF}] Then
       Begin
        vStringStream := TMemoryStream.Create;
        Try
         If (MassiveDataset.Fields.FieldByName(Query.Params[I].Name).value <> 'null') And
            (MassiveDataset.Fields.FieldByName(Query.Params[I].Name).value <> '') Then
          Begin
           MassiveDataset.Fields.FieldByName(Query.Params[I].Name).SaveToStream(vStringStream);
           vStringStream.Position := 0;
           Query.Params[I].LoadFromStream(vStringStream, ftBlob);
          End
         Else
          Query.Params[I].Clear;
        Finally
         FreeAndNil(vStringStream);
        End;
       End
      Else
       Query.Params[I].Value := MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value;
     End;
   End;
  Begin
   Query.Close;
   Query.SQL.Clear;
   vFields    := '';
   vParamsSQL := vFields;
   Case MassiveDataset.MassiveMode Of
    mmInsert : Begin
                vLineSQL := Format('INSERT INTO %s ', [MassiveDataset.TableName + ' (%s) VALUES (%s)']);
                For I := 0 To MassiveDataset.Fields.Count -1 Do
                 Begin
                  If (MassiveDataset.Fields.Items[I].AutoGenerateValue) And
                     (MassiveDataset.AtualRec.MassiveMode = mmInsert) Then
                   Continue;
                  If vFields = '' Then
                   Begin
                    vFields     := MassiveDataset.Fields.Items[I].FieldName;
                    vParamsSQL  := ':' + MassiveDataset.Fields.Items[I].FieldName;
                   End
                  Else
                   Begin
                    vFields     := vFields    + ', '  + MassiveDataset.Fields.Items[I].FieldName;
                    vParamsSQL  := vParamsSQL + ', :' + MassiveDataset.Fields.Items[I].FieldName;
                   End;
                 End;
                vLineSQL := Format(vLineSQL, [vFields, vParamsSQL]);
               End;
    mmUpdate : Begin
                vLineSQL := Format('UPDATE %s ',      [MassiveDataset.TableName + ' SET %s %s']);
                vFields  := '';
                For I := 0 To MassiveDataset.AtualRec.UpdateFieldChanges.Count -1 Do
                 Begin
                  If Lowercase(MassiveDataset.AtualRec.UpdateFieldChanges[I]) <> Lowercase(DWFieldBookmark) Then
                   Begin
                    If vFields = '' Then
                     vFields  := MassiveDataset.AtualRec.UpdateFieldChanges[I] + ' = :' + MassiveDataset.AtualRec.UpdateFieldChanges[I]
                    Else
                     vFields  := vFields + ', ' + MassiveDataset.AtualRec.UpdateFieldChanges[I] + ' = :' + MassiveDataset.AtualRec.UpdateFieldChanges[I];
                   End;
                 End;
                bPrimaryKeys := MassiveDataset.PrimaryKeys;
                Try
                 For I := 0 To bPrimaryKeys.Count -1 Do
                  Begin
                   If I = 0 Then
                    vParamsSQL := 'WHERE ' + bPrimaryKeys[I] + ' = :DWKEY_' + bPrimaryKeys[I]
                   Else
                    vParamsSQL := vParamsSQL + ' AND ' + bPrimaryKeys[I] + ' = :DWKEY_' + bPrimaryKeys[I]
                  End;
                Finally
                 FreeAndNil(bPrimaryKeys);
                End;
                vLineSQL := Format(vLineSQL, [vFields, vParamsSQL]);
               End;
    mmDelete : Begin
                vLineSQL := Format('DELETE FROM %s ', [MassiveDataset.TableName + ' %s ']);
                bPrimaryKeys := MassiveDataset.PrimaryKeys;
                Try
                 For I := 0 To bPrimaryKeys.Count -1 Do
                  Begin
                   If I = 0 Then
                    vParamsSQL := 'WHERE ' + bPrimaryKeys[I] + ' = :' + bPrimaryKeys[I]
                   Else
                    vParamsSQL := vParamsSQL + ' AND ' + bPrimaryKeys[I] + ' = :' + bPrimaryKeys[I]
                  End;
                Finally
                 FreeAndNil(bPrimaryKeys);
                End;
                vLineSQL := Format(vLineSQL, [vParamsSQL]);
               End;
   End;
   Query.SQL.Add(vLineSQL);
   //Params
   For I := 0 To Query.ParamCount -1 Do
    Begin
     If (MassiveDataset.Fields.FieldByName(Query.Params[I].Name) <> Nil) Then
      Begin
       vFieldType := ObjectValueToFieldType(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).FieldType);
       If MassiveDataset.Fields.FieldByName(Query.Params[I].Name).value = 'null' Then
        Begin
         If vFieldType = ftUnknown Then
          Query.Params[I].DataType := ftString
         Else
          Query.Params[I].DataType := vFieldType;
         Query.Params[I].Clear;
        End;
       If MassiveDataset.MassiveMode <> mmUpdate Then
        Begin
         If Query.Params[I].DataType in [{$IFNDEF FPC}{$if CompilerVersion > 21} // Delphi 2010 pra baixo
                               ftFixedChar, ftFixedWideChar,{$IFEND}{$ENDIF}
                               ftString,    ftWideString]    Then
          Begin
           If (MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value <> Null) And
              (Trim(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value) <> 'null') Then
            Begin
             If Query.Params[I].Size > 0 Then
              Query.Params[I].Value := Copy(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value, 1, Query.Params[I].Size)
             Else
              Query.Params[I].Value := MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value;
            End
           Else
            Query.Params[I].Clear;
          End
         Else
          Begin
           If Query.Params[I].DataType in [ftUnknown] Then
            Begin
             If Not (ObjectValueToFieldType(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).FieldType) in [ftUnknown]) Then
              Query.Params[I].DataType := ObjectValueToFieldType(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).FieldType)
             Else
              Query.Params[I].DataType := ftString;
            End;
           If Query.Params[I].DataType in [ftInteger, ftSmallInt, ftWord, ftLongWord, ftLargeint] Then
            Begin
             If (Trim(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value) <> '') And
                (Trim(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value) <> 'null') Then
              Begin
               If MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value <> Null Then
                Begin
                 If Query.Params[I].DataType in [ftLongWord, ftLargeint] Then
                  Query.Params[I].AsLargeInt := StrToInt64(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value)
                 Else If Query.Params[I].DataType = ftSmallInt Then
                  Query.Params[I].AsSmallInt := StrToInt(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value)
                 Else
                  Query.Params[I].AsInteger  := StrToInt(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value);
                End;
              End
             Else
              Query.Params[I].Clear;
            End
           Else If Query.Params[I].DataType in [ftFloat,   ftCurrency, ftBCD, ftFMTBcd, ftSingle] Then
            Begin
             If (MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value <> Null) And
                (Trim(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value) <> 'null') Then
              Query.Params[I].AsFloat  := StrToFloat(BuildFloatString(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value))
             Else
              Query.Params[I].Clear;
            End
           Else If Query.Params[I].DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] Then
            Begin
             If (MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value <> Null) And
                (Trim(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value) <> 'null') Then
              Query.Params[I].AsDateTime  := UnixToDateTime(StrToInt64(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value))
             Else
              Query.Params[I].Clear;
            End  //Tratar Blobs de Parametros...
           Else If Query.Params[I].DataType in [ftBytes, ftVarBytes, ftBlob,
                                                ftGraphic, ftOraBlob, ftOraClob,
                                                ftMemo {$IFNDEF FPC}
                                                        {$IF CompilerVersion > 21}
                                                         , ftWideMemo
                                                        {$IFEND}
                                                       {$ENDIF}] Then
            Begin
             vStringStream := TMemoryStream.Create;
             Try
              If (MassiveDataset.Fields.FieldByName(Query.Params[I].Name).value <> 'null') And
                 (MassiveDataset.Fields.FieldByName(Query.Params[I].Name).value <> '') Then
               Begin
                MassiveDataset.Fields.FieldByName(Query.Params[I].Name).SaveToStream(vStringStream);
                vStringStream.Position := 0;
                Query.Params[I].LoadFromStream(vStringStream, ftBlob);
               End
              Else
               Query.Params[I].Clear;
             Finally
              FreeAndNil(vStringStream);
             End;
            End
           Else If (MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value <> Null) And
                   (Trim(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value) <> 'null') Then
            Query.Params[I].Value := MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value
           Else
            Query.Params[I].Clear;
          End;
        End
       Else //Update
        Begin
         SetUpdateBuffer;
        End;
      End
     Else
      Begin
       If I = 0 Then
        SetUpdateBuffer;
      End;
    End;
  End;
 Begin
  MassiveDataset := TMassiveDatasetBuffer.Create(Nil);
  bJsonArray     := udwjson.TJsonArray.Create(MassiveCache);
  Result         := False;
  For x := 0 To bJsonArray.length -1 Do
   Begin
    If Not vFDConnection.InTransaction Then
     vFDConnection.StartTransaction;
    Try
     MassiveDataset.FromJSON(bJsonArray.get(X).toString);
     MassiveDataset.First;
     For A := 1 To MassiveDataset.RecordCount Do
      Begin
       Query.SQL.Clear;
       If Self.Owner      Is TServerMethodDataModule Then
        Begin
         vMassiveLine := False;
         If Assigned(TServerMethodDataModule(Self.Owner).OnMassiveProcess) Then
          Begin
           TServerMethodDataModule(Self.Owner).OnMassiveProcess(MassiveDataset, vMassiveLine);
           If vMassiveLine Then
            Begin
             MassiveDataset.Next;
             Continue;
            End;
          End;
        End
       Else If Self.Owner Is TServerMethods Then
        Begin
         vMassiveLine := False;
         If Assigned(TServerMethods(Self.Owner).OnMassiveProcess) Then
          Begin
           TServerMethods(Self.Owner).OnMassiveProcess(MassiveDataset, vMassiveLine);
           If vMassiveLine Then
            Begin
             MassiveDataset.Next;
             Continue;
            End;
          End;
        End;
       PrepareData(Query, MassiveDataset, Error, MessageError);
       Try
        Query.ExecSQL;
       Except
        On E : Exception do
         Begin
          Error  := True;
          Result := False;
          If vFDConnection.InTransaction Then
           vFDConnection.Rollback;
          MessageError := E.Message;
          Break;
         End;
       End;
       MassiveDataset.Next;
      End;
    Finally
     Query.SQL.Clear;
    End;
   End;
  If Not Error Then
   Begin
    Try
     Result        := True;
     If vFDConnection.InTransaction Then
      vFDConnection.Commit;
    Except
     On E : Exception do
      Begin
       Error  := True;
       Result := False;
       If vFDConnection.InTransaction Then
        vFDConnection.Rollback;
       MessageError := E.Message;
      End;
    End;
   End;
  FreeAndNil(MassiveDataset);
  FreeAndNil(bJsonArray);
 End;
Begin
 Inherited;
 Try
  Error      := False;
  vTempQuery := TFDQuery.Create(Owner);
  If Not vFDConnection.Connected Then
   vFDConnection.Connected := True;
  vTempQuery.Connection   := vFDConnection;
  vTempQuery.FormatOptions.StrsTrim       := StrsTrim;
  vTempQuery.FormatOptions.StrsEmpty2Null := StrsEmpty2Null;
  vTempQuery.FormatOptions.StrsTrim2Len   := StrsTrim2Len;
  vTempQuery.SQL.Clear;
  LoadMassive(MassiveCache, vTempQuery);
 Finally
  vTempQuery.Close;
  vTempQuery.Free;
 End;
End;

Procedure TRESTDWDriverFD.Close;
Begin
  Inherited;
 If Connection <> Nil Then
  Connection.Close;
End;

Class Procedure TRESTDWDriverFD.CreateConnection(Const ConnectionDefs : TConnectionDefs;
                                                 Var Connection       : TObject);
 Procedure ServerParamValue(ParamName, Value : String);
 Var
  I, vIndex : Integer;
  vFound : Boolean;
 Begin
  vFound := False;
  vIndex := -1;
  For I := 0 To TFDConnection(Connection).Params.Count -1 Do
   Begin
    If Lowercase(TFDConnection(Connection).Params.Names[I]) = Lowercase(ParamName) Then
     Begin
      vFound := True;
      vIndex := I;
      Break;
     End;
   End;
  If Not (vFound) Then
   TFDConnection(Connection).Params.Add(Format('%s=%s', [Lowercase(ParamName), Lowercase(Value)]))
  Else
   TFDConnection(Connection).Params[vIndex] := Format('%s=%s', [Lowercase(ParamName), Lowercase(Value)]);
 End;
Begin
 Inherited;
 If Assigned(ConnectionDefs) Then
  Begin
   Case ConnectionDefs.DriverType Of
    dbtUndefined  : Begin

                    End;
    dbtAccess     : Begin
                     TFDConnection(Connection).DriverName := 'MSAcc';

                    End;
    dbtDbase      : Begin

                    End;
    dbtFirebird   : Begin
                     TFDConnection(Connection).DriverName := 'FB';
                     ServerParamValue('Server',    ConnectionDefs.HostName);
                     ServerParamValue('Port',      IntToStr(ConnectionDefs.dbPort));
                     ServerParamValue('Database',  ConnectionDefs.DatabaseName);
                     ServerParamValue('User_Name', ConnectionDefs.Username);
                     ServerParamValue('Password',  ConnectionDefs.Password);
                     ServerParamValue('Protocol',  Uppercase(ConnectionDefs.Protocol));
                    End;
    dbtInterbase  : Begin
                     TFDConnection(Connection).DriverName := 'IB';
                     ServerParamValue('Server',    ConnectionDefs.HostName);
                     ServerParamValue('Port',      IntToStr(ConnectionDefs.dbPort));
                     ServerParamValue('Database',  ConnectionDefs.DatabaseName);
                     ServerParamValue('User_Name', ConnectionDefs.Username);
                     ServerParamValue('Password',  ConnectionDefs.Password);
                     ServerParamValue('Protocol',  Uppercase(ConnectionDefs.Protocol));
                    End;
    dbtMySQL      : Begin
                     TFDConnection(Connection).DriverName := 'MYSQL';

                    End;
    dbtSQLLite    : Begin
                     TFDConnection(Connection).DriverName := 'SQLLite';

                    End;
    dbtOracle     : Begin
                     TFDConnection(Connection).DriverName := 'Ora';

                    End;
    dbtMsSQL      : Begin
                     TFDConnection(Connection).DriverName := 'MSSQL';
                     ServerParamValue('DriverID',  ConnectionDefs.DriverID);
                     ServerParamValue('Server',    ConnectionDefs.HostName);
                     ServerParamValue('Port',      IntToStr(ConnectionDefs.dbPort));
                     ServerParamValue('Database',  ConnectionDefs.DatabaseName);
                     ServerParamValue('User_Name', ConnectionDefs.Username);
                     ServerParamValue('Password',  ConnectionDefs.Password);
                     ServerParamValue('Protocol',  Uppercase(ConnectionDefs.Protocol));

                    End;
    dbtODBC       : Begin
                     TFDConnection(Connection).DriverName := 'ODBC';
                     ServerParamValue('DataSource', ConnectionDefs.DataSource);
                    End;
    dbtParadox    : Begin

                    End;
    dbtPostgreSQL : Begin
                     TFDConnection(Connection).DriverName := 'PG';

                    End;
   End;
  End;
End;

function TRESTDWDriverFD.ExecuteCommand(SQL              : String;
                                        Params           : TDWParams;
                                        Var Error        : Boolean;
                                        Var MessageError : String;
                                        Execute          : Boolean) : String;
Var
 vTempQuery    : TFDQuery;
 A, I          : Integer;
 vParamName    : String;
 vStringStream : TMemoryStream;
 aResult       : TJSONValue;
 Function GetParamIndex(Params : TFDParams; ParamName : String) : Integer;
 Var
  I : Integer;
 Begin
  Result := -1;
  For I := 0 To Params.Count -1 Do
   Begin
    If UpperCase(Params[I].Name) = UpperCase(ParamName) Then
     Begin
      Result := I;
      Break;
     End;
   End;
 End;
Begin
 Inherited;
 Error  := False;
 Result := '';
 aResult := TJSONValue.Create;
 vTempQuery               := TFDQuery.Create(Owner);
 Try
  vTempQuery.Connection   := vFDConnection;
  vTempQuery.FormatOptions.StrsTrim       := StrsTrim;
  vTempQuery.FormatOptions.StrsEmpty2Null := StrsEmpty2Null;
  vTempQuery.FormatOptions.StrsTrim2Len   := StrsTrim2Len;
  vTempQuery.ResourceOptions.ParamCreate  := ParamCreate;
  vTempQuery.SQL.Clear;
  vTempQuery.SQL.Add(SQL);
  If Params <> Nil Then
  Begin
    if vTempQuery.ResourceOptions.ParamCreate then
    begin
      Try
      // vTempQuery.Prepare;
      Except
      End;
      For I := 0 To Params.Count -1 Do
       Begin
        If vTempQuery.ParamCount > I Then
         Begin
          vParamName := Copy(StringReplace(Params[I].ParamName, ',', '', []), 1, Length(Params[I].ParamName));
          A          := GetParamIndex(vTempQuery.Params, vParamName);
          If A > -1 Then//vTempQuery.ParamByName(vParamName) <> Nil Then
           Begin
            If vTempQuery.Params[A].DataType in [{$IFNDEF FPC}{$if CompilerVersion > 21} // Delphi 2010 pra baixo
                                                  ftFixedChar, ftFixedWideChar,{$IFEND}{$ENDIF}
                                                  ftString,    ftWideString]    Then
             Begin
              If vTempQuery.Params[A].Size > 0 Then
               vTempQuery.Params[A].Value := Copy(Params[I].Value, 1, vTempQuery.Params[A].Size)
              Else
               vTempQuery.Params[A].Value := Params[I].Value;
             End
            Else
             Begin
              If vTempQuery.Params[A].DataType in [ftUnknown] Then
               Begin
                If Not (ObjectValueToFieldType(Params[I].ObjectValue) in [ftUnknown]) Then
                 vTempQuery.Params[A].DataType := ObjectValueToFieldType(Params[I].ObjectValue)
                Else
                 vTempQuery.Params[A].DataType := ftString;
               End;
              If vTempQuery.Params[A].DataType in [ftInteger, ftSmallInt, ftWord, ftLongWord, ftLargeint] Then
               Begin
                If (Params[I].Value <> Null) Then
                 Begin
                  If vTempQuery.Params[A].DataType in [ftLongWord, ftLargeint] Then
                   vTempQuery.Params[A].AsLargeInt := StrToInt64(Params[I].Value)
                  Else If vTempQuery.Params[A].DataType = ftSmallInt Then
                   vTempQuery.Params[A].AsSmallInt := StrToInt(Params[I].Value)
                  Else
                   vTempQuery.Params[A].AsInteger  := StrToInt(Params[I].Value);
                 End
                Else
                 vTempQuery.Params[A].Clear;
               End
              Else If vTempQuery.Params[A].DataType in [ftFloat,   ftCurrency, ftBCD, ftFMTBcd, ftSingle] Then
               Begin
                If (Params[I].Value <> Null) Then
                 vTempQuery.Params[A].AsFloat  := StrToFloat(BuildFloatString(Params[I].Value))
                Else
                 vTempQuery.Params[A].Clear;
               End
              Else If vTempQuery.Params[A].DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] Then
               Begin
                If (Params[I].Value <> Null) Then
                 vTempQuery.Params[A].AsDateTime  := Params[I].AsDateTime
                Else
                 vTempQuery.Params[A].Clear;
               End  //Tratar Blobs de Parametros...
              Else If vTempQuery.Params[A].DataType in [ftBytes, ftVarBytes, ftBlob,
                                                        ftGraphic, ftOraBlob, ftOraClob,
                                                        ftMemo {$IFNDEF FPC}
                                                                {$IF CompilerVersion > 21}
                                                                , ftWideMemo
                                                                {$IFEND}
                                                               {$ENDIF}] Then
               Begin
                vStringStream := TMemoryStream.Create;
                Try
                 Params[I].SaveToStream(vStringStream);
                 vStringStream.Position := 0;
                 If vStringStream.Size > 0 Then
                  vTempQuery.Params[A].LoadFromStream(vStringStream, ftBlob);
                Finally
                 FreeAndNil(vStringStream);
                End;
               End
              Else If vTempQuery.Params[A].DataType in [{$IFNDEF FPC}{$if CompilerVersion > 21} // Delphi 2010 pra baixo
                                                        ftFixedChar, ftFixedWideChar,{$IFEND}{$ENDIF}
                                                        ftString,    ftWideString]    Then
               Begin
                If (Trim(Params[I].Value) <> '') Then
                 vTempQuery.Params[A].AsString := Params[I].Value
                Else
                 vTempQuery.Params[A].Clear;
               End
              Else
               vTempQuery.Params[A].Value    := Params[I].Value;
             End;
           End;
         End
        Else
         Break;
       End;
     end
     Else
      Begin
       For I := 0 To Params.Count -1 Do
        begin
         With vTempQuery.Params.Add do
          Begin
           vParamName := Copy(StringReplace(Params[I].ParamName, ',', '', []), 1, Length(Params[I].ParamName));
           Name := vParamName;
           ParamType := ptInput;
           If Not (ObjectValueToFieldType(Params[I].ObjectValue) in [ftUnknown]) Then
            DataType := ObjectValueToFieldType(Params[I].ObjectValue)
           Else
            DataType := ftString;
           If vTempQuery.Params[I].DataType in [ftInteger, ftSmallInt, ftWord, ftLongWord, ftLargeint] Then
            Begin
             If (Params[I].Value <> Null) Then
              Begin
               // Alterado por: Alexandre Magno - 04/11/2017
               If vTempQuery.Params[I].DataType in [ftLongWord, ftLargeint] Then
                vTempQuery.Params[I].AsLargeInt := StrToInt64(Params[I].Value)
               Else If vTempQuery.Params[I].DataType = ftSmallInt Then
                vTempQuery.Params[I].AsSmallInt := StrToInt(Params[I].Value)
               Else
                vTempQuery.Params[I].AsInteger  := StrToInt(Params[I].Value);
              End
             Else
              vTempQuery.Params[I].Clear;
            End
            Else If vTempQuery.Params[I].DataType in [ftFloat,   ftCurrency, ftBCD, ftFMTBcd, ftSingle] Then
             Begin
              If (Params[I].Value <> Null) Then
               vTempQuery.Params[I].AsFloat  := StrToFloat(BuildFloatString(Params[I].Value))
              Else
               vTempQuery.Params[I].Clear;
             End
            Else If vTempQuery.Params[I].DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] Then
             Begin
              If (Params[I].Value <> Null) Then
               vTempQuery.Params[I].AsDateTime  := Params[I].AsDateTime
              Else
               vTempQuery.Params[I].Clear;
             End  //Tratar Blobs de Parametros...
            Else If vTempQuery.Params[I].DataType in [ftBytes, ftVarBytes, ftBlob,
                                                      ftGraphic, ftOraBlob, ftOraClob,
                                                      ftMemo {$IFNDEF FPC}
                                                                {$IF CompilerVersion > 21}
                                                                , ftWideMemo
                                                                {$IFEND}
                                                               {$ENDIF}] Then
             Begin
              vStringStream := TMemoryStream.Create;
              Try
               Params[I].SaveToStream(vStringStream);
               vStringStream.Position := 0;
               If vStringStream.Size > 0 Then
                vTempQuery.Params[I].LoadFromStream(vStringStream, ftBlob);
              Finally
               FreeAndNil(vStringStream);
              End;
             End
            Else If vTempQuery.Params[I].DataType in [{$IFNDEF FPC}{$if CompilerVersion > 21} // Delphi 2010 pra baixo
                                                      ftFixedChar, ftFixedWideChar,{$IFEND}{$ENDIF}
                                                      ftString,    ftWideString]    Then
             Begin
              If (Params[I].Value <> '') And
                 (Params[I].Value <> Null) Then
               vTempQuery.Params[I].AsString := Params[I].Value
              Else
               vTempQuery.Params[I].Clear;
             End
            Else
             vTempQuery.Params[I].Value    := Params[I].Value;
          End;
        End;
      End;
  End;
  If Not Execute Then
   Begin
    vTempQuery.Active := True;
    If aResult = Nil Then
     aResult := TJSONValue.Create;
    aResult.Encoding := Encoding;
    Try
     aResult.LoadFromDataset('RESULTDATA', vTempQuery, EncodeStringsJSON);
     Result := aResult.ToJSON;
    Finally
    End;
   End
  Else
   Begin
    vTempQuery.ExecSQL;
    If aResult = Nil Then
     aResult := TJSONValue.Create;
    vFDConnection.CommitRetaining;
    aResult.SetValue('COMMANDOK');
    Result := aResult.ToJSON;
   End;
 Except
  On E : Exception do
   Begin
    Try
     Error        := True;
     MessageError := E.Message;
     If aResult = Nil Then
      aResult := TJSONValue.Create;
     aResult.Encoded := True;
     aResult.SetValue(GetPairJSON('NOK', MessageError));
     Result := aResult.ToJSON;
     vFDConnection.RollbackRetaining;
    Except
    End;
   End;
 End;
 FreeAndNil(aResult);
 vTempQuery.Close;
 vTempQuery.Free;
End;

procedure TRESTDWDriverFD.ExecuteProcedure(ProcName         : String;
                                           Params           : TDWParams;
                                           Var Error        : Boolean;
                                           Var MessageError : String);
Var
 A, I            : Integer;
 vParamName      : String;
 vTempStoredProc : TFDStoredProc;
 Function GetParamIndex(Params : TFDParams; ParamName : String) : Integer;
 Var
  I : Integer;
 Begin
  Result := -1;
  For I := 0 To Params.Count -1 Do
   Begin
    If UpperCase(Params[I].Name) = UpperCase(ParamName) Then
     Begin
      Result := I;
      Break;
     End;
   End;
 End;
Begin
 Inherited;
 Error  := False;
 vTempStoredProc                               := TFDStoredProc.Create(Owner);
 Try
  vTempStoredProc.Connection                   := vFDConnection;
  vTempStoredProc.FormatOptions.StrsTrim       := StrsTrim;
  vTempStoredProc.FormatOptions.StrsEmpty2Null := StrsEmpty2Null;
  vTempStoredProc.FormatOptions.StrsTrim2Len   := StrsTrim2Len;
  vTempStoredProc.StoredProcName               := ProcName;
  If Params <> Nil Then
   Begin
    Try
     vTempStoredProc.Prepare;
    Except
    End;
    For I := 0 To Params.Count -1 Do
     Begin
      If vTempStoredProc.ParamCount > I Then
       Begin
        vParamName := Copy(StringReplace(Params[I].ParamName, ',', '', []), 1, Length(Params[I].ParamName));
        A          := GetParamIndex(vTempStoredProc.Params, vParamName);
        If A > -1 Then//vTempQuery.ParamByName(vParamName) <> Nil Then
         Begin
          If vTempStoredProc.Params[A].DataType in [ftFixedChar, ftFixedWideChar,
                                                    ftString,    ftWideString]    Then
           Begin
            If vTempStoredProc.Params[A].Size > 0 Then
             vTempStoredProc.Params[A].Value := Copy(Params[I].Value, 1, vTempStoredProc.Params[A].Size)
            Else
             vTempStoredProc.Params[A].Value := Params[I].Value;
           End
          Else
           Begin
            If vTempStoredProc.Params[A].DataType in [ftUnknown] Then
             vTempStoredProc.Params[A].DataType := ObjectValueToFieldType(Params[I].ObjectValue);
            vTempStoredProc.Params[A].Value    := Params[I].Value;
           End;
         End;
       End
      Else
       Break;
     End;
   End;
  vTempStoredProc.ExecProc;
  vFDConnection.CommitRetaining;
 Except
  On E : Exception do
   Begin
    Try
     vFDConnection.RollbackRetaining;
    Except
    End;
    Error := True;
    MessageError := E.Message;
   End;
 End;
 vTempStoredProc.DisposeOf;
End;

procedure TRESTDWDriverFD.ExecuteProcedurePure(ProcName         : String;
                                               Var Error        : Boolean;
                                               Var MessageError : String);
Var
 vTempStoredProc : TFDStoredProc;
Begin
 Inherited;
 Error                                         := False;
 vTempStoredProc                               := TFDStoredProc.Create(Owner);
 Try
  If Not vFDConnection.Connected Then
   vFDConnection.Connected                     := True;
  vTempStoredProc.Connection                   := vFDConnection;
  vTempStoredProc.FormatOptions.StrsTrim       := StrsTrim;
  vTempStoredProc.FormatOptions.StrsEmpty2Null := StrsEmpty2Null;
  vTempStoredProc.FormatOptions.StrsTrim2Len   := StrsTrim2Len;
  vTempStoredProc.StoredProcName               := ProcName;
  vTempStoredProc.ExecProc;
  vFDConnection.CommitRetaining;
 Except
  On E : Exception do
   Begin
    Try
     vFDConnection.RollbackRetaining;
    Except
    End;
    Error := True;
    MessageError := E.Message;
   End;
 End;
 vTempStoredProc.DisposeOf;
End;

Function TRESTDWDriverFD.ApplyUpdates(Massive,
                                      SQL               : String;
                                      Params            : TDWParams;
                                      Var Error         : Boolean;
                                      Var MessageError  : String) : TJSONValue;
Var
 vTempQuery     : TFDQuery;
 A, I           : Integer;
 vParamName     : String;
 vStringStream  : TMemoryStream;
 bPrimaryKeys   : TStringList;
 vFieldType     : TFieldType;
 vMassiveLine   : Boolean;
 Function GetParamIndex(Params : TFDParams; ParamName : String) : Integer;
 Var
  I : Integer;
 Begin
  Result := -1;
  For I := 0 To Params.Count -1 Do
   Begin
    If UpperCase(Params[I].Name) = UpperCase(ParamName) Then
     Begin
      Result := I;
      Break;
     End;
   End;
 End;
 Function LoadMassive(Massive : String; Var Query : TFDQuery) : Boolean;
 Var
  MassiveDataset : TMassiveDatasetBuffer;
  A, B           : Integer;
  Procedure PrepareData(Var Query      : TFDQuery;
                        MassiveDataset : TMassiveDatasetBuffer;
                        Var vError     : Boolean;
                        Var ErrorMSG   : String);
  Var
   vLineSQL,
   vFields,
   vParamsSQL : String;
   I          : Integer;
   Procedure SetUpdateBuffer;
   Var
    X : Integer;
   Begin
    If I = 0 Then
     Begin
      bPrimaryKeys := MassiveDataset.PrimaryKeys;
      Try
       For X := 0 To bPrimaryKeys.Count -1 Do
        Begin
         If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [{$IFNDEF FPC}{$if CompilerVersion > 21} // Delphi 2010 pra baixo
                                                                       ftFixedChar, ftFixedWideChar,{$IFEND}{$ENDIF}
                                                                       ftString,    ftWideString]    Then
          Begin
           If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).Size > 0 Then
            Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).Value := Copy(MassiveDataset.AtualRec.PrimaryValues[X].Value, 1, Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).Size)
           Else
            Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).Value := MassiveDataset.AtualRec.PrimaryValues[X].Value;
          End
         Else
          Begin
           If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [ftUnknown] Then
            Begin
             If Not (ObjectValueToFieldType(MassiveDataset.Fields.FieldByName(bPrimaryKeys[X]).FieldType) in [ftUnknown]) Then
              Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType := ObjectValueToFieldType(MassiveDataset.Fields.FieldByName(bPrimaryKeys[X]).FieldType)
             Else
              Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType := ftString;
            End;
           If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [ftInteger, ftSmallInt, ftWord, ftLongWord, ftLargeint] Then
            Begin
             If Trim(MassiveDataset.AtualRec.PrimaryValues[X].Value) <> '' Then
              Begin
                // Alterado por: Alexandre Magno - 04/11/2017
                If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [ftLongWord, ftLargeint] Then
                  Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).AsLargeInt := StrToInt64(MassiveDataset.AtualRec.PrimaryValues[X].Value)
                else If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType = ftSmallInt Then
                  Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).AsSmallInt := StrToInt(MassiveDataset.AtualRec.PrimaryValues[X].Value)
                Else
                 Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).AsInteger  := StrToInt(MassiveDataset.AtualRec.PrimaryValues[X].Value);
              End;
            End
           Else If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [ftFloat,   ftCurrency, ftBCD,ftFMTBcd, ftSingle] Then
            Begin
             If Trim(MassiveDataset.AtualRec.PrimaryValues[X].Value) <> '' Then
              Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).AsFloat  := StrToFloat(BuildFloatString(MassiveDataset.AtualRec.PrimaryValues[X].Value));
            End
           Else If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] Then
            Begin
             If Trim(MassiveDataset.AtualRec.PrimaryValues[X].Value) <> '' Then
              Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).AsDateTime  := UnixToDateTime(StrToInt64(MassiveDataset.AtualRec.PrimaryValues[X].Value))
             Else
              Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).AsDateTime  := Null;
            End  //Tratar Blobs de Parametros...
           Else If Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).DataType in [ftBytes, ftVarBytes, ftBlob,
                                                                              ftGraphic, ftOraBlob, ftOraClob,
                                                                              ftMemo {$IFNDEF FPC}
                                                                                      {$IF CompilerVersion > 21}
                                                                                       , ftWideMemo
                                                                                      {$IFEND}
                                                                                     {$ENDIF}] Then
            Begin
             vStringStream := TMemoryStream.Create;
             Try
              MassiveDataset.AtualRec.PrimaryValues[X].SaveToStream(vStringStream);
              vStringStream.Position := 0;
              Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).LoadFromStream(vStringStream, ftBlob);
             Finally
              FreeAndNil(vStringStream);
             End;
            End
           Else
            Query.ParamByName('DWKEY_' + bPrimaryKeys[X]).Value := MassiveDataset.AtualRec.PrimaryValues[X].Value;
          End;
        End;
       Finally
        FreeAndNil(bPrimaryKeys);
       End;
      End;
    If Query.Params[I].DataType in [{$IFNDEF FPC}{$if CompilerVersion > 21} // Delphi 2010 pra baixo
                          ftFixedChar, ftFixedWideChar,{$IFEND}{$ENDIF}
                          ftString,    ftWideString]    Then
     Begin
      If (Trim(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value) <> '') And
         (Trim(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value) <> 'null') Then
       Begin
        If Query.Params[I].Size > 0 Then
         Query.Params[I].Value := Copy(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value, 1, Query.Params[I].Size)
        Else
         Query.Params[I].Value := MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value;
       End;
     End
    Else
     Begin
      If Query.Params[I].DataType in [ftUnknown] Then
       Begin
        If Not (ObjectValueToFieldType(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).FieldType) in [ftUnknown]) Then
         Query.Params[I].DataType := ObjectValueToFieldType(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).FieldType)
        Else
         Query.Params[I].DataType := ftString;
       End;
      If Query.Params[I].DataType in [ftInteger, ftSmallInt, ftWord, ftLongWord, ftLargeint] Then
       Begin
        If (Trim(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value) <> '') And
           (Trim(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value) <> 'null') Then
         Begin
           // Alterado por: Alexandre Magno - 04/11/2017
           If Query.Params[I].DataType in [ftLongWord, ftLargeint] Then
             Query.Params[I].AsLargeInt := StrToInt64(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value)
           else If Query.Params[I].DataType = ftSmallInt Then
             Query.Params[I].AsSmallInt := StrToInt(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value)
           Else
             Query.Params[I].AsInteger  := StrToInt(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value);

           // Como estava Anteriormente
           //If Query.Params[I].DataType = ftSmallInt Then
           //  Query.Params[I].AsSmallInt := StrToInt(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value)
           //Else
           //  Query.Params[I].AsInteger  := StrToInt(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value);
         End
        Else
         Query.Params[I].Clear;
       End
      Else If Query.Params[I].DataType in [ftFloat,   ftCurrency, ftBCD, ftFMTBcd, ftSingle] Then
       Begin
        If (Trim(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value) <> '') And
           (Trim(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value) <> 'null') Then
         Query.Params[I].AsFloat  := StrToFloat(BuildFloatString(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value))
        Else
         Query.Params[I].Clear;
       End
      Else If Query.Params[I].DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] Then
       Begin
        If (Trim(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value) <> '') And
           (Trim(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value) <> 'null') Then
         Query.Params[I].AsDateTime  := UnixToDateTime(StrToInt64(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value))
        Else
         Query.Params[I].Clear;
       End  //Tratar Blobs de Parametros...
      Else If Query.Params[I].DataType in [ftBytes, ftVarBytes, ftBlob,
                                           ftGraphic, ftOraBlob, ftOraClob,
                                           ftMemo {$IFNDEF FPC}
                                                   {$IF CompilerVersion > 21}
                                                    , ftWideMemo
                                                   {$IFEND}
                                                  {$ENDIF}] Then
       Begin
        vStringStream := TMemoryStream.Create;
        Try
         If (MassiveDataset.Fields.FieldByName(Query.Params[I].Name).value <> 'null') And
            (MassiveDataset.Fields.FieldByName(Query.Params[I].Name).value <> '') Then
          Begin
           MassiveDataset.Fields.FieldByName(Query.Params[I].Name).SaveToStream(vStringStream);
           vStringStream.Position := 0;
           Query.Params[I].LoadFromStream(vStringStream, ftBlob);
          End
         Else
          Query.Params[I].Clear;
        Finally
         FreeAndNil(vStringStream);
        End;
       End
      Else
       Query.Params[I].Value := MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value;
     End;
   End;
  Begin
   Query.Close;
   Query.SQL.Clear;
   vFields    := '';
   vParamsSQL := vFields;
   Case MassiveDataset.MassiveMode Of
    mmInsert : Begin
                vLineSQL := Format('INSERT INTO %s ', [MassiveDataset.TableName + ' (%s) VALUES (%s)']);
                For I := 0 To MassiveDataset.Fields.Count -1 Do
                 Begin
                  If (MassiveDataset.Fields.Items[I].AutoGenerateValue) And
                     (MassiveDataset.AtualRec.MassiveMode = mmInsert) Then
                   Continue;
                  If vFields = '' Then
                   Begin
                    vFields     := MassiveDataset.Fields.Items[I].FieldName;
                    vParamsSQL  := ':' + MassiveDataset.Fields.Items[I].FieldName;
                   End
                  Else
                   Begin
                    vFields     := vFields    + ', '  + MassiveDataset.Fields.Items[I].FieldName;
                    vParamsSQL  := vParamsSQL + ', :' + MassiveDataset.Fields.Items[I].FieldName;
                   End;
                 End;
                vLineSQL := Format(vLineSQL, [vFields, vParamsSQL]);
               End;
    mmUpdate : Begin
                vLineSQL := Format('UPDATE %s ',      [MassiveDataset.TableName + ' SET %s %s']);
                vFields  := '';
                For I := 0 To MassiveDataset.AtualRec.UpdateFieldChanges.Count -1 Do
                 Begin
                  If Lowercase(MassiveDataset.AtualRec.UpdateFieldChanges[I]) <> Lowercase(DWFieldBookmark) Then
                   Begin
                    If vFields = '' Then
                     vFields  := MassiveDataset.AtualRec.UpdateFieldChanges[I] + ' = :' + MassiveDataset.AtualRec.UpdateFieldChanges[I]
                    Else
                     vFields  := vFields + ', ' + MassiveDataset.AtualRec.UpdateFieldChanges[I] + ' = :' + MassiveDataset.AtualRec.UpdateFieldChanges[I];
                   End;
                 End;
                bPrimaryKeys := MassiveDataset.PrimaryKeys;
                Try
                 For I := 0 To bPrimaryKeys.Count -1 Do
                  Begin
                   If I = 0 Then
                    vParamsSQL := 'WHERE ' + bPrimaryKeys[I] + ' = :DWKEY_' + bPrimaryKeys[I]
                   Else
                    vParamsSQL := vParamsSQL + ' AND ' + bPrimaryKeys[I] + ' = :DWKEY_' + bPrimaryKeys[I]
                  End;
                Finally
                 FreeAndNil(bPrimaryKeys);
                End;
                vLineSQL := Format(vLineSQL, [vFields, vParamsSQL]);
               End;
    mmDelete : Begin
                vLineSQL := Format('DELETE FROM %s ', [MassiveDataset.TableName + ' %s ']);
                bPrimaryKeys := MassiveDataset.PrimaryKeys;
                Try
                 For I := 0 To bPrimaryKeys.Count -1 Do
                  Begin
                   If I = 0 Then
                    vParamsSQL := 'WHERE ' + bPrimaryKeys[I] + ' = :' + bPrimaryKeys[I]
                   Else
                    vParamsSQL := vParamsSQL + ' AND ' + bPrimaryKeys[I] + ' = :' + bPrimaryKeys[I]
                  End;
                Finally
                 FreeAndNil(bPrimaryKeys);
                End;
                vLineSQL := Format(vLineSQL, [vParamsSQL]);
               End;
   End;
   Query.SQL.Add(vLineSQL);
   //Params
   For I := 0 To Query.ParamCount -1 Do
    Begin
     If (MassiveDataset.Fields.FieldByName(Query.Params[I].Name) <> Nil) Then
      Begin
       vFieldType := ObjectValueToFieldType(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).FieldType);
       If MassiveDataset.Fields.FieldByName(Query.Params[I].Name).value = 'null' Then
        Begin
         If vFieldType = ftUnknown Then
          Query.Params[I].DataType := ftString
         Else
          Query.Params[I].DataType := vFieldType;
         Query.Params[I].Clear;
        End;
       If MassiveDataset.MassiveMode <> mmUpdate Then
        Begin
         If Query.Params[I].DataType in [{$IFNDEF FPC}{$if CompilerVersion > 21} // Delphi 2010 pra baixo
                               ftFixedChar, ftFixedWideChar,{$IFEND}{$ENDIF}
                               ftString,    ftWideString]    Then
          Begin
           If (MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value <> Null) And
              (Trim(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value) <> 'null') Then
            Begin
             If Query.Params[I].Size > 0 Then
              Query.Params[I].Value := Copy(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value, 1, Query.Params[I].Size)
             Else
              Query.Params[I].Value := MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value;
            End
           Else
            Query.Params[I].Clear;
          End
         Else
          Begin
           If Query.Params[I].DataType in [ftUnknown] Then
            Begin
             If Not (ObjectValueToFieldType(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).FieldType) in [ftUnknown]) Then
              Query.Params[I].DataType := ObjectValueToFieldType(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).FieldType)
             Else
              Query.Params[I].DataType := ftString;
            End;
           If Query.Params[I].DataType in [ftInteger, ftSmallInt, ftWord, ftLongWord, ftLargeint] Then
            Begin
             If (Trim(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value) <> '') And
                (Trim(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value) <> 'null') Then
              Begin
               If MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value <> Null Then
                Begin
                 If Query.Params[I].DataType in [ftLongWord, ftLargeint] Then
                  Query.Params[I].AsLargeInt := StrToInt64(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value)
                 Else If Query.Params[I].DataType = ftSmallInt Then
                  Query.Params[I].AsSmallInt := StrToInt(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value)
                 Else
                  Query.Params[I].AsInteger  := StrToInt(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value);
                End;
              End
             Else
              Query.Params[I].Clear;
            End
           Else If Query.Params[I].DataType in [ftFloat,   ftCurrency, ftBCD, ftFMTBcd, ftSingle] Then
            Begin
             If (MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value <> Null) And
                (Trim(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value) <> 'null') Then
              Query.Params[I].AsFloat  := StrToFloat(BuildFloatString(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value))
             Else
              Query.Params[I].Clear;
            End
           Else If Query.Params[I].DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] Then
            Begin
             If (MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value <> Null) And
                (Trim(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value) <> 'null') Then
              Query.Params[I].AsDateTime  := UnixToDateTime(StrToInt64(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value))
             Else
              Query.Params[I].Clear;
            End  //Tratar Blobs de Parametros...
           Else If Query.Params[I].DataType in [ftBytes, ftVarBytes, ftBlob,
                                                ftGraphic, ftOraBlob, ftOraClob,
                                                ftMemo {$IFNDEF FPC}
                                                        {$IF CompilerVersion > 21}
                                                         , ftWideMemo
                                                        {$IFEND}
                                                       {$ENDIF}] Then
            Begin
             vStringStream := TMemoryStream.Create;
             Try
              If (MassiveDataset.Fields.FieldByName(Query.Params[I].Name).value <> 'null') And
                 (MassiveDataset.Fields.FieldByName(Query.Params[I].Name).value <> '') Then
               Begin
                MassiveDataset.Fields.FieldByName(Query.Params[I].Name).SaveToStream(vStringStream);
                vStringStream.Position := 0;
                Query.Params[I].LoadFromStream(vStringStream, ftBlob);
               End
              Else
               Query.Params[I].Clear;
             Finally
              FreeAndNil(vStringStream);
             End;
            End
           Else If (MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value <> Null) And
                   (Trim(MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value) <> 'null') Then
            Query.Params[I].Value := MassiveDataset.Fields.FieldByName(Query.Params[I].Name).Value
           Else
            Query.Params[I].Clear;
          End;
        End
       Else //Update
        Begin
         SetUpdateBuffer;
        End;
      End
     Else
      Begin
       If I = 0 Then
        SetUpdateBuffer;
      End;
    End;
  End;
 Begin
  MassiveDataset := TMassiveDatasetBuffer.Create(Nil);
  Try
   Result         := False;
   MassiveDataset.FromJSON(Massive);
   MassiveDataset.First;
   B             := 1;
   Result        := True;
   For A := 1 To MassiveDataset.RecordCount Do
    Begin
     If Not vFDConnection.InTransaction Then
      vFDConnection.StartTransaction;
     Query.SQL.Clear;
     If Self.Owner      Is TServerMethodDataModule Then
      Begin
       vMassiveLine := False;
       If Assigned(TServerMethodDataModule(Self.Owner).OnMassiveProcess) Then
        Begin
         TServerMethodDataModule(Self.Owner).OnMassiveProcess(MassiveDataset, vMassiveLine);
         If vMassiveLine Then
          Begin
           MassiveDataset.Next;
           Continue;
          End;
        End;
      End
     Else If Self.Owner Is TServerMethods Then
      Begin
       vMassiveLine := False;
       If Assigned(TServerMethods(Self.Owner).OnMassiveProcess) Then
        Begin
         TServerMethods(Self.Owner).OnMassiveProcess(MassiveDataset, vMassiveLine);
         If vMassiveLine Then
          Begin
           MassiveDataset.Next;
           Continue;
          End;
        End;
      End;
     PrepareData(Query, MassiveDataset, Error, MessageError);
     Try
      Query.ExecSQL;
     Except
      On E : Exception do
       Begin
        Error  := True;
        Result := False;
        If vFDConnection.InTransaction Then
         vFDConnection.Rollback;
        MessageError := E.Message;
        Exit;
       End;
     End;
     If B >= CommitRecords Then
      Begin
       Try
        If vFDConnection.InTransaction Then
         vFDConnection.Commit;
       Except
        On E : Exception do
         Begin
          Error  := True;
          Result := False;
          If vFDConnection.InTransaction Then
           vFDConnection.Rollback;
          MessageError := E.Message;
          Break;
         End;
       End;
       B := 1;
      End
     Else
      Inc(B);
     MassiveDataset.Next;
    End;
   Try
    If vFDConnection.InTransaction Then
     vFDConnection.Commit;
   Except
    On E : Exception do
     Begin
      Error  := True;
      Result := False;
      If vFDConnection.InTransaction Then
       vFDConnection.Rollback;
      MessageError := E.Message;
     End;
   End;
  Finally
   FreeAndNil(MassiveDataset);
   Query.SQL.Clear;
  End;
 End;
Begin
 Inherited;
 Try
  Result     := Nil;
  Error      := False;
  vTempQuery := TFDQuery.Create(Owner);
  If Not vFDConnection.Connected Then
   vFDConnection.Connected := True;
  vTempQuery.Connection   := vFDConnection;
  vTempQuery.FormatOptions.StrsTrim       := StrsTrim;
  vTempQuery.FormatOptions.StrsEmpty2Null := StrsEmpty2Null;
  vTempQuery.FormatOptions.StrsTrim2Len   := StrsTrim2Len;
  vTempQuery.SQL.Clear;
  If LoadMassive(Massive, vTempQuery) Then
   Begin
    If SQL <> '' Then
     Begin
      Try
       vTempQuery.SQL.Clear;
       vTempQuery.SQL.Add(SQL);
       If Params <> Nil Then
        Begin
         For I := 0 To Params.Count -1 Do
          Begin
           If vTempQuery.ParamCount > I Then
            Begin
             vParamName := Copy(StringReplace(Params[I].ParamName, ',', '', []), 1, Length(Params[I].ParamName));
             A          := GetParamIndex(vTempQuery.Params, vParamName);
             If A > -1 Then//vTempQuery.ParamByName(vParamName) <> Nil Then
              Begin
               If vTempQuery.Params[A].DataType in [{$IFNDEF FPC}{$if CompilerVersion > 21} // Delphi 2010 pra baixo
                                                     ftFixedChar, ftFixedWideChar,{$IFEND}{$ENDIF}
                                                     ftString,    ftWideString]    Then
                Begin
                 If vTempQuery.Params[A].Size > 0 Then
                  vTempQuery.Params[A].Value := Copy(Params[I].Value, 1, vTempQuery.Params[A].Size)
                 Else
                  vTempQuery.Params[A].Value := Params[I].Value;
                End
               Else
                Begin
                 If vTempQuery.Params[A].DataType in [ftUnknown] Then
                  Begin
                   If Not (ObjectValueToFieldType(Params[I].ObjectValue) in [ftUnknown]) Then
                    vTempQuery.Params[A].DataType := ObjectValueToFieldType(Params[I].ObjectValue)
                   Else
                    vTempQuery.Params[A].DataType := ftString;
                  End;
                 If vTempQuery.Params[A].DataType in [ftInteger, ftSmallInt, ftWord, ftLongWord, ftLargeint] Then
                  Begin
                   If Trim(Params[I].Value) <> '' Then
                    Begin
                     If vTempQuery.Params[A].DataType in [ftLongWord, ftLargeint] Then
                      vTempQuery.Params[A].AsLargeInt := StrToInt64(Params[I].Value)
                     Else If vTempQuery.Params[A].DataType = ftSmallInt Then
                      vTempQuery.Params[A].AsSmallInt := StrToInt(Params[I].Value)
                     Else
                      vTempQuery.Params[A].AsInteger  := StrToInt(Params[I].Value);
                    End
                   Else
                    vTempQuery.Params[A].Clear;
                  End
                 Else If vTempQuery.Params[A].DataType in [ftFloat,   ftCurrency, ftBCD, ftFMTBcd, ftSingle] Then
                  Begin
                   If Trim(Params[I].Value) <> '' Then
                    vTempQuery.Params[A].AsFloat  := StrToFloat(BuildFloatString(Params[I].Value))
                   Else
                    vTempQuery.Params[A].Clear;
                  End
                 Else If vTempQuery.Params[A].DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] Then
                  Begin
                   If Trim(Params[I].Value) <> '' Then
                    vTempQuery.Params[A].AsDateTime  := Params[I].AsDateTime
                   Else
                    vTempQuery.Params[A].Clear;
                  End  //Tratar Blobs de Parametros...
                 Else If vTempQuery.Params[A].DataType in [ftBytes, ftVarBytes, ftBlob,
                                                           ftGraphic, ftOraBlob, ftOraClob,
                                                           ftMemo {$IFNDEF FPC}
                                                                   {$IF CompilerVersion > 21}
                                                                    , ftWideMemo
                                                                   {$IFEND}
                                                                  {$ENDIF}] Then
                  Begin
                   vStringStream := TMemoryStream.Create;
                   Try
                    Params[I].SaveToStream(vStringStream);
                    vStringStream.Position := 0;
                    If vStringStream.Size > 0 Then
                     vTempQuery.Params[A].LoadFromStream(vStringStream, ftBlob);
                   Finally
                    FreeAndNil(vStringStream);
                   End;
                  End
                 Else
                  vTempQuery.Params[A].Value    := Params[I].Value;
                End;
              End;
            End
           Else
            Break;
          End;
        End;
       vTempQuery.Open;
       If Result = Nil Then
        Result         := TJSONValue.Create;
       Result.Encoding := Encoding;
       Result.Encoded  := EncodeStringsJSON;
       Result.LoadFromDataset('RESULTDATA', vTempQuery, EncodeStringsJSON);
       Error         := False;
      Except
       On E : Exception do
        Begin
         Try
          Error          := True;
          MessageError   := E.Message;
          If Result = Nil Then
           Result        := TJSONValue.Create;
          Result.Encoded := True;
          Result.SetValue(GetPairJSON('NOK', MessageError));
          vFDConnection.RollbackRetaining;
         Except
         End;
        End;
      End;
     End;
   End;
 Finally
  vTempQuery.Close;
  vTempQuery.Free;
 End;
End;

Function TRESTDWDriverFD.ExecuteCommand(SQL              : String;
                                        Var Error        : Boolean;
                                        Var MessageError : String;
                                        Execute          : Boolean) : String;
Var
 vTempQuery   : TFDQuery;
 aResult      : TJSONValue;
Begin
 Inherited;
 Result := '';
 Error  := False;
 aResult := Nil;
 vTempQuery               := TFDQuery.Create(Owner);
 Try
  If Not vFDConnection.Connected Then
   vFDConnection.Connected := True;
  vTempQuery.Connection   := vFDConnection;
  vTempQuery.FormatOptions.StrsTrim       := StrsTrim;
  vTempQuery.FormatOptions.StrsEmpty2Null := StrsEmpty2Null;
  vTempQuery.FormatOptions.StrsTrim2Len   := StrsTrim2Len;
  vTempQuery.SQL.Clear;
  vTempQuery.SQL.Add(SQL);
  If Not Execute Then
   Begin
    vTempQuery.Open;
    vTempQuery.fetchall;
    aResult         := TJSONValue.Create;
    aResult.Encoding := Encoding;
    Try
     aResult.LoadFromDataset('RESULTDATA', vTempQuery, EncodeStringsJSON);
     Result := aResult.ToJSON;
     FreeAndNil(aResult);
     Error         := False;
    Finally
    End;
   End
  Else
   Begin
    try
      vTempQuery.ExecSQL;
      If aResult = Nil Then
       aResult := TJSONValue.Create;
      vFDConnection.CommitRetaining;
      aResult.SetValue('COMMANDOK');
      Result := aResult.ToJSON;
      FreeAndNil(aResult);
      Error         := False;
    Finally
    End;
   End;
 Except
  On E : Exception do
   Begin
    Try
     Error          := True;
     MessageError   := E.Message;
     If aResult = Nil Then
      aResult        := TJSONValue.Create;
     aResult.Encoded := True;
     aResult.SetValue(GetPairJSON('NOK', MessageError));
     Result := aResult.ToJSON;
     vFDConnection.RollbackRetaining;
    Except
    End;

   End;
 End;
 vTempQuery.Close;
 vTempQuery.Free;
End;

Function TRESTDWDriverFD.GetConnection: TFDConnection;
Begin
 Result := vFDConnectionBack;
End;

Function TRESTDWDriverFD.InsertMySQLReturnID(SQL              : String;
                                             Params           : TDWParams;
                                             Var Error        : Boolean;
                                             Var MessageError : String): Integer;
Var
 oTab        : TFDDatStable;
 A, I        : Integer;
 vParamName  : String;
 fdCommand   : TFDCommand;
 vStringStream : TMemoryStream;
 Function GetParamIndex(Params : TFDParams; ParamName : String) : Integer;
 Var
  I : Integer;
 Begin
  Result := -1;
  For I := 0 To Params.Count -1 Do
   Begin
    If UpperCase(Params[I].Name) = UpperCase(ParamName) Then
     Begin
      Result := I;
      Break;
     End;
   End;
 End;
Begin
  Inherited;
 Result := -1;
 Error  := False;
 fdCommand := TFDCommand.Create(Owner);
 Try
  fdCommand.Connection := vFDConnection;
  fdCommand.CommandText.Clear;
  fdCommand.CommandText.Add(SQL + '; SELECT LAST_INSERT_ID()ID');
  If Params <> Nil Then
   Begin
    Try
    // vTempQuery.Prepare;
    Except
    End;
    For I := 0 To Params.Count -1 Do
     Begin
      If fdCommand.Params.Count > I Then
       Begin
        vParamName := Copy(StringReplace(Params[I].ParamName, ',', '', []), 1, Length(Params[I].ParamName));
        A          := GetParamIndex(fdCommand.Params, vParamName);
        If A > -1 Then//vTempQuery.ParamByName(vParamName) <> Nil Then
         Begin
          If fdCommand.Params[A].DataType in [{$IFNDEF FPC}{$if CompilerVersion > 21} // Delphi 2010 pra baixo
                                                ftFixedChar, ftFixedWideChar,{$IFEND}{$ENDIF}
                                                ftString,    ftWideString]    Then
           Begin
            If fdCommand.Params[A].Size > 0 Then
             fdCommand.Params[A].Value := Copy(Params[I].Value, 1, fdCommand.Params[A].Size)
            Else
             fdCommand.Params[A].Value := Params[I].Value;
           End
          Else
           Begin
            If fdCommand.Params[A].DataType in [ftUnknown] Then
             Begin
              If Not (ObjectValueToFieldType(Params[I].ObjectValue) in [ftUnknown]) Then
               fdCommand.Params[A].DataType := ObjectValueToFieldType(Params[I].ObjectValue)
              Else
               fdCommand.Params[A].DataType := ftString;
             End;
            If fdCommand.Params[A].DataType in [ftInteger, ftSmallInt, ftWord, ftLongWord, ftLargeint] Then
             Begin
              If Trim(Params[I].Value) <> '' Then
               Begin
                 // Alterado por: Alexandre Magno - 04/11/2017
                 If fdCommand.Params[A].DataType in [ftLongWord, ftLargeint] Then
                   fdCommand.Params[A].AsLargeInt := StrToInt64(Params[I].Value)
                 else If fdCommand.Params[A].DataType = ftSmallInt Then
                   fdCommand.Params[A].AsSmallInt := StrToInt(Params[I].Value)
                 Else
                   fdCommand.Params[A].AsInteger  := StrToInt(Params[I].Value);

                 // Como estava Anteriormente
                 //If fdCommand.Params[A].DataType = ftSmallInt Then
                 //  fdCommand.Params[A].AsSmallInt := StrToInt(Params[I].Value)
                 //Else
                 //  fdCommand.Params[A].AsInteger  := StrToInt(Params[I].Value);
               End;
             End
            Else If fdCommand.Params[A].DataType in [ftFloat,   ftCurrency, ftBCD, ftFMTBcd, ftSingle] Then
             Begin
              If Trim(Params[I].Value) <> '' Then
               fdCommand.Params[A].AsFloat  := StrToFloat(BuildFloatString(Params[I].Value));
             End
            Else If fdCommand.Params[A].DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] Then
             Begin
              If Trim(Params[I].Value) <> '' Then
               fdCommand.Params[A].AsDateTime  := Params[I].AsDateTime
              Else
               fdCommand.Params[A].AsDateTime  := Null;
             End  //Tratar Blobs de Parametros...
            Else If fdCommand.Params[A].DataType in [ftBytes, ftVarBytes, ftBlob,
                                                     ftGraphic, ftOraBlob, ftOraClob,
                                                     ftMemo {$IFNDEF FPC}
                                                             {$IF CompilerVersion > 21}
                                                              , ftWideMemo
                                                             {$IFEND}
                                                            {$ENDIF}] Then
             Begin
              vStringStream := TMemoryStream.Create;
              Try
               Params[I].SaveToStream(vStringStream);
               vStringStream.Position := 0;
               If vStringStream.Size > 0 Then
                fdCommand.Params[A].LoadFromStream(vStringStream, ftBlob);
              Finally
               FreeAndNil(vStringStream);
              End;
             End
            Else
             fdCommand.Params[A].Value    := Params[I].Value;
           End;
         End;
       End
      Else
       Break;
     End;
   End;
  fdCommand.Open;
  oTab := fdCommand.Define;
  fdCommand.Fetch(oTab, True);
  If oTab.Rows.Count > 0 Then
   Result := StrToInt(oTab.Rows[0].AsString['ID']);
  vFDConnection.CommitRetaining;
 Except
  On E : Exception do
   Begin
    vFDConnection.RollbackRetaining;
    Error        := True;
    MessageError := E.Message;
   End;
 End;
 fdCommand.Close;
 FreeAndNil(fdCommand);
 FreeAndNil(oTab);
End;

Function TRESTDWDriverFD.OpenDatasets       (DatasetsLine     : String;
                                             Var Error        : Boolean;
                                             Var MessageError : String): TJSONValue;
Var
 vTempQuery  : TFDQuery;
 vTempJSON   : TJSONValue;
 vJSONLine   : String;
 I, X        : Integer;
 DWParams    : TDWParams;
 bJsonArray  : TDWJSONArray;
 bJsonValue  : TDWJSONObject;
Begin
 Inherited;
 Error  := False;
 bJsonArray := Nil;
 vTempQuery               := TFDQuery.Create(Nil);
 Try
  If Not vFDConnection.Connected Then
   vFDConnection.Connected := True;
  vTempQuery.Connection   := vFDConnection;
  vTempQuery.FormatOptions.StrsTrim       := StrsTrim;
  vTempQuery.FormatOptions.StrsEmpty2Null := StrsEmpty2Null;
  vTempQuery.FormatOptions.StrsTrim2Len   := StrsTrim2Len;
  bJsonValue  := TDWJSONObject.create(DatasetsLine);
  For I := 0 To bJsonValue.PairCount - 1 Do
   Begin
    bJsonArray  := bJsonValue.OpenArray(I);
    vTempQuery.Close;
    vTempQuery.SQL.Clear;
    vTempQuery.SQL.Add(DecodeStrings(TDWJSONObject(bJsonArray).Pairs[0].Value));
    If bJsonArray.ElementCount > 1 Then
     Begin
      DWParams := TDWParams.Create;
      Try
       DWParams.FromJSON(DecodeStrings(TDWJSONObject(bJsonArray).Pairs[1].Value));
       For X := 0 To DWParams.Count -1 Do
        Begin
         If vTempQuery.ParamByName(DWParams[X].ParamName) <> Nil Then
          Begin
           vTempQuery.ParamByName(DWParams[X].ParamName).DataType := ObjectValueToFieldType(DWParams[X].ObjectValue);
           vTempQuery.ParamByName(DWParams[X].ParamName).Value    := DWParams[X].Value;
          End;
        End;
      Finally
       DWParams.Free;
      End;
     End;
    vTempQuery.Open;
    vTempJSON  := TJSONValue.Create;
    vTempJSON.Encoding := Encoding;
    vTempJSON.LoadFromDataset('RESULTDATA', vTempQuery, EncodeStringsJSON);
    Try
     If Length(vJSONLine) = 0 Then
      vJSONLine := Format('%s', [vTempJSON.ToJSON])
     Else
      vJSONLine := vJSONLine + Format(', %s', [vTempJSON.ToJSON]);
    Finally
     vTempJSON.Free;
    End;
    FreeAndNil(bJsonArray);
   End;
 Except
  On E : Exception do
   Begin
    Try
     Error          := True;
     MessageError   := E.Message;
     vJSONLine      := GetPairJSON('NOK', MessageError);
    Except
    End;
   End;
 End;
 Result             := TJSONValue.Create;
 Result.Encoding    := Encoding;
 Result.ObjectValue := ovBlob;
 Try
  vJSONLine         := Format('[%s]', [vJSONLine]);
  Result.StringToBytes(vJSONLine, EncodeStringsJSON);
//  Result.SetValue(vJSONLine);
 Finally

 End;
 vTempQuery.Close;
 vTempQuery.Free;
 If bJsonValue <> Nil Then
  FreeAndNil(bJsonValue);
End;

Procedure TRESTDWDriverFD.PrepareConnection(Var ConnectionDefs : TConnectionDefs);
 Procedure ServerParamValue(ParamName, Value : String);
 Var
  I, vIndex : Integer;
  vFound : Boolean;
 Begin
  vFound := False;
  vIndex := -1;
  For I := 0 To vFDConnection.Params.Count -1 Do
   Begin
    If Lowercase(vFDConnection.Params.Names[I]) = Lowercase(ParamName) Then
     Begin
      vFound := True;
      vIndex := I;
      Break;
     End;
   End;
  If Not (vFound) Then
   vFDConnection.Params.Add(Format('%s=%s', [ParamName, Value]))
  Else
   vFDConnection.Params[vIndex] := Format('%s=%s', [ParamName, Value]);
 End;
Begin
 Inherited;
 If Assigned(ConnectionDefs) Then
  Begin
   Case ConnectionDefs.DriverType Of
    dbtUndefined  : Begin

                    End;
    dbtAccess     : Begin
                     vFDConnection.DriverName := 'MSAcc';

                    End;
    dbtDbase      : Begin

                    End;
    dbtFirebird   : Begin
                     vFDConnection.DriverName := 'FB';
                     If Assigned(OnPrepareConnection) Then
                      OnPrepareConnection(ConnectionDefs);
                     ServerParamValue('Server',    ConnectionDefs.HostName);
                     ServerParamValue('Port',      IntToStr(ConnectionDefs.dbPort));
                     ServerParamValue('Database',  ConnectionDefs.DatabaseName);
                     ServerParamValue('User_Name', ConnectionDefs.Username);
                     ServerParamValue('Password',  ConnectionDefs.Password);
                     ServerParamValue('Protocol',  Uppercase(ConnectionDefs.Protocol));
                    End;
    dbtInterbase  : Begin
                     vFDConnection.DriverName := 'IB';
                     If Assigned(OnPrepareConnection) Then
                      OnPrepareConnection(ConnectionDefs);
                     ServerParamValue('Server',    ConnectionDefs.HostName);
                     ServerParamValue('Port',      IntToStr(ConnectionDefs.dbPort));
                     ServerParamValue('Database',  ConnectionDefs.DatabaseName);
                     ServerParamValue('User_Name', ConnectionDefs.Username);
                     ServerParamValue('Password',  ConnectionDefs.Password);
                     ServerParamValue('Protocol',  Uppercase(ConnectionDefs.Protocol));
                    End;
    dbtMySQL      : Begin
                     vFDConnection.DriverName := 'MYSQL';

                    End;
    dbtSQLLite    : Begin
                     vFDConnection.DriverName := 'SQLLite';

                    End;
    dbtOracle     : Begin
                     vFDConnection.DriverName := 'Ora';

                    End;
    dbtMsSQL      : Begin
                     vFDConnection.DriverName := 'MSSQL';
                     If Assigned(OnPrepareConnection) Then
                      OnPrepareConnection(ConnectionDefs);
                     ServerParamValue('DriverID',  ConnectionDefs.DriverID);
                     ServerParamValue('Server',    ConnectionDefs.HostName);
                     ServerParamValue('Port',      IntToStr(ConnectionDefs.dbPort));
                     ServerParamValue('Database',  ConnectionDefs.DatabaseName);
                     ServerParamValue('User_Name', ConnectionDefs.Username);
                     ServerParamValue('Password',  ConnectionDefs.Password);
                     ServerParamValue('Protocol',  Uppercase(ConnectionDefs.Protocol));
                    End;
    dbtODBC       : Begin
                     vFDConnection.DriverName := 'ODBC';
                     If Assigned(OnPrepareConnection) Then
                      OnPrepareConnection(ConnectionDefs);
                     ServerParamValue('DataSource', ConnectionDefs.DataSource);
                    End;
    dbtParadox    : Begin

                    End;
    dbtPostgreSQL : Begin
                     vFDConnection.DriverName := 'PG';

                    End;
   End;
  End;
End;

Function TRESTDWDriverFD.InsertMySQLReturnID(SQL              : String;
                                             Var Error        : Boolean;
                                             Var MessageError : String): Integer;
Var
 oTab      : TFDDatStable;
 fdCommand : TFDCommand;
Begin
  Inherited;
 Result := -1;
 Error  := False;
 fdCommand := TFDCommand.Create(Owner);
 Try
  fdCommand.Connection := vFDConnection;
  fdCommand.CommandText.Clear;
  fdCommand.CommandText.Add(SQL + '; SELECT LAST_INSERT_ID()ID');
  fdCommand.Open;
  oTab := fdCommand.Define;
  fdCommand.Fetch(oTab, True);
  If oTab.Rows.Count > 0 Then
   Result := StrToInt(oTab.Rows[0].AsString['ID']);
  vFDConnection.CommitRetaining;
 Except
  On E : Exception do
   Begin
    vFDConnection.RollbackRetaining;
    Error        := True;
    MessageError := E.Message;
   End;
 End;
 fdCommand.Close;
 FreeAndNil(fdCommand);
 FreeAndNil(oTab);
End;

Procedure TRESTDWDriverFD.SetConnection(Value: TFDConnection);
Begin
 vFDConnectionBack := Value;
 If Value <> Nil Then
  vFDConnection    := vFDConnectionBack
 Else
  Begin
   If vFDConnection <> Nil Then
    vFDConnection.Close;
  End;
End;

end.
