unit uDWAbout;

{$I uRESTDW.inc}

interface

uses Classes, SysUtils, syncobjs, uDWConstsData;

Type
 TDWComponent = Class(TComponent)
 Private
  fsAbout: TDWAboutInfo;
 Published
  Property AboutInfo : TDWAboutInfo Read fsAbout Write fsAbout Stored False;
 End;

Type
 TDWOwnedCollection = Class(TOwnedCollection)
 Private
  fsAbout: TDWAboutInfo;
 Published
  Property AboutInfo : TDWAboutInfo Read fsAbout Write fsAbout Stored False;
 End;

Procedure DWAboutDialog;

Implementation

uses uDWConsts, uAboutForm;

Procedure DWAboutDialog;
Var
 Msg : String;
 frm : Tfrm_About;
 // funcao para converter compatibilidade
 Function DWStr(const AString: String) : String;
 Begin
  {$IFDEF UNICODE}
   {$IFDEF FPC}
    Result := CP1252ToUTF8(AString);
   {$ELSE}
    Result := String(AString) ;
   {$ENDIF}
  {$ELSE}
   Result := AString
  {$ENDIF}
 End;
Begin
 {$IFDEF NOGUI}
  Msg :=  DW CONSOLE'+sLineBreak+
         'Rest Dataware Componentes'+sLineBreak+
         'http://www.restdw.com.br'+#10+#10+
         'Version : '+ DWVERSAO;
  Msg := DWStr(Msg);
  Writeln( Msg )
 {$ELSE}
   Msg := 'DW '+{$IFDEF FPC}'Lazarus/FPC'{$ELSE}'VCL/FMX'{$ENDIF}+#10+
          'Rest Dataware Componentes'+#10+#10+
          'http://www.restdw.com.br'+#10+#10+
          'Version : '+ DWVERSAO;
   Msg := DWStr(Msg);
 {$ENDIF}
 frm := Tfrm_About.Create(nil);
 {$IFNDEF FPC}
  {$IF Defined(HAS_FMX)}
   frm.lbl_msg.Text := Msg;
  {$ELSE}
   frm.lbl_msg.Caption:= Msg;
  {$IFEND}
 {$ELSE}
 frm.lbl_msg.Caption:= Msg;
 {$ENDIF}
 frm.ShowModal;
End;


end.

