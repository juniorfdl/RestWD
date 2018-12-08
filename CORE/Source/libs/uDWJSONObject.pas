Unit uDWJSONObject;

{$I uRESTDW.inc}

Interface

Uses
  uDWJSONInterface, uDWResponseTranslator, IdURI,
  {$IFDEF FPC}
   SysUtils, Classes, uDWJSONTools, IdGlobal, DB, uDWJSON, uDWConsts,
   uDWConstsData, memds, LConvEncoding
  {$ELSE}
   {$IF CompilerVersion > 21} // Delphi 2010 pra cima
    System.SysUtils, System.Classes, uDWJSONTools, uDWConsts,
    uDWConstsData, IdGlobal, System.Rtti, Data.DB, Soap.EncdDecd
    {$IF Defined(HAS_FMX)} // Alteardo para IOS Brito
     , System.json, FMX.Types
    {$ELSE}
     , uDWJSON
    {$IFEND}
    {$IFDEF RESJEDI}
    , JvMemoryDataset
    {$ENDIF}
    {$IFDEF CLIENTDATASET}
    , Datasnap.DbClient
    {$ENDIF}
    {$IFDEF RESTKBMMEMTABLE}
    , kbmmemtable
    {$ENDIF}
    {$IFDEF RESTFDMEMTABLE}
    , FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
      FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
      FireDAC.Comp.DataSet, FireDAC.Comp.Client
    {$ENDIF}
   {$ELSE}
    SysUtils, Classes, uDWJSONTools, uDWJSON, IdGlobal, DB, EncdDecd,
    DbClient, uDWConsts, uDWConstsData
    {$IFDEF RESJEDI}
    , JvMemoryDataset
    {$ENDIF}
    {$IFDEF RESTKBMMEMTABLE}
    , kbmmemtable
    {$ENDIF}
  {$IFEND}
  {$ENDIF}
  , Variants;

