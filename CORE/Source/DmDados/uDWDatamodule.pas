unit uDWDatamodule;

interface

Uses
  SysUtils, Classes, SysTypes, uSystemEvents, uDWJSONObject, uDWConstsData, uRESTDWServerEvents;

 Type
  TServerMethodDataModule = Class(TDataModule)
  Private
   vClientWelcomeMessage : String;
   vReplyEvent           : TReplyEvent;
   vWelcomeMessage       : TWelcomeMessage;
   vMassiveProcess       : TMassiveProcess;
   vOnMassiveBegin,
   vOnMassiveAfterStartTransaction,
   vOnMassiveAfterBeforeCommit,
   vOnMassiveAfterAfterCommit,
   vOnMassiveEnd         : TMassiveEvent;
   vEncoding             : TEncodeSelect;
  Public
   Procedure SetClientWelcomeMessage(Value : String);
  Published
   Property ClientWelcomeMessage           : String           Read vClientWelcomeMessage;
   Property Encoding                       : TEncodeSelect    Read vEncoding                       Write vEncoding;
   Property OnReplyEvent                   : TReplyEvent      Read vReplyEvent                     Write vReplyEvent;
   Property OnWelcomeMessage               : TWelcomeMessage  Read vWelcomeMessage                 Write vWelcomeMessage;
   Property OnMassiveProcess               : TMassiveProcess  Read vMassiveProcess                 Write vMassiveProcess;
   Property OnMassiveBegin                 : TMassiveEvent    Read vOnMassiveBegin                 Write vOnMassiveBegin;
   Property OnMassiveAfterStartTransaction : TMassiveEvent    Read vOnMassiveAfterStartTransaction Write vOnMassiveAfterStartTransaction;
   Property OnMassiveAfterBeforeCommit     : TMassiveEvent    Read vOnMassiveAfterBeforeCommit     Write vOnMassiveAfterBeforeCommit;
   Property OnMassiveAfterAfterCommit      : TMassiveEvent    Read vOnMassiveAfterAfterCommit      Write vOnMassiveAfterAfterCommit;
   Property OnMassiveEnd                   : TMassiveEvent    Read vOnMassiveEnd                   Write vOnMassiveEnd;
 End;

implementation

{$IFDEF FPC}
{$R *.lfm}
{$ELSE}
{$R *.dfm}
{$ENDIF}

{ TServerMethodDataModule }

Procedure TServerMethodDataModule.SetClientWelcomeMessage(Value: String);
Begin
 vClientWelcomeMessage := Value;
End;

end.
