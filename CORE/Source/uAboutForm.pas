unit uAboutForm;

{$I uRESTDW.inc}

interface

uses
  {$IFDEF FPC}
  LCLIntf, LCLType, LMessages,
  SysUtils, Variants, Classes,
  Forms, Dialogs, ExtCtrls, StdCtrls, Controls, Graphics;
  {$ELSE}
   {$IF NOT Defined(HAS_FMX)}
    {$IF CompilerVersion < 21}
     Forms, SysUtils, ExtCtrls, StdCtrls, Variants, Classes, Messages, Graphics, Controls;
    {$ELSE}
     SysUtils, Variants, Classes,
     Messages, vcl.Graphics, vcl.Controls, vcl.Forms,
     vcl.Dialogs, vcl.ExtCtrls, vcl.StdCtrls;
    {$IFEND}
   {$ELSE}
    {$IF CompilerVersion < 21}
     SysUtils, Variants, Classes, Controls, Graphics;
    {$ELSE}
     {$IF Defined(HAS_UTF8)}
     SysUtils, Variants, Classes, FMX.Objects, FMX.Graphics, FMX.Controls, FMX.StdCtrls,
     System.UITypes, FMX.ExtCtrls, FMX.Forms;
     {$ELSE}
     SysUtils, Variants, Classes, Vcl.Graphics, Vcl.Controls, Vcl.StdCtrls,
     Vcl.ExtCtrls;
     {$IFEND}
    {$IFEND}
   {$IFEND}
  {$ENDIF}

type

  { Tfrm_About }

  Tfrm_About = class(TForm)
    Image1: TImage;
    Panel1: TPanel;
    lbl_msg: TLabel;
    {$IFDEF FPC}
    Procedure FormClose(Sender: TObject; var CloseAction : TCloseAction);
    {$ELSE}
    Procedure FormClose(Sender: TObject; var Action      : TCloseAction);
    {$ENDIF}
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frm_About: Tfrm_About;

implementation

{$IFDEF FPC}
{$R *.lfm}
{$ELSE}
{$R *.dfm}
{$ENDIF}

{ Tfrm_About }

{$IFDEF FPC}
Procedure Tfrm_About.FormClose(Sender: TObject; var CloseAction : TCloseAction);
{$ELSE}
Procedure Tfrm_About.FormClose(Sender: TObject; var Action      : TCloseAction);
{$ENDIF}
begin
 {$IFDEF FPC}
 CloseAction := caFree;
 {$ELSE}
   {$IF Defined(HAS_FMX)}
    Action := TCloseAction.caFree;
   {$ELSE}
    Action := caFree;
   {$IFEND}
 {$ENDIF}
end;

end.