Const // \b  \t  \n   \f   \r
  TSpecialChars: Array [0 .. 7] of Char = ('\', '"', '/', #8, #9, #10, #12, #13);

Type
 TJSONBufferObject = Class
End;

Type
 TJSONValue = Class
 Private
  vJsonMode        : TJsonMode;
  vNullValue,
  vBinary,
  vEncoded         : Boolean;
  vFloatDecimalFormat,
  vtagName         : String;
  vTypeObject      : TTypeObject;
  vObjectDirection : TObjectDirection;
  vObjectValue     : TObjectValue;
  aValue           : TIdBytes;
  vEncoding        : TEncodeSelect;
  {$IFDEF FPC}
  vEncodingLazarus : TEncoding;
  vDatabaseCharSet : TDatabaseCharSet;
  {$ENDIF}
  Function  GetValue      : String;
  Procedure WriteValue   (bValue             : String);
  Function  FormatValue  (bValue             : String) : String;
  Function  GetValueJSON (bValue             : String) : String;
  Function  DatasetValues(bValue             : TDataset;
                          DateTimeFormat     : String = '';
                          JsonModeD          : TJsonMode = jmDataware;
                          FloatDecimalFormat : String = '') : String;
  Function  EncodedString : String;
  Procedure SetEncoding  (bValue             : TEncodeSelect);
 Public
  Procedure ToStream       (Var bValue       : TMemoryStream);
  Procedure LoadFromDataset(TableName        : String;
                            bValue           : TDataset;
                            EncodedValue     : Boolean = True;
                            JsonModeD        : TJsonMode = jmDataware;
                            DateTimeFormat   : String = '';
                            DelimiterFormat  : String = ''{$IFDEF FPC};
                            CharSet          : TDatabaseCharSet = csUndefined{$ENDIF});
  Procedure WriteToFieldDefs(JSONValue                : String;
                             Const ResponseTranslator : TDWResponseTranslator);
  procedure WriteToDataset2(JSONValue: String; DestDS: TDataset);
  Procedure WriteToDataset (JSONValue          : String;
                            Const DestDS       : TDataset;
                            ResponseTranslator : TDWResponseTranslator;
                            ResquestMode       : TResquestMode);Overload;
  Procedure WriteToDataset (DatasetType      : TDatasetType;
                            JSONValue        : String;
                            DestDS           : TDataset;
                            Var JsonCount    : Integer;
                            Datapacks        : Integer          = -1;
                            ActualRec        : Integer          = 0;
                            ClearDataset     : Boolean          = False{$IFDEF FPC};
                            CharSet          : TDatabaseCharSet = csUndefined{$ENDIF});Overload;
  Procedure WriteToDataset (DatasetType      : TDatasetType;
                            JSONValue        : String;
                            DestDS           : TDataset;
                            ClearDataset     : Boolean          = False{$IFDEF FPC};
                            CharSet          : TDatabaseCharSet = csUndefined{$ENDIF});Overload;
  Procedure LoadFromJSON   (bValue           : String);Overload;
  Procedure LoadFromJSON   (bValue           : String;
                            JsonModeD        : TJsonMode);Overload;
  Procedure LoadFromStream (Stream           : TMemoryStream;
                            Encode           : Boolean = True);
  Procedure SaveToStream   (Stream           : TMemoryStream;
                            Binary           : Boolean = False);
  Procedure SaveToFile     (FileName         : String);
  Procedure StringToBytes  (Value            : String;
                            Encode           : Boolean = False);
  Function  ToJSON : String;
  Procedure SetValue       (Value            : String;
                            Encode           : Boolean = True);
  Function  Value  : String;
  Constructor Create;
  Destructor  Destroy; Override;
  Function IsNull  : Boolean;
  Property TypeObject         : TTypeObject      Read vTypeObject         Write vTypeObject;
  Property ObjectDirection    : TObjectDirection Read vObjectDirection    Write vObjectDirection;
  Property ObjectValue        : TObjectValue     Read vObjectValue        Write vObjectValue;
  Property Binary             : Boolean          Read vBinary             Write vBinary;
  Property Encoding           : TEncodeSelect    Read vEncoding           Write SetEncoding;
  Property Tagname            : String           Read vtagName            Write vtagName;
  Property Encoded            : Boolean          Read vEncoded            Write vEncoded;
  Property JsonMode           : TJsonMode        Read vJsonMode           Write vJsonMode;
  Property FloatDecimalFormat : String           Read vFloatDecimalFormat Write vFloatDecimalFormat;
  {$IFDEF FPC}
  Property DatabaseCharSet : TDatabaseCharSet Read vDatabaseCharSet Write vDatabaseCharSet;
  {$ENDIF}
End;

Type
 PJSONParam = ^TJSONParam;
 TJSONParam = Class(TObject)
 Private
  vJSONValue       : TJSONValue;
  vJsonMode        : TJsonMode;
  vEncoding        : TEncodeSelect;
  vTypeObject      : TTypeObject;
  vObjectDirection : TObjectDirection;
  vObjectValue     : TObjectValue;
  vFloatDecimalFormat,
  vParamName       : String;
  vBinary,
  vEncoded         : Boolean;
  Procedure WriteValue     (bValue     : String);
  Procedure SetParamName   (bValue     : String);
  Function  GetAsString : String;
  Procedure SetAsString    (Value      : String);
  {$IFDEF DEFINE(FPC) Or NOT(Defined(HAS_FMX))}
  Function  GetAsWideString : WideString;
  Procedure SetAsWideString(Value      : WideString);
  Function  GetAsAnsiString : AnsiString;
  Procedure SetAsAnsiString(Value      : AnsiString);
  {$ENDIF}
  Function  GetAsBCD      : Currency;
  Procedure SetAsBCD      (Value       : Currency);
  Function  GetAsFMTBCD   : Currency;
  Procedure SetAsFMTBCD   (Value       : Currency);
  Function  GetAsCurrency : Currency;
  Procedure SetAsCurrency (Value       : Currency);
  Function  GetAsBoolean  : Boolean;
  Procedure SetAsBoolean  (Value       : Boolean);
  Function  GetAsDateTime : TDateTime;
  Procedure SetAsDateTime (Value       : TDateTime);
  Procedure SetAsDate     (Value       : TDateTime);
  Procedure SetAsTime     (Value       : TDateTime);
  Function  GetAsSingle    : Single;
  Procedure SetAsSingle   (Value       : Single);
  Function  GetAsFloat     : Double;
  Procedure SetAsFloat    (Value       : Double);
  Function  GetAsInteger  : Integer;
  Procedure SetAsInteger  (Value       : Integer);
  Function  GetAsWord     : Word;
  Procedure SetAsWord     (Value       : Word);
  Procedure SetAsSmallInt (Value       : Integer);
  Procedure SetAsShortInt (Value       : Integer);
  Function  GetAsLongWord : LongWord;
  Procedure SetAsLongWord (Value       : LongWord);
  Function  GetAsLargeInt : LargeInt;
  Procedure SetAsLargeInt (Value       : LargeInt);
  Procedure SetObjectValue(Value       : TObjectValue);
  Procedure SetObjectDirection(Value   : TObjectDirection);
  Function  GetByteString : String;
  Procedure SetAsObject   (Value       : String);
  Procedure SetEncoded    (Value       : Boolean);
 Public
  Constructor Create      (Encoding    : TEncodeSelect);
  Destructor  Destroy; Override;
  Function    IsEmpty : Boolean;
  Procedure   FromJSON    (json        : String);
  Function    ToJSON  : String;
  Procedure   SaveToFile  (FileName       : String);
  Procedure   CopyFrom    (JSONParam   : TJSONParam);
  Procedure   SetVariantValue(Value    : Variant);
  Procedure   SetDataValue   (Value    : Variant;
                              DataType : TObjectValue);
  Function  GetVariantValue : Variant;
  Function  GetValue         (Value    : TObjectValue) : Variant;
  Procedure SetValue         (aValue   : String;
                              Encode   : Boolean = True);
  Procedure LoadFromStream   (Stream   : TMemoryStream;
                              Encode   : Boolean = True);
  Procedure StringToBytes    (Value    : String;
                              Encode   : Boolean = False);
  Procedure SaveToStream     (Stream   : TMemoryStream);
  Procedure LoadFromParam    (Param    : TParam);
  Property ObjectDirection    : TObjectDirection Read vObjectDirection    Write SetObjectDirection;
  Property ObjectValue        : TObjectValue     Read vObjectValue        Write SetObjectValue;
  Property ParamName          : String           Read vParamName          Write SetParamName;
  Property Encoded            : Boolean          Read vEncoded            Write SetEncoded;
  Property Binary             : Boolean          Read vBinary;
  Property JsonMode           : TJsonMode        Read vJsonMode           Write vJsonMode;
  Property FloatDecimalFormat : String           Read vFloatDecimalFormat Write vFloatDecimalFormat;
  // Propriedades Novas
  Property Value              : Variant          Read GetVariantValue     Write SetVariantValue;
  // Novas definições por tipo
  Property AsBCD              : Currency         Read GetAsBCD            Write SetAsBCD;
  Property AsFMTBCD           : Currency         Read GetAsFMTBCD         Write SetAsFMTBCD;
  Property AsBoolean          : Boolean          Read GetAsBoolean        Write SetAsBoolean;
  Property AsCurrency         : Currency         Read GetAsCurrency       Write SetAsCurrency;
  Property AsExtended         : Currency         Read GetAsCurrency       Write SetAsCurrency;
  Property AsDate             : TDateTime        Read GetAsDateTime       Write SetAsDate;
  Property AsTime             : TDateTime        Read GetAsDateTime       Write SetAsTime;
  Property AsDateTime         : TDateTime        Read GetAsDateTime       Write SetAsDateTime;
  Property AsSingle           : Single           Read GetAsSingle         Write SetAsSingle;
  Property AsFloat            : Double           Read GetAsFloat          Write SetAsFloat;
  Property AsInteger          : Integer          Read GetAsInteger        Write SetAsInteger;
  Property AsSmallInt         : Integer          Read GetAsInteger        Write SetAsSmallInt;
  Property AsShortInt         : Integer          Read GetAsInteger        Write SetAsShortInt;
  Property AsWord             : Word             Read GetAsWord           Write SetAsWord;
  Property AsLongWord         : LongWord         Read GetAsLongWord       Write SetAsLongWord;
  Property AsLargeInt         : LargeInt         Read GetAsLargeInt       Write SetAsLargeInt;
  Property AsString           : String           Read GetAsString         Write SetAsString;
  Property AsObject           : String           Read GetAsString         Write SetAsObject;
  Property AsByteString       : String           Read GetByteString;
  {$IFDEF DEFINE(FPC) Or NOT(Defined(HAS_FMX))}
  Property AsWideString       : WideString       Read GetAsWideString     Write SetAsWideString;
  Property AsAnsiString       : AnsiString       Read GetAsAnsiString     Write SetAsAnsiString;
  {$ENDIF}
  Property AsMemo             : String           Read GetAsString         Write SetAsString;
End;

Type
 PStringStream = ^TStringStream;
 TStringStreamList = Class(TList)
 Private
  Function  GetRec(Index : Integer): TStringStream; Overload;
  Procedure PutRec(Index : Integer;
                   Item  : TStringStream); Overload;
  Procedure ClearList;
 Public
  Constructor Create;
  Destructor  Destroy; Override;
  Procedure   Delete(Index : Integer); Overload;
  Function    Add   (Item  : TStringStream) : Integer; Overload;
  Property    Items [Index : Integer] : TStringStream Read GetRec Write PutRec; Default;
End;

Type
 TDWParams = Class(TList)
 Private
  vJsonMode : TJsonMode;
  vEncoding : TEncodeSelect;
  Function  GetRec    (Index : Integer) : TJSONParam; Overload;
  Procedure PutRec    (Index : Integer;
                       Item  : TJSONParam); Overload;
  Function  GetRecName(Index : String)  : TJSONParam; Overload;
  Procedure PutRecName(Index : String;
                       Item  : TJSONParam); Overload;
  Procedure ClearList;
 Public
  Constructor Create;
  Destructor  Destroy; Override;
  Function    ParamsReturn         : Boolean;
  Function    CountOutParams       : Integer;
  Function    ToJSON               : String;
  Procedure   SaveToFile (FileName : String);
  Procedure   FromJSON   (json     : String);
  Procedure   CopyFrom   (DWParams : TDWParams);
  Procedure   Delete     (Index    : Integer); Overload;
  Function    Add        (Item     : TJSONParam) : Integer; Overload;
  Property    Items      [Index    : Integer]    : TJSONParam Read GetRec     Write PutRec; Default;
  Property    ItemsString[Index    : String]     : TJSONParam Read GetRecName Write PutRecName;
  Property    JsonMode             : TJsonMode                Read vJsonMode  Write vJsonMode;
  Property    Encoding             : TEncodeSelect            Read vEncoding  Write vEncoding;
End;

Type
 TDWDatalist = Class
End;

Function StringToJsonString(OriginalString : String) : String;

implementation

Uses
 uRESTDWPoolerDB;


Function escape_chars(s: string): string;
Var
 b, c : char;
 i, len : integer;
 sb, t : string;
 Const
  NoConversion = ['A'..'Z','a'..'z','*','@','.','_','-',
                  '0'..'9','$','!','''','(',')'];
 Function toHexString(c : char) : String;
 Begin
  Result := IntToHex(ord(c), 2);
 End;
Begin
 b      := #0;
 c      := #0;
 i      := 0;
 len    := length(s);
 Result := '';
  //SetLength (s, len+4);
 t      := '';
 sb     := '';
 For  i := InitStrPos to len - FinalStrPos Do
  Begin
   b := c;
   c := s[i];
   Case (c) Of
    '\', '"' : Begin
                sb := sb + '\';
                sb := sb + c;
               End;
    '/' :      Begin
                If (b = '<') Then
                 sb := sb + '\';
                sb := sb + c;
               End;
    #8  :      Begin
                sb := sb + '\b';
               End;
    #9  :      Begin
                sb := sb + '\t';
               End;
    #10 :      Begin
                sb := sb + '\n';
               End;
    #12 :      Begin
                sb := sb + '\f';
               End;
    #13 :      Begin
                sb := sb + '\r';
               End;
    Else       Begin
                If (Not (c in NoConversion)) Then
                 Begin
                    t := '000' + toHexString(c);
                    sb := sb + '\u' + copy (t, Length(t) -3,4);
                 End
                Else
                 sb := sb + c;
               End;
   End;
  End;
 Result := sb;
End;

Procedure SetValueA(Field : TField;
                    Value : String);
Var
 vTempValue : String;
Begin
 Case Field.DataType Of
  ftUnknown,
  ftString,
  ftFixedChar,
  ftWideString : Field.AsString := Value;
  ftAutoInc,
  ftSmallint,
  ftInteger,
  ftLargeint,
  ftWord,
  {$IFNDEF FPC}
   {$IF CompilerVersion > 21} // Delphi 2010 pra cima
    ftByte, ftLongWord,
   {$IFEND}
  {$ENDIF}
  ftBoolean    : Begin
                  Value := Trim(Value);
                  If Value <> '' Then
                   Begin
                    If Field.DataType = ftBoolean Then
                     Begin
                      If (Value = '0') Or (Value = '1') Then
                       Field.AsBoolean := StrToInt(Value) = 1
                      Else
                       Field.AsBoolean := Lowercase(Value) = 'true';
                     End
                    Else
                     Begin
                      If Field.DataType = ftLargeint Then
                       Field.Value := StrToInt64(Value)
                      Else
                       Field.AsInteger := StrToInt(Value);
                     End;
                   End;
                 End;
  ftFloat,
  ftCurrency,
  ftBCD,
  {$IFNDEF FPC}{$IF CompilerVersion > 21}ftExtended, ftSingle,
  {$IFEND}{$ENDIF}
  ftFMTBcd     : Begin
                  Value := Trim(Value);
                  vTempValue := BuildFloatString(Value);
                  If vTempValue <> '' Then
                   Begin
                    Case Field.DataType Of
                     ftFloat  : Field.AsCurrency := StrToFloat(vTempValue);
                     ftCurrency,
                     ftBCD,
                     {$IFNDEF FPC}{$IF CompilerVersion > 21}ftExtended, ftSingle,
                     {$IFEND}{$ENDIF}
                     ftFMTBcd : Begin
                                 If Field.DataType in [ftBCD, ftFMTBcd] Then
                                  {$IFDEF FPC}
                                   Field.AsFloat := StrToFloat(vTempValue)
                                  {$ELSE}
                                   {$IF CompilerVersion > 21}
                                    Field.AsBCD := StrToFloat(vTempValue)
                                   {$ELSE}
                                    Field.AsFloat := StrToFloat(vTempValue)
                                   {$IFEND}
                                  {$ENDIF}
                                 Else
                                  Field.AsFloat := StrToFloat(vTempValue);
                                End;
                    End;
                   End;
                 End;
  ftDate,
  ftTime,
  ftDateTime,
  ftTimeStamp  : Begin
                  vTempValue := Value;
                  If vTempValue <> '' Then
                   If StrToInt64(vTempValue) > 0 then // StrToInt(vTempValue) > 0 Then
                    Field.AsDateTime := UnixToDateTime(StrToInt64(vTempValue));
                 End;
 End;
End;

Function RemoveSTR(Astr: string; Asubstr: string): string;
Begin
 Result := StringReplace(Astr, Asubstr, '', [rfReplaceAll, rfIgnoreCase]);
End;

Function StringToJsonString(OriginalString: String): String;
Var
 I : Integer;
 Function NewChar(OldChar: String): String;
 Begin
  Result := '';
  If Length(OldChar) > 0 Then
   Begin
    Case OldChar[1] Of
     '\' : Result := '\\';
     '"' : Result := '\"';
     '/' : Result := '\/';
     #8  : Result := '\b';
     #9  : Result := '\t';
     #10 : Result := '\n';
     #12 : Result := '\f';
     #13 : Result := '\r';
    End;
   End;
 End;
Begin
 Result := OriginalString;
 For I := 0 To Length(TSpecialChars) - 1 Do
  Result := StringReplace(Result, TSpecialChars[i], NewChar(TSpecialChars[i]), [rfReplaceAll]);
End;

{$IF Defined(ANDROID) or Defined(IOS)}
// Alterado para IOS Brito
Function CopyValue(Var bValue : String): String;
Var
 vOldString,
 vStringBase,
 vTempString,
 deb1, deb2       : string;
 A, vLengthString : Integer;
Begin
 vOldString    := bValue;
 vStringBase   := '"ValueType":"';
 vLengthString := Length(vStringBase) - 1;
 vTempString   := Copy(bValue, Pos(vStringBase, bValue) + vLengthString, Length(bValue) - 1);
 A := Pos(':', vTempString);
 vTempString   := Copy(vTempString, A, Length(vTempString) - 1);
 If vTempString[InitStrPos] = ':' Then
  vTempString  := vTempString.Remove(InitStrPos, 1); // [InitStrPos]:=char(''); //Delete(vTempString, InitStrPos, 1);
 If vTempString[InitStrPos] = '"' Then
  vTempString  := vTempString.Remove(InitStrPos, 1); // vTempString[InitStrPos]:='';//Delete(vTempString, InitStrPos, 1);
 If vTempString = '}' Then
  vTempString  := '';
 If vTempString <> '' Then
  Begin
   For A := Length(vTempString) - 1 Downto InitStrPos Do
    Begin
     If vTempString[Length(vTempString) - 1] <> '}' Then
      vTempString := vTempString.Remove(Length(vTempString) - 1, 1)
     Else
      Begin
       vTempString := vTempString.Remove(Length(vTempString) - 1, 1);
       Break;
      End;
    End;
   If vTempString[Length(vTempString) - 1] = '"' Then
    vTempString := vTempString.Remove(Length(vTempString) - 1, 1);
  End;
 Result := vTempString;
// deb1 := Copy(Result, Length(Result) - 50, Length(Result) - 1);
 bValue := StringReplace(bValue, Result, '', [rfReplaceAll]);
// deb1 := Copy(bValue, Length(bValue) - 50, Length(bValue) - 1);
End;
{$ELSE}
Function CopyValue(Var bValue : String): String;
Var
 vOldString,
 vStringBase,
 vTempString      : String;
 A, vLengthString : Integer;
Begin
 vOldString := bValue;
 vStringBase := '"ValueType":"';
 vLengthString := Length(vStringBase);
 vTempString := Copy(bValue, Pos(vStringBase, bValue) + vLengthString, Length(bValue));
 A := Pos(':', vTempString);
 vTempString := Copy(vTempString, A, Length(vTempString));
 If vTempString[InitStrPos] = ':' Then
  Delete(vTempString, InitStrPos, 1);
 If vTempString[InitStrPos] = '"' Then
  Delete(vTempString, InitStrPos, 1);
 If vTempString = '}' Then
  vTempString := '';
 If vTempString <> '' Then
  Begin
   For A := Length(vTempString) Downto InitStrPos Do
    Begin
     If vTempString[Length(vTempString)] <> '}' Then
      Delete(vTempString, Length(vTempString), 1)
     Else
      Begin
       Delete(vTempString, Length(vTempString), 1);
       Break;
      End;
    End;
   If vTempString[Length(vTempString)] = '"' Then
    Delete(vTempString, Length(vTempString), 1);
  End;
 Result := vTempString;
 bValue := StringReplace(bValue, Result, '', [rfReplaceAll]);
End;
{$IFEND}

Function TDWParams.Add(Item : TJSONParam): Integer;
Var
 vItem : ^TJSONParam;
Begin
 New(vItem);
 vItem^           := Item;
 vItem^.vEncoding := vEncoding;
 vItem^.JsonMode  := vJsonMode;
 Result           := TList(Self).Add(vItem);
End;

Constructor TDWParams.Create;
Begin
 Inherited;
 vJsonMode := jmDataware;
 {$IFNDEF FPC}
  {$IF CompilerVersion > 21}
   vEncoding := esUtf8;
  {$ELSE}
   vEncoding := esASCII;
  {$IFEND}
 {$ELSE}
  vEncoding := esUtf8;
 {$ENDIF}
End;

Function TDWParams.ToJSON : String;
Var
 i : Integer;
Begin
 If Assigned(Self) Then  //Alexandre Magno - 13/11/2018 (quando enviava sem parametro)
   For i := 0 To Self.Count - 1 Do
    Begin
     If TJSONParam(TList(Self).Items[i]^).vObjectValue <> ovUnknown Then
      Begin
       If I = 0 Then
        Result := TJSONParam(TList(Self).Items[i]^).ToJSON
       Else
        Result := Result + ', ' + TJSONParam(TList(Self).Items[i]^).ToJSON;
      End;
    End;
End;

{$IF (NOT Defined(FPC) AND Defined(HAS_FMX))}
// Alteardo para Lazarus LINUX Brito
Procedure TDWParams.FromJSON(json: String);
Var
 bJsonOBJ,
 bJsonValue : System.json.TJsonObject;
 bJsonArray : System.json.TJsonArray;
 JSONParam  : TJSONParam;
 i          : Integer;
Begin
 bJsonValue := TJsonObject.ParseJSONValue(Format('{"PARAMS":[%s]}', [json])) as TJsonObject;
 Try
  bJsonArray := bJsonValue.pairs[0].JSONValue as TJsonArray; // bJsonValue.optJSONArray(bJsonValue.names.get(0).ToString);
  For i := 0 To bJsonArray.Count - 1 Do
   Begin
    JSONParam := TJSONParam.Create(vEncoding);
    bJsonOBJ  := bJsonArray.Items[0] as TJsonObject; // udwjson.TJsonObject.Create(bJsonArray.get(I).ToString);
    Try
     JSONParam.ParamName       := Lowercase(RemoveSTR(bJsonOBJ.pairs[4].jsonstring.ToString, '"'));
     JSONParam.ObjectDirection := GetDirectionName(RemoveSTR(bJsonOBJ.pairs[1].JSONValue.ToString, '"'));
     JSONParam.ObjectValue     := GetValueType(RemoveSTR(bJsonOBJ.pairs[3].JSONValue.ToString, '"'));
     JSONParam.Encoded         := GetBooleanFromString(RemoveSTR(bJsonOBJ.pairs[2].JSONValue.ToString, '"'));
     If (JSONParam.ObjectValue in [ovString, ovWideString]) And (JSONParam.Encoded) Then
      JSONParam.SetValue(DecodeStrings(RemoveSTR(bJsonOBJ.pairs[4].JSONValue.ToString, '"'){$IFDEF FPC}, csUndefined{$ENDIF}))
     Else
      JSONParam.SetValue(bJsonOBJ.pairs[4].JSONValue.ToString, JSONParam.Encoded);
     Add(JSONParam);
    Finally
     FreeAndNil(bJsonOBJ);
    End;
   End;
 Finally
  bJsonValue.Free;
 End;
End;
{$ELSE}
Procedure TDWParams.FromJSON(json: String);
Var
 bJsonOBJ,
 bJsonValue  : uDWJSON.TJsonObject;
 bJsonArray  : uDWJSON.TJsonArray;
 JSONParam   : TJSONParam;
 I           : Integer;
 vTempString : String;
Begin
 vTempString := Format('{"PARAMS":[%s]}', [json]);
 bJsonValue  := uDWJSON.TJsonObject.Create(vTempString);
 Try
  bJsonArray := bJsonValue.optJSONArray(bJsonValue.names.get(0).ToString);
  For i := 0 To bJsonArray.Length - 1 Do
   Begin
    JSONParam := TJSONParam.Create(vEncoding);
    bJsonOBJ := bJsonArray.optJSONObject(i);
    Try
     JSONParam.ParamName       := Lowercase(bJsonOBJ.names.get(4).ToString);
     JSONParam.ObjectDirection := GetDirectionName(bJsonOBJ.opt(bJsonOBJ.names.get(1).ToString).ToString);
     JSONParam.ObjectValue     := GetValueType(bJsonOBJ.opt(bJsonOBJ.names.get(3).ToString).ToString);
     JSONParam.Encoded         := GetBooleanFromString(bJsonOBJ.opt(bJsonOBJ.names.get(2).ToString).ToString);
     If (JSONParam.ObjectValue in [ovString, ovWideString]) And (JSONParam.Encoded) Then
      JSONParam.SetValue(DecodeStrings(bJsonOBJ.opt(bJsonOBJ.names.get(4).ToString).ToString{$IFDEF FPC}, csUndefined{$ENDIF}))
     Else
      JSONParam.SetValue(bJsonOBJ.opt(bJsonOBJ.names.get(4).ToString).ToString, JSONParam.Encoded);
     Add(JSONParam);
    Finally
    End;
   End;
 Finally
  bJsonValue.Free;
 End;
End;
{$IFEND}

Procedure TDWParams.CopyFrom(DWParams : TDWParams);
Var
 I         : Integer;
 p,
 JSONParam : TJSONParam;
Begin
 Clear;
 For i := 0 To DWParams.Count - 1 Do
  Begin
   p         := DWParams.Items[i];
   JSONParam := TJSONParam.Create(DWParams.Encoding);
   JSONParam.CopyFrom(p);
   Add(JSONParam);
  End;
End;

Procedure TDWParams.Delete(Index : Integer);
Begin
 If (Index < Self.Count) And (Index > -1) Then
  Begin
   If Assigned(TList(Self).Items[Index])  Then
    Begin
     FreeAndNil(TList(Self).Items[Index]^);
     {$IFDEF FPC}
      Dispose(PJSONParam(TList(Self).Items[Index]));
     {$ELSE}
      Dispose(TList(Self).Items[Index]);
     {$ENDIF}
    End;
   TList(Self).Delete(Index);
  End;
End;

Procedure TDWParams.ClearList;
Var
 I : Integer;
Begin
 For I := Count - 1 Downto 0 Do
  Delete(i);
 Self.Clear;
End;

Destructor TDWParams.Destroy;
Begin
 ClearList;
 Inherited;
End;

Function TDWParams.GetRec(Index : Integer) : TJSONParam;
Begin
 Result := Nil;
 If (Index < Self.Count) And (Index > -1) Then
  Result := TJSONParam(TList(Self).Items[Index]^);
End;

Function TDWParams.GetRecName(Index : String) : TJSONParam;
Var
 I : Integer;
Begin
 Result := Nil;
 If Assigned(Self) Then  //Alexandre Magno - 13/11/2018 (quando enviava sem parametro)
   For i := 0 To Self.Count - 1 Do
    Begin
     If (Uppercase(Index) = Uppercase(TJSONParam(TList(Self).Items[i]^).vParamName)) Then
      Begin
       Result := TJSONParam(TList(Self).Items[i]^);
       Break;
      End;
    End;
End;

Function TDWParams.CountOutParams : Integer;
Var
 I : Integer;
Begin
 Result := 0;
 For i := 0 To Count - 1 Do
  Begin
   If TJSONParam(TList(Self).Items[i]^).ObjectDirection in [odOUT, odINOUT] Then
    Result := Result + 1;
  End;
End;

Function TDWParams.ParamsReturn : Boolean;
Var
 I : Integer;
Begin
 Result := False;
 If Assigned(Self) Then  //Alexandre Magno - 13/11/2018 (quando enviava sem parametro)
   For i := 0 To Self.Count - 1 Do
    Begin
     Result := Items[i].vObjectDirection In [odOUT, odINOUT];
     If Result Then
      Break;
    End;
End;

Procedure TDWParams.PutRec(Index : Integer;
                           Item  : TJSONParam);
Begin
 If (Index < Self.Count) And (Index > -1) Then
  TJSONParam(TList(Self).Items[Index]^) := Item;
End;

Procedure TDWParams.PutRecName(Index : String;
                               Item  : TJSONParam);
Var
 I : Integer;
Begin
 If Assigned(Self) Then  //Alexandre Magno - 13/11/2018 (quando enviava sem parametro)
   For i := 0 To Self.Count - 1 Do
    Begin
     If (Uppercase(Index) = Uppercase(TJSONParam(TList(Self).Items[i]^).vParamName)) Then
      Begin
       TJSONParam(TList(Self).Items[i]^) := Item;
       Break;
      End;
    End;
End;

Procedure TDWParams.SaveToFile(FileName : String);
Var
 vStringStream : TStringStream;
 {$IFDEF FPC}
 vFileStream   : TFileStream;
 {$ELSE}
   {$IF CompilerVersion < 21} // Delphi 2010 pra cima
   vFileStream : TFileStream;
   {$IFEND}
 {$ENDIF}
Begin
 vStringStream := TStringStream.Create(ToJSON);
 Try
  {$IFDEF FPC}
  vStringStream.Position := 0;
  vFileStream   := TFileStream.Create(FileName, fmCreate);
  Try
   vFileStream.CopyFrom(vStringStream, vStringStream.Size);
  Finally
   vFileStream.Free;
  End;
  {$ELSE}
   {$IF CompilerVersion > 21} // Delphi 2010 pra cima
    vStringStream.Position := 0;
    vStringStream.SaveToFile(FileName);
   {$ELSE}
    vStringStream.Position := 0;
    vFileStream   := TFileStream.Create(FileName, fmCreate);
    Try
     vFileStream.CopyFrom(vStringStream, vStringStream.Size);
    Finally
     vFileStream.Free;
    End;
   {$IFEND}
  {$ENDIF}
 Finally
  vStringStream.Free;
 End;
End;

Function EscapeQuotes(Const S: String): String;
Begin
 // Easy but not best performance
 Result := StringReplace(S,      '\', TSepValueMemString,    [rfReplaceAll]);
 Result := StringReplace(Result, '"', TQuotedValueMemString, [rfReplaceAll]);
End;

Function RevertQuotes(Const S: String): String;
Begin
 // Easy but not best performance
 Result := StringReplace(S,      TSepValueMemString,    '\', [rfReplaceAll]);
 Result := StringReplace(Result, TQuotedValueMemString, '"', [rfReplaceAll]);
End;

Constructor TJSONValue.Create;
Begin
 Inherited;
 {$IFNDEF FPC}
  {$IF CompilerVersion > 18}
   vEncoding       := esUtf8;
  {$ELSE}
   vEncoding       := esASCII;
  {$IFEND}
 {$ELSE}
  vEncoding        := esUtf8;
 {$ENDIF}
 {$IFDEF FPC}
  vDatabaseCharSet := csUndefined;
 {$ENDIF}
 vTypeObject       := toObject;
 ObjectDirection   := odINOUT;
 vObjectValue      := ovString;
 vtagName          := 'TAGJSON';
 vBinary           := True;
 vNullValue        := vBinary;
 vJsonMode         := jmDataware;
End;

Destructor TJSONValue.Destroy;
Begin
 SetLength(aValue, 0);
 Inherited;
End;

Function TJSONValue.GetValueJSON(bValue : String): String;
Begin
 Result := bValue;
 {
 If vObjectValue In [ovString,        ovFixedChar,    ovWideString,
                     ovFixedWideChar, ovDate, ovTime, ovDateTime,
                     ovBlob, ovGraphic, ovOraBlob, ovOraClob,
                     ovMemo, ovWideMemo, ovFmtMemo] Then
  If bValue = '' Then
   Result := '""';
}
End;

Function TJSONValue.IsNull : Boolean;
Begin
 Result := vNullValue;
End;

Function TJSONValue.FormatValue(bValue : String) : String;
Var
 aResult    : String;
 vInsertTag : Boolean;
Begin
 aResult    := StringReplace(bValue, #000, '', [rfReplaceAll]);
 vInsertTag := vObjectValue In [ovDate,    ovTime,    ovDateTime,
                                ovTimestamp];
 If Trim(aResult) <> '' Then
  Begin
   If (aResult[InitStrPos] = '"') And
      (aResult[Length(aResult) - FinalStrPos] = '"') Then
    Begin
     Delete(aResult, 1, 1);
     Delete(aResult, Length(aResult), 1);
    End;
  End;
 If Not vEncoded Then
  Begin
   If Trim(aResult) <> '' Then
    If Not(((Pos('{', aResult) > 0) And (Pos('}', aResult) > 0))  Or
           ((Pos('[', aResult) > 0) And (Pos(']', aResult) > 0))) Then
     If Not(vObjectValue In [ovBlob, ovGraphic, ovOraBlob, ovOraClob]) Then
      aResult := StringToJsonString(aResult);
  End;
 If ((Trim(aResult) = '') or (Trim(bValue) = '"null"')) And vInsertTag Then
  aResult := '""';
 If JsonMode = jmDataware Then
  Begin
   If (vTypeObject  = toDataset) Or
      (vObjectValue = ovObject)  Then
    Result := Format(TValueFormatJSON, ['ObjectType',  GetObjectName(vTypeObject), 'Direction',
                                        GetDirectionName(vObjectDirection),        'Encoded',
                                        EncodedString, 'ValueType', GetValueType(vObjectValue),
                                        vtagName,      GetValueJSON(aResult)])
   Else
    Begin
     If (vObjectValue in [ovString,   ovWideString, ovMemo,
                          ovWideMemo, ovFmtMemo,    ovFixedChar])  Or (vInsertTag) Then
      Result := Format(TValueFormatJSONValueS, ['ObjectType', GetObjectName(vTypeObject), 'Direction',
                                                GetDirectionName(vObjectDirection),       'Encoded',
                                                EncodedString, 'ValueType', GetValueType(vObjectValue),
                                                vtagName, GetValueJSON(aResult)])
     Else If (vObjectValue In [ovFloat, ovCurrency, ovBCD, ovFMTBcd, ovExtended]) Then
      Begin
       Result := Format(TValueFormatJSONValueS, ['ObjectType', GetObjectName(vTypeObject), 'Direction',
                                                 GetDirectionName(vObjectDirection),       'Encoded',
                                                 EncodedString, 'ValueType', GetValueType(vObjectValue),
                                                 vtagName, GetValueJSON(BuildStringFloat(aResult, JsonMode, vFloatDecimalFormat))]);
      End
     Else
      Begin
       If (vObjectValue In [ovBlob, ovGraphic, ovOraBlob, ovOraClob]) Then
        Begin
         If aResult <> '' Then
          Begin
           If ((((aResult <> '""')           And
             Not((aResult[InitStrPos] = '"') And
                 (aResult[Length(aResult) - FinalStrPos] = '"')))) And
              (vEncoded)) Or (Not(vEncoded) And (aResult = ''))    Then
            aResult := '"' + aResult + '"'
           Else If (aResult = '') Then
            aResult := '""';
          End
         Else
          aResult := '""';
        End;
       If (Trim(bValue) = '"null"') Then
        Result := Format(TValueFormatJSONValue, ['ObjectType', GetObjectName(vTypeObject), 'Direction',
                                                 GetDirectionName(vObjectDirection),       'Encoded',
                                                 EncodedString, 'ValueType', GetValueType(vObjectValue),
                                                 vtagName,      GetValueJSON(Trim(bValue))])
       Else
        Result := Format(TValueFormatJSONValue, ['ObjectType', GetObjectName(vTypeObject), 'Direction',
                                                 GetDirectionName(vObjectDirection),       'Encoded',
                                                 EncodedString, 'ValueType', GetValueType(vObjectValue),
                                                 vtagName,      GetValueJSON(aResult)]);
      End;
    End;
  End
 Else
  Result := aResult;
End;

Function TJSONValue.GetValue : String;
Var
 vTempString : String;
Begin
 Result := '';
 If Length(aValue) = 0 Then
  Exit;
 {$IFDEF FPC}
  vTempString := BytesArrToString(aValue, GetEncodingID(vEncoding)); //vEncodingLazarus.GetString(aValue);
 {$ELSE}
  vTempString := BytesArrToString(aValue, GetEncodingID(vEncoding));
 {$ENDIF}
 {$IF Defined(ANDROID) or defined(IOS)} // Alterado para IOS Brito
  If Length(vTempString) > 0 Then
   Begin
    If vTempString[InitStrPos] = '"' Then
     vTempString := vTempString.Substring(1, Length(vTempString) - 1);
    If vTempString[Length(vTempString) - 1] = '"' Then
     vTempString := Copy(vTempString, InitStrPos, Length(vTempString) - 1);
    vTempString := Trim(vTempString);
   End;
  If vEncoded Then
   Begin
    If (vObjectValue In [ovBytes, ovVarBytes, ovBlob, ovGraphic, ovOraBlob, ovOraClob]) And (vBinary) Then
     vTempString := vTempString
    Else
     Begin
      If Length(vTempString) > 0 Then
       vTempString := DecodeStrings(vTempString);
     End;
   End
  Else
   Begin
    If Length(vTempString) = 0 Then
     vTempString := BytesArrToString(aValue, GetEncodingID(vEncoding));
   End;
  If vObjectValue = ovString Then
   Begin
    If vTempString <> '' Then
     If vTempString[InitStrPos] = '"' Then
      Begin
       Delete(vTempString, 1, 1);
       If vTempString[Length(vTempString)] = '"' Then
        Delete(vTempString, Length(vTempString), 1);
      End;
    Result := vTempString;
   End
  Else
   Result := vTempString;
 {$ELSE}
  If Length(vTempString) > 0 Then
   Begin
    If vTempString[InitStrPos]          = '"' Then
     Delete(vTempString, InitStrPos, 1);
    If vTempString[Length(vTempString)] = '"' Then
     Delete(vTempString, Length(vTempString), 1);
    vTempString := Trim(vTempString);
   End;
  If vEncoded Then
   Begin
    If (vObjectValue In [ovBytes,   ovVarBytes, ovBlob,
                         ovGraphic, ovOraBlob,  ovOraClob]) And (vBinary) Then
     vTempString := vTempString
    Else
     Begin //TODO
      If Length(vTempString) > 0 Then
       vTempString := DecodeStrings(vTempString{$IFDEF FPC}, csUndefined{$ENDIF});
//      If vEncoding = esUtf8 Then
//       vTempString := UTF8Decode(vTempString);
     End;
   End
  Else
   Begin
    If Length(vTempString) = 0 Then
     Begin
      {$IFDEF FPC}
       vTempString := BytesArrToString(aValue, GetEncodingID(vEncoding)); //vEncodingLazarus.GetString(aValue);
      {$ELSE}
       vTempString := BytesArrToString(aValue, GetEncodingID(vEncoding));
      {$ENDIF}
     End;
   End;
  If vObjectValue = ovString Then
   Begin
    If vTempString <> '' Then
     If vTempString[InitStrPos] = '"' Then
      Begin
       Delete(vTempString, 1, 1);
       If vTempString[Length(vTempString)] = '"' Then
        Delete(vTempString, Length(vTempString), 1);
      End;
    Result := vTempString;
   End
  Else
   Result := vTempString;
 {$IFEND}
 vTempString := '';
End;

Function TJSONValue.DatasetValues(bValue             : TDataset;
                                  DateTimeFormat     : String = '';
                                  JsonModeD          : TJsonMode = jmDataware;
                                  FloatDecimalFormat : String = '') : String;
Var
 vLines : String;
 A      : Integer;
 Function GenerateHeader: String;
 Var
  I : Integer;
  vPrimary,
  vRequired,
  vReadOnly,
  vGenerateLine,
  vAutoinc      : string;
 Begin
  For i := 0 To bValue.Fields.Count - 1 Do
   Begin
    vPrimary := 'N';
    vAutoinc := 'N';
    vReadOnly := 'N';
    If pfInKey in bValue.Fields[i].ProviderFlags Then
     vPrimary := 'S';
    vRequired := 'N';
    If bValue.Fields[i].Required Then
     vRequired := 'S';
    If Not(bValue.Fields[i].CanModify) Then
     vReadOnly := 'S';
    {$IFNDEF FPC}
     {$IF CompilerVersion > 21}
      If bValue.Fields[i].AutoGenerateValue = arAutoInc Then
       vAutoinc := 'S';
     {$ELSE}
       vAutoinc := 'N';
     {$IFEND}
    {$ENDIF}
    If bValue.Fields[i].DataType In [{$IFNDEF FPC}{$IF CompilerVersion > 21}ftExtended, ftSingle,{$IFEND}{$ENDIF}
                                     ftFloat, ftCurrency, ftFMTBcd, ftBCD] Then
     Begin
      If bValue.Fields[i].DataType In [ftFMTBcd, ftBCD] then
       {$IFNDEF FPC}
       vGenerateLine := Format(TJsonDatasetHeader, [bValue.Fields[i].FieldName,
                                                    GetFieldType(bValue.Fields[i].DataType),
                                                    vPrimary, vRequired, TBCDField(bValue.Fields[i]).Size,
                                                    TBCDField(bValue.Fields[i]).Precision, vReadOnly, vAutoinc])
       {$ELSE}
       vGenerateLine := Format(TJsonDatasetHeader, [bValue.Fields[i].FieldName,
                                                    GetFieldType(bValue.Fields[i].DataType),
                                                    vPrimary, vRequired, TBCDField(bValue.Fields[i]).Size,
                                                    TBCDField(bValue.Fields[i]).Precision, vReadOnly, vAutoinc])
       {$ENDIF}
      Else
       vGenerateLine := Format(TJsonDatasetHeader, [bValue.Fields[i].FieldName,
                                                    GetFieldType(bValue.Fields[i].DataType),
                                                    vPrimary, vRequired, TFloatField(bValue.Fields[i]).Size,
                                                    TFloatField(bValue.Fields[i]).Precision,       vReadOnly, vAutoinc]);
     End
    Else
     vGenerateLine   := Format(TJsonDatasetHeader, [bValue.Fields[i].FieldName,
                                                    GetFieldType(bValue.Fields[i].DataType),
                                                    vPrimary, vRequired, bValue.Fields[i].Size, 0, vReadOnly, vAutoinc]);
    If i = 0 Then
     Result := vGenerateLine
    Else
     Result := Result + ', ' + vGenerateLine;
   End;
 End;
 Function GenerateLine: String;
 Var
  I             : Integer;
  vTempField,
  vTempValue    : String;
  bStream       : TStream;
  vStringStream : TStringStream;
 Begin
  For i := 0 To bValue.Fields.Count - 1 Do
   Begin
    Case JsonModeD Of
     jmDataware : Begin
                  End;
     jmPureJSON,
     jmMongoDB  : vTempField := Format('"%s": ', [bValue.Fields[i].FieldName]);
    End;
    If Not bValue.Fields[i].IsNull then
     Begin
      If bValue.Fields[i].DataType In [{$IFNDEF FPC}{$IF CompilerVersion > 21}ftExtended, ftSingle,{$IFEND}{$ENDIF}
                                       ftFloat, ftCurrency, ftFMTBcd, ftBCD] Then
       vTempValue := Format('%s"%s"', [vTempField, BuildStringFloat(FloatToStr(bValue.Fields[i].AsFloat), JsonModeD, FloatDecimalFormat)])
      Else If bValue.Fields[i].DataType in [ftBytes, ftVarBytes, ftBlob, ftGraphic, ftOraBlob, ftOraClob] Then
       Begin
        vStringStream := TStringStream.Create('');
        bStream := bValue.CreateBlobStream(TBlobField(bValue.Fields[i]), bmRead);
        Try
         bStream.Position := 0;
         {$IFDEF FPC}
         vStringStream.CopyFrom(bStream, bStream.Size);
         {$ELSE}
          {$IF CompilerVersion > 21}
          vStringStream.LoadFromStream(bStream);
          {$ELSE}
          vStringStream.CopyFrom(bStream, bStream.Size);
          {$IFEND}
         {$ENDIF}
         vTempValue := Format('%s%s', [vTempField, StreamToHex(vStringStream)]);
        Finally
         vStringStream.Free;
         bStream.Free;
        End;
       End
      Else
       Begin
        If bValue.Fields[i].DataType in [ftString, ftWideString, ftMemo,
                                         {$IFNDEF FPC}{$IF CompilerVersion > 21}ftWideMemo,{$IFEND}{$ENDIF}
                                         ftFmtMemo, ftFixedChar] Then
         Begin
          If vEncoded Then
           Begin
            If vJsonMode in [jmPureJSON, jmMongoDB] Then
             Begin
              {$IFDEF FPC}
               vTempValue := Format('%s"%s"', [vTempField, EncodeStrings(StringToJsonString(bValue.Fields[i].AsString), vDatabaseCharSet)]);
              {$ELSE}
               vTempValue := Format('%s"%s"', [vTempField, EncodeStrings(StringToJsonString(bValue.Fields[i].AsString))]);
              {$ENDIF}
             End
            Else
             Begin
              {$IFDEF FPC}
               vTempValue := Format('%s"%s"', [vTempField, EncodeStrings(bValue.Fields[i].AsString, vDatabaseCharSet)]);
              {$ELSE}
               vTempValue := bValue.Fields[i].AsString;
               {$IF (CompilerVersion < 19)}
                If vEncoding = esUtf8 Then
                 Result := UTF8Decode(vTempValue);
               {$IFEND}
               vTempValue := Format('%s"%s"', [vTempField, EncodeStrings(vTempValue)]);
              {$ENDIF}
             End;
           End
          Else
           Begin
            {$IFDEF FPC}
{
             Case DatabaseCharSet Of
              csWin1250    : vTempValue := CP1250ToUTF8(bValue.Fields[i].AsString);
              csWin1251    : vTempValue := CP1251ToUTF8(bValue.Fields[i].AsString);
              csWin1252    : vTempValue := CP1252ToUTF8(bValue.Fields[i].AsString);
              csWin1253    : vTempValue := CP1253ToUTF8(bValue.Fields[i].AsString);
              csWin1254    : vTempValue := CP1254ToUTF8(bValue.Fields[i].AsString);
              csWin1255    : vTempValue := CP1255ToUTF8(bValue.Fields[i].AsString);
              csWin1256    : vTempValue := CP1256ToUTF8(bValue.Fields[i].AsString);
              csWin1257    : vTempValue := CP1257ToUTF8(bValue.Fields[i].AsString);
              csWin1258    : vTempValue := CP1258ToUTF8(bValue.Fields[i].AsString);
              csUTF8       : vTempValue := UTF8ToUTF8BOM(bValue.Fields[i].AsString);
              csISO_8859_1 : vTempValue := ISO_8859_1ToUTF8(bValue.Fields[i].AsString);
              csISO_8859_2 : vTempValue := ISO_8859_2ToUTF8(bValue.Fields[i].AsString);
             End;
}
             vTempValue := Format('%s"%s"', [vTempField, StringToJsonString(bValue.Fields[i].AsString)]); //vTempValue)]);
            {$ELSE}
             vTempValue := bValue.Fields[i].AsString;//escape_chars(bValue.Fields[i].AsString);
             vTempValue := Format('%s"%s"', [vTempField, StringToJsonString(vTempValue)]);
            {$ENDIF}
           End;
         End
        Else If bValue.Fields[i].DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] Then
         Begin
          If DateTimeFormat <> '' Then
           vTempValue := Format('%s"%s"', [vTempField, FormatDateTime(DateTimeFormat, bValue.Fields[i].AsDateTime)])
          Else
           vTempValue := Format('%s"%s"', [vTempField, inttostr(DateTimeToUnix(bValue.Fields[i].AsDateTime))]);
         End
        Else
         vTempValue := Format('%s"%s"', [vTempField, bValue.Fields[i].AsString]); // asstring
       End;
     End
    Else
     vTempValue := Format('%s"%s"', [vTempField, 'null']);
    If I = 0 Then
     Result := vTempValue
    Else
     Result := Result + ', ' + vTempValue;
   End;
 End;
Begin
 bValue.DisableControls;
 Try
  If Not bValue.Active Then
   bValue.Open;
  bValue.First;
  Case JsonModeD Of
   jmDataware : Result := '{"fields":[' + GenerateHeader + ']}, {"lines":[%s]}';
   jmPureJSON : Begin
                End;
   jmMongoDB  : Begin
                End;
  End;
  A := 0;
  {$IFDEF  POSIX}  // aqui para linux tem que ser diferente o rastrwio da query
  For A := 0 To bValue.Recordcount -1 Do
   Begin
    Case JsonModeD Of
     jmDataware : Begin
                   If bValue.RecNo = 1 Then
                    vLines := Format('{"line%d":[%s]}',            [A, GenerateLine])
                   Else
                    vLines := vLines + Format(', {"line%d":[%s]}', [A, GenerateLine]);
                  End;
     jmPureJSON,
     jmMongoDB  : Begin
                   If bValue.RecNo = 1 Then
                    vLines := Format('{%s}', [GenerateLine])
                   Else
                    vLines := vLines + Format(', {%s}', [GenerateLine]);
                  End;
    End;
    bValue.Next;
   End;
  {$ELSE}
   While Not bValue.Eof Do
    Begin
     Case JsonModeD Of
      jmDataware : Begin
                    If bValue.RecNo = 1 Then
                     vLines := Format('{"line%d":[%s]}', [A, GenerateLine])
                    Else
                     vLines := vLines + Format(', {"line%d":[%s]}', [A, GenerateLine]);
                   End;
      jmPureJSON,
      jmMongoDB  : Begin
                    If bValue.RecNo = 1 Then
                      vLines := Format('{%s}', [GenerateLine])
                    Else
                      vLines := vLines + Format(', {%s}', [GenerateLine]);
                   End;
     End;
     bValue.Next;
     Inc(A);
    End;
  {$ENDIF}
  Case JsonModeD Of
   jmDataware : Begin
                 If vEncoding = esUtf8 Then
                  Result := Format(Result, [vLines])
                 Else
                 {$IF Defined(HAS_FMX)}
                  Result := Format(Result, [vLines]);
                 {$ELSE}
                  Result := Format(Result, [AnsiString(vLines)]);
                 {$IFEND}
                End;
   jmPureJSON,
   jmMongoDB  : Begin
                 If vtagName <> '' Then
                  Result := Format('{"%s": [%s]}', [vtagName, vLines])
                 Else
                  Result := Format('[%s]', [vLines]);
                End;
  End;
  bValue.First;
 Finally
  bValue.EnableControls;
 End;
End;

Function TJSONValue.EncodedString: String;
Begin
 If vEncoded Then
  Result := 'true'
 Else
  Result := 'false';
End;

Procedure TJSONValue.LoadFromDataset(TableName       : String;
                                     bValue          : TDataset;
                                     EncodedValue    : Boolean = True;
                                     JsonModeD       : TJsonMode = jmDataware;
                                     DateTimeFormat  : String = '';
                                     DelimiterFormat : String = ''{$IFDEF FPC};
                                     CharSet         : TDatabaseCharSet = csUndefined{$ENDIF});
Var
 vTagGeral : String;
 vSizeChar : Integer;
Begin
 vTypeObject      := toDataset;
 vObjectDirection := odINOUT;
 vObjectValue     := ovDataSet;
 vtagName         := Lowercase(TableName);
 vEncoded         := EncodedValue;
 {$IFDEF FPC}
  If CharSet <> csUndefined Then
   DatabaseCharSet := CharSet;
 {$ENDIF}
 vTagGeral        := DatasetValues(bValue, DateTimeFormat, JsonModeD, DelimiterFormat);
 {$IFDEF FPC}
  If vEncodingLazarus = Nil Then
   SetEncoding(vEncoding);
  If vEncoding = esUtf8 Then
   aValue          := TIdBytes(vEncodingLazarus.GetBytes(vTagGeral))
  Else
   aValue          := ToBytes(vTagGeral, GetEncodingID(vEncoding));
 {$ELSE}
  {$IF CompilerVersion > 21} // Delphi 2010 pra cima
   aValue          := ToBytes(vTagGeral, GetEncodingID(vEncoding));
  {$ELSE}
   vSizeChar := 1;
   If vEncoding = esUtf8 Then
    Begin
     vSizeChar := 2;
     SetLength(aValue, Length(vTagGeral) * vSizeChar);
     move(vTagGeral[InitStrPos], pByteArray(aValue)^, Length(aValue));
    End
   Else
    Begin
     SetLength(aValue, Length(vTagGeral) * vSizeChar);
     move(AnsiString(vTagGeral)[InitStrPos], pByteArray(aValue)^, Length(vTagGeral) * vSizeChar);
    End;
//   aValue          := ToBytes(vTagGeral, GetEncodingID(vEncoding));
  {$IFEND}
 {$ENDIF}
 vJsonMode        := JsonModeD;
End;

Function TJSONValue.ToJSON : String;
Var
 {$IFNDEF FPC}
  {$IF CompilerVersion > 21}
   vTempValue : String;
  {$ELSE}
   vTempValue : AnsiString;
  {$IFEND}
 {$ELSE}
  vTempValue : String;
 {$ENDIF}
 SizeOfString : Integer;
Begin
 Result := '';
 {$IFDEF FPC}
 If vEncodingLazarus = Nil Then
  SetEncoding(vEncoding);
 If vEncoding = esUtf8 Then
  vTempValue := vEncodingLazarus.GetString(aValue)
 Else
  vTempValue := BytesToString(aValue, GetEncodingID(vEncoding));
//  vTempValue := FormatValue(vEncodingLazarus.GetString(aValue))
 If vTempValue = '' Then
  Begin
   If Not(vObjectValue in [ovString,   ovFixedChar, ovWideString, ovFixedWideChar,
                           ovBlob,     ovGraphic,   ovOraBlob,  ovOraClob, ovMemo,
                           ovWideMemo, ovFmtMemo]) Then
    vTempValue := FormatValue('""')
   Else
    vTempValue := FormatValue('');
  End
 Else
  vTempValue := FormatValue(vTempValue);
 {$ELSE}
 If vEncoded Then
  Begin
   vTempValue := FormatValue(BytesToString(aValue, GetEncodingID(vEncoding)));
  End
 Else If BytesArrToString(aValue, GetEncodingID(vEncoding)) = '' Then
  Begin
   If Not(vObjectValue in [ovString,   ovFixedChar, ovWideString, ovFixedWideChar,
                           ovBlob,     ovGraphic,   ovOraBlob,  ovOraClob, ovMemo,
                           ovWideMemo, ovFmtMemo]) Then
    vTempValue := FormatValue('"null"')
   Else
    vTempValue := FormatValue('');
  End
 Else
  Begin
   {$IF CompilerVersion > 19} // Delphi 2010 pra cima
    vTempValue   := FormatValue(BytesArrToString(aValue, GetEncodingID(vEncoding)));
   {$ELSE} // Delphi 2010 pra cima
    SizeOfString := Length(aValue);
    SetString(vTempValue, PChar(@aValue[0]), SizeOfString);
    While pos(#0, vTempValue) > 0 Do
     Delete(vTempValue, pos(#0, vTempValue), 1);
    vTempValue   := FormatValue(vTempValue);
   {$IFEND} // Delphi 2010 pra cima
  End;
 {$ENDIF}
 If Not(Pos('"TAGJSON":}', vTempValue) > 0) Then
  Result := vTempValue;
End;

Procedure TJSONValue.ToStream(Var bValue : TMemoryStream);
Begin
 If Length(aValue) > 0 Then
  Begin
   bValue := TMemoryStream.Create;
   bValue.Write(aValue[0], -1);
  End
 Else
  bValue := Nil;
End;

Function TJSONValue.Value : String;
Begin
 Result := GetValue;
 {$IFNDEF FPC}
  {$IF (CompilerVersion < 19)}
   Result := UTF8Decode(Result);
  {$IFEND}
 {$ENDIF}
End;

Procedure TJSONValue.WriteToFieldDefs(JSONValue                : String;
                                      Const ResponseTranslator : TDWResponseTranslator);
 Function ReadFieldDefs(JSONObject,
                        ElementRoot      : String;
                        ElementRootIndex : Integer) : String;
 Var
  bJsonValueB,
  bJsonValue   : TDWJSONObject;
  A            : Integer;
  vFindIndex   : Boolean;
  vDWFieldDef  : TDWFieldDef;
  vStringData,
  vStringDataB : String;
 Begin
  Result     := '';
  bJsonValue := TDWJSONObject.Create(JSONObject);
  vFindIndex := False;
  Try
   If bJsonValue.PairCount > 0 Then
    Begin
     Result := JSONObject;
     If ResponseTranslator.FieldDefs.Count = 0 Then
      Begin
       For A := 0 To bJsonValue.PairCount -1 Do
        Begin
         If (ElementRoot <> '') or (JSONObject[InitStrPos] = '[') Then
          Begin
           If (UpperCase(ElementRoot) = UpperCase(bJsonValue.pairs[A].Name)) or
              (JSONObject[InitStrPos] = '[') Then
            Begin
             vStringData  := bJsonValue.pairs[A].Value;
             bJsonValueB := TDWJSONObject.Create(vStringData);
             If (JSONObject[InitStrPos] <> '[') Then
              vStringDataB := vStringData
             Else
              vStringDataB := JSONObject;
             While bJsonValueB.ClassType = TDWJSONArray Do
              Begin
               vStringData := bJsonValueB.Pairs[0].Value;
               bJsonValueB.Free;
               bJsonValueB := TDWJSONObject.Create(vStringData);
               If bJsonValueB.ClassType = TDWJSONArray Then
                vStringDataB := vStringData;
              End;
             bJsonValueB.Free;
             Result := vStringDataB;
             ReadFieldDefs(vStringData, '', -1);
             Exit;
            End;
          End
         Else
          Begin
           If ResponseTranslator.FieldDefs.FieldDefByName[bJsonValue.pairs[A].Name] = Nil Then
            Begin
             vDWFieldDef              := TDWFieldDef(ResponseTranslator.FieldDefs.Add);
             vDWFieldDef.ElementName  := bJsonValue.pairs[A].Name;
             vDWFieldDef.ElementIndex := A;
             vDWFieldDef.FieldName    := vDWFieldDef.ElementName;
             vDWFieldDef.FieldSize    := Length(bJsonValue.pairs[A].Value);
             vDWFieldDef.DataType     := ovString;
            End;
          End;
        End;
      End;
    End;
  Finally
   bJsonValue.Free;
  End;
 End;
Var
 bJsonValue : TDWJSONObject;
Begin
 bJsonValue := TDWJSONObject.Create(JSONValue);
 Try
  If bJsonValue.PairCount > 0 Then
   ReadFieldDefs(JSONValue,
                 ResponseTranslator.ElementRootBaseName,
                 ResponseTranslator.ElementRootBaseIndex);
 Finally
  FreeAndNil(bJsonValue);
 End;
End;

Procedure TJSONValue.WriteToDataset(JSONValue          : String;
                                    Const DestDS       : TDataset;
                                    ResponseTranslator : TDWResponseTranslator;
                                    ResquestMode       : TResquestMode);
Var
 FieldValidate    : TFieldNotifyEvent;
 bJsonValue,
 bJsonValueB      : TDWJSONObject;
 bJsonArrayB,
 bJsonArray       : TDWJSONArray;
 ListFields       : TStringList;
 A, J, I          : Integer;
 vBlobStream      : TStringStream;
 vFieldDefinition : TFieldDefinition;
 vTempValueJSONB,
 vTempValueJSON,
 vTempValue       : String;
 FieldDef         : TFieldDef;
 Field            : TField;
 vOldReadOnly,
 vFindFlag        : Boolean;
 bJsonOBJBase,
 bJsonOBJB,
 bJsonOBJ         : TDWJSONBase;
 Function ReadFieldDefs(Var vResult      : String;
                        JSONObject,
                        ElementRoot      : String;
                        ElementRootIndex : Integer;
                        InLoop            : Boolean = False) : Boolean;
 Var
  bJsonValueB,
  bJsonValue   : TDWJSONObject;
  A, I         : Integer;
  vFounded,
  vFieldDefsCreate,
  vFindIndex   : Boolean;
  vDWFieldDef  : TDWFieldDef;
  vLastData,
  vStringData,
  vStringDataB,
  vStringDataTemp : String;
 Begin
  Result     := False;
  If JSONObject <> '' Then
   Begin
    bJsonValue := TDWJSONObject.Create(JSONObject);
    vFindIndex := False;
    Try
     If bJsonValue.PairCount > 0 Then
      Begin
  //     vResult          := JSONObject;
       vFieldDefsCreate := ResponseTranslator.FieldDefs.Count = 0;
       If Not vFieldDefsCreate Then
        vFieldDefsCreate := InLoop;
       For A := 0 To bJsonValue.PairCount -1 Do
        Begin
         If ((ElementRoot <> '') or (JSONObject[InitStrPos] = '[')) or (Not (vFieldDefsCreate)) Then
          Begin
           vResult    := '';
           If (UpperCase(ElementRoot) = UpperCase(bJsonValue.pairs[A].Name)) or
              (JSONObject[InitStrPos] = '[') Then
            Begin
             vFindIndex   := UpperCase(ElementRoot) = UpperCase(bJsonValue.pairs[A].Name);
             vStringData  := bJsonValue.pairs[A].Value;
             If (JSONObject[InitStrPos] <> '[') Then
              vStringDataB    := vStringData
             Else
              vStringDataB    := JSONObject;
             If (vStringData = 'null') Or (vStringData = '') Then
              Begin
               vStringData := '';
               If (vStringDataB = 'null') Or (vStringDataB = '') Then
                vStringDataB := '';
               vResult := vStringDataB;
              End
             Else
              Begin
               vStringDataTemp := vStringDataB;
               bJsonValueB := TDWJSONObject.Create(vStringDataTemp);
               I := 0;
               While (bJsonValueB.ClassType = TDWJSONArray) And
                      ((bJsonValueB.PairCount > 0) And (I <= bJsonValueB.PairCount))  Do
                Begin
                 vStringData := bJsonValueB.Pairs[I].Value;
                 bJsonValueB.Free;
                 bJsonValueB := TDWJSONObject.Create(vStringData);
                 Inc(I);
                End;
               bJsonValueB.Free;
               vResult := vStringDataTemp;
              End;
  //           vResult := vStringDataB;
             If vFindIndex Then
              Begin
               vResult := vStringDataTemp;
               Result := ReadFieldDefs(vResult, vStringData, '', -1, vFindIndex);
              End
             Else
              Begin
               Result := ReadFieldDefs(vResult, vStringData, ElementRoot, -1, vFindIndex);
//               vResult := vStringDataTemp;
              End;
             Exit;
            End;
          End
         Else If vFieldDefsCreate Then
          Begin
           Result     := True;
           vFindIndex := True;
           If ResponseTranslator.FieldDefs.FieldDefByName[bJsonValue.pairs[A].Name] = Nil Then
            Begin
             vDWFieldDef              := TDWFieldDef(ResponseTranslator.FieldDefs.Add);
             vDWFieldDef.ElementName  := bJsonValue.pairs[A].Name;
             vDWFieldDef.ElementIndex := A;
             vDWFieldDef.FieldName    := vDWFieldDef.ElementName;
             vDWFieldDef.FieldSize    := Length(bJsonValue.pairs[A].Value);
             If vDWFieldDef.FieldSize = 0 Then
              vDWFieldDef.FieldSize   := 10;
             vDWFieldDef.DataType     := ovString;
            End;
          End;
        End;
       If (ElementRoot <> '') Then
       If Not(vFindIndex) Then
        Begin
         For A := 0 To bJsonValue.PairCount -1 Do
          Begin
           vStringDataTemp := bJsonValue.pairs[A].Value;
           Result := ReadFieldDefs(vResult, vStringDataTemp, ElementRoot, -1);
           If Result Then
            Break;
          End;
        End;
      End;
    Finally
     bJsonValue.Free;
     If Not Result Then
      If vResult = '' Then
       vResult := JSONValue;
    End;
   End;
 End;
Begin
 If (Trim(JSONValue) = '') or (Trim(JSONValue) = '{}') or (Trim(JSONValue) = '[]') Then // Ico Menezes - Tratar Erros de JsonVazio
  Exit;
 ListFields := TStringList.Create;
 bJsonValue := TDWJSONObject.Create(JSONValue);
 Try
  If bJsonValue.PairCount > 0 Then
   Begin
    If DestDS is TRESTDWClientSQL Then
     Begin
      TRESTDWClientSQL(DestDS).SetInBlockEvents(True);
      TRESTDWClientSQL(DestDS).DisableControls;
     End
    Else
     DestDS.DisableControls;
    If DestDS.Active Then
     DestDS.Close;
    vTempValueJSON := JSONValue;
    If (ResquestMode = rtOnlyFields) Or
      (((ResponseTranslator.ElementAutoReadRootIndex)    Or
        (ResponseTranslator.ElementRootBaseName <> '')   Or
        (ResponseTranslator.ElementRootBaseIndex > -1))) Then
     ReadFieldDefs(vTempValueJSON, JSONValue,
                   ResponseTranslator.ElementRootBaseName,
                   ResponseTranslator.ElementRootBaseIndex);
    If DestDS is TRESTDWClientSQL Then
     TRESTDWClientSQL(DestDS).NewFieldList;
    vFieldDefinition := TFieldDefinition.Create;
    //Removendo campos inválidos
    For J := DestDS.Fields.Count - 1 DownTo 0 Do
     Begin
      If DestDS.Fields[J].FieldKind = fkData Then
       If ResponseTranslator.FieldDefs.FieldDefByName[DestDS.Fields[J].FieldName] = Nil Then
        DestDS.Fields.Remove(DestDS.Fields[J]);
     End;
    For J := 0 To DestDS.Fields.Count - 1 Do
     Begin
      vFieldDefinition.FieldName := DestDS.Fields[J].FieldName;
      vFieldDefinition.DataType  := DestDS.Fields[J].DataType;
      If (vFieldDefinition.DataType <> ftFloat) Then
       vFieldDefinition.Size     := DestDS.Fields[J].Size
      Else
       vFieldDefinition.Size     := 0;
      If (vFieldDefinition.DataType In [ftCurrency, ftBCD,
                                        {$IFNDEF FPC}{$IF CompilerVersion > 21}ftExtended, ftSingle,
                                        {$IFEND}{$ENDIF} ftFMTBcd]) Then
       vFieldDefinition.Precision := TBCDField(DestDS.Fields[J]).Precision
      Else If (vFieldDefinition.DataType = ftFloat) Then
       vFieldDefinition.Precision := TFloatField(DestDS.Fields[J]).Precision;
      vFieldDefinition.Required := DestDS.Fields[J].Required;
      TRESTDWClientSQL(DestDS).NewDataField(vFieldDefinition);
     End;
    For J := 0 To ResponseTranslator.FieldDefs.Count - 1 Do
     Begin
      vTempValue := Trim(ResponseTranslator.FieldDefs[J].FieldName);
      If Trim(vTempValue) <> '' Then
       Begin
        FieldDef := TRESTDWClientSQL(DestDS).FieldDefExist(vTempValue);
        If (FieldDef = Nil) Then
         Begin
          If (TRESTDWClientSQL(DestDS).FieldExist(vTempValue) = Nil) And
             (DestDS is TRESTDWClientSQL)                            Then
           Begin
            vFieldDefinition.FieldName  := vTempValue;
            vFieldDefinition.DataType   := ObjectValueToFieldType(ResponseTranslator.FieldDefs[J].DataType);
            If (vFieldDefinition.DataType <> ftFloat) Then
             vFieldDefinition.Size     := ResponseTranslator.FieldDefs[J].FieldSize
            Else
             vFieldDefinition.Size         := 0;
            If (vFieldDefinition.DataType In [ftFloat, ftCurrency, ftBCD,
                                              {$IFNDEF FPC}{$IF CompilerVersion > 21}ftExtended, ftSingle,
                                              {$IFEND}{$ENDIF} ftFMTBcd]) Then
             vFieldDefinition.Precision := ResponseTranslator.FieldDefs[J].Precision
            Else If (vFieldDefinition.DataType = ftFloat) Then
             vFieldDefinition.Precision := ResponseTranslator.FieldDefs[J].Precision;
            vFieldDefinition.Required   := ResponseTranslator.FieldDefs[J].Required;
            TRESTDWClientSQL(DestDS).NewDataField(vFieldDefinition);
           End;
          If DestDS is TRESTDWClientSQL Then
           FieldDef          := TRESTDWClientSQL(DestDS).FieldDefs.AddFieldDef
          Else
           FieldDef          := DestDS.FieldDefs.AddFieldDef;
          FieldDef.Name     := vTempValue;
          FieldDef.DataType := ObjectValueToFieldType(ResponseTranslator.FieldDefs[J].DataType);
          If (FieldDef.DataType <> ftFloat) Then
           FieldDef.Size     := ResponseTranslator.FieldDefs[J].FieldSize;
          If (FieldDef.DataType In [ftFloat, ftCurrency, ftBCD,
                                    {$IFNDEF FPC}{$IF CompilerVersion > 21}ftExtended, ftSingle,
                                    {$IFEND}{$ENDIF} ftFMTBcd]) Then
           FieldDef.Precision := ResponseTranslator.FieldDefs[J].Precision;
//          {$IFDEF CLIENTDATASET}
           If DestDS.FindField(vTempValue) = Nil Then
            FieldDef.CreateField(DestDS);
//          {$ENDIF}
         End;
       End;
     End;
    FreeAndNil(vFieldDefinition);
    DestDS.FieldDefs.EndUpdate;
    Try
     If DestDS is TRESTDWClientSQL Then
      Begin
       TRESTDWClientSQL(DestDS).SetInBlockEvents(True);
       TRESTDWClientSQL(DestDS).Inactive := True;
       TRESTDWClientSQL(DestDS).CreateDataSet;
      End;
     If DestDS is TRESTDWClientSQL Then
      Begin
       If Not TRESTDWClientSQL(DestDS).Active Then
        TRESTDWClientSQL(DestDS).Open;
      End
     Else
      Begin
       If Not DestDS.Active Then
        DestDS.Open;
      End;
     If Not DestDS.Active Then
      Begin
       bJsonValue.Free;
       ListFields.Free;
       Raise Exception.Create('Error on Parse JSON Data...');
       Exit;
      End;
     {$IFNDEF CLIENTDATASET}
      If DestDS is TRESTDWClientSQL Then
       Begin
        TRESTDWClientSQL(DestDS).Active := True;
        TRESTDWClientSQL(DestDS).Inactive := False;
       End;
     {$ENDIF}
     //Add Set PK Fields
     For J := 0 To ResponseTranslator.FieldDefs.Count - 1 Do
      Begin
       If ResponseTranslator.FieldDefs[J].Required Then
        Begin
         Field := DestDS.FindField(ResponseTranslator.FieldDefs[J].FieldName);
         If Field <> Nil Then
          Begin
           If Field.FieldKind = fkData Then
            Field.ProviderFlags := [pfInUpdate, pfInWhere, pfInKey]
           Else
            Field.ProviderFlags := [];
          End;
        End;
      End;
     bJsonValueB := TDWJSONObject.Create(vTempValueJSON);
     For A := 0 To DestDS.Fields.Count - 1 Do // ADICIONA REGISTRO
      Begin
       vFindFlag := False;
       If DestDS.FindField(DestDS.Fields[A].FieldName) <> Nil Then
        If DestDS.FindField(DestDS.Fields[A].FieldName).FieldKind = fkData Then
         Begin
          If bJsonValueB.ClassType = TDWJSONObject Then
           Begin
            For J := 0 To bJsonValueB.PairCount - 1 Do
             Begin
              If Trim(bJsonValueB.pairs[J].Value) <> '' Then
               Begin
                vFindFlag := Uppercase(Trim(bJsonValueB.pairs[J].Name)) = Uppercase(DestDS.Fields[A].FieldName);
                If vFindFlag Then
                 Begin
                  ListFields.Add(inttostr(J));
                  Break;
                 End;
                End;
//              FreeAndNil(bJsonOBJ);
             End;
           End
          Else If bJsonValueB.ClassType = TDWJSONArray Then
           Begin
            vTempValueJSONB := TDWJSONObject(bJsonValueB).pairs[0].Value;
            bJsonValueB.Free;
            bJsonValueB := TDWJSONObject.Create(vTempValueJSONB);
            For J := 0 To bJsonValueB.PairCount - 1 Do
             Begin
              If Trim(bJsonValueB.pairs[J].Name) <> '' Then
               Begin
                vFindFlag := Uppercase(Trim(bJsonValueB.pairs[J].Name)) = Uppercase(DestDS.Fields[A].FieldName);
                If vFindFlag Then
                 Begin
                  ListFields.Add(inttostr(J));
                  Break;
                 End;
                End;
              FreeAndNil(bJsonOBJ);
             End;
           End;
         End;
       If Not vFindFlag Then
        ListFields.Add('-1');
      End;
     bJsonValueB.Free;
     bJsonValueB := TDWJSONObject.Create(vTempValueJSON);
     If bJsonValueB.ClassType = TDWJSONObject Then
      Begin
       If DestDS Is TRESTDWClientSQL Then
        Begin
         TRESTDWClientSQL(DestDS).SetInBlockEvents(True);
         TRESTDWClientSQL(DestDS).SetRecordCount(1, 1);
        End;
       If DestDS Is TRESTDWClientSQL Then
        TRESTDWClientSQL(DestDS).Append
       Else
        DestDS.Append;
       Try
        For i := 0 To DestDS.Fields.Count - 1 Do
         Begin
          vOldReadOnly                := DestDS.Fields[i].ReadOnly;
          FieldValidate               := DestDS.Fields[i].OnValidate;
          DestDS.Fields[i].OnValidate := Nil;
          DestDS.Fields[i].ReadOnly   := False;
          If DestDS.Fields[i].FieldKind = fkLookup Then
           Begin
            If DestDS Is TRESTDWClientSQL Then
             Begin
              DestDS.Fields[i].ReadOnly := vOldReadOnly;
              DestDS.Fields[i].OnValidate := FieldValidate;
             End
            Else
             Begin
              DestDS.Fields[i].ReadOnly := vOldReadOnly;
              DestDS.Fields[i].OnValidate := FieldValidate;
             End;
            Continue;
           End;
          If (i >= ListFields.Count) Then
           Begin
            DestDS.Fields[i].ReadOnly := vOldReadOnly;
            DestDS.Fields[i].OnValidate := FieldValidate;
            Continue;
           End;
          If (StrToInt(ListFields[i])       = -1)     Or
             Not(DestDS.Fields[i].FieldKind = fkData) Or
             (StrToInt(ListFields[i]) = -1)           Then
           Begin
            DestDS.Fields[i].ReadOnly := vOldReadOnly;
            DestDS.Fields[i].OnValidate := FieldValidate;
            Continue;
           End;
//          FreeAndNil(bJsonOBJB);
          vTempValue := bJsonValueB.Pairs[StrToInt(ListFields[i])].Value;
          If DestDS.Fields[i].DataType In [ftGraphic, ftParadoxOle, ftDBaseOle, ftTypedBinary, ftCursor,
                                           ftDataSet, ftBlob, ftOraBlob, ftOraClob{$IFNDEF FPC}{$IF CompilerVersion > 21},
                                           ftParams, ftStream{$IFEND}{$ENDIF}] Then
           Begin
            If (vTempValue <> 'null') And (vTempValue <> '') Then
             Begin
              HexStringToStream(vTempValue, vBlobStream);
              Try
               vBlobStream.Position := 0;
               TBlobField(DestDS.Fields[i]).LoadFromStream(vBlobStream);
              Finally
               {$IFNDEF FPC}
                {$IF CompilerVersion > 21}
                 vBlobStream.Clear;
                {$IFEND}
               {$ENDIF}
               FreeAndNil(vBlobStream);
              End;
             End;
           End
          Else
           Begin
            If (Lowercase(vTempValue) <> 'null') Then
             Begin
              If DestDS.Fields[i].DataType in [ftString, ftWideString,
                                               {$IFNDEF FPC}{$IF CompilerVersion > 21}ftWideMemo,
                                               {$IFEND}{$ENDIF}ftMemo, ftFmtMemo, ftFixedChar] Then
               Begin
                If vTempValue = '' Then
                 DestDS.Fields[i].AsString := ''
                Else
                 Begin
//                  If vEncoded Then
//                   DestDS.Fields[i].AsString := DecodeStrings(vTempValue{$IFDEF FPC}, vDatabaseCharSet{$ENDIF})
//                  Else
                   DestDS.Fields[i].AsString := vTempValue;
                 End;
               End
              Else If (vTempValue <> '') then
               SetValueA(DestDS.Fields[i], vTempValue);
             End;
           End;
          DestDS.Fields[i].ReadOnly := vOldReadOnly;
          DestDS.Fields[i].OnValidate := FieldValidate;
         End;
       Finally
        vTempValue := '';
       End;
       DestDS.Post;
      End
     Else
      Begin
       bJsonArrayB := TDWJSONArray(bJsonValueB);
       If DestDS Is TRESTDWClientSQL Then
        Begin
         TRESTDWClientSQL(DestDS).SetInBlockEvents(True);
         TRESTDWClientSQL(DestDS).SetRecordCount(bJsonArrayB.ElementCount, bJsonArrayB.ElementCount);
        End;
       For J := 0 To bJsonArrayB.ElementCount - 1 Do
        Begin
         bJsonOBJB := TDWJSONArray(bJsonArrayB).GetObject(J);
         If DestDS Is TRESTDWClientSQL Then
          TRESTDWClientSQL(DestDS).Append
         Else
          DestDS.Append;
         Try
          For i := 0 To DestDS.Fields.Count - 1 Do
           Begin
            vOldReadOnly                := DestDS.Fields[i].ReadOnly;
            FieldValidate               := DestDS.Fields[i].OnValidate;
            DestDS.Fields[i].OnValidate := Nil;
            DestDS.Fields[i].ReadOnly   := False;
            If DestDS.Fields[i].FieldKind = fkLookup Then
             Begin
              If DestDS Is TRESTDWClientSQL Then
               Begin
                DestDS.Fields[i].ReadOnly := vOldReadOnly;
                DestDS.Fields[i].OnValidate := FieldValidate;
               End
              Else
               Begin
                DestDS.Fields[i].ReadOnly := vOldReadOnly;
                DestDS.Fields[i].OnValidate := FieldValidate;
               End;
              Continue;
             End;
            If (i >= ListFields.Count) Then
             Begin
              DestDS.Fields[i].ReadOnly := vOldReadOnly;
              DestDS.Fields[i].OnValidate := FieldValidate;
              Continue;
             End;
            If (StrToInt(ListFields[i])       = -1)     Or
               Not(DestDS.Fields[i].FieldKind = fkData) Or
               (StrToInt(ListFields[i]) = -1)           Then
             Begin
              DestDS.Fields[i].ReadOnly := vOldReadOnly;
              DestDS.Fields[i].OnValidate := FieldValidate;
              Continue;
             End;
//            FreeAndNil(bJsonOBJB);
            vTempValue := TDWJSONObject(bJsonOBJB).pairs[StrToInt(ListFields[i])].Value; // bJsonOBJTemp.get().ToString;
            If DestDS.Fields[i].DataType In [ftGraphic, ftParadoxOle, ftDBaseOle, ftTypedBinary, ftCursor,
                                             ftDataSet, ftBlob, ftOraBlob, ftOraClob{$IFNDEF FPC}{$IF CompilerVersion > 21},
                                             ftParams, ftStream{$IFEND}{$ENDIF}] Then
             Begin
              If (vTempValue <> 'null') And (vTempValue <> '') Then
               Begin
                HexStringToStream(vTempValue, vBlobStream);
                Try
                 vBlobStream.Position := 0;
                 TBlobField(DestDS.Fields[i]).LoadFromStream(vBlobStream);
                Finally
                 {$IFNDEF FPC}
                  {$IF CompilerVersion > 21}
                   vBlobStream.Clear;
                  {$IFEND}
                 {$ENDIF}
                 FreeAndNil(vBlobStream);
                End;
               End;
             End
            Else
             Begin
              If (Lowercase(vTempValue) <> 'null') Then
               Begin
                If DestDS.Fields[i].DataType in [ftString, ftWideString,
                                                 {$IFNDEF FPC}{$IF CompilerVersion > 21}ftWideMemo,
                                                 {$IFEND}{$ENDIF}ftMemo, ftFmtMemo, ftFixedChar] Then
                 Begin
                  If vTempValue = '' Then
                   DestDS.Fields[i].AsString := ''
                  Else
                   Begin
                    If vEncoded Then
                     DestDS.Fields[i].AsString := DecodeStrings(vTempValue{$IFDEF FPC}, vDatabaseCharSet{$ENDIF})
                    Else
                     DestDS.Fields[i].AsString := vTempValue;
                   End;
                 End
                Else If (vTempValue <> '') then
                 SetValueA(DestDS.Fields[i], vTempValue);
               End;
             End;
            DestDS.Fields[i].ReadOnly := vOldReadOnly;
            DestDS.Fields[i].OnValidate := FieldValidate;
           End;
         Finally
          vTempValue := '';
         End;
         FreeAndNil(bJsonOBJB);
         DestDS.Post;
//            FreeAndNil(bJsonOBJB);
        End;
      End;
    Except
    End;
   End;
 Finally
  If Assigned(ListFields) Then
   FreeAndNil(ListFields);
  TRESTDWClientSQL(DestDS).First;
  If DestDS is TRESTDWClientSQL Then
   TRESTDWClientSQL(DestDS).EnableControls
  Else
   DestDS.EnableControls;
  bJsonValue.Free;
  bJsonValueB.Free;
 End;
End;

Procedure TJSONValue.WriteToDataset (DatasetType    : TDatasetType;
                                     JSONValue      : String;
                                     DestDS         : TDataset;
                                     ClearDataset   : Boolean          = False{$IFDEF FPC};
                                     CharSet        : TDatabaseCharSet = csUndefined{$ENDIF});
Var
 JsonCount : Integer;
Begin
 JsonCount := 0;
 WriteToDataset(DatasetType, JSONValue, DestDS, JsonCount, -1, 0,
                ClearDataset{$IFDEF FPC}, CharSet{$ENDIF});
End;

Procedure TJSONValue.WriteToDataset(DatasetType   : TDatasetType;
                                    JSONValue     : String;
                                    DestDS        : TDataset;
                                    Var JsonCount : Integer;
                                    Datapacks     : Integer = -1;
                                    ActualRec     : Integer = 0;
                                    ClearDataset  : Boolean          = False{$IFDEF FPC};
                                    CharSet       : TDatabaseCharSet = csUndefined{$ENDIF});
Var
 FieldValidate    : TFieldNotifyEvent;
 bJsonOBJB,
 bJsonOBJ         : TDWJSONBase;
 bJsonValue       : TDWJSONObject;
 bJsonOBJTemp,
 bJsonArray,
 bJsonArrayB      : TDWJSONArray;
 A, J, I,
 vPageCount       : Integer;
 FieldDef         : TFieldDef;
 Field            : TField;
 vOldReadOnly,
 vFindFlag        : Boolean;
 vBlobStream      : TStringStream;
 ListFields       : TStringList;
 vTempValue       : String;
 vFieldDefinition : TFieldDefinition;
 vActualBookmark  : TBookmark;
 Function FieldIndex(FieldName: String): Integer;
 Var
  I : Integer;
 Begin
  Result := -1;
  For i := 0 To ListFields.Count - 1 Do
   Begin
    If Uppercase(ListFields[i]) = Uppercase(FieldName) Then
     Begin
      Result := i;
      Break;
     End;
   End;
 End;
Begin
 If JSONValue = '' Then
  Exit;
 ListFields := TStringList.Create;
 Try
  If Pos('[', JSONValue) = 0 Then
   Begin
    FreeAndNil(ListFields);
    Exit;
   End;
  bJsonValue  := TDWJSONObject.Create(JSONValue);
  If bJsonValue.PairCount > 0 Then
   Begin
    bJsonArray  := TDWJSONArray(bJsonValue.openArray(bJsonValue.pairs[4].Name));
    bJsonOBJ    := bJsonArray.GetObject(0);
    bJsonArrayB := TDWJSONObject(bJsonOBJ).openArray(TDWJSONObject(bJsonOBJ).pairs[0].Name);
    FreeAndNil(bJsonOBJ);
   End
  Else
   Begin
    DestDS.Close;
    Raise Exception.Create('Invalid JSON Data...');
   End;
  If ActualRec = 0 Then
   Begin
    vTypeObject      := GetObjectName(bJsonValue.pairs[0].Value);
    vObjectDirection := GetDirectionName(bJsonValue.pairs[1].Value);
    vEncoded         := GetBooleanFromString(bJsonValue.pairs[2].Value);
    vObjectValue     := GetValueType(bJsonValue.pairs[3].Value);
    vtagName         := Lowercase(bJsonValue.pairs[4].Name);
    If DestDS is TRESTDWClientSQL Then
     Begin
      TRESTDWClientSQL(DestDS).SetInBlockEvents(True);
      TRESTDWClientSQL(DestDS).DisableControls;
     End
    Else
     DestDS.DisableControls;
    If DestDS.Active Then
     DestDS.Close;
    If DestDS is TRESTDWClientSQL Then
     TRESTDWClientSQL(DestDS).NewFieldList;
    vFieldDefinition := TFieldDefinition.Create;
    If (DestDS.Fields.Count = 0) And
       (DestDS.FieldDefs.Count > 0) Then
     DestDS.FieldDefs.Clear
    Else
     Begin
      If (DestDS is TRESTDWClientSQL) Then
       For J := 0 To DestDS.Fields.Count - 1 Do
        Begin
         vFieldDefinition.FieldName := DestDS.Fields[J].FieldName;
         vFieldDefinition.DataType  := DestDS.Fields[J].DataType;
         If (vFieldDefinition.DataType <> ftFloat) Then
          vFieldDefinition.Size     := DestDS.Fields[J].Size
         Else
          vFieldDefinition.Size         := 0;
         If (vFieldDefinition.DataType In [ftCurrency, ftBCD,
                                           {$IFNDEF FPC}{$IF CompilerVersion > 21}ftExtended, ftSingle,
                                           {$IFEND}{$ENDIF} ftFMTBcd]) Then
          vFieldDefinition.Precision := TBCDField(DestDS.Fields[J]).Precision
         Else If (vFieldDefinition.DataType = ftFloat) Then
          vFieldDefinition.Precision := TFloatField(DestDS.Fields[J]).Precision;
         vFieldDefinition.Required   := DestDS.Fields[J].Required;
         TRESTDWClientSQL(DestDS).NewDataField(vFieldDefinition);
        End;
     End;
    For J := 0 To DestDS.Fields.Count - 1 Do
     DestDS.Fields[J].Required := False;
    DestDS.FieldDefs.BeginUpdate;
    For J := 0 To bJsonArrayB.ElementCount - 1 Do
     Begin
      bJsonOBJ := bJsonArrayB.GetObject(J);
      Try
       vTempValue := Trim(TDWJSONObject(bJsonOBJ).pairs[0].Value);
       If Trim(vTempValue) <> '' Then
        Begin
         FieldDef := TRESTDWClientSQL(DestDS).FieldDefExist(vTempValue);
         If (FieldDef = Nil) Then
          Begin
           If (TRESTDWClientSQL(DestDS).FieldExist(vTempValue) = Nil) And
              (DestDS is TRESTDWClientSQL)                            Then
            Begin
             vFieldDefinition.FieldName     := vTempValue;
             vFieldDefinition.DataType      := GetFieldType(TDWJSONObject(bJsonOBJ).pairs[1].Value);
             If (vFieldDefinition.DataType <> ftFloat) Then
              vFieldDefinition.Size         := StrToInt(TDWJSONObject(bJsonOBJ).pairs[4].Value)
             Else
              vFieldDefinition.Size         := 0;
             If (vFieldDefinition.DataType In [ftFloat, ftCurrency, ftBCD,
                                               {$IFNDEF FPC}{$IF CompilerVersion > 21}ftExtended, ftSingle,
                                               {$IFEND}{$ENDIF} ftFMTBcd]) Then
              vFieldDefinition.Precision    := StrToInt(TDWJSONObject(bJsonOBJ).pairs[5].Value);
             vFieldDefinition.Required      := Uppercase(TDWJSONObject(bJsonOBJ).pairs[3].Value) = 'S';
             TRESTDWClientSQL(DestDS).NewDataField(vFieldDefinition);
            End;
           If DestDS is TRESTDWClientSQL Then
            FieldDef         := TRESTDWClientSQL(DestDS).FieldDefs.AddFieldDef
           Else
            FieldDef         := DestDS.FieldDefs.AddFieldDef;
           FieldDef.Name     := vTempValue;
           FieldDef.DataType := GetFieldType(TDWJSONObject(bJsonOBJ).pairs[1].Value);
           If (FieldDef.DataType <> ftFloat) Then
            FieldDef.Size    := StrToInt(TDWJSONObject(bJsonOBJ).pairs[4].Value)
           Else
            FieldDef.Size    := 0;
           If (vFieldDefinition.DataType In [ftFloat, ftCurrency, ftBCD,
                                             {$IFNDEF FPC}{$IF CompilerVersion > 21}ftExtended, ftSingle,
                                             {$IFEND}{$ENDIF} ftFMTBcd]) Then
            FieldDef.Precision := StrToInt(TDWJSONObject(bJsonOBJ).pairs[5].Value);
           {$IFDEF CLIENTDATASET}
            If DestDS.FindField(vTempValue) = Nil Then
             FieldDef.CreateField(DestDS);
           {$ENDIF}
          End;
        End;
      Finally
       FreeAndNil(bJsonOBJ);
      End;
     End;
    FreeAndNil(vFieldDefinition);
    DestDS.FieldDefs.EndUpdate;
    Try
     If DestDS is TRESTDWClientSQL Then
      Begin
       TRESTDWClientSQL(DestDS).SetInBlockEvents(True);
       TRESTDWClientSQL(DestDS).Inactive := True;
       TRESTDWClientSQL(DestDS).CreateDataSet;
      End;
     If DestDS is TRESTDWClientSQL Then
      Begin
       If Not TRESTDWClientSQL(DestDS).Active Then
        TRESTDWClientSQL(DestDS).Open;
      End
     Else
      Begin
       If Not DestDS.Active Then
        DestDS.Open;
      End;
     If Not DestDS.Active Then
      Begin
       bJsonValue.Free;
       ListFields.Free;
       Raise Exception.Create('Error on Parse JSON Data...');
       Exit;
      End;
     {$IFNDEF CLIENTDATASET}
      If DestDS is TRESTDWClientSQL Then
       Begin
        TRESTDWClientSQL(DestDS).Active := True;
        TRESTDWClientSQL(DestDS).Inactive := False;
       End;
     {$ENDIF}
    Except
    End;
   If csDesigning in DestDS.ComponentState Then
    Begin
     //Clean Invalid Fields
     For A := DestDS.Fields.Count - 1 DownTo 0 Do
      Begin
       If DestDS.Fields[A].FieldKind = fkData Then
        Begin
         vFindFlag := False;
         For J := 0 To bJsonArrayB.ElementCount - 1 Do
          Begin
           bJsonOBJ := bJsonArrayB.GetObject(J);
           Try
            If Trim(TDWJSONObject(bJsonOBJ).pairs[0].Value) <> '' Then
             Begin
              vFindFlag := Lowercase(TDWJSONObject(bJsonOBJ).pairs[0].Value) = Lowercase(DestDS.Fields[A].FieldName);
              If vFindFlag Then
               Break;
             End;
           Finally
            FreeAndNil(bJsonOBJ);
           End;
          End;
         If Not vFindFlag Then
          DestDS.Fields.Remove(DestDS.Fields[A]);
        End;
      End;
    End;
    //Add Set PK Fields
    For J := 0 To bJsonArrayB.ElementCount - 1 Do
     Begin
      bJsonOBJ := bJsonArrayB.GetObject(J);
      Try
       If Uppercase(Trim(TDWJSONObject(bJsonOBJ).pairs[2].Value)) = 'S' Then
        Begin
         Field := DestDS.FindField(TDWJSONObject(bJsonOBJ).pairs[0].Value);
         If Field <> Nil Then
          Begin
           If Field.FieldKind = fkData Then
            Field.ProviderFlags := [pfInUpdate, pfInWhere, pfInKey]
           Else
            Field.ProviderFlags := [];
           {$IFNDEF FPC}
            {$IF CompilerVersion > 21}
             If bJsonOBJ.PairCount > 6 Then
              Begin
               If (Uppercase(Trim(TDWJSONObject(bJsonOBJ).pairs[7].Value)) = 'S') Then
                Field.AutoGenerateValue := arAutoInc;
              End;
            {$IFEND}
           {$ENDIF}
           End;
        End;
      Finally
       FreeAndNil(bJsonOBJ);
      End;
     End;
    For A := 0 To DestDS.Fields.Count - 1 Do // ADICIONA REGISTRO
     Begin
      vFindFlag := False;
      If DestDS.FindField(DestDS.Fields[A].FieldName) <> Nil Then
       If DestDS.FindField(DestDS.Fields[A].FieldName).FieldKind = fkData Then
        Begin
         For J := 0 To bJsonArrayB.ElementCount - 1 Do
          Begin
           bJsonOBJ := bJsonArrayB.GetObject(J);
           If Trim(TDWJSONObject(bJsonOBJ).pairs[0].Value) <> '' Then
            Begin
             vFindFlag := Uppercase(Trim(TDWJSONObject(bJsonOBJ).pairs[0].Value)) = Uppercase(DestDS.Fields[A].FieldName);
             If vFindFlag Then
              Begin
               ListFields.Add(inttostr(J));
               FreeAndNil(bJsonOBJ);
               Break;
             End;
             End;
           FreeAndNil(bJsonOBJ);
          End;
        End;
      If Not vFindFlag Then
       ListFields.Add('-1');
     End;
    If DestDS is TRESTDWClientSQL Then
     Begin
      If TRESTDWClientSQL(DestDS).GetInDesignEvents Then
       Begin
        FreeAndNil(bJsonValue);
        ListFields.Free;
        TRESTDWClientSQL(DestDS).SetInDesignEvents(False);
        Exit;
       End;
     End;
   End
  Else
   Begin
    For A := 0 To DestDS.Fields.Count - 1 Do // ADICIONA REGISTRO
     Begin
      vFindFlag := False;
      If DestDS.FindField(DestDS.Fields[A].FieldName) <> Nil Then
       If DestDS.FindField(DestDS.Fields[A].FieldName).FieldKind = fkData Then
        Begin
         For J := 0 To bJsonArrayB.ElementCount - 1 Do
          Begin
           bJsonOBJ := bJsonArrayB.GetObject(J);
           If Trim(TDWJSONObject(bJsonOBJ).pairs[0].Value) <> '' Then
            Begin
             vFindFlag := Uppercase(Trim(TDWJSONObject(bJsonOBJ).pairs[0].Value)) = Uppercase(DestDS.Fields[A].FieldName);
             If vFindFlag Then
              Begin
               ListFields.Add(inttostr(J));
               FreeAndNil(bJsonOBJ);
               Break;
             End;
             End;
           FreeAndNil(bJsonOBJ);
          End;
        End;
      If Not vFindFlag Then
       ListFields.Add('-1');
     End;
    vActualBookmark := DestDS.GetBookmark;
   End;
  FreeAndNil(bJsonArrayB);
  bJsonOBJ    := bJsonArray.GetObject(1);
  bJsonArrayB := TDWJSONArray(TDWJSONArray(bJsonOBJ).GetObject(0));
  If DestDS Is TRESTDWClientSQL Then
   TRESTDWClientSQL(DestDS).SetInBlockEvents(True);
  JsonCount   := bJsonArrayB.ElementCount;
  If ((ActualRec + Datapacks) > (bJsonArrayB.ElementCount - 1)) Or (Datapacks = -1) Then
   vPageCount  := bJsonArrayB.ElementCount - 1
  Else
   vPageCount  := (ActualRec + Datapacks - 1);
  For J := ActualRec To vPageCount Do
   Begin
    bJsonOBJB := TDWJSONArray(bJsonArrayB).GetObject(J);
    bJsonOBJTemp := TDWJSONObject(bJsonOBJB).openArray(TDWJSONObject(bJsonOBJB).pairs[0].Name);
    If DestDS Is TRESTDWClientSQL Then
     TRESTDWClientSQL(DestDS).Append
    Else
     DestDS.Append;
    Try
     For i := 0 To DestDS.Fields.Count - 1 Do
      Begin
       vOldReadOnly                := DestDS.Fields[i].ReadOnly;
       FieldValidate               := DestDS.Fields[i].OnValidate;
       DestDS.Fields[i].OnValidate := Nil;
       DestDS.Fields[i].ReadOnly   := False;
       If DestDS.Fields[i].FieldKind = fkLookup Then
        Begin
         If DestDS Is TRESTDWClientSQL Then
          Begin
           DestDS.Fields[i].ReadOnly := vOldReadOnly;
           DestDS.Fields[i].OnValidate := FieldValidate;
          End
         Else
          Begin
           DestDS.Fields[i].ReadOnly := vOldReadOnly;
           DestDS.Fields[i].OnValidate := FieldValidate;
          End;
         Continue;
        End;
       If (i >= ListFields.Count) Then
        Begin
         DestDS.Fields[i].ReadOnly := vOldReadOnly;
         DestDS.Fields[i].OnValidate := FieldValidate;
         Continue;
        End;
       If (StrToInt(ListFields[i])       = -1)     Or
          Not(DestDS.Fields[i].FieldKind = fkData) Or
          (StrToInt(ListFields[i]) = -1)           Then
        Begin
         DestDS.Fields[i].ReadOnly := vOldReadOnly;
         DestDS.Fields[i].OnValidate := FieldValidate;
         Continue;
        End;
       FreeAndNil(bJsonOBJB);
       bJsonOBJB  := bJsonOBJTemp.GetObject(StrToInt(ListFields[i]));
       vTempValue := TDWJSONObject(bJsonOBJB).pairs[0].Value;
       If vEncoding = esUtf8 Then
        Begin
//      {$IFDEF FPC}
//       vTempValue := PWidechar(UTF8Decode(vTempValue));
//      {$ELSE}
         vTempValue := UTF8Decode(vTempValue);
//      {$ENDIF}
        End;
       If DestDS.Fields[i].DataType In [ftGraphic, ftParadoxOle, ftDBaseOle, ftTypedBinary, ftCursor,
                                        ftDataSet, ftBlob, ftOraBlob, ftOraClob{$IFNDEF FPC}{$IF CompilerVersion > 21},
                                        ftParams, ftStream{$IFEND}{$ENDIF}] Then
        Begin
         If (vTempValue <> 'null') And (vTempValue <> '') Then
          Begin
           HexStringToStream(vTempValue, vBlobStream);
           Try
            vBlobStream.Position := 0;
            TBlobField(DestDS.Fields[i]).LoadFromStream(vBlobStream);
           Finally
            {$IFNDEF FPC}
             {$IF CompilerVersion > 21}
              vBlobStream.Clear;
             {$IFEND}
            {$ENDIF}
            FreeAndNil(vBlobStream);
           End;
          End;
        End
       Else
        Begin
         If (Lowercase(vTempValue) <> 'null') Then
          Begin
          If DestDS.Fields[i].DataType in [ftString, ftWideString,
                                             {$IFNDEF FPC}{$IF CompilerVersion > 21}ftWideMemo,
                                            {$IFEND}{$ENDIF}ftMemo, ftFmtMemo, ftFixedChar] Then
            Begin
             If vTempValue = '' Then
              DestDS.Fields[i].AsString := ''
             Else
              Begin
               If vEncoded Then
                Begin
                 vTempValue := DecodeStrings(vTempValue{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
                 {$IFNDEF FPC}
                  {$IF (CompilerVersion < 19)}
                   If vEncoding = esUtf8 Then
                    vTempValue := UTF8Decode(vTempValue);
                  {$IFEND}
                 {$ENDIF}
                 DestDS.Fields[i].AsString := vTempValue;
                End
               Else
                DestDS.Fields[i].AsString := vTempValue;
              End;
            End
           Else If (vTempValue <> '') then
            SetValueA(DestDS.Fields[i], vTempValue);
          End;
        End;
       DestDS.Fields[i].ReadOnly := vOldReadOnly;
       DestDS.Fields[i].OnValidate := FieldValidate;
       FreeAndNil(bJsonOBJB);
      End;
    Finally
     vTempValue := '';
    End;
    FreeAndNil(bJsonOBJTemp);
    FreeAndNil(bJsonOBJB);
    DestDS.Post;
   End;
  If DestDS is TRESTDWClientSQL Then
   Begin
    For J := 0 To TRESTDWClientSQL(DestDS).FieldListCount - 1 Do
     Begin
      If Not (TRESTDWClientSQL(DestDS).FieldExist(TRESTDWClientSQL(DestDS).ServerFieldList[J].FieldName) = Nil) Then
       DestDS.FindField(TRESTDWClientSQL(DestDS).ServerFieldList[J].FieldName).Required := TRESTDWClientSQL(DestDS).ServerFieldList[J].Required;
     End;
   End;
 Finally
  FreeAndNil(bJsonOBJ);
  FreeAndNil(bJsonArrayB);
  FreeAndNil(bJsonArray);
  FreeAndNil(bJsonValue);
  If DestDS is TRESTDWClientSQL Then
   Begin
    TRESTDWClientSQL(DestDS).SetInBlockEvents(False);
    TRESTDWClientSQL(DestDS).SetInitDataset(True);
    If (DestDS.Active) And (ActualRec = 0) Then
     Begin
      If Datapacks = -1 Then
       TRESTDWClientSQL(DestDS).SetRecordCount(vPageCount +1, vPageCount +1)
      Else
       TRESTDWClientSQL(DestDS).SetRecordCount(JsonCount, vPageCount +1);
      DestDS.First;
     End
    Else
     Begin
      TRESTDWClientSQL(DestDS).SetNotRepage(True);
      DestDS.GotoBookmark(vActualBookmark);
     End;
    If DestDS.State = dsBrowse Then
     Begin
      If DestDS.RecordCount = 0 Then
       TRESTDWClientSQL(DestDS).PrepareDetailsNew
      Else
       TRESTDWClientSQL(DestDS).PrepareDetails(True);
     End;
    TRESTDWClientSQL(DestDS).SetInitDataset(False);
   End
  Else
   DestDS.First;
  If Assigned(ListFields) Then
   FreeAndNil(ListFields);
  If DestDS is TRESTDWClientSQL Then
   TRESTDWClientSQL(DestDS).EnableControls
  Else
   DestDS.EnableControls;
 End;
End;

procedure TJSONValue.WriteToDataset2(JSONValue: String; DestDS: TDataset);
Var
  FieldsValidate: Array of TFieldNotifyEvent;
  FieldsChange: Array of TFieldNotifyEvent;
  FieldsReadOnly: Array of Boolean;
  bJsonOBJB, bJsonOBJ, FieldJson: TDWJSONBase;
  bJsonValue: TDWJSONObject;
  bJsonOBJTemp, DataSetJson, FieldsJson, LinesJson: TDWJSONArray;
  J, I: Integer;
  FieldDef: TFieldDef;
  vBlobStream: TStringStream;
  vTempValue: String;
  sFieldName: string;
  vFieldDefinition: TFieldDefinition;
Begin
  If JSONValue = '' Then
    Exit;
  Try
    If Pos('[', JSONValue) = 0 Then
      Exit;
    bJsonValue := TDWJSONObject.Create(JSONValue);
    If bJsonValue.PairCount > 0 Then Begin
      vTypeObject := GetObjectName(bJsonValue.pairs[0].Value);
      vObjectDirection := GetDirectionName(bJsonValue.pairs[1].Value);
      vEncoded := GetBooleanFromString(bJsonValue.pairs[2].Value);
      vObjectValue := GetValueType(bJsonValue.pairs[3].Value);
      vtagName := Lowercase(bJsonValue.pairs[4].Name);
      DestDS.DisableControls;
      If DestDS.Active Then
        DestDS.Close;
      DataSetJson := TDWJSONArray(bJsonValue.openArray(bJsonValue.pairs[4].Name));
      bJsonOBJ := DataSetJson.GetObject(0);
      FieldsJson := TDWJSONObject(bJsonOBJ).openArray(TDWJSONObject(bJsonOBJ).pairs[0].Name);
      FreeAndNil(bJsonOBJ);
      vFieldDefinition := TFieldDefinition.Create;

      If DestDS.Fields.Count = 0 Then
        DestDS.FieldDefs.Clear;
      For J := 0 To DestDS.Fields.Count - 1 Do
        DestDS.Fields[J].Required := False;
      DestDS.FieldDefs.BeginUpdate;

      if (not DestDS.Active) and (DestDS.FieldCount = 0) then begin
        For J := 0 To FieldsJson.ElementCount - 1 Do Begin
          FieldJson := FieldsJson.GetObject(J);
          Try
            sFieldName := Trim(TDWJSONObject(FieldJson).pairs[0].Value);
            If Trim(sFieldName) <> '' Then Begin
              FieldDef := DestDS.FieldDefs.AddFieldDef;
              FieldDef.Name := sFieldName;
              FieldDef.DataType := GetFieldType(TDWJSONObject(FieldJson).pairs[1].Value);
              FieldDef.Size := StrToInt(TDWJSONObject(FieldJson).pairs[4].Value);
              If FieldDef.DataType In [ftFloat, ftCurrency, ftBCD, ftFMTBcd] Then Begin
                FieldDef.Size := StrToInt(TDWJSONObject(FieldJson).pairs[4].Value);
                FieldDef.Precision := StrToInt(TDWJSONObject(FieldJson).pairs[5].Value);
              End;
            End;
          Finally
            FreeAndNil(FieldJson);
          End;
        End;
        FreeAndNil(vFieldDefinition);
        DestDS.FieldDefs.EndUpdate;
      end;

      If Not DestDS.Active Then
        DestDS.Open;
      If Not DestDS.Active Then Begin
        bJsonValue.Free;
        Raise Exception.Create('Error on Parse JSON Data...');
        Exit;
      End;

      {Reservando as propriedades ReadOnly, OnValidate e OnChange de cada TField}
      for I := 0 to DestDS.FieldCount - 1 do begin
        SetLength(FieldsValidate, Length(FieldsValidate) + 1);
        FieldsValidate[High(FieldsValidate)] := DestDS.Fields[I].OnValidate;
        DestDS.Fields[I].OnValidate := nil;

        SetLength(FieldsChange, Length(FieldsChange) + 1);
        FieldsValidate[High(FieldsChange)] := DestDS.Fields[I].OnChange;
        DestDS.Fields[I].OnChange := nil;

        SetLength(FieldsReadOnly, Length(FieldsReadOnly) + 1);
        FieldsReadOnly[High(FieldsReadOnly)] := DestDS.Fields[I].ReadOnly;
        DestDS.Fields[I].ReadOnly := False;
      end;

      {Loop no dataset}
      FreeAndNil(bJsonOBJ);
      bJsonOBJ := DataSetJson.GetObject(0);
      FreeAndNil(FieldsJson);
      FieldsJson := TDWJSONObject(bJsonOBJ).openArray(TDWJSONObject(bJsonOBJ).pairs[0].Name);

      FreeAndNil(bJsonOBJ);
      bJsonOBJ := FieldsJson.GetObject(0);
      FreeAndNil(LinesJson);
      bJsonOBJ := DataSetJson.GetObject(1);
      LinesJson := TDWJSONArray(TDWJSONArray(bJsonOBJ).GetObject(0));

      For J := 0 To LinesJson.ElementCount - 1 Do Begin
        bJsonOBJB := TDWJSONArray(LinesJson).GetObject(J);
        bJsonOBJTemp := TDWJSONObject(bJsonOBJB).openArray(TDWJSONObject(bJsonOBJB).pairs[0].Name);
        DestDS.Append;
        Try
          For I := 0 To FieldsJson.ElementCount - 1 Do Begin
            FieldJson := FieldsJson.GetObject(I);
            sFieldName := Trim(TDWJSONObject(FieldJson).pairs[0].Value);
            FreeAndNil(bJsonOBJB);
            bJsonOBJB := bJsonOBJTemp.GetObject(I);
            vTempValue := TDWJSONObject(bJsonOBJB).pairs[0].Value;
            If DestDS.FieldByName(sFieldName).DataType In [ftGraphic, ftParadoxOle, ftDBaseOle, ftTypedBinary, ftCursor, ftDataSet, ftBlob,
              ftOraBlob, ftOraClob
{$IFNDEF FPC}{$IF CompilerVersion > 21}, ftParams, ftStream{$IFEND}{$ENDIF}] Then
            Begin
              If (vTempValue <> 'null') And (vTempValue <> '') Then Begin
                HexStringToStream(vTempValue, vBlobStream);
                Try
                  vBlobStream.Position := 0;
                  TBlobField(DestDS.FieldByName(sFieldName)).LoadFromStream(vBlobStream);
                Finally
{$IFNDEF FPC}{$IF CompilerVersion > 21}
                  vBlobStream.Clear;
{$IFEND}{$ENDIF}
                  FreeAndNil(vBlobStream);
                End;
              End;
            End Else Begin
              If (Lowercase(vTempValue) <> 'null') Then Begin
                If DestDS.FieldByName(sFieldName).DataType in [ftString, ftWideString,{$IFNDEF FPC}{$IF CompilerVersion > 21}ftWideMemo, {$IFEND}{$ENDIF}ftMemo, ftFmtMemo, ftFixedChar] Then Begin
                  If vTempValue = '' Then
                    DestDS.FieldByName(sFieldName).Value := ''
                  Else Begin
                    If vEncoded Then
                      DestDS.FieldByName(sFieldName).Value := DecodeStrings(vTempValue{$IFDEF FPC}, vDatabaseCharSet{$ENDIF})
                    Else
                      DestDS.FieldByName(sFieldName).Value := vTempValue;
                  End;
                End Else If (vTempValue <> '') then
                  SetValueA(DestDS.FieldByName(sFieldName), vTempValue);
              End;
            End;
            FreeAndNil(bJsonOBJB);
          End;
        Finally
          vTempValue := '';
        End;
        FreeAndNil(bJsonOBJTemp);
        FreeAndNil(bJsonOBJB);
        DestDS.Post;
      End;

      {Devolvendo as propriedades ReadOnly, OnValidate e OnChange de cada TField}
      for I := 0 to DestDS.FieldCount - 1 do begin
        DestDS.Fields[I].OnValidate := FieldsValidate[I];
        DestDS.Fields[I].OnChange := FieldsChange[I];
        DestDS.Fields[I].ReadOnly := FieldsReadOnly[I];
      end;

    End Else Begin
      DestDS.Close;
      Raise Exception.Create('Invalid JSON Data...');
    End;
  Finally
    FreeAndNil(bJsonOBJ);
    FreeAndNil(FieldsJson);
    FreeAndNil(DataSetJson);
    FreeAndNil(bJsonValue);
    If DestDS.Active Then
      DestDS.First;
    DestDS.EnableControls;
  End;
End;

Procedure TJSONValue.SaveToFile(FileName: String);
Var
 vStringStream : TStringStream;
 {$IFDEF FPC}
 vFileStream   : TFileStream;
 {$ELSE}
   {$IF CompilerVersion < 21} // Delphi 2010 pra cima
   vFileStream : TFileStream;
   {$IFEND}
 {$ENDIF}
Begin
 vStringStream := TStringStream.Create(ToJSON);
 Try
  {$IFDEF FPC}
  vStringStream.Position := 0;
  vFileStream   := TFileStream.Create(FileName, fmCreate);
  Try
   vFileStream.CopyFrom(vStringStream, vStringStream.Size);
  Finally
   vFileStream.Free;
  End;
  {$ELSE}
   {$IF CompilerVersion > 21} // Delphi 2010 pra cima
    vStringStream.Position := 0;
    vStringStream.SaveToFile(FileName);
   {$ELSE}
    vStringStream.Position := 0;
    vFileStream   := TFileStream.Create(FileName, fmCreate);
    Try
     vFileStream.CopyFrom(vStringStream, vStringStream.Size);
    Finally
     vFileStream.Free;
    End;
   {$IFEND}
  {$ENDIF}
 Finally
  vStringStream.Free;
 End;
End;

Procedure TJSONValue.SaveToStream(Stream : TMemoryStream;
                                  Binary : Boolean = False);
Begin
 Try
  If Not Binary Then
   Stream.Write(aValue[0], Length(aValue))
  Else
   HexToStream(Value, Stream);
 Finally
  Stream.Position := 0;
 End;
End;

{$IF Defined(ANDROID) OR Defined(IOS)}
// Alterado para IOS Brito
Procedure TJSONValue.LoadFromJSON(bValue: String);
Var
 bJsonValue: System.json.TJsonObject;
 vTempValue: String;
 vStringStream: TMemoryStream;
Begin
 bJsonValue := TJsonObject.ParseJSONValue(bValue) as System.json.TJsonObject;
 Try
  If bJsonValue.Count > 0 Then
   Begin
    vNullValue       := False;
    vTempValue       := CopyValue(bValue);
    vTypeObject      := GetObjectName(RemoveSTR(bJsonValue.pairs[0].JSONValue.ToString, '"'));
    vObjectDirection := GetDirectionName(RemoveSTR(bJsonValue.pairs[1].JSONValue.ToString, '"'));
    vObjectValue     := GetValueType(RemoveSTR(bJsonValue.pairs[3].JSONValue.ToString, '"'));
    vtagName := Lowercase(RemoveSTR(bJsonValue.pairs[4].jsonstring.ToString, '"')); // bJsonValue.names.get(4).ToString);
    If vTypeObject = toDataset Then
     Begin
      If vTempValue[InitStrPos] = '[' Then
       vTempValue := vTempValue.Remove(InitStrPos, 1); // Delete(vTempValue, InitStrPos, 1);
      If vTempValue[Length(vTempValue) - 1] = ']' Then
       vTempValue := vTempValue.Remove(Length(vTempValue) - 1, 1); // Delete(vTempValue, Length(vTempValue), 1);
     End;
    If vEncoded Then
     Begin
      If vObjectValue In [ovBytes, ovVarBytes, ovBlob, ovGraphic, ovOraBlob, ovOraClob] Then
       Begin
        vStringStream := TMemoryStream.Create;
        Try
         HexToStream(vTempValue, vStringStream);
         aValue := TIdBytes(StreamToBytes(vStringStream));
        Finally
         vStringStream.Free;
        End;
       End
      Else
       vTempValue := DecodeStrings(vTempValue);
     End;
    If Not(vObjectValue In [ovBytes, ovVarBytes, ovBlob, ovGraphic, ovOraBlob, ovOraClob]) Then
     SetValue(vTempValue, vEncoded)
    Else
     Begin
      vStringStream := TMemoryStream.Create;
      Try
       HexToStream(vTempValue, vStringStream);
       aValue := TIdBytes(StreamToBytes(vStringStream));
      Finally
       FreeAndNil(vStringStream);
      End;
     End;
   End;
 Finally
  bJsonValue.Free;
 End;
End;
{$ELSE}
Procedure TJSONValue.LoadFromJSON(bValue: String);
Var
 bJsonValue    : TDWJSONObject;
 vTempValue    : String;
 vStringStream : TMemoryStream;
Begin
 bJsonValue    := TDWJSONObject.Create(bValue);
 Try
  If bJsonValue.PairCount > 0 Then
   Begin
    vNullValue := False;
    vTempValue := CopyValue(bValue);
    vTypeObject := GetObjectName(bJsonValue.pairs[0].Value);
    vObjectDirection := GetDirectionName(bJsonValue.pairs[1].Value);
    vObjectValue := GetValueType(bJsonValue.pairs[3].Value);
    vtagName := Lowercase(bJsonValue.pairs[4].Name);
    If vTypeObject = toDataset Then
     Begin
      If vTempValue[InitStrPos] = '[' Then
       Delete(vTempValue, InitStrPos, 1);
      If vTempValue[Length(vTempValue)] = ']' Then
       Delete(vTempValue, Length(vTempValue), 1);
     End;
    If vEncoded Then
     Begin
      If vObjectValue In [ovBytes, ovVarBytes, ovBlob, ovGraphic, ovOraBlob, ovOraClob] Then
       Begin
        vStringStream := TMemoryStream.Create;
        Try
         HexToStream(vTempValue, vStringStream);
         aValue := TIdBytes(StreamToBytes(vStringStream));
        Finally
         vStringStream.Free;
        End;
       End
      Else
       vTempValue := DecodeStrings(vTempValue{$IFDEF FPC}, vDatabaseCharSet{$ENDIF});
     End;
    If Not(vObjectValue In [ovBytes, ovVarBytes, ovBlob, ovGraphic, ovOraBlob, ovOraClob]) Then
     SetValue(vTempValue, vEncoded)
    Else
     Begin
      vStringStream := TMemoryStream.Create;
      Try
       HexToStream(vTempValue, vStringStream);
       aValue := TIdBytes(StreamToBytes(vStringStream));
      Finally
       FreeAndNil(vStringStream);
      End;
     End;
   End;
 Finally
  bJsonValue.Free;
 End;
End;
{$IFEND}
Procedure TJSONValue.LoadFromJSON(bValue         : String;
                                  JsonModeD      : TJsonMode);
Var
 bJsonValue    : TDWJSONObject;
Begin
 bJsonValue    := TDWJSONObject.Create(bValue);
 Try
  If bJsonValue.PairCount > 0 Then
   Begin
    vTypeObject      := toObject;
    vObjectDirection := odINOUT;
    vObjectValue     := ovString;
    vtagName         := 'jsonpure';
    SetValue(bValue, vEncoded);
   End;
 Finally
  bJsonValue.Free;
 End;
End;

Procedure TJSONValue.LoadFromStream(Stream : TMemoryStream;
                                    Encode : Boolean = True);
Begin
 ObjectValue := ovBlob;
 vBinary := True;
 SetValue(StreamToHex(Stream), Encode);
End;

Procedure TJSONValue.StringToBytes(Value  : String;
                                   Encode : Boolean = False);
Var
 Stream: TStringStream;
Begin
 If Value <> '' Then
  Begin
   ObjectValue := ovBlob;
   vBinary     := True;
   vEncoded    := Encode;
   Stream      := TStringStream.Create(Value);
   Try
    Stream.Position := 0;
    SetValue(StreamToHex(Stream), Encode);
   Finally
    Stream.Free;
   End;
  End;
End;

Procedure TJSONValue.SetEncoding(bValue : TEncodeSelect);
Begin
 vEncoding := bValue;
 {$IFDEF FPC}
  Case vEncoding Of
   esASCII : vEncodingLazarus := TEncoding.ANSI;
   esUtf8  : vEncodingLazarus := TEncoding.Utf8;
  End;
 {$ENDIF}
End;

Procedure TJSONValue.SetValue(Value  : String;
                              Encode : Boolean);
Begin
 vEncoded   := Encode;
 vNullValue := False;
 If Encode Then
  Begin
   If vObjectValue in [ovBytes, ovVarBytes, ovBlob, ovGraphic, ovOraBlob, ovOraClob] Then
    Begin
     vBinary := True;
     WriteValue(Value);
    End
   Else
    Begin
     vBinary := False;
     WriteValue(EncodeStrings(Value{$IFDEF FPC}, vDatabaseCharSet{$ENDIF}))
    End;
  End
 Else
  Begin
   If vObjectValue in [ovBytes, ovVarBytes, ovBlob, ovGraphic, ovOraBlob, ovOraClob] Then
    Begin
     vBinary := True;
     WriteValue(Value);
    End
   Else
    Begin
     vBinary := False;
     WriteValue(Value);
    End;
  End;
End;

Procedure TJSONValue.WriteValue(bValue : String);
Var
 vSizeChar  : Integer;
 {$IF Not Defined(HAS_FMX)}
  vValueAnsi : AnsiString;
 {$IFEND}
Begin
 SetLength(aValue, 0);
 If bValue = '' Then
  Exit;
 If vObjectValue in [ovString, ovMemo, ovWideMemo, ovFmtMemo, ovObject] Then
  Begin
   {$IFDEF FPC}
   If vEncodingLazarus = Nil Then
    SetEncoding(vEncoding);
   If vEncoded Then
    Begin
     If vEncoding = esUtf8 Then
      aValue := TIdBytes(vEncodingLazarus.GetBytes(Format(TJsonStringValue, [bValue])))
     Else
      aValue := ToBytes(Format(TJsonStringValue, [bValue]), GetEncodingID(vEncoding))
    End
   Else
    Begin
     If ((JsonMode = jmDataware) And (vEncoded)) Or Not(vObjectValue = ovObject) Then
      Begin
       If vEncoding = esUtf8 Then
        aValue := TIdBytes(vEncodingLazarus.GetBytes(Format(TJsonStringValue, [bValue])))
       Else
        aValue := ToBytes(Format(TJsonStringValue, [bValue]), GetEncodingID(vEncoding));
      End
     Else
      Begin
       If vEncoding = esUtf8 Then
        aValue := TIdBytes(vEncodingLazarus.GetBytes(bValue))
       Else
        aValue := ToBytes(bValue, GetEncodingID(vEncoding));
      End;
    End;
   {$ELSE}
   If vEncoded Then
    aValue := ToBytes(Format(TJsonStringValue, [bValue]), GetEncodingID(vEncoding))
   Else
    Begin
     If ((JsonMode = jmDataware) And (vEncoded)) Or
        Not(vObjectValue = ovObject) Then
      aValue := ToBytes(Format(TJsonStringValue, [bValue]), GetEncodingID(vEncoding))
     Else
      aValue := ToBytes(bValue, GetEncodingID(vEncoding));
    End;
   {$ENDIF}
  End
 Else If vObjectValue in [ovDate, ovTime, ovDateTime, ovTimeStamp, ovOraTimeStamp, ovTimeStampOffset] Then
  Begin
   {$IFDEF FPC}
    If vEncoding = esUtf8 Then
     aValue := TIdBytes(vEncodingLazarus.GetBytes(Format(TJsonStringValue, [bValue])))
    Else
     aValue := ToBytes(Format(TJsonStringValue, [bValue]), GetEncodingID(vEncoding));
   {$ELSE}
    aValue := ToBytes(Format(TJsonStringValue, [bValue]), GetEncodingID(vEncoding));
   {$ENDIF}
  End
 Else If vObjectValue in [ovFloat, ovCurrency, ovBCD, ovFMTBcd, ovExtended] Then
  Begin
   {$IFDEF FPC}
    If vEncoding = esUtf8 Then
     aValue := TIdBytes(vEncodingLazarus.GetBytes(Format(TJsonStringValue, [bValue])))
    Else
     aValue := ToBytes(BuildFloatString(Format(TJsonStringValue, [bValue])), GetEncodingID(vEncoding));
   {$ELSE}
    aValue := ToBytes(BuildFloatString(Format(TJsonStringValue, [bValue])), GetEncodingID(vEncoding));
   {$ENDIF}
  End
 Else
  Begin
   {$IFDEF FPC}
    If vEncoding = esUtf8 Then
     aValue := TIdBytes(vEncodingLazarus.GetBytes(bValue))
    Else
     aValue := ToBytes(bValue, GetEncodingID(vEncoding));
   {$ELSE}
   {$IF CompilerVersion > 21} // Delphi 2010 pra cima
    aValue := ToBytes(bValue, GetEncodingID(vEncoding));
   {$ELSE} // Delphi 2010 pra cima
    vSizeChar := 1;
    {
    If vEncoding = esUtf8 Then
     Begin
      vSizeChar := 2;
      SetLength(aValue, Length(bValue) * vSizeChar);
      move(bValue[InitStrPos], pByteArray(aValue)^, Length(aValue));
     End
    Else
     Begin
     }
      vValueAnsi := bValue;
      SetLength(aValue, Length(vValueAnsi));
      move(vValueAnsi[InitStrPos], pByteArray(aValue)^, Length(aValue));
//     End;
    {$IFEND}
   {$ENDIF}
  End;
End;

Constructor TJSONParam.Create(Encoding: TEncodeSelect);
Begin
 vJSONValue         := TJSONValue.Create;
 vJsonMode          := jmDataware;
 vEncoding          := Encoding;
 vTypeObject        := toParam;
 ObjectDirection    := odINOUT;
 vObjectValue       := ovString;
 vBinary            := False;
 vJSONValue.vBinary := vBinary;
 vEncoded           := True;
End;

Destructor TJSONParam.Destroy;
Begin
 If vJSONValue <> Nil Then
  FreeAndNil(vJSONValue);
 Inherited;
End;

Procedure TJSONParam.LoadFromParam(Param : TParam);
Var
 MemoryStream : TMemoryStream;
Begin
 If Param.DataType in [ftString, ftWideString, ftMemo,
                      {$IFNDEF FPC}{$IF CompilerVersion > 21}ftWideMemo,{$IFEND}{$ENDIF}
                       ftFmtMemo, ftFixedChar] Then
  Begin
   vEncoded := True;
   SetValue(Param.AsString, vEncoded);
  End
 Else If Param.DataType in [{$IFNDEF FPC}{$IF CompilerVersion > 21}ftLongword, ftExtended, ftSingle,{$IFEND}{$ENDIF}
                            ftInteger, ftSmallint, ftLargeint, ftFloat, ftCurrency, ftFMTBcd, ftBCD] Then
  SetValue(BuildStringFloat(Param.AsString, JsonMode, vFloatDecimalFormat), False)
 Else If Param.DataType In [ftBytes, ftVarBytes, ftBlob, ftGraphic, ftOraBlob, ftOraClob] Then
  Begin
   MemoryStream := TMemoryStream.Create;
   Try
    {$IFDEF FPC}
     Param.SetData(MemoryStream);
    {$ELSE}
     {$IF CompilerVersion > 21}
      MemoryStream.CopyFrom(Param.AsStream, Param.AsStream.Size);
     {$ELSE}
      Param.SetData(MemoryStream);
     {$IFEND}
    {$ENDIF}
    LoadFromStream(MemoryStream);
    vEncoded := False;
   Finally
    MemoryStream.Free;
   End;
  End
 Else If Param.DataType in [ftDate, ftTime, ftDateTime, ftTimeStamp] Then
  Begin
   If Param.DataType = ftDate Then
    SetValue(inttostr(DateTimeToUnix(Param.AsDate)), False)
   Else if Param.DataType = ftTime then
    SetValue(inttostr(DateTimeToUnix(Param.AsTime)), False)
   Else
    SetValue(inttostr(DateTimeToUnix(Param.AsDateTime)), False);
  End;
 vObjectValue := FieldTypeToObjectValue(Param.DataType);
 vJSONValue.vObjectValue := vObjectValue;
End;

Procedure TJSONParam.LoadFromStream(Stream : TMemoryStream;
                                    Encode : Boolean);
Begin
 ObjectValue       := ovBlob;
 vEncoded          := True;
 SetValue(StreamToHex(Stream), vEncoded);
 vBinary           := True;
 vJSONValue.Binary := vBinary;
End;

Procedure TJSONParam.FromJSON(json    : String);
Var
 bJsonValue : TDWJSONObject;
 vValue     : String;
Begin
 If Pos(#$D#$A, json) > 0 Then
  vValue     := StringReplace(json, #$D#$A, '', [rfReplaceAll])
 Else
  vValue     := json;
 {$IFDEF FPC}
  If vEncoding = esUtf8 Then
   bJsonValue    := TDWJSONObject.Create(PWidechar(UTF8Decode(vValue)))
  Else
   bJsonValue    := TDWJSONObject.Create(vValue);
 {$ELSE}
  bJsonValue    := TDWJSONObject.Create(vValue);
 {$ENDIF}
 Try
  vValue := CopyValue(vValue);
  If bJsonValue.PairCount > 0 Then
   Begin
    vTypeObject        := GetObjectName       (bJsonValue.Pairs[0].Value);
    vObjectDirection   := GetDirectionName    (bJsonValue.Pairs[1].Value);
    vEncoded           := GetBooleanFromString(bJsonValue.Pairs[2].Value);
    vObjectValue       := GetValueType        (bJsonValue.Pairs[3].Value);
    vParamName         := Lowercase           (bJsonValue.Pairs[4].name);
    WriteValue(vValue);
    vBinary            := vObjectValue in [ovBytes, ovVarBytes, ovBlob, ovGraphic, ovOraBlob, ovOraClob];
    vJSONValue.vBinary := vBinary;
   End;
 Finally
  bJsonValue.Free;
 End;
End;

Procedure TJSONParam.CopyFrom(JSONParam : TJSONParam);
Var
 vValue : String;
Begin
 Try
  vValue                := JSONParam.Value;
  Self.vTypeObject      := JSONParam.vTypeObject;
  Self.vObjectDirection := JSONParam.vObjectDirection;
  Self.vEncoded         := JSONParam.vEncoded;
  Self.vObjectValue     := JSONParam.vObjectValue;
  Self.vParamName       := JSONParam.vParamName;
  Self.SetValue(vValue);
 Finally
 End;
End;

Procedure TJSONParam.SaveToFile(FileName: String);
Var
 vStringStream : TStringStream;
 {$IFDEF FPC}
 vFileStream   : TFileStream;
 {$ELSE}
   {$IF CompilerVersion < 21} // Delphi 2010 pra cima
   vFileStream : TFileStream;
   {$IFEND}
 {$ENDIF}
Begin
 vStringStream := TStringStream.Create(ToJSON);
 Try
  {$IFDEF FPC}
  vStringStream.Position := 0;
  vFileStream   := TFileStream.Create(FileName, fmCreate);
  Try
   vFileStream.CopyFrom(vStringStream, vStringStream.Size);
  Finally
   vFileStream.Free;
  End;
  {$ELSE}
   {$IF CompilerVersion > 21} // Delphi 2010 pra cima
    vStringStream.Position := 0;
    vStringStream.SaveToFile(FileName);
   {$ELSE}
    vStringStream.Position := 0;
    vFileStream   := TFileStream.Create(FileName, fmCreate);
    Try
     vFileStream.CopyFrom(vStringStream, vStringStream.Size);
    Finally
     vFileStream.Free;
    End;
   {$IFEND}
  {$ENDIF}
 Finally
  vStringStream.Free;
 End;
End;

Procedure TJSONParam.SaveToStream(Stream: TMemoryStream);
Begin
 HexToStream(GetAsString, Stream);
End;

{$IFDEF DEFINE(FPC) Or NOT(DEFINE(POSIX))}
Procedure TJSONParam.SetAsAnsiString(Value: AnsiString);
Begin
 {$IFDEF FPC}
  SetDataValue(Value, ovString);
 {$ELSE}
  {$IF CompilerVersion > 21} // Delphi 2010 pra cima
   SetDataValue(Utf8ToAnsi(Value), ovString);
  {$ELSE}
   SetDataValue(Value, ovString);
  {$IFEND}
 {$ENDIF}
End;
{$ENDIF}

Procedure TJSONParam.SetAsBCD     (Value : Currency);
Begin
 SetDataValue(Value, ovBCD);
End;

Procedure TJSONParam.SetAsBoolean (Value : Boolean);
Begin
 SetDataValue(Value, ovBoolean);
End;

Procedure TJSONParam.SetAsCurrency(Value : Currency);
Begin
 SetDataValue(Value, ovCurrency);
End;

Procedure TJSONParam.SetAsDate    (Value : TDateTime);
Begin
 SetDataValue(Value, ovDate);
End;

Procedure TJSONParam.SetAsDateTime(Value : TDateTime);
Begin
 SetDataValue(Value, ovDateTime);
End;

Procedure TJSONParam.SetAsFloat   (Value : Double);
Begin
 SetDataValue(Value, ovFloat);
End;

Procedure TJSONParam.SetAsFMTBCD  (Value : Currency);
Begin
 SetDataValue(Value, ovFMTBcd);
End;

Procedure TJSONParam.SetAsInteger (Value : Integer);
Begin
 SetDataValue(Value, ovInteger);
End;

Procedure TJSONParam.SetAsLargeInt(Value : LargeInt);
Begin
 SetDataValue(Value, ovLargeInt);
End;

Procedure TJSONParam.SetAsLongWord(Value : LongWord);
Begin
 SetDataValue(Value, ovLongWord);
End;

Procedure TJSONParam.SetAsObject  (Value : String);
Begin
 SetDataValue(Value, ovObject);
End;

Procedure TJSONParam.SetAsShortInt(Value : Integer);
Begin
 SetDataValue(Value, ovShortInt);
End;

Procedure TJSONParam.SetAsSingle  (Value : Single);
Begin
 SetDataValue(Value, ovSmallInt);
End;

Procedure TJSONParam.SetAsSmallInt(Value : Integer);
Begin
 SetDataValue(Value, ovSmallInt);
End;

Procedure TJSONParam.SetAsString  (Value : String);
Begin
 SetDataValue(Value, ovString);
End;

Procedure TJSONParam.SetAsTime    (Value : TDateTime);
Begin
 SetDataValue(Value, ovTime);
End;

{$IFDEF DEFINE(FPC) Or NOT(DEFINE(POSIX))}
Procedure TJSONParam.SetAsWideString(Value    : WideString);
Begin
 SetDataValue(Value, ovWideString);
End;
{$ENDIF}

Procedure TJSONParam.SetAsWord      (Value    : Word);
Begin
 SetDataValue(Value, ovWord);
End;

Procedure TJSONParam.SetDataValue   (Value    : Variant;
                                     DataType : TObjectValue);
Var
 ms : TMemoryStream;
 p  : Pointer;
Begin
 If (VarIsNull(Value))  Or
    (VarIsEmpty(Value)) Or
    (DataType in [ovBytes,    ovVarBytes,    ovBlob, ovByte, ovGraphic, ovParadoxOle,
                  ovDBaseOle, ovTypedBinary, ovOraBlob,      ovOraClob, ovStream]) Then
  Exit;
 vObjectValue   := DataType;
 Case vObjectValue Of
  ovBytes,
  ovVarBytes,
  ovBlob,
  ovByte,
  ovGraphic,
  ovParadoxOle,
  ovDBaseOle,
  ovTypedBinary,
  ovOraBlob,
  ovOraClob,
  ovStream          : Begin
                       ms := TMemoryStream.Create;
                       Try
                        ms.Position := 0;
                        p           := VarArrayLock(Value);
                        ms.Write(p^, VarArrayHighBound(Value, 1));
                        VarArrayUnlock(Value);
                        ms.Position := 0;
                        If ms.Size > 0 Then
                         LoadFromStream(ms);
                       Finally
                        ms.Free;
                       End;
                      End;
  ovVariant,
  ovUnknown         : Begin
                       vEncoded     := True;
                       vObjectValue := ovString;
                       SetValue(Value, vEncoded);
                      End;
  ovLargeInt,
  ovLongWord,
  ovShortInt,
  ovSingle,
  ovSmallInt,
  ovInteger,
  ovWord,
  ovBoolean,
  ovAutoInc,
  ovOraInterval     : Begin
                       vEncoded := False;
                       If vObjectValue = ovBoolean Then
                        Begin
                         If Boolean(Value) then
                          SetValue('1', vEncoded)
                         Else
                          SetValue('0', vEncoded);
                        End
                       Else
                        Begin
                         {$IFNDEF FPC}
                          {$if CompilerVersion < 21}
                           SetValue(inttostr(Value), vEncoded);
                          {$ELSE}
                           If vObjectValue <> ovInteger Then
                            SetValue(IntToStr(Int64(Value)), vEncoded)
                           Else
                            SetValue(inttostr(Value), vEncoded);
                          {$IFEND}
                         {$ELSE}
                          If vObjectValue <> ovInteger Then
                           SetValue(IntToStr(Int64(Value)), vEncoded)
                          Else
                           SetValue(inttostr(Value), vEncoded);
                         {$ENDIF}
                        End;
                      End;
  ovFloat,
  ovCurrency,
  ovBCD,
  ovFMTBcd,
  ovExtended        : Begin
                       vEncoded     := False;
                       vObjectValue := ovFloat;
                       SetValue(BuildStringFloat(FloatToStr(Value), JsonMode, vFloatDecimalFormat), vEncoded);
                      End;
  ovDate,
  ovTime,
  ovDateTime,
  ovTimeStamp,
  ovOraTimeStamp,
  ovTimeStampOffset : Begin
                       vEncoded     := False;
                       vObjectValue := ovDateTime;
                       SetValue(inttostr(DateTimeToUnix(Value)), vEncoded);
                      End;
  ovString,
  ovFixedChar,
  ovWideString,
  ovWideMemo,
  ovFixedWideChar,
  ovMemo,
  ovFmtMemo,
  ovObject          : Begin
                       If vObjectValue <> ovObject then
                        vObjectValue := ovString
                       Else
                        vObjectValue := ovObject;
                       SetValue(Value, vEncoded);
                      End;
 End;
End;

Procedure TJSONParam.SetEncoded(Value: Boolean);
Begin
 vEncoded := Value;
 vJSONValue.Encoded := vEncoded;
End;

procedure TJSONParam.SetObjectDirection(Value: TObjectDirection);
begin
 vObjectDirection := Value;
 vJSONValue.vObjectDirection := vObjectDirection;
end;

Procedure TJSONParam.SetObjectValue (Value  : TObjectValue);
Begin
 vObjectValue := Value;
 vBinary := vObjectValue In [ovBlob, ovGraphic, ovOraBlob, ovOraClob];
End;

Procedure TJSONParam.SetVariantValue(Value  : Variant);
Begin
 SetDataValue(Value, vObjectValue);
End;

Procedure TJSONParam.StringToBytes  (Value  : String;
                                     Encode : Boolean);
Begin
 vJSONValue.JsonMode := vJsonMode;
 vObjectValue        := ovBlob;
 vBinary             := vObjectValue in [ovBlob, ovGraphic, ovOraBlob, ovOraClob];
 If vBinary Then
  vJSONValue.StringToBytes(Value);
 vEncoded            := Encoded;
 vJSONValue.vEncoded := vEncoded;
End;

Procedure TJSONParam.SetParamName(bValue : String);
Begin
 vParamName := Uppercase(bValue);
 vJSONValue.vtagName := vParamName;
End;

Procedure TJSONParam.SetValue    (aValue : String;
                                  Encode : Boolean);
Begin
 vEncoded := Encode;
 vJSONValue.JsonMode := vJsonMode;
 vJSONValue.vEncoded := vEncoded;
 vBinary := vObjectValue in [ovBlob, ovGraphic, ovOraBlob, ovOraClob];
 vJSONValue.ObjectValue := vObjectValue;
 If (Encode) And Not(vBinary) Then
  Begin
   If vEncoding = esUtf8 Then
    WriteValue(EncodeStrings(utf8encode(aValue){$IFDEF FPC}, csUndefined{$ENDIF}))
   Else
    WriteValue(EncodeStrings(aValue{$IFDEF FPC}, csUndefined{$ENDIF}))
  End
 Else
  WriteValue(aValue);
 vJSONValue.vBinary := vBinary;
End;

Function TJSONParam.ToJSON: String;
Begin
 vJSONValue.Encoded    := vEncoded;
 vJSONValue.JsonMode   := vJsonMode;
 vJSONValue.TypeObject := vTypeObject;
 vJSONValue.vtagName   := vParamName;
 Result := vJSONValue.ToJSON;
 If vJsonMode in [jmPureJSON, jmMongoDB] Then
  Begin
   If Not(((Pos('{', Result) > 0)   And
           (Pos('}', Result) > 0))  Or
          ((Pos('[', Result) > 0)   And
           (Pos(']', Result) > 0))) Then
    Result := Format('{"%s" : "%s"}', [vParamName, vJSONValue.ToJSON]);
  End;
End;

{$IFDEF DEFINE(FPC) Or NOT(DEFINE(POSIX))}
Function TJSONParam.GetAsAnsiString: AnsiString;
Begin
 {$IFDEF FPC}
  Result := GetValue(ovString);
 {$ELSE}
  {$IF CompilerVersion > 21} // Delphi 2010 pra cima
   Result := Utf8ToAnsi(GetValue(ovString));
  {$ELSE}
   Result := GetValue(ovString);
  {$IFEND}
 {$ENDIF}
End;
{$ENDIF}

Function TJSONParam.GetAsBCD      : Currency;
Begin
 Result := GetValue(ovBCD);
End;

Function TJSONParam.GetAsBoolean  : Boolean;
Begin
 Result := GetValue(ovBoolean);
End;

Function TJSONParam.GetAsCurrency : Currency;
Begin
 Result := GetValue(ovCurrency);
End;

Function TJSONParam.GetAsDateTime : TDateTime;
Begin
 Result := GetValue(ovDateTime);
End;

Function TJSONParam.GetAsFloat    : Double;
Begin
 Result := GetValue(ovFloat);
End;

Function TJSONParam.GetAsFMTBCD   : Currency;
Begin
 Result := GetValue(ovFMTBcd);
End;

Function TJSONParam.GetAsInteger  : Integer;
Begin
 Result := GetValue(ovInteger);
End;

Function TJSONParam.GetAsLargeInt : LargeInt;
Begin
 Result := GetValue(ovLargeInt);
End;

Function TJSONParam.GetAsLongWord : LongWord;
Begin
 Result := GetValue(ovLongWord);
End;

Function TJSONParam.GetAsSingle   : Single;
Begin
  Result := GetValue(ovSmallInt);
End;

Function TJSONParam.GetAsString   : String;
Begin
 Result := GetValue(ovString);
End;

{$IFDEF DEFINE(FPC) Or NOT(DEFINE(POSIX))}
Function TJSONParam.GetAsWideString : WideString;
Begin
 Result := GetValue(ovWideString);
End;
{$ENDIF}

Function TJSONParam.GetAsWord       : Word;
Begin
 Result := GetValue(ovWord);
End;

Function TJSONParam.GetByteString   : String;
Var
 Stream: TStringStream;
Begin
 Stream := TStringStream.Create('');
 Try
  HexToStream(GetValue(ovString), Stream);
  Stream.Position := 0;
  Result := Stream.DataString;
 Finally
  Stream.Free;
 End;
End;

Function TJSONParam.GetValue(Value : TObjectValue) : Variant;
Var
 ms       : TMemoryStream;
 MyBuffer : Pointer;
Begin
 vJSONValue.TypeObject := vTypeObject;
 Case Value Of
  ovVariant,
  ovUnknown     : Result := vJSONValue.Value;
  ovString,
  ovFixedChar,
  ovWideString,
  ovWideMemo,
  ovFixedWideChar,
  ovMemo,
  ovFmtMemo     : Result := vJSONValue.Value;
  ovLargeInt,
  ovLongWord,
  ovShortInt,
  ovSingle,
  ovSmallInt,
  ovInteger,
  ovWord,
  ovBoolean,
  ovAutoInc,
  ovOraInterval : Begin
                   If (vJSONValue.Value <> '')                And
                      (Lowercase(vJSONValue.Value) <> 'null') Then
                    Begin
                     If Value = ovBoolean Then
                      Result := (vJSONValue.Value = '1')        Or (Lowercase(vJSONValue.Value) = 'true')
                     Else If (Trim(vJSONValue.Value) <> '')     And
                             (Trim(vJSONValue.Value) <> 'null') Then
                      Begin
                       If Value in [ovLargeInt, ovLongWord] Then
                        Result := StrToInt64(vJSONValue.Value)
                       Else
                        Result := StrToInt(vJSONValue.Value);
                      End;
                    End;
                  End;
  ovFloat,
  ovCurrency,
  ovBCD,
  ovFMTBcd,
  ovExtended        : Begin
                       If (vJSONValue.Value <> '')                And
                          (Lowercase(vJSONValue.Value) <> 'null') Then
                        Result := StrToFloat(BuildFloatString(vJSONValue.Value))
                       Else
                        Result := Null;
                      End;
  ovDate,
  ovTime,
  ovDateTime,
  ovTimeStamp,
  ovOraTimeStamp,
  ovTimeStampOffset : Begin
                       If (vJSONValue.Value <> '')                And
                          (Lowercase(vJSONValue.Value) <> 'null') Then
                        Result := UnixToDateTime(StrToInt64(vJSONValue.Value))
                       Else
                        Result := Null;
                      End;
  ovBytes,
  ovVarBytes,
  ovBlob,
  ovByte,
  ovGraphic,
  ovParadoxOle,
  ovDBaseOle,
  ovTypedBinary,
  ovOraBlob,
  ovOraClob,
  ovStream          : Begin
                       ms := TMemoryStream.Create;
                       Try
                        vJSONValue.SaveToStream(ms, vJSONValue.vBinary);
                        If ms.Size > 0 Then
                         Begin
                          Result   := VarArrayCreate([0, ms.Size - 1], VarByte);
                          MyBuffer := VarArrayLock(Result);
                          ms.ReadBuffer(MyBuffer^, ms.Size);
                          VarArrayUnlock(Result);
                         End
                        Else
                         Result := Null;
                       Finally
                        ms.Free;
                       End
                      End;
 End;
End;

Function TJSONParam.GetVariantValue : Variant;
Var
 ms       : TMemoryStream;
 MyBuffer : Pointer;
Begin
 Case vObjectValue Of
  ovVariant,
  ovUnknown         : Result := vJSONValue.Value;
  ovString,
  ovFixedChar,
  ovWideString,
  ovWideMemo,
  ovFixedWideChar,
  ovMemo,
  ovFmtMemo         : Result := vJSONValue.Value;
  ovLargeInt,
  ovLongWord,
  ovShortInt,
  ovSingle,
  ovSmallInt,
  ovInteger,
  ovWord,
  ovBoolean,
  ovAutoInc,
  ovOraInterval     : Begin
                       If (vJSONValue.Value <> '')                And
                          (Lowercase(vJSONValue.Value) <> 'null') Then
                        Begin
                         If vObjectValue = ovBoolean Then
                          Result := (vJSONValue.Value = '1') Or (Lowercase(vJSONValue.Value) = 'true')
                         Else
                          Result := StrToInt(vJSONValue.Value)
                        End
                       Else
                        Result := Null;
                      End;
  ovFloat,
  ovCurrency,
  ovBCD,
  ovFMTBcd,
  ovExtended        : Begin
                       If (vJSONValue.Value <> '') And (Lowercase(vJSONValue.Value) <> 'null') Then
                        Result := StrToFloat(BuildFloatString(vJSONValue.Value))
                       Else
                        Result := Null;
                      End;
  ovDate,
  ovTime,
  ovDateTime,
  ovTimeStamp,
  ovOraTimeStamp,
  ovTimeStampOffset : Begin
                       If (vJSONValue.Value <> '') And (Lowercase(vJSONValue.Value) <> 'null') Then
                        Result := UnixToDateTime(StrToInt64(vJSONValue.Value))
                       Else
                        Result := Null;
                      End;
  ovBytes,
  ovVarBytes,
  ovBlob,
  ovByte,
  ovGraphic,
  ovParadoxOle,
  ovDBaseOle,
  ovTypedBinary,
  ovOraBlob,
  ovOraClob,
  ovStream          : Begin
                       ms := TMemoryStream.Create;
                       Try
                        vJSONValue.SaveToStream(ms, vJSONValue.vBinary);
                        If ms.Size > 0 Then
                         Begin
                          ms.Position := 0;
                          Result      := VarArrayCreate([0, ms.Size - 1], VarByte);
                          MyBuffer    := VarArrayLock(Result);
                          ms.ReadBuffer(MyBuffer^, ms.Size);
                          VarArrayUnlock(Result);
                         End
                        Else
                         Result := Null;
                       Finally
                        ms.Free;
                       End;
                      End;
  End;
End;

Function TJSONParam.IsEmpty : Boolean;
Begin
 Result := GetValue(ovString) = '';
End;

Procedure TJSONParam.WriteValue(bValue : String);
Begin
 vJSONValue.Encoding         := vEncoding;
 vJSONValue.vtagName         := vParamName;
 vJSONValue.vTypeObject      := vTypeObject;
 vJSONValue.vObjectDirection := vObjectDirection;
 vJSONValue.vObjectValue     := vObjectValue;
 vJSONValue.vEncoded         := vEncoded;
 vJSONValue.WriteValue(bValue);
End;

Function TStringStreamList.Add(Item : TStringStream) : Integer;
Var
 vItem : ^TStringStream;
Begin
 New(vItem);
 vItem^ := Item;
 Result := TList(Self).Add(vItem);
End;

Procedure TStringStreamList.ClearList;
Var
 I : Integer;
Begin
 For I := Count - 1 Downto 0 Do
  Delete(i);
 Self.Clear;
End;

Constructor TStringStreamList.Create;
Begin
 Inherited;
End;

Procedure TStringStreamList.Delete(Index: Integer);
Begin
 If (Index < Self.Count) And (Index > -1) Then
  Begin
   If Assigned(TList(Self).Items[Index]) Then
    Begin
     FreeAndNil(TList(Self).Items[Index]^);
     {$IFDEF FPC}
      Dispose(PStringStream(TList(Self).Items[Index]));
     {$ELSE}
      Dispose(TList(Self).Items[Index]);
     {$ENDIF}
    End;
   TList(Self).Delete(Index);
  End;
End;

Destructor TStringStreamList.Destroy;
Begin
 ClearList;
 Inherited;
End;

Function TStringStreamList.GetRec(Index : Integer) : TStringStream;
Begin
 Result := Nil;
 If (Index < Self.Count) And (Index > -1) Then
  Result := TStringStream(TList(Self).Items[Index]^);
End;

Procedure TStringStreamList.PutRec(Index : Integer;
                                   Item  : TStringStream);
Begin
 If (Index < Self.Count) And (Index > -1) Then
  TStringStream(TList(Self).Items[Index]^) := Item;
End;

End.
