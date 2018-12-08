unit uRESTDWBase;

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
 A. Brito                   - Admin - Administrador do CORE do pacote.
 Alexandre Abbade           - Admin - Administrador do desenvolvimento de DEMOS, coordenador do Grupo.
 Ari                        - Admin - Administrador do desenvolvimento de DEMOS, coordenador do Grupo.
 Alexandre Souza            - Admin - Administrador do Grupo de Organização.
 Anderson Fiori             - Admin - Gerencia de Organização dos Projetos
 Mizael Rocha               - Member Tester and DEMO Developer.
 Flávio Motta               - Member Tester and DEMO Developer.
 Itamar Gaucho              - Member Tester and DEMO Developer.
 Ico Menezes                - Member Tester and DEMO Developer.
}

interface

Uses
     {$IFDEF FPC}
     SysUtils,                      Classes,            ServerUtils, {$IFDEF WINDOWS}Windows,{$ENDIF}
     IdContext, IdTCPConnection,    IdHTTPServer,       IdCustomHTTPServer,  IdSSLOpenSSL,    IdSSL,
     IdAuthentication,              IdTCPClient,        IdHTTPHeaderInfo,    IdComponent, IdBaseComponent,
     IdHTTP,                        uDWConsts, uDWConstsData,  IdMessageCoderMIME, IdMultipartFormData, IdMessageCoder,
     IdMessage, uDWJSON, IdStack,   uDWJSONObject,      IdGlobal, IdGlobalProtocols, IdURI,
     uSystemEvents, HTTPDefs,       LConvEncoding,      uDWAbout;
     {$ELSE}
     {$IF CompilerVersion < 21}
     SysUtils, Classes, EncdDecd, SyncObjs,
      dwISAPIRunner, dwCGIRunner,
     {$ELSE}
     System.SysUtils, System.Classes, system.SyncObjs,
     {$IF Defined(HAS_FMX)}
      {$IFDEF WINDOWS}
       dwISAPIRunner, dwCGIRunner,
      {$ENDIF}
      {$ELSE}
       dwISAPIRunner, dwCGIRunner,
      {$IFEND}
     {$IFEND}
     ServerUtils, HTTPApp, uDWAbout, idSSLOpenSSL, IdStack,
     {$IFDEF WINDOWS} Windows, {$ENDIF} uDWConsts, uDWConstsData,       IdTCPClient,
     {$IF Defined(HAS_FMX)} System.json,{$ELSE} uDWJSON,{$IFEND} IdMultipartFormData,
     IdContext,             IdHTTPServer,        IdCustomHTTPServer,    IdSSL, IdURI,
     IdAuthentication,      IdHTTPHeaderInfo,    IdComponent, IdBaseComponent, IdTCPConnection,
     IdHTTP,                IdMessageCoder,      uDWJSONObject,
     uSystemEvents, IdMessageCoderMIME,    IdMessage,           IdGlobalProtocols,     IdGlobal;
     {$ENDIF}


Type
 TLastRequest  = Procedure (Value             : String)              Of Object;
 TLastResponse = Procedure (Value             : String)              Of Object;
 TEventContext = Procedure (AContext          : TIdContext;
                            ARequestInfo      : TIdHTTPRequestInfo;
                            AResponseInfo     : TIdHTTPResponseInfo) Of Object;
 TOnWork       = Procedure (ASender           : TObject;
                            AWorkMode         : TWorkMode;
                            AWorkCount        : Int64)               Of Object;
 TOnWorkBegin  = Procedure (ASender           : TObject;
                            AWorkMode         : TWorkMode;
                            AWorkCountMax     : Int64)               Of Object;
 TOnWorkEnd    = Procedure (ASender           : TObject;
                            AWorkMode         : TWorkMode)           Of Object;
 TOnStatus     = Procedure (ASender           : TObject;
                            Const AStatus     : TIdStatus;
                            Const AStatusText : String)              Of Object;
 TCallBack      = Procedure (JSon : String; DWParams : TDWParams) Of Object;
 TCallSendEvent = Function (EventData  : String;
                            Var Params : TDWParams;
                            EventType  : TSendEvent = sePOST;
                            JsonMode   : TJsonMode  = jmDataware;
                            ServerEventName : String = '';
                            CallBack   : TCallBack  = Nil) : String Of Object;

Type
 TServerMethodClass = Class(TComponent)
End;

Type
 TThread_Request = class(TThread)
 Private
  FHttpRequest      : TIdHTTP;
  vUserName,
  vPassword,
  vHost             : String;
  vUrlPath          : String;
  vPort             : Integer;
  vAuthentication   : Boolean;
  vTransparentProxy : TIdProxyConnectionInfo;
  vRequestTimeOut   : Integer;
  vTypeRequest      : TTypeRequest;
  vRSCharset        : TEncodeSelect;
  EventData         : String;
  //RBody     : TStringStream;
  Params            : TDWParams;
  EventType         : TSendEvent;
  FCallBack         : TCallBack;
  FCallSendEvent    : TCallSendEvent;
  Procedure SetParams(HttpRequest : TIdHTTP);
  Function  GetHttpRequest : TIdHTTP;
 Protected
  Procedure Execute;  Override;
 Public
  Constructor Create;
  Destructor Destroy; Override;
  Property CallBack:TCallBack  Read FCallBack Write FCallBack;
  Property HttpRequest:TIdHTTP Read GetHttpRequest;
 End;

 TProxyOptions = Class(TPersistent)
 Private
  vServer,                  //Servidor Proxy na Rede
  vLogin,                   //Login do Servidor Proxy
  vPassword     : String;   //Senha do Servidor Proxy
  vPort         : Integer;  //Porta do Servidor Proxy
 Public
  Constructor Create;
  Procedure   Assign(Source : TPersistent); Override;
 Published
  Property Server        : String  Read vServer   Write vServer;   //Servidor Proxy na Rede
  Property Port          : Integer Read vPort     Write vPort;     //Porta do Servidor Proxy
  Property Login         : String  Read vLogin    Write vLogin;    //Login do Servidor
  Property Password      : String  Read vPassword Write vPassword; //Senha do Servidor
End;

Type
 TRESTDWServiceNotification = Class(TDWComponent)
 Protected
 Private
  vAccessTag            : String;
  vGarbageTime,
  vQueueNotifications   : Integer;
  vNotifyWelcomeMessage : TNotifyWelcomeMessage;
  Procedure  SetAccessTag(Value : String);
  Function   GetAccessTag       : String;
 Public
  Function GetNotifications(LastNotification : String) : String;
  Constructor Create       (AOwner           : TComponent);Override; //Cria o Componente
  Destructor  Destroy;Override; //Destroy a Classe
 Published
  Property GarbageTime          : Integer                Read vGarbageTime           Write vGarbageTime;
  Property QueueNotifications   : Integer                Read vQueueNotifications    Write vQueueNotifications;
  Property AccessTag            : String                 Read vAccessTag             Write vAccessTag;
  Property OnWelcomeMessage     : TNotifyWelcomeMessage  Read vNotifyWelcomeMessage  Write vNotifyWelcomeMessage;
End;

Type
 TRESTServicePooler = Class(TDWComponent)
 Protected
  Procedure aCommandGet  (AContext      : TIdContext;
                          ARequestInfo  : TIdHTTPRequestInfo;
                          AResponseInfo : TIdHTTPResponseInfo);
  Procedure aCommandOther(AContext      : TIdContext;
                          ARequestInfo  : TIdHTTPRequestInfo;
                          AResponseInfo : TIdHTTPResponseInfo);
 Private
  {$IFNDEF FPC}
  {$IF CompilerVersion > 21}
  {$IFDEF WINDOWS}
   vCriticalSection : TRTLCriticalSection;
  {$ELSE}
   vCriticalSection : TCriticalSection;
  {$ENDIF}
  {$ELSE}
   vCriticalSection : TCriticalSection;
  {$IFEND}
  {$ELSE}
   vCriticalSection : TRTLCriticalSection;
  {$ENDIF}
  {$IFDEF FPC}
  {$ELSE}
  {$IF Defined(HAS_FMX)}
   {$IFDEF WINDOWS}
    vDWISAPIRunner    : TDWISAPIRunner;
    vDWCGIRunner      : TDWCGIRunner;
   {$ENDIF}
  {$ELSE}
   vDWISAPIRunner    : TDWISAPIRunner;
   vDWCGIRunner      : TDWCGIRunner;
  {$IFEND}
  {$ENDIF}
  vForceWelcomeAccess,
  vCORS,
  vActive          : Boolean;
  vProxyOptions    : TProxyOptions;
  HTTPServer       : TIdHTTPServer;
  vServicePort     : Integer;
  vServerBaseMethod,
  vServerMethod    : TComponentClass;
  vServerParams    : TServerParams;
  vLastRequest     : TLastRequest;
  vLastResponse    : TLastResponse;
  lHandler         : TIdServerIOHandlerSSLOpenSSL;
  aSSLMethod       : TIdSSLVersion;
  aSSLVersions     : TIdSSLVersions;
  vServerContext,
  ASSLPrivateKeyFile,
  ASSLPrivateKeyPassword,
  FRootPath,
  ASSLCertFile     : String;
  VEncondig        : TEncodeSelect;              //Enconding se usar CORS usar UTF8 - Alexandre Abade
  vSSLVerifyMode      : TIdSSLVerifyModeSet;
  vSSLVerifyDepth     : integer;
  vRESTServiceNotification : TRESTDWServiceNotification;
  Function SSLVerifyPeer(Certificate: TIdX509;
                         AOk: Boolean; ADepth, AError: Integer): Boolean;
  Procedure GetSSLPassWord (Var Password              : {$IFNDEF FPC}{$IF (CompilerVersion = 23) OR (CompilerVersion = 24)}
                                                                                     AnsiString
                                                                                    {$ELSE}
                                                                                     String
                                                                                    {$IFEND}
                                                                                    {$ELSE}
                                                                                     String
                                                                                    {$ENDIF});
  Procedure SetActive      (Value                     : Boolean);
  Function  GetSecure : Boolean;
  Procedure SetServerMethod(Value                     : TComponentClass);
  Procedure GetPoolerList(ServerMethodsClass          : TComponent;
                          Var PoolerList              : String;
                           AccessTag                  : String);
  Function  ServiceMethods           (BaseObject              : TComponent;
                                      AContext                : TIdContext;
                                      UrlMethod               : String;
                                      Var urlContext          : String;
                                      Var DWParams            : TDWParams;
                                      Var JSONStr             : String;
                                      Var JsonMode            : TJsonMode;
                                      Var ErrorCode           : Integer;
                                      Var ContentType         : String;
                                      Var ServerContextCall   : Boolean;
                                      Var ServerContextStream : TMemoryStream;
                                      ConnectionDefs          : TConnectionDefs;
                                      hEncodeStrings          : Boolean;
                                      AccessTag               : String;
                                      WelcomeAccept           : Boolean;
                                      Const RequestType       : TRequestType;
                                      mark                    : String) : Boolean;
  Procedure EchoPooler               (ServerMethodsClass      : TComponent;
                                      AContext                : TIdContext;
                                      Var Pooler, MyIP        : String;
                                      AccessTag               : String;
                                      Var InvalidTag          : Boolean);
  Procedure ExecuteCommandPureJSON   (ServerMethodsClass      : TComponent;
                                      Var Pooler              : String;
                                      Var DWParams            : TDWParams;
                                      ConnectionDefs          : TConnectionDefs;
                                      hEncodeStrings          : Boolean;
                                      AccessTag               : String);
  Procedure ExecuteCommandJSON       (ServerMethodsClass      : TComponent;
                                      Var Pooler              : String;
                                      Var DWParams            : TDWParams;
                                      ConnectionDefs          : TConnectionDefs;
                                      hEncodeStrings          : Boolean;
                                      AccessTag               : String);
  Procedure InsertMySQLReturnID      (ServerMethodsClass      : TComponent;
                                      Var Pooler              : String;
                                      Var DWParams            : TDWParams;
                                      ConnectionDefs          : TConnectionDefs;
                                      hEncodeStrings          : Boolean;
                                      AccessTag               : String);
  Procedure ApplyUpdatesJSON         (ServerMethodsClass      : TComponent;
                                      Var Pooler              : String;
                                      Var DWParams            : TDWParams;
                                      ConnectionDefs          : TConnectionDefs;
                                      hEncodeStrings          : Boolean;
                                      AccessTag               : String);
  Procedure OpenDatasets             (ServerMethodsClass      : TComponent;
                                      Var Pooler              : String;
                                      Var DWParams            : TDWParams;
                                      ConnectionDefs          : TConnectionDefs;
                                      hEncodeStrings          : Boolean;
                                      AccessTag               : String);
  Procedure ApplyUpdates_MassiveCache(ServerMethodsClass      : TComponent;
                                      Var Pooler              : String;
                                      Var DWParams            : TDWParams;
                                      ConnectionDefs          : TConnectionDefs;
                                      hEncodeStrings          : Boolean;
                                      AccessTag               : String);
  Procedure GetEvents                (ServerMethodsClass      : TComponent;
                                      Var Pooler,
                                      urlContext              : String;
                                      Var DWParams            : TDWParams);
  Function ReturnEvent               (ServerMethodsClass      : TComponent;
                                      Var Pooler,
                                      vResult,
                                      urlContext              : String;
                                      Var DWParams            : TDWParams;
                                      Var JsonMode            : TJsonMode;
                                      Var ErrorCode           : Integer;
                                      Var ContentType         : String;
                                      Const RequestType       : TRequestType) : Boolean;
  Procedure GetServerEventsList      (ServerMethodsClass      : TComponent;
                                      Var ServerEventsList    : String;
                                      AccessTag               : String);
  Function  ReturnContext            (ServerMethodsClass      : TComponent;
                                      Var Pooler, vResult,
                                      urlContext,
                                      ContentType             : String;
                                      Var ServerContextStream : TMemoryStream;
                                      Var Error               : Boolean;
                                      Const DWParams          : TDWParams;
                                      Const RequestType       : TRequestType;
                                      mark                    : String) : Boolean;

  {$IFDEF FPC}
  {$ELSE}
  {$IF Defined(HAS_FMX)}
   {$IFDEF WINDOWS}
    Procedure SetISAPIRunner(Value : TDWISAPIRunner);
    Procedure SetCGIRunner  (Value : TDWCGIRunner);
   {$ENDIF}
  {$ELSE}
   Procedure SetISAPIRunner(Value : TDWISAPIRunner);
   Procedure SetCGIRunner  (Value : TDWCGIRunner);
  {$IFEND}
  {$ENDIF}
 Public
  Constructor Create           (AOwner                : TComponent);Override; //Cria o Componente
  Destructor  Destroy;Override;                      //Destroy a Classe
 Published
  Property Active                  : Boolean                    Read vActive                  Write SetActive;
  Property CORS                    : Boolean                    Read vCORS                    Write vCORS;
  Property Secure                  : Boolean                    Read GetSecure;
  Property ServicePort             : Integer                    Read vServicePort             Write vServicePort;  //A Porta do Serviço do DataSet
  Property ProxyOptions            : TProxyOptions              Read vProxyOptions            Write vProxyOptions; //Se tem Proxy diz quais as opções
  Property ServerParams            : TServerParams              Read vServerParams            Write vServerParams;
  Property ServerMethodClass       : TComponentClass            Read vServerMethod            Write SetServerMethod;
  Property SSLPrivateKeyFile       : String                     Read aSSLPrivateKeyFile       Write aSSLPrivateKeyFile;
  Property SSLPrivateKeyPassword   : String                     Read aSSLPrivateKeyPassword   Write aSSLPrivateKeyPassword;
  Property SSLCertFile             : String                     Read aSSLCertFile             Write aSSLCertFile;
  Property SSLMethod               : TIdSSLVersion              Read aSSLMethod               Write aSSLMethod;
  Property SSLVersions             : TIdSSLVersions             Read aSSLVersions             Write aSSLVersions;
  Property OnLastRequest           : TLastRequest               Read vLastRequest             Write vLastRequest;
  Property OnLastResponse          : TLastResponse              Read vLastResponse            Write vLastResponse;
  Property Encoding                : TEncodeSelect              Read VEncondig                Write VEncondig;          //Encoding da string
  Property ServerContext           : String                     Read vServerContext           Write vServerContext;
  Property RootPath                : String                     Read FRootPath                Write FRootPath;
  property SSLVerifyMode           : TIdSSLVerifyModeSet        Read vSSLVerifyMode           Write vSSLVerifyMode;
  property SSLVerifyDepth          : Integer                    Read vSSLVerifyDepth          Write vSSLVerifyDepth;
  Property ForceWelcomeAccess      : Boolean                    Read vForceWelcomeAccess      Write vForceWelcomeAccess;
  Property RESTServiceNotification : TRESTDWServiceNotification Read vRESTServiceNotification Write vRESTServiceNotification;
  {$IFDEF FPC}
  {$ELSE}
  {$IF Defined(HAS_FMX)}
   {$IFDEF WINDOWS}
    Property ISAPIRunner             : TDWISAPIRunner             Read vDWISAPIRunner           Write SetISAPIRunner;
    Property CGIRunner               : TDWCGIRunner               Read vDWCGIRunner             Write SetCGIRunner;
   {$ENDIF}
  {$ELSE}
  Property ISAPIRunner             : TDWISAPIRunner             Read vDWISAPIRunner           Write SetISAPIRunner;
  Property CGIRunner               : TDWCGIRunner               Read vDWCGIRunner             Write SetCGIRunner;
  {$IFEND}
  {$ENDIF}
End;


Type
 TRESTServiceCGI = Class(TDWComponent)
 Protected
 Private
  vCORS,
  vForceWelcomeAccess : Boolean;
  vServerContext,
  FRootPath        : String;
  vServerBaseMethod,
  vServerMethod    : TComponentClass;
  vServerParams    : TServerParams;
  vLastRequest     : TLastRequest;
  vLastResponse    : TLastResponse;
  VEncondig        : TEncodeSelect;              //Enconding se usar CORS usar UTF8 - Alexandre Abade
  vRESTServiceNotification : TRESTDWServiceNotification;
  Procedure SetServerMethod(Value                     : TComponentClass);
  Procedure GetPoolerList(ServerMethodsClass          : TComponent;
                          Var PoolerList              : String;
                          AccessTag                   : String);
  Function  ServiceMethods(BaseObject                 : TComponent;
                           AContext,
                           UrlMethod,
                           urlContext                 : String;
                           Var DWParams               : TDWParams;
                           Var JSONStr                : String;
                           Var JsonMode               : TJsonMode;
                           Var ErrorCode              : Integer;
                           Var ContentType            : String;
                           Var ServerContextCall      : Boolean;
                           Var ServerContextStream    : TMemoryStream;
                           ConnectionDefs             : TConnectionDefs;
                           hEncodeStrings             : Boolean;
                           AccessTag                  : String;
                           WelcomeAccept              : Boolean;
                           Const RequestType          : TRequestType;
                           mark                       : String) : Boolean;
  Procedure EchoPooler    (ServerMethodsClass         : TComponent;
                           AContext                   : String;
                           Var Pooler, MyIP           : String;
                           AccessTag                  : String;
                           Var InvalidTag             : Boolean);
  Procedure ExecuteCommandPureJSON(ServerMethodsClass : TComponent;
                                   Var Pooler         : String;
                                   Var DWParams       : TDWParams;
                                   ConnectionDefs     : TConnectionDefs;
                                   hEncodeStrings     : Boolean;
                                   AccessTag          : String);
  Procedure ExecuteCommandJSON(ServerMethodsClass     : TComponent;
                               Var Pooler             : String;
                               Var DWParams           : TDWParams;
                               ConnectionDefs         : TConnectionDefs;
                                   hEncodeStrings     : Boolean;
                                   AccessTag          : String);
  Procedure InsertMySQLReturnID(ServerMethodsClass    : TComponent;
                                Var Pooler            : String;
                                Var DWParams          : TDWParams;
                                ConnectionDefs        : TConnectionDefs;
                                   hEncodeStrings     : Boolean;
                                   AccessTag          : String);
  Procedure ApplyUpdatesJSON   (ServerMethodsClass    : TComponent;
                                Var Pooler            : String;
                                Var DWParams          : TDWParams;
                                ConnectionDefs        : TConnectionDefs;
                                   hEncodeStrings     : Boolean;
                                   AccessTag          : String);
  Procedure OpenDatasets       (ServerMethodsClass    : TComponent;
                                Var Pooler            : String;
                                Var DWParams          : TDWParams;
                                ConnectionDefs        : TConnectionDefs;
                                   hEncodeStrings     : Boolean;
                                   AccessTag          : String);
  Procedure ApplyUpdates_MassiveCache(ServerMethodsClass : TComponent;
                                      Var Pooler         : String;
                                      Var DWParams       : TDWParams;
                                      ConnectionDefs     : TConnectionDefs;
                                      hEncodeStrings     : Boolean;
                                      AccessTag          : String);
  Procedure GetEvents                (ServerMethodsClass : TComponent;
                                      Var Pooler,
                                      urlContext         : String;
                                      Var DWParams       : TDWParams);
  Function ReturnEvent               (ServerMethodsClass : TComponent;
                                      Var Pooler,
                                      vResult,
                                      urlContext         : String;
                                      Var DWParams       : TDWParams;
                                      Var JsonMode       : TJsonMode;
                                      Var ErrorCode      : Integer;
                                      Var ContentType    : String;
                                      Const RequestType  : TRequestType): Boolean;
  Procedure GetServerEventsList      (ServerMethodsClass   : TComponent;
                                      Var ServerEventsList : String;
                                      AccessTag            : String);
  Function ReturnContext             (ServerMethodsClass      : TComponent;
                                      Var Pooler, vResult,
                                      urlContext,
                                      ContentType             : String;
                                      Var ServerContextStream : TMemoryStream;
                                      Var Error               : Boolean;
                                      Const DWParams          : TDWParams;
                                      Const RequestType       : TRequestType;
                                      mark                    : String): Boolean;
 Public
  {$IFDEF FPC}
   Procedure Command(ARequest: TRequest;    AResponse: TResponse;   Var Handled: Boolean);
  {$ELSE}
   Procedure Command(ARequest: TWebRequest; AResponse: TWebResponse; var Handled: Boolean);
  {$ENDIF}
  Constructor Create           (AOwner                : TComponent);Override; //Cria o Componente
  Destructor  Destroy;Override;                      //Destroy a Classe
 Published
  Property CORS                    : Boolean                    Read vCORS                    Write vCORS;
  Property ServerParams            : TServerParams              Read vServerParams            Write vServerParams;
  Property ServerMethodClass       : TComponentClass            Read vServerMethod            Write SetServerMethod;
  Property OnLastRequest           : TLastRequest               Read vLastRequest             Write vLastRequest;
  Property OnLastResponse          : TLastResponse              Read vLastResponse            Write vLastResponse;
  Property Encoding                : TEncodeSelect              Read VEncondig                Write VEncondig;          //Encoding da string
  Property ForceWelcomeAccess      : Boolean                    Read vForceWelcomeAccess      Write vForceWelcomeAccess;
  Property ServerContext           : String                     Read vServerContext           Write vServerContext;
  Property RESTServiceNotification : TRESTDWServiceNotification Read vRESTServiceNotification Write vRESTServiceNotification;
  Property RootPath                : String                     Read FRootPath                Write FRootPath;
End;

Type
 TRESTClientPooler = Class(TDWComponent) //Novo Componente de Acesso a Requisições REST para o RESTDataware
 Protected
  //Variáveis, Procedures e  Funções Protegidas
  HttpRequest       : TIdHTTP;
  Procedure SetParams      (Var aHttpRequest : TIdHTTP);
  Procedure SetOnWork      (Value            : TOnWork);
  Procedure SetOnWorkBegin (Value            : TOnWorkBegin);
  Procedure SetOnWorkEnd   (Value            : TOnWorkEnd);
  Procedure SetOnStatus    (Value            : TOnStatus);
  Function  GetAllowCookies                  : Boolean;
  Procedure SetAllowCookies(Value            : Boolean);
  Function  GetHandleRedirects               : Boolean;
  Procedure SetHandleRedirects(Value         : Boolean);
 Private
  //Variáveis, Procedures e Funções Privadas
  vOnWork           : TOnWork;
  vOnWorkBegin      : TOnWorkBegin;
  vOnWorkEnd        : TOnWorkEnd;
  vOnStatus         : TOnStatus;
  vTypeRequest      : TTypeRequest;
  vRSCharset        : TEncodeSelect;
  vAccessTag,
  vWelcomeMessage,
  vUrlPath,
  vUserName,
  vPassword,
  vHost             : String;
  vPort             : Integer;
  vEncodeStrings,
  vDatacompress,
  vThreadRequest,
  vAuthentication   : Boolean;
  vThreadExecuting  : Boolean;
  vTransparentProxy : TIdProxyConnectionInfo;
  vRequestTimeOut   : Integer;
  {$IFDEF FPC}
  vDatabaseCharSet  : TDatabaseCharSet;
  {$ENDIF}
  Procedure SetUserName(Value : String);
  Procedure SetPassword(Value : String);
  Procedure SetUrlPath (Value : String);
 Public
  //Métodos, Propriedades, Variáveis, Procedures e Funções Publicas
  Procedure   SetAccessTag(Value        : String);
  Function    GetAccessTag              : String;
  Function    SendEvent(EventData       : String)          : String;Overload;
  Function    SendEvent(EventData       : String;
                        Var Params      : TDWParams;
                        EventType       : TSendEvent = sePOST;
                        JsonMode        : TJsonMode  = jmDataware;
                        ServerEventName : String = '';
                        CallBack        : TCallBack  = Nil) : String;Overload;
  Constructor Create   (AOwner          : TComponent);Override;
  Destructor  Destroy;Override;
 Published
  //Métodos e Propriedades
  Property DataCompression  : Boolean                Read vDatacompress      Write vDatacompress;
  Property UrlPath          : String                 Read vUrlPath           Write SetUrlPath;
  Property Encoding         : TEncodeSelect          Read vRSCharset         Write vRSCharset;
  Property hEncodeStrings   : Boolean                Read vEncodeStrings     Write vEncodeStrings;
  Property TypeRequest      : TTypeRequest           Read vTypeRequest       Write vTypeRequest       Default trHttp;
  Property Host             : String                 Read vHost              Write vHost;
  Property Port             : Integer                Read vPort              Write vPort              Default 8082;
  Property UserName         : String                 Read vUserName          Write SetUserName;
  Property Password         : String                 Read vPassword          Write SetPassword;
  Property Authentication   : Boolean                Read vAuthentication    Write vAuthentication      Default True;
  Property ProxyOptions     : TIdProxyConnectionInfo Read vTransparentProxy  Write vTransparentProxy;
  Property RequestTimeOut   : Integer                Read vRequestTimeOut    Write vRequestTimeOut;
  Property ThreadRequest    : Boolean                Read vThreadRequest     Write vThreadRequest;
  Property AllowCookies     : Boolean                Read GetAllowCookies    Write SetAllowCookies;
  Property HandleRedirects  : Boolean                Read GetHandleRedirects Write SetHandleRedirects;
  Property WelcomeMessage   : String                 Read vWelcomeMessage    Write vWelcomeMessage;
  Property AccessTag        : String                 Read vAccessTag         Write vAccessTag;
  Property OnWork           : TOnWork                Read vOnWork            Write SetOnWork;
  Property OnWorkBegin      : TOnWorkBegin           Read vOnWorkBegin       Write SetOnWorkBegin;
  Property OnWorkEnd        : TOnWorkEnd             Read vOnWorkEnd         Write SetOnWorkEnd;
  Property OnStatus         : TOnStatus              Read vOnStatus          Write SetOnStatus;
  {$IFDEF FPC}
  Property DatabaseCharSet  : TDatabaseCharSet       Read vDatabaseCharSet   Write vDatabaseCharSet;
  {$ENDIF}
End;

implementation

Uses uDWDatamodule, uRESTDWPoolerDB, SysTypes, uDWJSONTools, uRESTDWServerEvents,
     uRESTDWServerContext, uDWJSONInterface;

Procedure DeleteInvalidChar(Var Value : String);
Begin
 If Length(Value) > 0 Then
  If Value[InitStrPos] <> '{' then
   Delete(Value, InitStrPos, 1);
 If Length(Value) > 0 Then
  If Value[Length(Value) - FinalStrPos] <> '{' then
   Delete(Value, Length(Value) - FinalStrPos, 1);
End;

{ TRESTServiceCGI }

{$IFDEF FPC}
procedure TRESTServiceCGI.Command(ARequest: TRequest; AResponse: TResponse;
                                  Var Handled: Boolean);
{$ELSE}
procedure TRESTServiceCGI.Command(ARequest: TWebRequest; AResponse: TWebResponse;
  var Handled: Boolean);
{$ENDIF}
Var
 I, vErrorCode       : Integer;
 JsonMode            : TJsonMode;
 DWParams            : TDWParams;
 vObjectName,
 vOldMethod,
 vBasePath,
 vWelcomeMessage,
 vAccessTag,
 boundary,
 startboundary,
 vReplyString,
 vReplyStringResult,
 vTempCmd,
 Cmd, vmark,
 UrlMethod,
 tmp, JSONStr,
 sFile, sContentType,
 authDecode,
 sCharSet,
 urlContext,
 baseEventUnit,
 ServerEventsName,
 vContentType,
 ReturnObject        : String;
 vdwConnectionDefs   : TConnectionDefs;
 RequestType         : TRequestType;
 vTempServerMethods  : TObject;
 newdecoder,
 Decoder             : TIdMessageDecoder;
 JSONParam           : TJSONParam;
 JSONValue           : TJSONValue;
 dwassyncexec,
 vFileExists,
 vServerContextCall,
 vTagReply,
 WelcomeAccept,
 encodestrings,
 compresseddata,
 msgEnd              : Boolean;
 mb,
 vContentStringStream,
 ms                  : TStringStream;
 ServerContextStream : TMemoryStream;
 vParamList,
 vLog                : TStringList;
 Function GetParamsReturn(Params : TDWParams) : String;
 Var
  A, I : Integer;
 Begin
  A := 0;
  Result := '';
  If Assigned(Params) Then
   Begin
    For I := 0 To Params.Count -1 Do
     Begin
      If TJSONParam(TList(Params).Items[I]^).ObjectDirection in [odOUT, odINOUT] Then
       Begin
        If A = 0 Then
         Result := TJSONParam(TList(Params).Items[I]^).ToJSON
        Else
         Result := Result + ', ' + TJSONParam(TList(Params).Items[I]^).ToJSON;
        Inc(A);
       End;
     End;
   End;
 End;
 Procedure SaveLog;
 Begin
  vLog := TStringList.Create;
  {$IFNDEF FPC}
   vLog.Add('Cmd = ' + Trim(ARequest.URL));
  {$ELSE}
   vLog.Add('Cmd = ' + Trim(ARequest.CommandLine));
  {$ENDIF}
  vLog.Add('PathInfo = ' + Trim(ARequest.PathInfo));
  {$IFNDEF FPC}
  vLog.Add('Title = ' + ARequest.Title);
  {$ELSE}
  vLog.Add('HeaderLine = ' + ARequest.HeaderLine);
  {$ENDIF}
  vLog.Add('Content = ' +  ARequest.Content);
  vLog.Add('Query = ' +  ARequest.Query);
  If vServerParams.HasAuthentication Then
   vLog.Add('HasAuthentication = true')
  Else
   vLog.Add('HasAuthentication = false');
  vLog.Add('Authorization = ' +  ARequest.Authorization);
  {$IFNDEF FPC}
  vLog.Add('ContentFields.Count = ' +  IntToStr(ARequest.ContentFields.Count));
  {$ELSE}
  vLog.Add('FieldCount = ' +  IntToStr(ARequest.FieldCount));
  {$ENDIF}
  vLog.Add('ContentFields = ' +  ARequest.ContentFields.Text);
  {$IFNDEF FPC}
  vLog.Add('PathTranslated = ' + ARequest.PathTranslated);
  {$ELSE}
  vLog.Add('LocalPathPrefix = ' + ARequest.LocalPathPrefix);
  {$ENDIF}
  vLog.Add('UrlMethod = ' + UrlMethod);
  vLog.Add('urlContext = ' + urlContext);
  vLog.Add('Method = ' + ARequest.Method);
  vLog.Add('File = ' + sFile);
  If DWParams <> Nil Then
   vLog.Add('DWParams = ' +  DWParams.ToJSON);
  vLog.SaveToFile(ExtractFilePath(ParamSTR(0)) + 'log.txt');
  vLog.Free;
 End;
 Function ExcludeTag(Value : String) : String;
 Begin
  Result := Value;
  If (UpperCase(Copy (Value, InitStrPos, 3)) = 'GET')    or
     (UpperCase(Copy (Value, InitStrPos, 4)) = 'POST')   or
     (UpperCase(Copy (Value, InitStrPos, 3)) = 'PUT')    or
     (UpperCase(Copy (Value, InitStrPos, 6)) = 'DELETE') or
     (UpperCase(Copy (Value, InitStrPos, 5)) = 'PATCH')  Then
   Begin
    While (Result <> '') And (Result[InitStrPos] <> '/') Do
     Delete(Result, InitStrPos, 1);
   End;
  If Result <> '' Then
   If Result[InitStrPos] = '/' Then
    Delete(Result, InitStrPos, 1);
  Result := Trim(Result);
 End;
 Function GetFileOSDir(Value : String) : String;
 Begin
  Result := vBasePath + Value;
  {$IFDEF MSWINDOWS}
   Result := StringReplace(Result, '/', '\', [rfReplaceAll]);
  {$ENDIF}
 End;
 Function GetLastMethod(Value : String) : String;
 Var
  I : Integer;
 Begin
  Result := '';
  If Value <> '' Then
   Begin
    If Value[Length(Value) - FinalStrPos] <> '/' Then
     Begin
      For I := (Length(Value) - FinalStrPos) Downto InitStrPos Do
       Begin
        If Value[I] <> '/' Then
         Result := Value[I] + Result
        Else
         Break;
       End;
     End;
   End;
 End;
Begin
 vContentType       := '';
 vBasePath          := FRootPath;
 JsonMode           := jmDataware;
 vErrorCode         := 200;
 baseEventUnit      := '';
 vdwConnectionDefs  := Nil;
 vTempServerMethods := Nil;
 DWParams           := Nil;
 compresseddata     := False;
 encodestrings      := False;
 vTagReply          := False;
 ServerContextStream := Nil;
 vServerContextCall  := False;
 {$IFNDEF FPC}
  Cmd := Trim(ARequest.PathInfo);
  {$if CompilerVersion > 21}
   AResponse.CustomHeaders.Add('Access-Control-Allow-Origin=*');
   If vCORS Then
    Begin
     AResponse.CustomHeaders.Add('Access-Control-Allow-Methods=GET, POST, PATCH, PUT, DELETE, OPTIONS');
     AResponse.CustomHeaders.Add('Access-Control-Allow-Headers=Content-Type, Origin, Accept, Authorization, X-CUSTOM-HEADER');
    End;
  {$ELSE}
   AResponse.CustomHeaders.Add     ('Access-Control-Allow-Origin=*');
   If vCORS Then
    Begin
     AResponse.CustomHeaders.Add     ('Access-Control-Allow-Methods=GET, POST, PATCH, PUT, DELETE, OPTIONS');
     AResponse.CustomHeaders.Add     ('Access-Control-Allow-Headers=Content-Type, Origin, Accept, Authorization, X-CUSTOM-HEADER');
    End;
  {$IFEND}
 {$ELSE}
  Cmd := Trim(ARequest.PathInfo);
  AResponse.CustomHeaders.Add('Access-Control-Allow-Origin=*');
  If vCORS Then
   Begin
    AResponse.CustomHeaders.Add('Access-Control-Allow-Methods=GET, POST, PATCH, PUT, DELETE, OPTIONS');
    AResponse.CustomHeaders.Add('Access-Control-Allow-Headers=Content-Type, Origin, Accept, Authorization, X-CUSTOM-HEADER');
   End;
 {$ENDIF}
 sCharSet := '';
 vContentStringStream := Nil;
 {$IFNDEF FPC}
  If ARequest.ContentLength > 0 Then
   Begin
   {$IF CompilerVersion > 29}
   ARequest.ReadTotalContent;
   If Length(ARequest.RawContent) > 0 Then
    Begin
     vContentStringStream := TStringStream.Create('');
     vContentStringStream.Write(TBytes(ARequest.RawContent),
                                Length(ARequest.RawContent));
     vContentStringStream.Position := 0;
    End
   Else
   {$IFEND}
 {$ELSE}
 If Trim(ARequest.Content) <> '' Then
  Begin
 {$ENDIF}
   If vContentStringStream = Nil Then
    vContentStringStream := TStringStream.Create(ARequest.Content);
   vContentStringStream.Position := 0;
   If pos('--', vContentStringStream.DataString) > 0 Then
    Begin
     Try
      msgEnd   := False;
      boundary := ExtractHeaderSubItem(ARequest.ContentType, 'boundary', QuoteHTTP);
      startboundary := '--' + boundary;
      Repeat
       tmp := ReadLnFromStream(vContentStringStream, -1, True);
      until tmp = startboundary;
     Finally
  //    vContentStringStream.Free;
     End;
    End;
  End;
 Try
  {$IFNDEF FPC}
   Cmd := stringreplace(Trim(lowercase(ARequest.PathInfo)), lowercase(vServerContext) + '/', '', [rfReplaceAll]);
  {$ELSE}
  Cmd := stringreplace(Trim(lowercase(ARequest.PathInfo)), lowercase(vServerContext) + '/', '', [rfReplaceAll]);
   If Cmd = ''  Then
    Cmd := stringreplace(Trim(lowercase(ARequest.HeaderLine)), lowercase(vServerContext) + '/', '', [rfReplaceAll]);
  {$ENDIF}
  If (Trim(ARequest.Content) = '') And (Cmd = '') then
   Exit;
  Cmd := StringReplace(Cmd, lowercase(' HTTP/1.0'), '', [rfReplaceAll]);
  Cmd := StringReplace(Cmd, lowercase(' HTTP/1.1'), '', [rfReplaceAll]);
  Cmd := StringReplace(Cmd, lowercase(' HTTP/2.0'), '', [rfReplaceAll]);
  Cmd := StringReplace(Cmd, lowercase(' HTTP/2.1'), '', [rfReplaceAll]);
  If (UpperCase(Copy (Cmd, 1, 7)) <> 'OPTIONS') And (vServerParams.HasAuthentication) Then
   Begin
    If ARequest.Authorization <> '' Then
     Begin
      authDecode := DecodeStrings(StringReplace(ARequest.Authorization, 'Basic ', '', [rfReplaceAll])
                                  {$IFDEF FPC}, csUndefined{$ENDIF});
      If Not ((Pos(vServerParams.Username, authDecode) > 0) And
              (Pos(vServerParams.Password, authDecode) > 0)) Then
       Begin
        Handled := False;
        Exit;
       End;
     End;
   End;
    RequestType := rtGet;
    If (UpperCase(Trim(ARequest.Method)) = 'POST')      Then
     RequestType := rtPost
    Else If (UpperCase(Trim(ARequest.Method)) = 'PUT')  Then
     RequestType := rtPut
    Else If (UpperCase(Trim(ARequest.Method)) = 'DELETE') Then
     RequestType := rtDelete
    Else If (UpperCase(Trim(ARequest.Method)) = 'PATCH') Then
     RequestType := rtPatch;
    {$IFNDEF FPC}
    If ARequest.PathInfo <> '/favicon.ico' Then
    {$ELSE}
    If ARequest.URI <> '/favicon.ico' Then
    {$ENDIF}
     Begin
    {$IFNDEF FPC}
     If (ARequest.QueryFields.Count > 0) And (RequestType = rtGet) Then
      Begin
       vTempCmd := Cmd;
       DWParams  := TServerUtils.ParseWebFormsParams (ARequest.QueryFields, vTempCmd,
                                                      ARequest.Query,
                                                      UrlMethod, urlContext, vmark, VEncondig,
                                                      ARequest.Method);
       If ARequest.Query <> '' Then
        vTempCmd := vTempCmd + '?' + ARequest.Query;
       Cmd := vTempCmd;
       If DWParams <> Nil Then
        Begin
         If DWParams.ItemsString['dwwelcomemessage'] <> Nil Then
          vWelcomeMessage := DecodeStrings(DWParams.ItemsString['dwwelcomemessage'].AsString{$IFDEF FPC}, csUndefined{$ENDIF});
         If DWParams.ItemsString['accesstag'] <> Nil Then
          vAccessTag := DecodeStrings(DWParams.ItemsString['accesstag'].AsString{$IFDEF FPC}, csUndefined{$ENDIF});
         If DWParams.ItemsString['datacompression'] <> Nil Then
          compresseddata := StringToBoolean(DWParams.ItemsString['datacompression'].AsString);
         If DWParams.ItemsString['dwencodestrings'] <> Nil Then
          encodestrings  := StringToBoolean(DWParams.ItemsString['dwencodestrings'].AsString);
         If DWParams.ItemsString['dwservereventname'] <> Nil Then
          urlContext := DWParams.ItemsString['dwservereventname'].AsString;
        End;
      End
    {$ELSE}
     If (ARequest.FieldCount > 0) And //(Trim(ARequest.ContentFields.Text) <> '')) And
         (Trim(ARequest.Content) = '') Then
      Begin
       DWParams  := TServerUtils.ParseWebFormsParams (ARequest.ContentFields, Cmd, ARequest.Query,
                                                      UrlMethod, urlContext, vmark, VEncondig);
//       SaveLog; //For Debbug Vars
       If DWParams <> Nil Then
        Begin
         If DWParams.ItemsString['dwwelcomemessage'] <> Nil Then
          vWelcomeMessage := DecodeStrings(DWParams.ItemsString['dwwelcomemessage'].AsString{$IFDEF FPC}, csUndefined{$ENDIF});
         If DWParams.ItemsString['accesstag'] <> Nil Then
          vAccessTag := DecodeStrings(DWParams.ItemsString['accesstag'].AsString{$IFDEF FPC}, csUndefined{$ENDIF});
         If DWParams.ItemsString['datacompression'] <> Nil Then
          compresseddata := StringToBoolean(DWParams.ItemsString['datacompression'].AsString);
         If DWParams.ItemsString['dwencodestrings'] <> Nil Then
          encodestrings  := StringToBoolean(DWParams.ItemsString['dwencodestrings'].AsString);
         If DWParams.ItemsString['dwservereventname'] <> Nil Then
          urlContext := DWParams.ItemsString['dwservereventname'].AsString;
        End;
      End
    {$ENDIF}
      Else
       Begin
        If (((vContentStringStream <> Nil) And (Trim(vContentStringStream.Datastring) <> ''))
            Or (Trim(ARequest.Content) = '')) And (Trim(ARequest.Method) = 'GET') Then
         Begin
//          SaveLog; //For Debbug Vars
          {$IFDEF FPC}
           If Trim(ARequest.Query) <> '' Then
            DWParams  := TServerUtils.ParseRESTURL (ARequest.PathInfo + '?' + ARequest.Query, VEncondig, UrlMethod, urlContext, vmark)
           Else
            DWParams  := TServerUtils.ParseRESTURL (ARequest.PathInfo, VEncondig, UrlMethod, urlContext, vmark);
          {$ELSE}
          DWParams  := TServerUtils.ParseRESTURL (ARequest.PathInfo + ARequest.Query, VEncondig, UrlMethod, urlContext, vmark);
          {$ENDIF}
          vOldMethod := UrlMethod;
//          SaveLog; //For Debbug Vars
          If DWParams <> Nil Then
           Begin
            If DWParams.ItemsString['dwwelcomemessage'] <> Nil Then
             vWelcomeMessage := DecodeStrings(DWParams.ItemsString['dwwelcomemessage'].AsString{$IFDEF FPC}, csUndefined{$ENDIF});
            If DWParams.ItemsString['accesstag'] <> Nil Then
             vAccessTag := DecodeStrings(DWParams.ItemsString['accesstag'].AsString{$IFDEF FPC}, csUndefined{$ENDIF});
            If DWParams.ItemsString['datacompression'] <> Nil Then
             compresseddata := StringToBoolean(DWParams.ItemsString['datacompression'].AsString);
            If DWParams.ItemsString['dwencodestrings'] <> Nil Then
             encodestrings  := StringToBoolean(DWParams.ItemsString['dwencodestrings'].AsString);
            If DWParams.ItemsString['dwservereventname'] <> Nil Then
             urlContext := DWParams.ItemsString['dwservereventname'].AsString;
           End;
         End
        Else
         Begin
          If vContentStringStream = Nil Then
           vContentStringStream := TStringStream.Create(ARequest.Content);
          If (vContentStringStream.Size > 0) And (boundary <> '') Then
           Begin
            Try
             Repeat
              decoder              := TIdMessageDecoderMIME.Create(nil);
              TIdMessageDecoderMIME(decoder).MIMEBoundary := boundary;
              Try
               decoder.SourceStream := vContentStringStream;
               decoder.FreeSourceStream := False;
              finally
              end;
              decoder.ReadHeader;
  //            Inc(I);
              Case Decoder.PartType of
               mcptAttachment,
               mcptText :
                Begin
                 If (Decoder.PartType = mcptAttachment) And
                    (boundary <> '')                    Then
                  Begin
                   sFile := '';
                   If ServerContextStream = Nil Then
                    Begin
                     ServerContextStream := TMemoryStream.Create;
                     sFile := ExtractFileName(Decoder.FileName);
                     Decoder := Decoder.ReadBody(ServerContextStream, MsgEnd);  //TODO XyberX
                     ServerContextStream.Position := 0;
                    End;
                   If (DWParams = Nil) Then
                    Begin
                     {$IFNDEF FPC}
                     If (ARequest.QueryFields.Count = 0) Then
                     {$ELSE}
                     If (ARequest.FieldCount = 0) Then
                     {$ENDIF}
                      Begin
                       DWParams           := TDWParams.Create;
                       DWParams.Encoding  := VEncondig;
                      End
                     Else
                      Begin
                       {$IFDEF FPC}
                        If Trim(ARequest.Query) <> '' Then
                         DWParams  := TServerUtils.ParseRESTURL (ARequest.PathInfo + '?' + ARequest.Query, VEncondig, UrlMethod, urlContext, vmark)
                        Else
                         DWParams  := TServerUtils.ParseRESTURL (ARequest.PathInfo, VEncondig, UrlMethod, urlContext, vmark);
                       {$ELSE}
                        If Trim(ARequest.Query) <> '' Then
                         DWParams  := TServerUtils.ParseRESTURL (ARequest.PathInfo + '?' + ARequest.Query, VEncondig, UrlMethod, urlContext, vmark)
                        Else
                         DWParams  := TServerUtils.ParseRESTURL (ARequest.PathInfo, VEncondig, UrlMethod, urlContext, vmark);
                       {$ENDIF}
                      End;
                    End;
                   If sFile <> '' Then
                    Begin
                     vObjectName := 'dwfilename';
                     JSONParam   := TJSONParam.Create(DWParams.Encoding);
                     JSONParam.ParamName := vObjectName;
                     JSONParam.SetValue(sFile, JSONParam.Encoded);
                     DWParams.Add(JSONParam);
                    End;
                   If (ARequest.QueryFields.Count = 0) And
                      (ARequest.ContentFields.Count > 0) Then
                    Begin
                     For I := 0 To ARequest.ContentFields.Count -1 Do
                      Begin 
                       JSONParam           := TJSONParam.Create(DWParams.Encoding);
                       JSONParam.ParamName := ARequest.ContentFields.Names[I];
                       JSONParam.SetValue(ARequest.ContentFields.Values[JSONParam.ParamName], JSONParam.Encoded);
                       DWParams.Add(JSONParam);
                      End;
                    End;
                   If Assigned(Decoder) Then
                    FreeAndNil(Decoder);
                  End
                 Else If Boundary <> '' Then
                  Begin
                  {$IFDEF FPC}
                   ms := TStringStream.Create('');
                  {$ELSE}
                   ms := TStringStream.Create(''{$if CompilerVersion > 21}, TEncoding.UTF8{$IFEND});
                  {$ENDIF}
                   ms.Position := 0;
                   newdecoder  := Decoder.ReadBody(ms, msgEnd);
                   tmp         := Decoder.Headers.Text;
                   FreeAndNil(Decoder);
                   Decoder     := newdecoder;
                   If Decoder <> Nil Then
                    TIdMessageDecoderMIME(Decoder).MIMEBoundary := Boundary;
                   If pos('dwwelcomemessage', lowercase(tmp)) > 0 Then
                    vWelcomeMessage := DecodeStrings(ms.DataString{$IFDEF FPC}, csUndefined{$ENDIF})
                   Else If pos('accesstag', lowercase(tmp)) > 0 Then
                    vAccessTag := DecodeStrings(ms.DataString{$IFDEF FPC}, csUndefined{$ENDIF})
                   Else If pos('datacompression', lowercase(tmp)) > 0 Then
                    compresseddata := StringToBoolean(ms.DataString)
                   Else If pos('dwencodestrings', lowercase(tmp)) > 0 Then
                    encodestrings  := StringToBoolean(ms.DataString)
                   Else If pos('dwconnectiondefs', lowercase(tmp)) > 0 Then
                    Begin
                     vdwConnectionDefs  := TConnectionDefs.Create;
                     JSONValue           := TJSONValue.Create;
                     Try
                      JSONValue.Encoding  := VEncondig;
                      JSONValue.Encoded  := True;
                      JSONValue.LoadFromJSON(ms.DataString);
                      vdwConnectionDefs.LoadFromJSON(JSONValue.Value);
                     Finally
                      FreeAndNil(JSONValue);
                     End;
                    End
                   Else If pos('dwservereventname', lowercase(tmp)) > 0  Then
                    Begin
                     JSONValue           := TJSONValue.Create;
                     Try
                      JSONValue.Encoding  := VEncondig;
                      JSONValue.Encoded  := True;
                      JSONValue.LoadFromJSON(ms.DataString);
                      urlContext := JSONValue.Value;
                      If Pos('.', urlContext) > 0 Then
                       Begin
                        baseEventUnit := Copy(urlContext, InitStrPos, Pos('.', urlContext) - 1 - FinalStrPos);
                        urlContext    := Copy(urlContext, Pos('.', urlContext) + 1, Length(urlContext));
                       End;
                     Finally
                      FreeAndNil(JSONValue);
                     End;
                    End
                   Else
                    Begin
                     If Not Assigned(DWParams) Then
                      Begin
                       {$IFDEF FPC}
                        If Trim(ARequest.Query) <> '' Then
                         DWParams  := TServerUtils.ParseRESTURL (ARequest.PathInfo + '?' + ARequest.Query, VEncondig, UrlMethod, urlContext, vmark)
                        Else
                         DWParams  := TServerUtils.ParseRESTURL (ARequest.PathInfo, VEncondig, UrlMethod, urlContext, vmark);
                       {$ELSE}
                        If Trim(ARequest.Query) <> '' Then
                         DWParams  := TServerUtils.ParseRESTURL (ARequest.PathInfo + '?' + ARequest.Query, VEncondig, UrlMethod, urlContext, vmark)
                        Else
                         DWParams  := TServerUtils.ParseRESTURL (ARequest.PathInfo, VEncondig, UrlMethod, urlContext, vmark);
                       {$ENDIF}
                      End;
                     JSONParam   := TJSONParam.Create(DWParams.Encoding);
                     JSONParam.FromJSON(ms.DataString);
                     DWParams.Add(JSONParam);
                    End;
                   {$IFNDEF FPC}ms.Size := 0;{$ENDIF}
                   FreeAndNil(ms);
                   {ico}
                   FreeAndNil(newdecoder);
                   {ico}
                  End
                 Else
                  Begin
                   {$IFDEF FPC}
                    If Trim(ARequest.Query) <> '' Then
                     DWParams  := TServerUtils.ParseRESTURL (ARequest.PathInfo + '?' + ARequest.Query, VEncondig, UrlMethod, urlContext, vmark)
                    Else
                     DWParams  := TServerUtils.ParseRESTURL (ARequest.PathInfo, VEncondig, UrlMethod, urlContext, vmark);
                   {$ELSE}
                    If Trim(ARequest.Query) <> '' Then
                     DWParams  := TServerUtils.ParseRESTURL (ARequest.PathInfo + '?' + ARequest.Query, VEncondig, UrlMethod, urlContext, vmark)
                    Else
                     DWParams  := TServerUtils.ParseRESTURL (ARequest.PathInfo, VEncondig, UrlMethod, urlContext, vmark);
                   {$ENDIF}
                   FreeAndNil(decoder);
                  End;
                End;
               mcptIgnore :
                Begin
                 Try
                  If decoder <> Nil Then
                   FreeAndNil(decoder);
                  decoder := TIdMessageDecoderMIME.Create(Nil);
                  TIdMessageDecoderMIME(decoder).MIMEBoundary := boundary;
                 Finally
                 End;
                End;
               mcptEOF:
                Begin
                 FreeAndNil(decoder);
                 msgEnd := True
                End;
               End;
             Until (Decoder = Nil) Or (msgEnd);
            Finally
             If decoder <> nil then
              FreeAndNil(decoder);
             If vContentStringStream <> Nil Then
              FreeAndNil(vContentStringStream);
            End;
           End
          Else
           Begin
            {$IFDEF FPC}
             If Trim(ARequest.Query) <> '' Then
              DWParams  := TServerUtils.ParseRESTURL (ARequest.PathInfo + '?' + ARequest.Query, VEncondig, UrlMethod, urlContext, vmark)
             Else
              DWParams  := TServerUtils.ParseRESTURL (ARequest.PathInfo, VEncondig, UrlMethod, urlContext, vmark);
            {$ELSE}
             If Trim(ARequest.Query) <> '' Then
              DWParams  := TServerUtils.ParseRESTURL (ARequest.PathInfo + '?' + ARequest.Query, VEncondig, UrlMethod, urlContext, vmark)
             Else
              DWParams  := TServerUtils.ParseRESTURL (ARequest.PathInfo, VEncondig, UrlMethod, urlContext, vmark);
            {$ENDIF}
            If vContentStringStream <> Nil Then
             FreeAndNil(vContentStringStream);
            {$IFNDEF FPC}
             {$IF CompilerVersion > 30}
              ARequest.ReadTotalContent;
              If vContentStringStream = Nil Then
               If VEncondig = esUtf8 Then
                vContentStringStream := TStringStream.Create(TEncoding.UTF8.GetString(ARequest.RawContent))
               Else
                vContentStringStream := TStringStream.Create(TEncoding.ANSI.GetString(ARequest.RawContent));
             {$ELSE}
              If vContentStringStream = Nil Then
               vContentStringStream := TStringStream.Create(ARequest.Content);
              vContentStringStream.Position := 0;
             {$IFEND}
            {$ELSE}
             If vContentStringStream = Nil Then
              vContentStringStream := TStringStream.Create(ARequest.Content);
             vContentStringStream.Position := 0;
            {$ENDIF}
            If vContentStringStream.Size > 0 Then
             Begin
              vParamList := TStringList.Create;
              vParamList.Text := vContentStringStream.DataString;
              If (Not TServerUtils.ParseDWParamsURL(vContentStringStream.DataString, VEncondig, DWParams)) And
                 (vParamList.Count > 0) Then
               Begin
                For I := 0 To vParamList.Count -1 Do
                 Begin
                  tmp := vParamList.Names[I];
                  If pos('dwwelcomemessage', lowercase(tmp)) > 0 Then
                   vWelcomeMessage := DecodeStrings(vParamList.Values[tmp]{$IFDEF FPC}, csUndefined{$ENDIF})
                  Else If pos('accesstag', lowercase(tmp)) > 0 Then
                   vAccessTag := DecodeStrings(vParamList.Values[tmp]{$IFDEF FPC}, csUndefined{$ENDIF})
                  Else If pos('datacompression', lowercase(tmp)) > 0 Then
                   compresseddata := StringToBoolean(vParamList.Values[tmp])
                  Else If pos('dwencodestrings', lowercase(tmp)) > 0 Then
                   encodestrings  := StringToBoolean(vParamList.Values[tmp])
                  Else If pos('dwconnectiondefs', lowercase(tmp)) > 0 Then
                   Begin
                    vdwConnectionDefs   := TConnectionDefs.Create;
                    JSONValue           := TJSONValue.Create;
                    Try
                     JSONValue.Encoding  := VEncondig;
                     JSONValue.Encoded  := True;
                     JSONValue.LoadFromJSON(vParamList.Values[tmp]);
                     vdwConnectionDefs.LoadFromJSON(JSONValue.Value);
                    Finally
                     FreeAndNil(JSONValue);
                    End;
                   End
                  Else If pos('dwservereventname', lowercase(tmp)) > 0  Then
                   Begin
                    JSONValue           := TJSONValue.Create;
                    Try
                     JSONValue.Encoding  := VEncondig;
                     JSONValue.Encoded  := True;
                     JSONValue.LoadFromJSON(vParamList.Values[tmp]);
                     urlContext := JSONValue.Value;
                     If Pos('.', urlContext) > 0 Then
                      Begin
                       baseEventUnit := Copy(urlContext, InitStrPos, Pos('.', urlContext) - 1 - FinalStrPos);
                       urlContext    := Copy(urlContext, Pos('.', urlContext) + 1, Length(urlContext));
                      End;
                    Finally
                     FreeAndNil(JSONValue);
                    End;
                   End
                  Else
                   Begin
                    If DWParams = Nil Then
                     Begin
                      DWParams           := TDWParams.Create;
                      DWParams.Encoding  := VEncondig;
                     End;
                    JSONParam                 := TJSONParam.Create(DWParams.Encoding);
                    JSONParam.ObjectDirection := odIN;
                    JSONParam.ParamName       := lowercase(tmp);
                    tmp                       := TIdURI.URLDecode(StringReplace(vParamList.Values[tmp], '+', ' ', [rfReplaceAll]), GetEncodingID(DWParams.Encoding));
                    If Pos('{"ObjectType":"toParam", "Direction":"', tmp) = InitStrPos Then
                     JSONParam.FromJSON(tmp)
                    Else
                     JSONParam.AsString  := tmp;
                    DWParams.Add(JSONParam);
                   End;
                 End;
                vParamList.Free;
               End;
             End;
            If vContentStringStream <> Nil Then
             FreeAndNil(vContentStringStream);
           End;
//          aRequest.ReadTotalContent;  // added
//    SetString(s, PAnsiChar(@aRequest.RawContent[0]), Length(aRequest.RawContent));
//          SaveLog;
          If DWParams <> Nil Then
           If DWParams.ItemsString['dwEventNameData'] <> Nil Then
            UrlMethod := DWParams.ItemsString['dwEventNameData'].Value;
         End;
       End;
      WelcomeAccept     := True;
      If Assigned(vServerMethod) Then
       Begin
        vTempServerMethods:=vServerMethod.Create(nil);
        If vServerBaseMethod = TServerMethods Then
         Begin
          TServerMethods(vTempServerMethods).SetClientWelcomeMessage(vWelcomeMessage);
          If Assigned(TServerMethods(vTempServerMethods).OnWelcomeMessage) then
           TServerMethods(vTempServerMethods).OnWelcomeMessage(vWelcomeMessage, vAccessTag, vdwConnectionDefs, WelcomeAccept);
         End
        Else If vServerBaseMethod = TServerMethodDatamodule Then
         Begin
          TServerMethodDatamodule(vTempServerMethods).SetClientWelcomeMessage(vWelcomeMessage);
          If Assigned(TServerMethodDatamodule(vTempServerMethods).OnWelcomeMessage) then
           TServerMethodDatamodule(vTempServerMethods).OnWelcomeMessage(vWelcomeMessage, vAccessTag, vdwConnectionDefs, WelcomeAccept);
         End;
       End
      Else
       JSONStr := GetPairJSON(-5, 'Server Methods Cannot Assigned');
      Try
       If Assigned(vServerMethod) Then
        Begin
         {$IFNDEF FPC}
         If ARequest.PathInfo + ARequest.Query <> '' Then
         {$ELSE}
         If ARequest.URI <> '' Then
         {$ENDIF}
          Begin
           vOldMethod := UrlMethod;
//         {$IFNDEF FPC}
           If ARequest.Query <> '' Then
            UrlMethod := Trim(ARequest.PathInfo + '?' + ARequest.Query) //Alterações enviadas por "joaoantonio19"
           Else
            UrlMethod := Trim(ARequest.PathInfo);
//         {$ELSE}
//           UrlMethod := Trim(ARequest.URI);
//         {$ENDIF}
           If Pos('/?', UrlMethod) > InitStrPos Then
            UrlMethod := vOldMethod;
          End;
         While (Length(UrlMethod) > 0) Do
          Begin
           If Pos('/', UrlMethod) > 0 then
            Delete(UrlMethod, 1, 1)
           Else
            Begin
             UrlMethod := Trim(UrlMethod);
             If Pos('?', UrlMethod) > 0 Then
              UrlMethod := Copy(UrlMethod, 1, Pos('?', UrlMethod)-1);
             Break;
            End;
          End;
         If (UrlMethod = '') And (urlContext = '') Then
          UrlMethod := vOldMethod;
         If VEncondig = esUtf8 Then
          AResponse.ContentType            := 'application/json;charset=utf-8'
         Else If VEncondig = esASCII Then
          AResponse.ContentType            := 'application/json;charset=ansi';
         If vTempServerMethods <> Nil Then
          Begin
           JSONStr := ARequest.RemoteAddr;
           dwassyncexec := False;
           If DWParams.ItemsString['dwassyncexec'] <> Nil Then
            Begin
             dwassyncexec := DWParams.ItemsString['dwassyncexec'].AsBoolean;
             If dwassyncexec Then
              Begin
               {$IFNDEF FPC}
                AResponse.StatusCode        := 200;
               {$ELSE}
                AResponse.Code              := 200;
               {$ENDIF}
               If VEncondig = esUtf8 Then
                AResponse.ContentEncoding   := 'utf-8'
               Else
                AResponse.ContentEncoding   := 'ansi';
               AResponse.ContentLength      := -1; //Length(JSONStr);
               AResponse.Content            := AssyncCommandMSG;
               Handled := True;
              End;
            End;
           {$IFDEF FPC}
           If UrlMethod = '' Then
            UrlMethod := StringReplace(ARequest.PathInfo, '/', '', [rfReplaceAll]);
           {$ENDIF}
//             SaveLog; //For Debbug Vars
           {$IFDEF FPC}
           If Not ServiceMethods(TComponent(vTempServerMethods), ARequest.LocalPathPrefix, UrlMethod, urlContext, DWParams, JSONStr, JSONMode, vErrorCode,
                                 vContentType, vServerContextCall, ServerContextStream,vdwConnectionDefs, encodestrings, vAccessTag, WelcomeAccept, RequestType, vMark) Then
           {$ELSE}
           If Not ServiceMethods(TComponent(vTempServerMethods), ARequest.Method, UrlMethod, urlContext, DWParams, JSONStr, JsonMode, vErrorCode,
                                 vContentType, vServerContextCall, ServerContextStream, vdwConnectionDefs, encodestrings, vAccessTag, WelcomeAccept, RequestType, vMark) Then
           {$ENDIF}
            Begin
             If Not dwassyncexec Then
              Begin
               If Trim(lowercase(ARequest.PathInfo)) <> '' Then
                sFile := GetFileOSDir(ExcludeTag(Trim(lowercase(ARequest.PathInfo))))
               Else
                sFile := GetFileOSDir(ExcludeTag(Cmd));
               vFileExists := DWFileExists(sFile, FRootPath);
               If Not vFileExists Then
                Begin
                 tmp := '';
                 If ARequest.Referer <> '' Then
                  tmp := GetLastMethod(ARequest.Referer);
                 If Trim(lowercase(ARequest.PathInfo)) <> '' Then
                  sFile := GetFileOSDir(ExcludeTag(tmp + Trim(lowercase(ARequest.PathInfo))))
                 Else
                  sFile := GetFileOSDir(ExcludeTag(Cmd));
                 vFileExists := DWFileExists(sFile, FRootPath);
                End;
               vTagReply := vFileExists or scripttags(ExcludeTag(Cmd));
  //               SaveLog;
               If vTagReply Then
                Begin
                 AResponse.ContentType := GetMIMEType(sFile);
                 If TEncodeSelect(VEncondig) = esUtf8 Then
                  AResponse.ContentEncoding := 'utf-8'
                 Else If TEncodeSelect(VEncondig) = esASCII Then
                  AResponse.ContentEncoding := 'ansi';
                 If scripttags(ExcludeTag(Cmd)) and Not vFileExists Then
                  AResponse.ContentStream         := TMemoryStream.Create
                 Else
                  AResponse.ContentStream         := TIdReadFileExclusiveStream.Create(sFile);
  //                 AResponse.ContentStream := TIdReadFileExclusiveStream.Create(sFile);
                 {$IFNDEF FPC}{$if CompilerVersion > 21}AResponse.FreeContentStream := true;{$IFEND}{$ENDIF}
                 {$IFNDEF FPC}
                  AResponse.StatusCode      := 200;
                 {$ELSE}
                  AResponse.Code            := 200;
                 {$ENDIF}
                 Handled := True;
                End;
              End;
            End;
          End;
        End;
       Try
        If Not dwassyncexec Then
         Begin
          If Not (vTagReply) Then
           Begin
            If VEncondig = esUtf8 Then
             AResponse.ContentEncoding := 'utf-8'
            Else
             AResponse.ContentEncoding := 'ansi';
            If vContentType <> '' Then
             AResponse.ContentType := vContentType;
            If Not vServerContextCall Then
             Begin
              If (Assigned(DWParams)) And (UrlMethod <> '') Then
               Begin
                If JsonMode = jmDataware Then
                 Begin
                  If Trim(JSONStr) <> '' Then
                   Begin
                    If Not(((Pos('{', JSONStr) > 0)   And
                            (Pos('}', JSONStr) > 0))  Or
                           ((Pos('[', JSONStr) > 0)   And
                            (Pos(']', JSONStr) > 0))) Then
                     Begin
                      If Not((JSONStr[InitStrPos] = '"') And
                             (JSONStr[Length(JSONStr)] = '"')) Then
                       JSONStr := '"' + JSONStr + '"';
                     End;
                   End;
                  vReplyString := Format(TValueDisp, [GetParamsReturn(DWParams), JSONStr]);
                 End
                Else If JsonMode in [jmPureJSON, jmMongoDB] Then
                 Begin
                  If DWParams.CountOutParams < 2 Then
                   ReturnObject := '%s'
                  Else
                   ReturnObject := '[%s]';
                  vReplyString                        := Format(ReturnObject, [JSONStr]); //GetParamsReturn(DWParams)]);
                  If vReplyString = '' Then
                   vReplyString                       := JSONStr;
                 End;
               End;
              If compresseddata Then
               Begin
                ZCompressStr(vReplyString, vReplyStringResult);
                mb                                 := TStringStream.Create(vReplyStringResult{$IFNDEF FPC}{$IF CompilerVersion > 21}, TEncoding.UTF8{$IFEND}{$ENDIF});
               End
              Else
               Begin
                If (UrlMethod = '') and (urlContext = '') And (vErrorCode = 404) then
                 Begin
                  vReplyString                     := TServerStatusHTML;
                  vErrorCode                       := 200;
                  AResponse.ContentType            := 'text/html';
                  mb                               := TStringStream.Create(vReplyString{$IFNDEF FPC}{$IF CompilerVersion > 21}, TEncoding.UTF8{$IFEND}{$ENDIF});
                 End
                Else
                 mb                                := TStringStream.Create(vReplyString{$IFNDEF FPC}{$IF CompilerVersion > 21}, TEncoding.UTF8{$IFEND}{$ENDIF});
               End;
              mb.Position                          := 0;
              {$IFNDEF FPC}
              {$IF CompilerVersion > 21}
              AResponse.FreeContentStream          := True;
              {$IFEND}
              {$ELSE}
               AResponse.FreeContentStream         := True;
              {$ENDIF}
              AResponse.ContentStream           := mb;
              AResponse.ContentStream.Position := 0;
              AResponse.ContentLength          := mb.Size;
              {$IFNDEF FPC}
               AResponse.StatusCode            := vErrorCode;
              {$ELSE}
               AResponse.Code                  := vErrorCode;
              {$ENDIF}
             End
            Else
             Begin
              {$IFNDEF FPC}
               AResponse.StatusCode            := vErrorCode;
              {$ELSE}
               AResponse.Code                  := vErrorCode;
              {$ENDIF}
              If TEncodeSelect(VEncondig) = esUtf8 Then
               AResponse.ContentEncoding := 'utf-8'
              Else If TEncodeSelect(VEncondig) = esASCII Then
               AResponse.ContentEncoding := 'ansi';
              If ServerContextStream <> Nil Then
               Begin
                {$IFNDEF FPC}{$if CompilerVersion > 21}AResponse.FreeContentStream := true;{$IFEND}{$ENDIF}
                ServerContextStream.Position := 0;
                AResponse.ContentStream      := ServerContextStream;
                AResponse.ContentLength      := ServerContextStream.Size;
               End
              Else
               Begin
                AResponse.ContentLength      := -1; //Length(JSONStr);
                AResponse.Content            := JSONStr;
               End;
             End;
           End;
         End;
       Finally
        {$IFNDEF FPC}
        {$IF CompilerVersion < 21}
        If Assigned(mb) Then
         FreeAndNil(mb);
        If Assigned(ServerContextStream) Then
         FreeAndNil(ServerContextStream);
        {$IFEND}
        {$ENDIF}
       End;
      Finally
       If Assigned(vServerMethod) Then
        If Assigned(vTempServerMethods) Then
         Begin
          Try
           FreeAndNil(vTempServerMethods); //.free;
          Except
          End;
         End;
      End;
     End;
 Finally
  If AResponse.ContentLength = 0 Then
   AResponse.Content := Format('{"ServerStatus":"REST Dataware - Server CGI - Online! Command "%s", Content "%s", Autorization "%s", QueryString "%s""}',
                               [ARequest.ContentFields.Text, ARequest.Content, ARequest.Authorization, ARequest.Query]);
  If Not dwassyncexec Then
   Handled := True;
  If Assigned(DWParams) Then
   FreeAndNil(DWParams);
  If Assigned(vdwConnectionDefs) Then
   FreeAndNil(vdwConnectionDefs);
 End;
End;

procedure TRESTServiceCGI.SetServerMethod(Value: TComponentClass);
begin
 If (Value.ClassParent      = TServerMethods) Or
    (Value                  = TServerMethods) Then
  Begin
   vServerMethod     := Value;
   vServerBaseMethod := TServerMethods;
  End
 Else If (Value.ClassParent = TServerMethodDatamodule) Or
         (Value             = TServerMethodDatamodule) Then
  Begin
   vServerMethod := Value;
   vServerBaseMethod := TServerMethodDatamodule;
  End;
end;

procedure TRESTServiceCGI.GetPoolerList(ServerMethodsClass: TComponent;
                                        Var PoolerList    : String;
                                        AccessTag         : String);
Var
 I : Integer;
Begin
 If ServerMethodsClass <> Nil Then
  Begin
   For I := 0 To ServerMethodsClass.ComponentCount -1 Do
    Begin
     If ServerMethodsClass.Components[i] is TRESTDWPoolerDB Then
      Begin
       If Trim(TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag) <> '' Then
        Begin
         If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag <> AccessTag Then
          Continue;
        End;
       If PoolerList = '' then
        PoolerList := Format('%s.%s', [ServerMethodsClass.ClassName, ServerMethodsClass.Components[i].Name])
       Else
        PoolerList := PoolerList + '|' + Format('%s.%s', [ServerMethodsClass.ClassName, ServerMethodsClass.Components[i].Name]);
      End;
    End;
  End;
End;

Procedure TRESTServiceCGI.GetServerEventsList(ServerMethodsClass   : TComponent;
                                              Var ServerEventsList : String;
                                              AccessTag            : String);
Var
 I : Integer;
Begin
 If ServerMethodsClass <> Nil Then
  Begin
   For I := 0 To ServerMethodsClass.ComponentCount -1 Do
    Begin
     If ServerMethodsClass.Components[i] is TDWServerEvents Then
      Begin
       If Trim(TDWServerEvents(ServerMethodsClass.Components[i]).AccessTag) <> '' Then
        Begin
         If TDWServerEvents(ServerMethodsClass.Components[i]).AccessTag <> AccessTag Then
          Continue;
        End;
       If ServerEventsList = '' then
        ServerEventsList := Format('%s.%s', [ServerMethodsClass.ClassName, ServerMethodsClass.Components[i].Name])
       Else
        ServerEventsList := ServerEventsList + '|' + Format('%s.%s', [ServerMethodsClass.ClassName, ServerMethodsClass.Components[i].Name]);
      End;
    End;
  End;
End;

Function TRESTServiceCGI.ServiceMethods(BaseObject     : TComponent;
                                        AContext,
                                        UrlMethod,
                                        urlContext              : String;
                                        Var DWParams            : TDWParams;
                                        Var JSONStr             : String;
                                        Var JsonMode            : TJsonMode;
                                        Var ErrorCode           : Integer;
                                        Var ContentType         : String;
                                        Var ServerContextCall   : Boolean;
                                        Var ServerContextStream : TMemoryStream;
                                        ConnectionDefs          : TConnectionDefs;
                                        hEncodeStrings          : Boolean;
                                        AccessTag               : String;
                                        WelcomeAccept           : Boolean;
                                        Const RequestType       : TRequestType;
                                        mark                    : String): Boolean;
Var
 vJsonMSG,
 vResult,
 vResultIP,
 vUrlMethod   : String;
 vError,
 vInvalidTag  : Boolean;
 JSONParam    : TJSONParam;
Begin
 Result       := False;
 vUrlMethod   := UpperCase(UrlMethod);
 If WelcomeAccept Then
  Begin
   If vUrlMethod = UpperCase('GetPoolerList') Then
    Begin
     Result     := True;
     GetPoolerList(BaseObject, vResult, AccessTag);
     If DWParams.ItemsString['Result'] = Nil Then
      Begin
       JSONParam                 := TJSONParam.Create(DWParams.Encoding);
       JSONParam.ParamName       := 'Result';
       JSONParam.ObjectDirection := odOut;
       DWParams.Add(JSONParam);
      End;
     DWParams.ItemsString['Result'].SetValue(vResult, DWParams.ItemsString['Result'].Encoded);
     JSONStr    := TReplyOK;
    End
   Else If vUrlMethod = UpperCase('GetServerEventsList') Then
    Begin
     Result     := True;
     GetServerEventsList(BaseObject, vResult, AccessTag);
     If DWParams.ItemsString['Result'] = Nil Then
      Begin
       JSONParam                 := TJSONParam.Create(DWParams.Encoding);
       JSONParam.ParamName       := 'Result';
       JSONParam.ObjectDirection := odOut;
       DWParams.Add(JSONParam);
      End;
     DWParams.ItemsString['Result'].SetValue(vResult,
                                             DWParams.ItemsString['Result'].Encoded);
     JSONStr    := TReplyOK;
    End
   Else If vUrlMethod = UpperCase('EchoPooler') Then
    Begin
     vResultIP := JSONStr;
     vJsonMSG  := TReplyNOK;
     If DWParams.ItemsString['Pooler'] <> Nil Then
      Begin
       vResult    := DWParams.ItemsString['Pooler'].Value;
       EchoPooler(BaseObject, JSONStr, vResult, vResultIP, AccessTag, vInvalidTag);
      End;
     If DWParams.ItemsString['Result'] = Nil Then
      Begin
       JSONParam                 := TJSONParam.Create(DWParams.Encoding);
       JSONParam.ParamName       := 'Result';
       JSONParam.ObjectValue     := ovString;
       JSONParam.ObjectDirection := odOut;
       DWParams.Add(JSONParam);
      End;
     DWParams.ItemsString['Result'].SetValue(vResultIP,
                                             DWParams.ItemsString['Result'].Encoded);
     Result := vResultIP <> '';
     If Result Then
      Begin
       If DWParams.ItemsString['Result'] <> Nil Then
        JSONStr  := TReplyOK
       Else
        JSONStr  := vResultIP;
      End
     Else If vInvalidTag Then
      JSONStr    := TReplyTagError
     Else
      Begin
       JSONStr    := TReplyInvalidPooler;
       ErrorCode  := 404;
      End;
    End
   Else If vUrlMethod = UpperCase('ExecuteCommandPureJSON') Then
    Begin
     vResult    := DWParams.ItemsString['Pooler'].Value;
     ExecuteCommandPureJSON(BaseObject, vResult, DWParams, ConnectionDefs, hEncodeStrings, AccessTag);
     Result     := True;
     If Not(DWParams.ItemsString['Error'].AsBoolean) Then
      JSONStr    := TReplyOK
     Else
      Begin
       If DWParams.ItemsString['MessageError'] <> Nil Then
        JSONStr   := DWParams.ItemsString['MessageError'].AsString
       Else
        Begin
         JSONStr   := TReplyNOK;
         ErrorCode  := 500;
        End;
      End;
    End
   Else If vUrlMethod = UpperCase('ExecuteCommandJSON') Then
    Begin
     vResult    := DWParams.ItemsString['Pooler'].Value;
     ExecuteCommandJSON(BaseObject, vResult, DWParams, ConnectionDefs, hEncodeStrings, AccessTag);
     Result     := True;
     If Not(DWParams.ItemsString['Error'].AsBoolean) Then
      JSONStr    := TReplyOK
     Else
      Begin
       If DWParams.ItemsString['MessageError'] <> Nil Then
        JSONStr   := DWParams.ItemsString['MessageError'].AsString
       Else
        Begin
         JSONStr   := TReplyNOK;
         ErrorCode  := 500;
        End;
      End;
    End
   Else If vUrlMethod = UpperCase('ApplyUpdates') Then
    Begin
     vResult    := DWParams.ItemsString['Pooler'].Value;
     ApplyUpdatesJSON(BaseObject, vResult, DWParams, ConnectionDefs, hEncodeStrings, AccessTag);
     Result     := True;
     If Not(DWParams.ItemsString['Error'].AsBoolean) Then
      JSONStr    := TReplyOK
     Else
      Begin
       If DWParams.ItemsString['MessageError'] <> Nil Then
        JSONStr   := DWParams.ItemsString['MessageError'].AsString
       Else
        Begin
         JSONStr   := TReplyNOK;
         ErrorCode  := 500;
        End;
      End;
    End
   Else If vUrlMethod = UpperCase('ApplyUpdates_MassiveCache') Then
    Begin
     vResult    := DWParams.ItemsString['Pooler'].Value;
     ApplyUpdates_MassiveCache(BaseObject, vResult, DWParams, ConnectionDefs, hEncodeStrings, AccessTag);
     Result     := True;
     If Not(DWParams.ItemsString['Error'].AsBoolean) Then
      JSONStr    := TReplyOK
     Else
      Begin
       If DWParams.ItemsString['MessageError'] <> Nil Then
        JSONStr   := DWParams.ItemsString['MessageError'].AsString
       Else
        Begin
         JSONStr   := TReplyNOK;
         ErrorCode  := 500;
        End;
      End;
    End
   Else If vUrlMethod = UpperCase('InsertMySQLReturnID_PARAMS') Then
    Begin
     vResult    := DWParams.ItemsString['Pooler'].Value;
     InsertMySQLReturnID(BaseObject, vResult, DWParams, ConnectionDefs, hEncodeStrings, AccessTag);
     Result     := True;
     If Not(DWParams.ItemsString['Error'].AsBoolean) Then
      JSONStr    := TReplyOK
     Else
      Begin
       If DWParams.ItemsString['MessageError'] <> Nil Then
        JSONStr   := DWParams.ItemsString['MessageError'].AsString
       Else
        Begin
         JSONStr   := TReplyNOK;
         ErrorCode  := 500;
        End;
      End;
    End
   Else If vUrlMethod = UpperCase('InsertMySQLReturnID') Then
    Begin
     vResult    := DWParams.ItemsString['Pooler'].Value;
     InsertMySQLReturnID(BaseObject, vResult, DWParams, ConnectionDefs, hEncodeStrings, AccessTag);
     Result     := True;
     If Not(DWParams.ItemsString['Error'].AsBoolean) Then
      JSONStr    := TReplyOK
     Else
      Begin
       If DWParams.ItemsString['MessageError'] <> Nil Then
        JSONStr   := DWParams.ItemsString['MessageError'].AsString
       Else
        Begin
         JSONStr   := TReplyNOK;
         ErrorCode  := 500;
        End;
      End;
    End
   Else If vUrlMethod = UpperCase('OpenDatasets') Then
    Begin
     vResult     := DWParams.ItemsString['Pooler'].Value;
     OpenDatasets(BaseObject, vResult, DWParams, ConnectionDefs, hEncodeStrings, AccessTag);
     Result      := True;
     If Not(DWParams.ItemsString['Error'].AsBoolean) Then
      JSONStr    := TReplyOK
     Else
      Begin
       If DWParams.ItemsString['MessageError'] <> Nil Then
        JSONStr   := DWParams.ItemsString['MessageError'].AsString
       Else
        Begin
         JSONStr   := TReplyNOK;
         ErrorCode  := 500;
        End;
      End;
    End
   Else If vUrlMethod = UpperCase('GETEVENTS') Then
    Begin
     If DWParams.ItemsString['Error'] = Nil Then
      Begin
       JSONParam                 := TJSONParam.Create(DWParams.Encoding);
       JSONParam.ParamName       := 'Error';
       JSONParam.ObjectDirection := odOut;
       DWParams.Add(JSONParam);
      End;
     If DWParams.ItemsString['MessageError'] = Nil Then
      Begin
       JSONParam                 := TJSONParam.Create(DWParams.Encoding);
       JSONParam.ParamName       := 'MessageError';
       JSONParam.ObjectDirection := odOut;
       DWParams.Add(JSONParam);
      End;
     If DWParams.ItemsString['Result'] = Nil Then
      Begin
       JSONParam                 := TJSONParam.Create(DWParams.Encoding);
       JSONParam.ParamName       := 'Result';
       JSONParam.ObjectDirection := odOut;
       DWParams.Add(JSONParam);
      End;
     GetEvents(BaseObject, vResult, urlContext, DWParams);
     If Not(DWParams.ItemsString['Error'].AsBoolean) Then
      JSONStr    := TReplyOK
     Else
      Begin
       If DWParams.ItemsString['MessageError'] <> Nil Then
        JSONStr   := DWParams.ItemsString['MessageError'].AsString
       Else
        Begin
         JSONStr   := TReplyNOK;
         ErrorCode  := 500;
        End;
      End;
     Result      := JSONStr = TReplyOK;
    End
   Else
    Begin
     If ReturnEvent(BaseObject, vUrlMethod, vResult, urlContext, DWParams, JsonMode, ErrorCode, ContentType, RequestType) Then
      Begin
       JSONStr := vResult;
       Result  := JSONStr <> '';
      End
     Else
      Begin
       Result  := ReturnContext(BaseObject, vUrlMethod, vResult, urlContext, ContentType, ServerContextStream, vError, DWParams, RequestType, mark);
       If Not (Result) Or (vError) Then
        Begin
         If Not WelcomeAccept Then
          Begin
           JsonMode   := jmPureJSON;
           JSONStr    := TReplyInvalidWelcome;
           ErrorCode  := 500;
          End
         Else
          Begin
           JsonMode   := jmPureJSON;
           JSONStr    := vResult;
           ErrorCode  := 404;
          End;
         If vError Then
          Result := True;
        End
       Else
        Begin
         JsonMode  := jmPureJSON;
         JSONStr   := vResult;
         ErrorCode := 200;
         ServerContextCall := True;
        End;
      End;
    End;
  End
 Else If (vUrlMethod = UpperCase('GETEVENTS')) And (Not (vForceWelcomeAccess)) Then
  Begin
   If DWParams.ItemsString['Error'] = Nil Then
    Begin
     JSONParam                 := TJSONParam.Create(DWParams.Encoding);
     JSONParam.ParamName       := 'Error';
     JSONParam.ObjectDirection := odOut;
     DWParams.Add(JSONParam);
    End;
   If DWParams.ItemsString['MessageError'] = Nil Then
    Begin
     JSONParam                 := TJSONParam.Create(DWParams.Encoding);
     JSONParam.ParamName       := 'MessageError';
     JSONParam.ObjectDirection := odOut;
     DWParams.Add(JSONParam);
    End;
   If DWParams.ItemsString['Result'] = Nil Then
    Begin
     JSONParam                 := TJSONParam.Create(DWParams.Encoding);
     JSONParam.ParamName       := 'Result';
     JSONParam.ObjectDirection := odOut;
     DWParams.Add(JSONParam);
    End;
   GetEvents(BaseObject, vResult, urlContext, DWParams);
   If Not(DWParams.ItemsString['Error'].AsBoolean) Then
    JSONStr    := TReplyOK
   Else
    Begin
     If DWParams.ItemsString['MessageError'] <> Nil Then
      JSONStr   := DWParams.ItemsString['MessageError'].AsString
     Else
      Begin
       JSONStr   := TReplyNOK;
       ErrorCode  := 500;
      End;
    End;
   Result      := JSONStr = TReplyOK;
  End
 Else If (Not (vForceWelcomeAccess)) Then
  Begin
   If Not WelcomeAccept Then
    JSONStr := TReplyInvalidWelcome
   Else
    Begin
     If ReturnEvent(BaseObject, vUrlMethod, vResult, urlContext, DWParams, JsonMode, ErrorCode, ContentType, RequestType) Then
      Begin
       JSONStr := vResult;
       Result  := JSONStr <> '';
      End
     Else
      Begin
       If Not WelcomeAccept Then
        Begin
         JSONStr   := TReplyInvalidWelcome;
         ErrorCode := 500;
        End
       Else
        JSONStr := '';
       Result  := JSONStr <> '';
      End;
    End;
  End
 Else
  Begin
   If Not WelcomeAccept Then
    JSONStr := TReplyInvalidWelcome
   Else
    JSONStr := TReplyNOK;
   Result  := False;
   If DWParams.ItemsString['Error']        <> Nil Then
    DWParams.ItemsString['Error'].AsBoolean := True;
   If DWParams.ItemsString['MessageError'] <> Nil Then
    DWParams.ItemsString['MessageError'].AsString := 'Invalid welcomemessage...'
   Else
    ErrorCode  := 500;
  End;
End;

procedure TRESTServiceCGI.EchoPooler(ServerMethodsClass : TComponent;
                                     AContext           : String;
                                     Var Pooler, MyIP   : String;
                                     AccessTag          : String;
                                     Var InvalidTag     : Boolean);
Var
 I : Integer;
Begin
 MyIP := '';
 InvalidTag := False;
 If ServerMethodsClass <> Nil Then
  Begin
   For I := 0 To ServerMethodsClass.ComponentCount -1 Do
    Begin
     If ServerMethodsClass.Components[i] is TRESTDWPoolerDB Then
      Begin
       If Pooler = Format('%s.%s', [ServerMethodsClass.ClassName, ServerMethodsClass.Components[i].Name]) Then
        Begin
         If Trim(TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag) <> '' Then
          Begin
           If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag <> AccessTag Then
            Begin
             InvalidTag := True;
             Exit;
            End;
          End;
         If AContext <> '' Then
          MyIP := AContext;
         Break;
        End;
      End;
    End;
  End;
End;

procedure TRESTServiceCGI.ExecuteCommandPureJSON(ServerMethodsClass : TComponent;
                                                 Var Pooler         : String;
                                                 Var DWParams       : TDWParams;
                                                 ConnectionDefs     : TConnectionDefs;
                                                 hEncodeStrings     : Boolean;
                                                 AccessTag          : String);
Var
 I         : Integer;
 vError,
 vExecute  : Boolean;
 vTempJSON,
 vMessageError : String;
Begin
  try
   If ServerMethodsClass <> Nil Then
    Begin
     For I := 0 To ServerMethodsClass.ComponentCount -1 Do
      Begin
       If ServerMethodsClass.Components[i] is TRESTDWPoolerDB Then
        Begin
         If UpperCase(Pooler) = UpperCase(Format('%s.%s', [ServerMethodsClass.ClassName, ServerMethodsClass.Components[i].Name])) then
          Begin
           If Trim(TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag) <> '' Then
            Begin
             If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag <> AccessTag Then
              Begin
               DWParams.ItemsString['MessageError'].AsString := 'Invalid Access tag...';
               DWParams.ItemsString['Error'].AsBoolean       := True;
               Exit;
              End;
            End;
           If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver <> Nil Then
            Begin
             vExecute := DWParams.ItemsString['Execute'].AsBoolean;
             vError   := DWParams.ItemsString['Error'].AsBoolean;
             TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.Encoding          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).Encoding;
             TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.EncodeStringsJSON := hEncodeStrings;
             TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim;
             TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsEmpty2Null    := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsEmpty2Null;
             TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim2Len      := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim2Len;
             Try
              TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.PrepareConnection(ConnectionDefs);
              vTempJSON := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.ExecuteCommand(DWParams.ItemsString['SQL'].Value,
                                                                                                       vError,
                                                                                                       vMessageError,
                                                                                                       vExecute);
             Except
              On E : Exception Do
               Begin
                vMessageError := e.Message;
                vError        := True;
               End;
             End;
             If vMessageError <> '' Then
              DWParams.ItemsString['MessageError'].AsString := vMessageError;
             DWParams.ItemsString['Error'].AsBoolean := vError;
             If DWParams.ItemsString['Result'] <> Nil Then
              Begin
               If Not(vError) And (vTempJSON <> '') Then
                DWParams.ItemsString['Result'].SetValue(vTempJSON,
                                                        DWParams.ItemsString['Result'].Encoded)
               Else
                DWParams.ItemsString['Result'].SetValue('');
              End;
            End;
           Break;
          End;
        End;
      End;
    End;
  Finally
  End;
End;

procedure TRESTServiceCGI.ExecuteCommandJSON(ServerMethodsClass : TComponent;
                                             Var Pooler         : String;
                                             Var DWParams       : TDWParams;
                                             ConnectionDefs     : TConnectionDefs;
                                             hEncodeStrings     : Boolean;
                                             AccessTag          : String);
Var
 I         : Integer;
 vError,
 vExecute  : Boolean;
 vTempJSON,
 vMessageError : String;
 DWParamsD     : TDWParams;
Begin
 DWParamsD := Nil;
 If ServerMethodsClass <> Nil Then
  Begin
   For I := 0 To ServerMethodsClass.ComponentCount -1 Do
    Begin
     If ServerMethodsClass.Components[i] is TRESTDWPoolerDB Then
      Begin
       If UpperCase(Pooler) = UpperCase(Format('%s.%s', [ServerMethodsClass.ClassName, ServerMethodsClass.Components[i].Name])) then
        Begin
         If Trim(TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag) <> '' Then
          Begin
           If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag <> AccessTag Then
            Begin
             DWParams.ItemsString['MessageError'].AsString := 'Invalid Access tag...';
             DWParams.ItemsString['Error'].AsBoolean       := True;
             Exit;
            End;
          End;
         If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver <> Nil Then
          Begin
           vExecute := DWParams.ItemsString['Execute'].AsBoolean;
           vError   := DWParams.ItemsString['Error'].AsBoolean;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.Encoding          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).Encoding;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.EncodeStringsJSON := hEncodeStrings;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsEmpty2Null    := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsEmpty2Null;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim2Len      := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim2Len;
           If DWParams.ItemsString['Params'] <> Nil Then
            Begin
             DWParamsD := TDWParams.Create;
             DWParamsD.FromJSON(DWParams.ItemsString['Params'].Value);
            End;
           Try
            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.PrepareConnection(ConnectionDefs);
            If DWParamsD <> Nil Then
             Begin
              vTempJSON := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.ExecuteCommand(DWParams.ItemsString['SQL'].Value,
                                                                                                       DWParamsD, vError, vMessageError,
                                                                                                       vExecute);
             End
            Else
             vTempJSON := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.ExecuteCommand(DWParams.ItemsString['SQL'].Value,
                                                                                                      vError,
                                                                                                      vMessageError,
                                                                                                      vExecute);
           Except
            On E : Exception Do
             Begin
              vMessageError := e.Message;
              vError        := True;
             End;
           End;
           If vMessageError <> '' Then
            DWParams.ItemsString['MessageError'].AsString := vMessageError;
           DWParams.ItemsString['Error'].AsBoolean        := vError;
           If DWParams.ItemsString['Result'] <> Nil Then
            Begin
             If Not (vError) And (vTempJSON <> '') Then
              DWParams.ItemsString['Result'].SetValue(vTempJSON,
                                                      DWParams.ItemsString['Result'].Encoded)
             Else
              DWParams.ItemsString['Result'].SetValue('');
            End;
          End;
         Break;
        End;
      End;
    End;
  End;
End;

procedure TRESTServiceCGI.InsertMySQLReturnID(ServerMethodsClass : TComponent;
                                              Var Pooler         : String;
                                              Var DWParams       : TDWParams;
                                              ConnectionDefs     : TConnectionDefs;
                                              hEncodeStrings     : Boolean;
                                              AccessTag          : String);
Var
 I,
 vTempJSON     : Integer;
 vError        : Boolean;
 vMessageError : String;
 DWParamsD     : TDWParams;
Begin
 DWParamsD := Nil;
 If ServerMethodsClass <> Nil Then
  Begin
   For I := 0 To ServerMethodsClass.ComponentCount -1 Do
    Begin
     If ServerMethodsClass.Components[i] is TRESTDWPoolerDB Then
      Begin
       If UpperCase(Pooler) = UpperCase(Format('%s.%s', [ServerMethodsClass.ClassName, ServerMethodsClass.Components[i].Name])) then
        Begin
         If Trim(TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag) <> '' Then
          Begin
           If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag <> AccessTag Then
            Begin
             DWParams.ItemsString['MessageError'].AsString := 'Invalid Access tag...';
             DWParams.ItemsString['Error'].AsBoolean       := True;
             Exit;
            End;
          End;
         If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver <> Nil Then
          Begin
           vError   := DWParams.ItemsString['Error'].AsBoolean;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.Encoding          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).Encoding;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.EncodeStringsJSON := hEncodeStrings;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsEmpty2Null    := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsEmpty2Null;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim2Len      := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim2Len;
           If DWParams.ItemsString['Params'] <> Nil Then
            Begin
             DWParamsD := TDWParams.Create;
             DWParamsD.FromJSON(DWParams.ItemsString['Params'].Value);
            End;
           Try
            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.PrepareConnection(ConnectionDefs);
            If DWParamsD <> Nil Then
             Begin
              vTempJSON := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.InsertMySQLReturnID(DWParams.ItemsString['SQL'].Value,
                                                                                                            DWParamsD, vError, vMessageError);
              DWParamsD.Free;
             End
            Else
             vTempJSON := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.InsertMySQLReturnID(DWParams.ItemsString['SQL'].Value,
                                                                                                           vError,
                                                                                                           vMessageError);
           Except
            On E : Exception Do
             Begin
              vMessageError := e.Message;
              vError        := True;
             End;
           End;
           If vMessageError <> '' Then
            DWParams.ItemsString['MessageError'].AsString := vMessageError;
           DWParams.ItemsString['Error'].AsBoolean := vError;
           If DWParams.ItemsString['Result'] <> Nil Then
            Begin
             If vTempJSON <> -1 Then
              DWParams.ItemsString['Result'].SetValue(IntToStr(vTempJSON),
                                                      DWParams.ItemsString['Result'].Encoded)
             Else
              DWParams.ItemsString['Result'].SetValue('-1');
            End;
          End;
         Break;
        End;
      End;
    End;
  End;
End;

procedure TRESTServiceCGI.ApplyUpdatesJSON(ServerMethodsClass : TComponent;
                                           Var Pooler         : String;
                                           Var DWParams       : TDWParams;
                                           ConnectionDefs     : TConnectionDefs;
                                           hEncodeStrings     : Boolean;
                                           AccessTag          : String);
Var
 I             : Integer;
 vTempJSON     : TJSONValue;
 vError        : Boolean;
 vSQL,
 vMessageError : String;
 DWParamsD     : TDWParams;
Begin
 DWParamsD := Nil;
 If ServerMethodsClass <> Nil Then
  Begin
   For I := 0 To ServerMethodsClass.ComponentCount -1 Do
    Begin
     If ServerMethodsClass.Components[i] is TRESTDWPoolerDB Then
      Begin
       If UpperCase(Pooler) = UpperCase(Format('%s.%s', [ServerMethodsClass.ClassName, ServerMethodsClass.Components[i].Name])) then
        Begin
         If Trim(TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag) <> '' Then
          Begin
           If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag <> AccessTag Then
            Begin
             DWParams.ItemsString['MessageError'].AsString := 'Invalid Access tag...';
             DWParams.ItemsString['Error'].AsBoolean       := True;
             Exit;
            End;
          End;
         If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver <> Nil Then
          Begin
           vError   := DWParams.ItemsString['Error'].AsBoolean;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.Encoding          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).Encoding;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.EncodeStringsJSON := hEncodeStrings;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsEmpty2Null    := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsEmpty2Null;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim2Len      := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim2Len;
           If DWParams.ItemsString['Params'] <> Nil Then
            Begin
             DWParamsD := TDWParams.Create;
             DWParamsD.FromJSON(DWParams.ItemsString['Params'].Value);
            End;
           If DWParams.ItemsString['SQL'] <> Nil Then
            vSQL := DWParams.ItemsString['SQL'].Value;
           Try
            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.PrepareConnection(ConnectionDefs);
            vTempJSON := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.ApplyUpdates(DWParams.ItemsString['Massive'].Value,
                                                                                                   vSQL,
                                                                                                   DWParamsD, vError, vMessageError);
            If DWParamsD <> Nil Then
             DWParamsD.Free;
           Except
            On E : Exception Do
             Begin
              vMessageError := e.Message;
              vError        := True;
             End;
           End;
           If vMessageError <> '' Then
            DWParams.ItemsString['MessageError'].AsString := vMessageError;
           DWParams.ItemsString['Error'].AsBoolean        := vError;
           If DWParams.ItemsString['Result'] <> Nil Then
            Begin
             If vTempJSON <> Nil Then
              Begin
               DWParams.ItemsString['Result'].SetValue(vTempJSON.ToJSON,
                                                       DWParams.ItemsString['Result'].Encoded);
               vTempJSON.Free;
              End
             Else
              DWParams.ItemsString['Result'].SetValue('');
            End;
          End;
         Break;
        End;
      End;
    End;
  End;
End;


Function TRESTServiceCGI.ReturnContext(ServerMethodsClass : TComponent;
                                          Var Pooler,
                                          vResult,
                                          urlContext,
                                          ContentType             : String;
                                          Var ServerContextStream : TMemoryStream;
                                          Var Error               : Boolean;
                                          Const DWParams          : TDWParams;
                                          Const RequestType       : TRequestType;
                                          mark                    : String) : Boolean;
Var
 I             : Integer;
 vRejected,
 vTagService,
 vDefaultPage  : Boolean;
 vBaseHeader,
 vErrorMessage,
 vRootContext  : String;
Begin
 Result        := False;
 Error         := False;
 vDefaultPage  := False;
 vRejected     := False;
 vTagService   := Result;
 vRootContext  := '';
 vErrorMessage := '';
 If (Pooler <> '') And (urlContext = '') Then
  Begin
   urlContext := Pooler;
   Pooler     := '';
  End;
 If ServerMethodsClass <> Nil Then
  Begin
   For I := 0 To ServerMethodsClass.ComponentCount -1 Do
    Begin
     If ServerMethodsClass.Components[i] is TDWServerContext Then
      Begin
       If (LowerCase(urlContext) = LowerCase(TDWServerContext(ServerMethodsClass.Components[i]).BaseContext)) Then
        Begin
         vRootContext := TDWServerContext(ServerMethodsClass.Components[i]).RootContext;
         If (Pooler = '') And (vRootContext <> '') Then
          Pooler := vRootContext;
         vTagService := TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler] <> Nil;
        End;
       If vTagService Then
        Begin
         Result   := True;
         If (RequestTypeToRoute(RequestType) In TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].Routes) Or
            (crAll in TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].Routes) Then
          Begin
           If Assigned(TDWServerContext(ServerMethodsClass.Components[i]).OnBeforeRenderer) Then
            TDWServerContext(ServerMethodsClass.Components[i]).OnBeforeRenderer(ServerMethodsClass.Components[i]);
           If Assigned(TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].OnAuthRequest) Then
            TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].OnAuthRequest(DWParams, vRejected, vErrorMessage);
           If Not vRejected Then
            Begin
             vResult := '';
             Try
              ContentType := TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].ContentType;
              If mark <> '' Then
               Begin
                vResult    := '';
                Result     := Assigned(TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].ContextRules);
                If Result Then
                 Begin
                  Result   := TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].ContextRules.Items.MarkByName[mark] <> Nil;
                  If Result Then
                   Begin
                    Result := Assigned(TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].ContextRules.Items.MarkByName[mark].OnRequestExecute);
                    If Result Then
                     Begin
                      ContentType := 'application/json';
                      TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].ContextRules.Items.MarkByName[mark].OnRequestExecute(DWParams, ContentType, vResult);
                     End;
                   End;
                 End;
               End
              Else If Assigned(TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].ContextRules) Then
               Begin
                vBaseHeader := '';
                ContentType := TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].ContextRules.ContentType;
                vResult := TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].ContextRules.BuildContext(TDWServerContext(ServerMethodsClass.Components[i]).BaseHeader,
                                                                                                                                          TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].IgnoreBaseHeader);
               End
              Else
               Begin
                If Assigned(TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].OnBeforeCall) Then
                 TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].OnBeforeCall(TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler]);
                vDefaultPage := Not Assigned(TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].OnReplyRequest);
                If Not vDefaultPage Then
                 TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].OnReplyRequest(DWParams, ContentType, vResult, RequestType);
                If Assigned(TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].OnReplyRequestStream) Then
                 Begin
                  vDefaultPage := False;
                  TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].OnReplyRequestStream(DWParams, ContentType, ServerContextStream, RequestType);
                 End;
                If vDefaultPage Then
                 Begin
                  vBaseHeader := '';
                  If Assigned(TDWServerContext(ServerMethodsClass.Components[i]).BaseHeader) Then
                   vBaseHeader := TDWServerContext(ServerMethodsClass.Components[i]).BaseHeader.Text;
                  vResult := TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].DefaultHtml.Text;
                  If Assigned(TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].OnBeforeRenderer) Then
                   TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].OnBeforeRenderer(vBaseHeader, ContentType, vResult, RequestType);
                 End;
               End;
             Except
              On E : Exception Do
               Begin
                vResult := e.Message;
                Error   := True;
                Exit;
               End;
             End;
            End
           Else
            Begin
             If vErrorMessage <> '' Then
              Begin
               ContentType := 'text/html';
               vResult     := vErrorMessage;
              End
             Else
              vResult   := 'The Requested URL was Rejected';
            End;
           If Trim(vResult) = '' Then
            vResult := TReplyOK;
          End
         Else
          vResult   := 'Request not found...';
         Break;
        End;
      End;
    End;
  End;
End;

Function TRESTServiceCGI.ReturnEvent(ServerMethodsClass : TComponent;
                                     Var Pooler,
                                     vResult,
                                     urlContext         : String;
                                     Var DWParams       : TDWParams;
                                     Var JsonMode       : TJsonMode;
                                     Var ErrorCode      : Integer;
                                     Var ContentType    : String;
                                     Const RequestType  : TRequestType) : Boolean;
Var
 I : Integer;
 vRejected,
 vTagService   : Boolean;
 vErrorMessage : String;
Begin
 Result        := False;
 vRejected     := False;
 vTagService   := Result;
 vErrorMessage := '';
 If ServerMethodsClass <> Nil Then
  Begin
   For I := 0 To ServerMethodsClass.ComponentCount -1 Do
    Begin
     If ServerMethodsClass.Components[i] is TDWServerEvents Then
      Begin
       If (LowerCase(urlContext) = LowerCase(TDWServerEvents(ServerMethodsClass.Components[i]).ContextName)) Or
          (LowerCase(urlContext) = LowerCase(ServerMethodsClass.Components[i].Name)) Then
        vTagService := TDWServerEvents(ServerMethodsClass.Components[i]).Events.EventByName[Pooler] <> Nil;
       If vTagService Then
        Begin
         Result   := True;
         JsonMode := jmPureJSON;
         If (RequestTypeToRoute(RequestType) In TDWServerEvents(ServerMethodsClass.Components[i]).Events.EventByName[Pooler].Routes) Or
            (crAll in TDWServerEvents(ServerMethodsClass.Components[i]).Events.EventByName[Pooler].Routes) Then
          Begin
           TDWServerEvents(ServerMethodsClass.Components[i]).CreateDWParams(Pooler, DWParams);
           If Assigned(TDWServerEvents(ServerMethodsClass.Components[i]).Events.EventByName[Pooler].OnAuthRequest) Then
            TDWServerEvents(ServerMethodsClass.Components[i]).Events.EventByName[Pooler].OnAuthRequest(DWParams, vRejected, vErrorMessage);
           If Not vRejected Then
            Begin
             vResult    := '';
             Try
              If Assigned(TDWServerEvents(ServerMethodsClass.Components[i]).Events.EventByName[Pooler].OnBeforeExecute) Then
               TDWServerEvents(ServerMethodsClass.Components[i]).Events.EventByName[Pooler].OnBeforeExecute(TDWServerEvents(ServerMethodsClass.Components[i]).Events.EventByName[Pooler]);
              If Assigned(TDWServerEvents(ServerMethodsClass.Components[i]).Events.EventByName[Pooler].OnReplyEventByType) Then
               TDWServerEvents(ServerMethodsClass.Components[i]).Events.EventByName[Pooler].OnReplyEventByType(DWParams, vResult, RequestType)
              Else If Assigned(TDWServerEvents(ServerMethodsClass.Components[i]).Events.EventByName[Pooler].OnReplyEvent) Then
               TDWServerEvents(ServerMethodsClass.Components[i]).Events.EventByName[Pooler].OnReplyEvent(DWParams, vResult);
              JsonMode := TDWServerEvents(ServerMethodsClass.Components[i]).Events.EventByName[Pooler].JsonMode;
             Except
              On E : Exception Do
               Begin
                vResult := e.Message;
                Result  := True;
                If Not vTagService Then
                 ErrorCode := 500;
                Exit;
               End;
             End;
            End
           Else
            Begin
             If vErrorMessage <> '' Then
              Begin
               ContentType := 'text/html';
               vResult   := vErrorMessage;
              End
             Else
              vResult   := 'The Requested URL was Rejected';
             ErrorCode := 500;
            End;
           If Trim(vResult) = '' Then
            vResult := TReplyOK;
          End
         Else
          Begin
           vResult   := 'Request not found...';
           ErrorCode := 500;
          End;
         Break;
        End
       Else
        Begin
         vResult := 'Event not found...';
//         Result  := True;
        End;
      End;
    End;
  End;
 If Not vTagService Then
  ErrorCode := 404;
End;

Procedure TRESTServiceCGI.GetEvents(ServerMethodsClass : TComponent;
                                    Var Pooler,
                                    urlContext         : String;
                                    Var DWParams       : TDWParams);
Var
 I         : Integer;
 vError    : Boolean;
 vTempJSON : String;
Begin
 vTempJSON := '';
 If ServerMethodsClass <> Nil Then
  Begin
   For I := 0 To ServerMethodsClass.ComponentCount -1 Do
    Begin
     If ServerMethodsClass.Components[i] is TDWServerEvents Then
      Begin
       If (LowerCase(urlContext) = LowerCase(TDWServerEvents(ServerMethodsClass.Components[i]).ContextName)) or
          (LowerCase(urlContext) = LowerCase(ServerMethodsClass.Components[i].Name)) Then
        Begin
         If vTempJSON = '' Then
          vTempJSON := Format('%s', [TDWServerEvents(ServerMethodsClass.Components[i]).Events.ToJSON])
         Else
          vTempJSON := vTempJSON + Format(', %s', [TDWServerEvents(ServerMethodsClass.Components[i]).Events.ToJSON]);
        End;
      End;
    End;
   vError := vTempJSON = '';
   If vError Then
    DWParams.ItemsString['MessageError'].AsString := 'Event Not Found';
   DWParams.ItemsString['Error'].AsBoolean        := vError;
   If DWParams.ItemsString['Result'] <> Nil Then
    Begin
     If vTempJSON <> '' Then
      DWParams.ItemsString['Result'].SetValue(Format('[%s]', [vTempJSON]), DWParams.ItemsString['Result'].Encoded)
     Else
      DWParams.ItemsString['Result'].SetValue('');
    End;
  End;
End;

procedure TRESTServiceCGI.OpenDatasets(ServerMethodsClass : TComponent;
                                       Var Pooler         : String;
                                       Var DWParams       : TDWParams;
                                       ConnectionDefs     : TConnectionDefs;
                                       hEncodeStrings     : Boolean;
                                       AccessTag          : String);
Var
 I         : Integer;
 vTempJSON : TJSONValue;
 vError    : Boolean;
 vMessageError : String;
Begin
 If ServerMethodsClass <> Nil Then
  Begin
   For I := 0 To ServerMethodsClass.ComponentCount -1 Do
    Begin
     If ServerMethodsClass.Components[i] is TRESTDWPoolerDB Then
      Begin
       If UpperCase(Pooler) = UpperCase(Format('%s.%s', [ServerMethodsClass.ClassName, ServerMethodsClass.Components[i].Name])) then
        Begin
         If Trim(TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag) <> '' Then
          Begin
           If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag <> AccessTag Then
            Begin
             DWParams.ItemsString['MessageError'].AsString := 'Invalid Access tag...';
             DWParams.ItemsString['Error'].AsBoolean       := True;
             Exit;
            End;
          End;
         If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver <> Nil Then
          Begin
           vError   := DWParams.ItemsString['Error'].AsBoolean;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.Encoding          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).Encoding;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.EncodeStringsJSON := hEncodeStrings;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsEmpty2Null    := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsEmpty2Null;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim2Len      := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim2Len;
           Try
            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.PrepareConnection(ConnectionDefs);
            vTempJSON := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.OpenDatasets(DWParams.ItemsString['LinesDataset'].Value,
                                                                                                   vError, vMessageError);
           Except
            On E : Exception Do
             Begin
              vMessageError := e.Message;
              vError        := True;
             End;
           End;
           If vMessageError <> '' Then
            DWParams.ItemsString['MessageError'].AsString := vMessageError;
           DWParams.ItemsString['Error'].AsBoolean        := vError;
           If DWParams.ItemsString['Result'] <> Nil Then
            Begin
             If vTempJSON <> Nil Then
              Begin
               DWParams.ItemsString['Result'].StringToBytes(vTempJSON.ToJSON, True);
               FreeAndNil(vTempJSON);
              End
             Else
              DWParams.ItemsString['Result'].SetValue('');
            End;
          End;
         Break;
        End;
      End;
    End;
  End;
End;

procedure TRESTServiceCGI.ApplyUpdates_MassiveCache(ServerMethodsClass : TComponent;
                                                    Var Pooler         : String;
                                                    Var DWParams       : TDWParams;
                                                    ConnectionDefs     : TConnectionDefs;
                                                    hEncodeStrings     : Boolean;
                                                    AccessTag          : String);
Var
 I             : Integer;
 vError        : Boolean;
 vMessageError : String;
Begin
 If ServerMethodsClass <> Nil Then
  Begin
   For I := 0 To ServerMethodsClass.ComponentCount -1 Do
    Begin
     If ServerMethodsClass.Components[i] is TRESTDWPoolerDB Then
      Begin
       If UpperCase(Pooler) = UpperCase(Format('%s.%s', [ServerMethodsClass.ClassName, ServerMethodsClass.Components[i].Name])) then
        Begin
         If Trim(TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag) <> '' Then
          Begin
           If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag <> AccessTag Then
            Begin
             DWParams.ItemsString['MessageError'].AsString := 'Invalid Access tag...';
             DWParams.ItemsString['Error'].AsBoolean       := True;
             Exit;
            End;
          End;
         If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver <> Nil Then
          Begin
           vError   := DWParams.ItemsString['Error'].AsBoolean;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.Encoding          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).Encoding;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.EncodeStringsJSON := hEncodeStrings;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsEmpty2Null    := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsEmpty2Null;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim2Len      := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim2Len;
           Try
            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.PrepareConnection(ConnectionDefs);
            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.ApplyUpdates_MassiveCache(DWParams.ItemsString['MassiveCache'].Value,
                                                                                                   vError,  vMessageError);
           Except
            On E : Exception Do
             Begin
              vMessageError := e.Message;
              vError        := True;
             End;
           End;
           If vMessageError <> '' Then
            DWParams.ItemsString['MessageError'].AsString := vMessageError;
           DWParams.ItemsString['Error'].AsBoolean        := vError;
          End;
         Break;
        End;
      End;
    End;
  End;
End;

constructor TRESTServiceCGI.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  vServerParams := TServerParams.Create(Self);
  vServerParams.HasAuthentication := True;
  vForceWelcomeAccess             := False;
  vServerParams.UserName          := 'testserver';
  vServerParams.Password          := 'testserver';
  vServerContext                  := 'restdataware';
  VEncondig                       := esUtf8;
  FRootPath                       := '/';
  vCORS                           := False;
end;

destructor TRESTServiceCGI.Destroy;
begin
  vServerParams.Free;
  inherited Destroy;
end;

Constructor TRESTClientPooler.Create(AOwner: TComponent);
Begin
 Inherited;
 HttpRequest                     := TIdHTTP.Create(Nil);
 HttpRequest.Request.ContentType := 'application/json';
 HttpRequest.AllowCookies        := False;
 HttpRequest.HTTPOptions         := [hoKeepOrigProtocol];
 vTransparentProxy               := TIdProxyConnectionInfo.Create;
 vHost                           := 'localhost';
 vPort                           := 8082;
 vUserName                       := 'testserver';
 vPassword                       := 'testserver';
 vRSCharset                      := esUtf8;
 vAuthentication                 := True;
 vRequestTimeOut                 := 10000;
 vThreadRequest                  := False;
 vDatacompress                   := True;
 vEncodeStrings                  := True;
 {$IFDEF FPC}
 vDatabaseCharSet                := csUndefined;
 {$ENDIF}
End;

Destructor  TRESTClientPooler.Destroy;
Begin
 Try
  If HttpRequest.Connected Then
   HttpRequest.Disconnect;
 Except
 End;
 FreeAndNil(HttpRequest);
 FreeAndNil(vTransparentProxy);
 Inherited;
End;

Function TRESTClientPooler.GetAccessTag: String;
Begin
 Result := vAccessTag;
End;

Function TRESTClientPooler.GetAllowCookies: Boolean;
Begin
 Result := HttpRequest.AllowCookies;
End;

Function TRESTClientPooler.GetHandleRedirects : Boolean;
Begin
 Result := HttpRequest.HandleRedirects;
End;

Function TRESTClientPooler.SendEvent(EventData       : String;
                                     Var Params      : TDWParams;
                                     EventType       : TSendEvent = sePOST;
                                     JsonMode        : TJsonMode  = jmDataware;
                                     ServerEventName : String     = '';
                                     CallBack        : TCallBack  = Nil) : String; //Código original VCL e LCL
Var
 vURL,
 vTpRequest    : String;
 aStringStream : TStringStream;
 vResultParams : TMemoryStream;
 bStringStream,
 StringStream  : TStringStream;
 SendParams    : TIdMultipartFormDataStream;
 thd           : TThread_Request;
 vDataPack,
 SResult : String;
 StringStreamList : TStringStreamList;
 JSONValue        : TJSONValue;
 Procedure SetData(Var InputValue     : String;
                   Var ParamsData : TDWParams;
                   Var ResultJSON : String);
 Var
  bJsonOBJ,
  bJsonValue    : TDWJSONObject;
  bJsonOBJTemp  : TDWJSONArray;
  JSONParam,
  JSONParamNew  : TJSONParam;
  A, InitPos    : Integer;
  vValue,
  aValue,
  vTempValue    : String;
 Begin
  ResultJSON := InputValue;
  If Pos(', "RESULT":[', InputValue) = 0 Then
   Begin
    If vRSCharset = esUtf8 Then
     ResultJSON := PWidechar(UTF8Decode(InputValue))
    Else
     ResultJSON := InputValue;
    Exit;
   End;
  Try
//   InitPos    := Pos(', "RESULT":[', InputValue) + Length(', "RESULT":[') ;
   If (Pos(', "RESULT":[{"MESSAGE":"', InputValue) > 0) Then
    InitPos   := Pos(', "RESULT":[{"MESSAGE":"', InputValue) + Length(', "RESULT":[')   //TODO Brito
   Else If (Pos(', "RESULT":[', InputValue) > 0) Then
    InitPos   := Pos(', "RESULT":[', InputValue) + Length(', "RESULT":[')
   Else If (Pos('{"PARAMS":[{"', InputValue) > 0)       And
            (Pos('", "RESULT":', InputValue) > 0)       Then
    InitPos   := Pos('", "RESULT":', InputValue) + Length('", "RESULT":');
   aValue   := Copy(InputValue, InitPos,    Length(InputValue) -1);
   If Pos(']}', aValue) > 0 Then
    aValue     := Copy(aValue, InitStrPos, Pos(']}', aValue) -1);
   vTempValue := aValue;
   InputValue := Copy(InputValue, InitStrPos, InitPos-1) + ']}';//Delete(InputValue, InitPos, Pos(']}', InputValue) - InitPos);
   If (Params <> Nil) And (InputValue <> '{"PARAMS"]}') And (InputValue <> '') Then
    Begin
     {$IFDEF FPC}
      If vRSCharset = esUtf8 Then
       bJsonValue    := TDWJSONObject.Create(PWidechar(UTF8Decode(InputValue)))
      Else
       bJsonValue    := TDWJSONObject.Create(InputValue);
     {$ELSE}
      bJsonValue    := TDWJSONObject.Create(InputValue);
     {$ENDIF}
     InputValue    := '';
     bJsonOBJTemp  := TDWJSONArray(bJsonValue.OpenArray(bJsonValue.pairs[0].name));
     If bJsonOBJTemp.ElementCount > 0 Then
      Begin
       For A := 0 To bJsonOBJTemp.ElementCount -1 Do
        Begin
         bJsonOBJ := TDWJSONObject(bJsonOBJTemp.GetObject(A));
         If Length(bJsonOBJ.Pairs[0].Value) = 0 Then
          Continue;
         If GetObjectName(bJsonOBJ.Pairs[0].Value) <> toParam Then
          Continue;
         JSONParam := TJSONParam.Create(vRSCharset);
         Try
          JSONParam.ParamName       := bJsonOBJ.Pairs[4].name;
          JSONParam.ObjectValue     := GetValueType(bJsonOBJ.Pairs[3].Value);
          JSONParam.ObjectDirection := GetDirectionName(bJsonOBJ.Pairs[1].Value);
          JSONParam.Encoded         := GetBooleanFromString(bJsonOBJ.Pairs[2].Value);
          If Not(JSONParam.ObjectValue In [ovBlob, ovGraphic, ovOraBlob, ovOraClob]) Then
           Begin
            If (JSONParam.Encoded) Then
             vValue := DecodeStrings(bJsonOBJ.Pairs[4].Value{$IFDEF FPC}, vDatabaseCharSet{$ENDIF})
            Else If JSONParam.ObjectValue <> ovObject then
             vValue := bJsonOBJ.Pairs[4].Value
            Else                                            //TODO Brito
             Begin
              vValue := bJsonOBJ.Pairs[4].Value;
              DeleteInvalidChar(vValue);
             End;
           End
          Else
           vValue := bJsonOBJ.Pairs[4].Value;
          JSONParam.SetValue(vValue, JSONParam.Encoded);
          //parametro criandos no servidor
          If ParamsData.ItemsString[JSONParam.ParamName] = Nil Then
           Begin
            JSONParamNew           := TJSONParam.Create(ParamsData.Encoding);
            JSONParamNew.ParamName := JSONParam.ParamName;
            JSONParamNew.SetValue(JSONParam.Value, JSONParam.Encoded);
            ParamsData.Add(JSONParamNew);
           End
          Else If Not (JSONParam.Binary) Then
           ParamsData.ItemsString[JSONParam.ParamName].Value := JSONParam.Value
          Else
           ParamsData.ItemsString[JSONParam.ParamName].SetValue(vValue, JSONParam.Encoded);
         Finally
          FreeAndNil(JSONParam);
          //Magno - 28/08/2018
          FreeAndNil(bJsonOBJ);
         End;
        End;
      End;
//     bJsonValue.Clean;
     FreeAndNil(bJsonValue);
     //Magno - 28/08/2018
     FreeAndNil(bJsonOBJTemp);
    End;
  Finally
   If vTempValue <> '' Then
    ResultJSON := vTempValue;
   vTempValue := '';
  End;
 End;
 Procedure SetParamsValues(DWParams : TDWParams; SendParamsData : TIdMultipartFormDataStream);
 Var
  I : Integer;
 Begin
  If DWParams <> Nil Then
   Begin
    If Not (Assigned(StringStreamList)) Then
     StringStreamList := TStringStreamList.Create;
    For I := 0 To DWParams.Count -1 Do
     Begin
      If DWParams.Items[I].ObjectValue in [ovWideMemo, ovBytes, ovVarBytes, ovBlob,
                                           ovMemo,   ovGraphic, ovFmtMemo,  ovOraBlob, ovOraClob] Then
       Begin
        StringStreamList.Add({$IFDEF FPC}
                              TStringStream.Create(DWParams.Items[I].ToJSON)
                             {$ELSE}
                              TStringStream.Create(DWParams.Items[I].ToJSON{$if CompilerVersion > 21}, TEncoding.UTF8{$IFEND})
                             {$ENDIF});
        {$IFNDEF FPC}
         {$if CompilerVersion > 21}
          SendParamsData.AddObject(DWParams.Items[I].ParamName, 'multipart/form-data', HttpRequest.Request.Charset, StringStreamList.Items[StringStreamList.Count-1]);
         {$ELSE}
          SendParamsData.AddObject(DWParams.Items[I].ParamName, 'multipart/form-data', HttpRequest.Request.Charset, StringStreamList.Items[StringStreamList.Count-1]);
         {$IFEND}
        {$ELSE}
         SendParamsData.AddObject(DWParams.Items[I].ParamName, 'multipart/form-data', HttpRequest.Request.Charset, StringStreamList.Items[StringStreamList.Count-1]);
        {$ENDIF}
       End
      Else
       SendParamsData.AddFormField(DWParams.Items[I].ParamName, DWParams.Items[I].ToJSON);
     End;
   End;
 End;
Begin
 SendParams := Nil;
 StringStreamList := Nil;
 // INICIO BLOCO PARA USA thread
 If vThreadRequest and (not vThreadExecuting) then
  Begin
   thd := TThread_Request.Create;
   Try
    thd.FreeOnTerminate := true;
    thd.Priority        := tpHighest;
    thd.EventData       := EventData;
    thd.Params.CopyFrom(Params);
    thd.EventType       := EventType;
    thd.vUserName       := vUserName;
    thd.vPassword       := vPassword;
    thd.vUrlPath        := vUrlPath;
    thd.vHost           :=   vHost;
    thd.vPort           :=   vPort;
    thd.vAuthentication   :=   vAuthentication;
    thd.vTransparentProxy:=   vTransparentProxy;
    thd.vRequestTimeOut :=   vRequestTimeOut;
    thd.vTypeRequest    :=   vTypeRequest;
    thd.vRSCharset      :=   vRSCharset;
    thd.FCallBack       :=  CallBack;
    {$IFDEF FPC}
    thd.FCallSendEvent  :=  @self.SendEvent;
    {$ELSE}
    thd.FCallSendEvent  :=  self.SendEvent;
    {$ENDIF}
    vThreadExecuting:=True;
   Finally
    thd.Execute;
   End;
   Exit;
  End;
 vResultParams := TMemoryStream.Create;
 If vTypeRequest = trHttp Then
  vTpRequest := 'http'
 Else If vTypeRequest = trHttps Then
  vTpRequest := 'https';
 Try
  vURL := LowerCase(Format(UrlBase, [vTpRequest, vHost, vPort, vUrlPath])) + EventData;
  If vRSCharset = esUtf8 Then
   HttpRequest.Request.Charset := 'utf-8'
  Else If vRSCharset = esASCII Then
   HttpRequest.Request.Charset := 'ansi';
  SetParams(HttpRequest);
  HttpRequest.MaxAuthRetries := 0;
  Case EventType Of
   seGET :
    Begin
     HttpRequest.Request.ContentType := 'application/json';
     If not vThreadRequest Then
       Result := HttpRequest.Get(EventData)
     else
     begin
       SResult := HttpRequest.Get(EventData);
       If Assigned(CallBack) Then
         CallBack(SResult, Params);
     end;
    End;
   sePOST,
   sePUT,
   seDELETE :
    Begin;
     If EventType = sePOST Then
      Begin
       SendParams := TIdMultiPartFormDataStream.Create;
       try //Alexandre Magno - 24/11/2018
         If Params <> Nil Then
          SetParamsValues(Params, SendParams);
         If vWelcomeMessage <> '' Then
          SendParams.AddFormField('dwwelcomemessage', EncodeStrings(vWelcomeMessage{$IFDEF FPC}, vDatabaseCharSet{$ENDIF}));
         If vAccessTag <> '' Then
          SendParams.AddFormField('accesstag',        EncodeStrings(vAccessTag{$IFDEF FPC}, vDatabaseCharSet{$ENDIF}));
         If ServerEventName <> '' Then
          Begin
           JSONValue           := TJSONValue.Create;
           Try
            JSONValue.Encoding  := vRSCharset;
            JSONValue.Encoded   := True;
            JSONValue.Tagname   := 'dwservereventname';
            JSONValue.SetValue(ServerEventName, JSONValue.Encoded);
           Finally
            SendParams.AddFormField('dwservereventname', JSONValue.ToJSON);
            //Magno - 28/08/2018
            FreeAndNil(JSONValue);
           End;
          End;
  //        SendParams.AddFormField('dwservereventname', EncodeStrings(ServerEventName));
         SendParams.AddFormField('datacompression',   BooleanToString(vDatacompress));
         SendParams.AddFormField('dwencodestrings',   BooleanToString(vEncodeStrings));
         If (Params <> Nil) Or (vWelcomeMessage <> '') Or (vDatacompress) Then
          Begin
           HttpRequest.Request.ContentType     := 'application/x-www-form-urlencoded';
           HttpRequest.Request.ContentEncoding := 'multipart/form-data';
           If vDatacompress Then
            Begin
             {$IFDEF FPC}
              aStringStream := TStringStream.Create(HttpRequest.Post(vURL, SendParams));
             {$ELSE}
              aStringStream := TStringStream.Create(HttpRequest.Post(vURL, SendParams){$if CompilerVersion > 21}, TEncoding.UTF8{$IFEND});
             {$ENDIF}
             ZDecompressStreamD(aStringStream, StringStream);
             FreeAndNil(aStringStream);
            End
           Else
            Begin
             StringStream                      := TStringStream.Create('');
             HttpRequest.Post(vURL, SendParams, StringStream);
            End;
           StringStream.Position := 0;
           If SendParams <> Nil Then
            Begin
             If Assigned(StringStreamList) Then
              FreeAndNil(StringStreamList);
             {$IFNDEF FPC}SendParams.Clear;{$ENDIF}
             FreeAndNil(SendParams);
            End;
          End
         Else
          Begin
           HttpRequest.Request.ContentType     := 'application/json';
           HttpRequest.Request.ContentEncoding := '';
           aStringStream := TStringStream.Create('');
           HttpRequest.Get(EventData, aStringStream);
           aStringStream.Position := 0;
           StringStream   := TStringStream.Create('');
           bStringStream  := TStringStream.Create('');
           If vDatacompress Then
            Begin
             bStringStream.CopyFrom(aStringStream, aStringStream.Size);
             bStringStream.Position := 0;
             ZDecompressStreamD(bStringStream, StringStream);
            End
           Else
            Begin
             bStringStream.CopyFrom(aStringStream, aStringStream.Size);
             bStringStream.Position := 0;
             HexToStream(bStringStream.DataString, StringStream);
            End;
           FreeAndNil(bStringStream);
           FreeAndNil(aStringStream);
          End;
         HttpRequest.Request.Clear;
         StringStream.Position := 0;
         vDataPack := StringStream.DataString;
         If not vThreadRequest Then
          Begin
            {$IFNDEF FPC}
            {$IF CompilerVersion > 21}
            StringStream.Clear;
            {$IFEND}
            StringStream.Size := 0;
            {$ENDIF}
            FreeAndNil(StringStream);
            SetData(vDataPack, Params, Result);
          End
         Else
          Begin
           {$IFNDEF FPC}
           {$IF CompilerVersion > 21}
           StringStream.Clear;
           {$IFEND}
           StringStream.Size := 0;
           {$ENDIF}
           FreeAndNil(StringStream);
           SetData(vDataPack, Params, SResult);
           If Assigned(CallBack) Then
            CallBack(SResult, Params);
          End;
       except
        //Alexandre Magno - 24/11/2018
        On E : Exception Do
         Begin
          if Assigned(SendParams) then
            FreeAndNil(SendParams);

          Raise Exception.Create(e.Message);
         End;
       end
      End
     Else If EventType = sePUT Then
      Begin
       HttpRequest.Request.ContentType := 'application/x-www-form-urlencoded';
       StringStream  := TStringStream.Create('');
       HttpRequest.Post(vURL, SendParams, StringStream);
       StringStream.WriteBuffer(#0' ', 1);
       StringStream.Position := 0;
       vDataPack := StringStream.DataString;
       If not vThreadRequest Then
        Begin
         {$IFNDEF FPC}
         {$IF CompilerVersion > 21}
         StringStream.Clear;
         {$IFEND}
         StringStream.Size := 0;
         {$ENDIF}
         FreeAndNil(StringStream);
         SetData(vDataPack, Params, Result);
        End
       Else
        Begin
         {$IFNDEF FPC}
         {$IF CompilerVersion > 21}
         StringStream.Clear;
         {$IFEND}
         StringStream.Size := 0;
         {$ENDIF}
         FreeAndNil(StringStream);
         SetData(vDataPack, Params, SResult);
         If Assigned(CallBack) Then
          CallBack(SResult, Params);
        End;
      End
     Else If EventType = seDELETE Then
      Begin
       Try
        HttpRequest.Request.ContentType := 'application/json';
        HttpRequest.Delete(vURL);
        If not vThreadRequest Then
          Result := GetPairJSON('OK', 'DELETE COMMAND OK')
        else
        begin
           SResult := GetPairJSON('OK', 'DELETE COMMAND OK');
           If Assigned(CallBack) Then
             CallBack(SResult, Params);
        end;
       Except
        On e:exception Do
         Begin
          If not vThreadRequest Then
             Result := GetPairJSON('NOK', e.Message)
           else
           Begin
              SResult := GetPairJSON('NOK', e.Message);
              If Assigned(CallBack) Then
                CallBack(SResult, Params);
           End;
         End;
       End;
      End;
    End;
  End;
 Except
  On E : Exception Do
   Begin
    {Todo: Acrescentado}
    HttpRequest.Disconnect;
    //Alexandre Magno - 24/11/2018
    if Assigned(vResultParams) then
      FreeAndNil(vResultParams);
    //Alexandre Magno - 24/11/2018
    If Assigned(StringStreamList) Then
      FreeAndNil(StringStreamList);

    Raise Exception.Create(e.Message);
   End;
 End;
 FreeAndNil(vResultParams);
 vThreadExecuting:=false;
End;

{
Function TRESTClientPooler.SendEvent(EventData : String;
                                     CallBack  : TCallBack = Nil) : String;
Var
 RBody      : TStringStream;
 vTpRequest : String;
 Params     : TDWParams;
Begin
 Params  := Nil;
 RBody   := TStringStream.Create('');
 Try
  If vTypeRequest = trHttp Then
   vTpRequest := 'http'
  Else If vTypeRequest = trHttps Then
   vTpRequest := 'https';
  Result := SendEvent(LowerCase(Format(UrlBase, [vTpRequest, vHost, vPort, vUrlPath])) + EventData, Params, sePOST, CallBack);
 Except
 End;
 RBody.Free;
End;
}

Function TRESTClientPooler.SendEvent(EventData : String) : String;
Var
 Params : TDWParams;
Begin
 Try
  Params := Nil;
  Result := SendEvent(EventData, Params);
 Finally
 End;
End;

Procedure TRESTClientPooler.SetAccessTag(Value : String);
Begin
 vAccessTag := Value;
End;

Procedure TRESTClientPooler.SetAllowCookies(Value: Boolean);
Begin
 HttpRequest.AllowCookies    := Value;
End;

Procedure TRESTClientPooler.SetHandleRedirects(Value: Boolean);
Begin
 HttpRequest.HandleRedirects := Value;
End;

Procedure TRESTClientPooler.SetOnStatus(Value : TOnStatus);
Begin
 {$IFDEF FPC}
  vOnStatus            := Value;
  HttpRequest.OnStatus := vOnStatus;
 {$ELSE}
  vOnStatus            := Value;
  HttpRequest.OnStatus := vOnStatus;
 {$ENDIF}
End;

Procedure TRESTClientPooler.SetOnWork(Value : TOnWork);
Begin
 {$IFDEF FPC}
  vOnWork            := Value;
  HttpRequest.OnWork := vOnWork;
 {$ELSE}
  vOnWork            := Value;
  HttpRequest.OnWork := vOnWork;
 {$ENDIF}
End;

Procedure TRESTClientPooler.SetOnWorkBegin(Value : TOnWorkBegin);
Begin
 {$IFDEF FPC}
  vOnWorkBegin            := Value;
  HttpRequest.OnWorkBegin := vOnWorkBegin;
 {$ELSE}
  vOnWorkBegin            := Value;
  HttpRequest.OnWorkBegin := vOnWorkBegin;
 {$ENDIF}
End;

Procedure TRESTClientPooler.SetOnWorkEnd(Value : TOnWorkEnd);
Begin
 {$IFDEF FPC}
  vOnWorkEnd            := Value;
  HttpRequest.OnWorkEnd := vOnWorkEnd;
 {$ELSE}
  vOnWorkEnd            := Value;
  HttpRequest.OnWorkEnd := vOnWorkEnd;
 {$ENDIF}
End;

Procedure TRESTClientPooler.SetParams(Var aHttpRequest  : TIdHTTP);
Begin
 aHttpRequest.Request.BasicAuthentication := vAuthentication;
 If aHttpRequest.Request.BasicAuthentication Then
  Begin
   If aHttpRequest.Request.Authentication = Nil Then
    aHttpRequest.Request.Authentication         := TIdBasicAuthentication.Create;
   aHttpRequest.Request.Authentication.Password := vPassword;
   aHttpRequest.Request.Authentication.Username := vUserName;
  End;
 aHttpRequest.ProxyParams.BasicAuthentication := vTransparentProxy.BasicAuthentication;
 aHttpRequest.ProxyParams.ProxyUsername       := vTransparentProxy.ProxyUsername;
 aHttpRequest.ProxyParams.ProxyServer         := vTransparentProxy.ProxyServer;
 aHttpRequest.ProxyParams.ProxyPassword       := vTransparentProxy.ProxyPassword;
 aHttpRequest.ProxyParams.ProxyPort           := vTransparentProxy.ProxyPort;
 aHttpRequest.ReadTimeout         := vRequestTimeout;
 aHttpRequest.Request.ContentType := HttpRequest.Request.ContentType;
 aHttpRequest.AllowCookies        := HttpRequest.AllowCookies;
 aHttpRequest.HandleRedirects     := HttpRequest.HandleRedirects;
 aHttpRequest.HTTPOptions         := HttpRequest.HTTPOptions;
 aHttpRequest.Request.Charset     := HttpRequest.Request.Charset;
End;

procedure TRESTClientPooler.SetPassword(Value : String);
begin
 vPassword := Value;
 HttpRequest.Request.Password := vPassword;
end;

Procedure TRESTClientPooler.SetUrlPath(Value : String);
Begin
 vUrlPath := Value;
 If Length(vUrlPath) > 0 Then
  If vUrlPath[Length(vUrlPath)] <> '/' Then
   vUrlPath := vUrlPath + '/';
End;

procedure TRESTClientPooler.SetUserName(Value : String);
begin
 vUsername := Value;
 HttpRequest.Request.Username := vUsername;
end;

Constructor TProxyOptions.Create;
Begin
 Inherited;
 vServer   := '';
 vLogin    := vServer;
 vPassword := vLogin;
 vPort     := 8888;
End;

Procedure TProxyOptions.Assign(Source: TPersistent);
Var
 Src : TProxyOptions;
Begin
 If Source is TProxyOptions Then
  Begin
   Src := TProxyOptions(Source);
   vServer := Src.Server;
   vLogin  := Src.Login;
   vPassword := Src.Password;
   vPort     := Src.Port;
  End
 Else
  Inherited;
End;

Procedure TRESTServicePooler.GetServerEventsList(ServerMethodsClass   : TComponent;
                                                 Var ServerEventsList : String;
                                                 AccessTag            : String);
Var
 I : Integer;
Begin
 If ServerMethodsClass <> Nil Then
  Begin
   For I := 0 To ServerMethodsClass.ComponentCount -1 Do
    Begin
     If ServerMethodsClass.Components[i] is TDWServerEvents Then
      Begin
       If Trim(TDWServerEvents(ServerMethodsClass.Components[i]).AccessTag) <> '' Then
        Begin
         If TDWServerEvents(ServerMethodsClass.Components[i]).AccessTag <> AccessTag Then
          Continue;
        End;
       If ServerEventsList = '' then
        ServerEventsList := Format('%s.%s', [ServerMethodsClass.ClassName, ServerMethodsClass.Components[i].Name])
       Else
        ServerEventsList := ServerEventsList + '|' + Format('%s.%s', [ServerMethodsClass.ClassName, ServerMethodsClass.Components[i].Name]);
      End;
    End;
  End;
End;

Procedure TRESTServicePooler.GetPoolerList(ServerMethodsClass : TComponent;
                                           Var PoolerList     : String;
                                           AccessTag          : String);
Var
 I : Integer;
Begin
 If ServerMethodsClass <> Nil Then
  Begin
   For I := 0 To ServerMethodsClass.ComponentCount -1 Do
    Begin
     If ServerMethodsClass.Components[i] is TRESTDWPoolerDB Then
      Begin
       If Trim(TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag) <> '' Then
        Begin
         If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag <> AccessTag Then
          Continue;
        End;
       If PoolerList = '' then
        PoolerList := Format('%s.%s', [ServerMethodsClass.ClassName, ServerMethodsClass.Components[i].Name])
       Else
        PoolerList := PoolerList + '|' + Format('%s.%s', [ServerMethodsClass.ClassName, ServerMethodsClass.Components[i].Name]);
      End;
    End;
  End;
End;

Procedure TRESTServicePooler.EchoPooler(ServerMethodsClass : TComponent;
                                        AContext           : TIdContext;
                                        Var Pooler,
                                            MyIP           : String;
                                        AccessTag          : String;
                                        Var InvalidTag     : Boolean);
Var
 I : Integer;
Begin
 InvalidTag := False;
 MyIP       := '';
 If ServerMethodsClass <> Nil Then
  Begin
   For I := 0 To ServerMethodsClass.ComponentCount -1 Do
    Begin
     If (ServerMethodsClass.Components[i] is TRESTDWPoolerDB) Then
      Begin
       If Pooler = Format('%s.%s', [ServerMethodsClass.ClassName, ServerMethodsClass.Components[i].Name]) Then
        Begin
         If Trim(TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag) <> '' Then
          Begin
           If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag <> AccessTag Then
            Begin
             InvalidTag := True;
             Exit;
            End;
          End;
         If AContext <> Nil Then
          MyIP := AContext.Connection.Socket.Binding.PeerIP;
         Break;
        End;
      End;
    End;
  End;
End;

Procedure TRESTServicePooler.ExecuteCommandPureJSON(ServerMethodsClass : TComponent;
                                                    Var Pooler         : String;
                                                    Var DWParams       : TDWParams;
                                                    ConnectionDefs     : TConnectionDefs;
                                                    hEncodeStrings     : Boolean;
                                                    AccessTag          : String);
Var
 I         : Integer;
 vEncoded,
 vError,
 vExecute  : Boolean;
 vTempJSON,
 vMessageError : String;
Begin
 Try
  vTempJSON := '';
  If ServerMethodsClass <> Nil Then
   Begin
    For I := 0 To ServerMethodsClass.ComponentCount -1 Do
     Begin
      If ServerMethodsClass.Components[i] is TRESTDWPoolerDB Then
       Begin
        If UpperCase(Pooler) = UpperCase(Format('%s.%s', [ServerMethodsClass.ClassName, ServerMethodsClass.Components[i].Name])) then
         Begin
          If Trim(TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag) <> '' Then
           Begin
            If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag <> AccessTag Then
             Begin
              DWParams.ItemsString['MessageError'].AsString := 'Invalid Access tag...';
              DWParams.ItemsString['Error'].AsBoolean       := True;
              Exit;
             End;
           End;
          If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver <> Nil Then
           Begin
            vExecute := DWParams.ItemsString['Execute'].AsBoolean;
            vError   := DWParams.ItemsString['Error'].AsBoolean;
            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.Encoding          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).Encoding;
            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.EncodeStringsJSON := hEncodeStrings;
            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim;
            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsEmpty2Null    := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsEmpty2Null;
            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim2Len      := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim2Len;
            Try
             TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.PrepareConnection(ConnectionDefs);
             vTempJSON := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.ExecuteCommand(DWParams.ItemsString['SQL'].Value,
                                                                                                      vError,
                                                                                                      vMessageError,
                                                                                                      vExecute);
            Except
             On E : Exception Do
              Begin
               vMessageError := e.Message;
               vError        := True;
              End;
            End;
            If vMessageError <> '' Then
             DWParams.ItemsString['MessageError'].AsString := vMessageError;
            DWParams.ItemsString['Error'].AsBoolean := vError;
            If DWParams.ItemsString['Result'] <> Nil Then
             Begin
              vEncoded := DWParams.ItemsString['Result'].Encoded;
              If Not(vError) And (vTempJSON <> '') Then
               DWParams.ItemsString['Result'].SetValue(vTempJSON, vEncoded)
              Else
               DWParams.ItemsString['Result'].SetValue('');
             End;
           End;
          Break;
         End;
       End;
     End;
   End;
 Finally
 End;
End;

Procedure TRESTServicePooler.InsertMySQLReturnID(ServerMethodsClass : TComponent;
                                                 Var Pooler         : String;
                                                 Var DWParams       : TDWParams;
                                                 ConnectionDefs     : TConnectionDefs;
                                                 hEncodeStrings     : Boolean;
                                                 AccessTag          : String);
Var
 I,
 vTempJSON     : Integer;
 vError        : Boolean;
 vMessageError : String;
 DWParamsD     : TDWParams;
Begin
 DWParamsD := Nil;
 If ServerMethodsClass <> Nil Then
  Begin
   For I := 0 To ServerMethodsClass.ComponentCount -1 Do
    Begin
     If ServerMethodsClass.Components[i] is TRESTDWPoolerDB Then
      Begin
       If UpperCase(Pooler) = UpperCase(Format('%s.%s', [ServerMethodsClass.ClassName, ServerMethodsClass.Components[i].Name])) then
        Begin
         If Trim(TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag) <> '' Then
          Begin
           If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag <> AccessTag Then
            Begin
             DWParams.ItemsString['MessageError'].AsString := 'Invalid Access tag...';
             DWParams.ItemsString['Error'].AsBoolean       := True;
             Exit;
            End;
          End;
         If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver <> Nil Then
          Begin
           vError   := DWParams.ItemsString['Error'].AsBoolean;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.Encoding          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).Encoding;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.EncodeStringsJSON := hEncodeStrings;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsEmpty2Null    := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsEmpty2Null;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim2Len      := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim2Len;
           If DWParams.ItemsString['Params'] <> Nil Then
            Begin
             DWParamsD := TDWParams.Create;
             DWParamsD.FromJSON(DWParams.ItemsString['Params'].Value);
            End;
           Try
            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.PrepareConnection(ConnectionDefs);
            If DWParamsD <> Nil Then
             Begin
              vTempJSON := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.InsertMySQLReturnID(DWParams.ItemsString['SQL'].Value,
                                                                                                            DWParamsD, vError, vMessageError);
              DWParamsD.Free;
             End
            Else
             vTempJSON := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.InsertMySQLReturnID(DWParams.ItemsString['SQL'].Value,
                                                                                                           vError,
                                                                                                           vMessageError);
           Except
            On E : Exception Do
             Begin
              vMessageError := e.Message;
              vError        := True;
             End;
           End;
           If vMessageError <> '' Then
            DWParams.ItemsString['MessageError'].AsString := vMessageError;
           DWParams.ItemsString['Error'].AsBoolean := vError;
           If DWParams.ItemsString['Result'] <> Nil Then
            Begin
             If vTempJSON <> -1 Then
              DWParams.ItemsString['Result'].SetValue(IntToStr(vTempJSON), DWParams.ItemsString['Result'].Encoded)
             Else
              DWParams.ItemsString['Result'].SetValue('-1');
            End;
          End;
         Break;
        End;
      End;
    End;
  End;
End;

Procedure TRESTServicePooler.ApplyUpdates_MassiveCache(ServerMethodsClass : TComponent;
                                                       Var Pooler         : String;
                                                       Var DWParams       : TDWParams;
                                                       ConnectionDefs     : TConnectionDefs;
                                                       hEncodeStrings     : Boolean;
                                                       AccessTag          : String);
Var
 I             : Integer;
 vError        : Boolean;
 vMessageError : String;
Begin
 If ServerMethodsClass <> Nil Then
  Begin
   For I := 0 To ServerMethodsClass.ComponentCount -1 Do
    Begin
     If ServerMethodsClass.Components[i] is TRESTDWPoolerDB Then
      Begin
       If UpperCase(Pooler) = UpperCase(Format('%s.%s', [ServerMethodsClass.ClassName, ServerMethodsClass.Components[i].Name])) then
        Begin
         If Trim(TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag) <> '' Then
          Begin
           If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag <> AccessTag Then
            Begin
             DWParams.ItemsString['MessageError'].AsString := 'Invalid Access tag...';
             DWParams.ItemsString['Error'].AsBoolean       := True;
             Exit;
            End;
          End;
         If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver <> Nil Then
          Begin
           vError   := DWParams.ItemsString['Error'].AsBoolean;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.Encoding          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).Encoding;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.EncodeStringsJSON := hEncodeStrings;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsEmpty2Null    := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsEmpty2Null;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim2Len      := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim2Len;
           Try
            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.PrepareConnection(ConnectionDefs);
            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.ApplyUpdates_MassiveCache(DWParams.ItemsString['MassiveCache'].Value,
                                                                                                   vError,  vMessageError);
           Except
            On E : Exception Do
             Begin
              vMessageError := e.Message;
              vError        := True;
             End;
           End;
           If vMessageError <> '' Then
            DWParams.ItemsString['MessageError'].AsString := vMessageError;
           DWParams.ItemsString['Error'].AsBoolean        := vError;
          End;
         Break;
        End;
      End;
    End;
  End;
End;

Procedure TRESTServicePooler.ApplyUpdatesJSON(ServerMethodsClass : TComponent;
                                              Var Pooler         : String;
                                              Var DWParams       : TDWParams;
                                              ConnectionDefs     : TConnectionDefs;
                                              hEncodeStrings     : Boolean;
                                              AccessTag          : String);
Var
 I             : Integer;
 vTempJSON     : TJSONValue;
 vError        : Boolean;
 vSQL,
 vMessageError : String;
 DWParamsD     : TDWParams;
Begin
 DWParamsD := Nil;
 If ServerMethodsClass <> Nil Then
  Begin
   For I := 0 To ServerMethodsClass.ComponentCount -1 Do
    Begin
     If ServerMethodsClass.Components[i] is TRESTDWPoolerDB Then
      Begin
       If UpperCase(Pooler) = UpperCase(Format('%s.%s', [ServerMethodsClass.ClassName, ServerMethodsClass.Components[i].Name])) then
        Begin
         If Trim(TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag) <> '' Then
          Begin
           If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag <> AccessTag Then
            Begin
             DWParams.ItemsString['MessageError'].AsString := 'Invalid Access tag...';
             DWParams.ItemsString['Error'].AsBoolean       := True;
             Exit;
            End;
          End;
         If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver <> Nil Then
          Begin
           vError   := DWParams.ItemsString['Error'].AsBoolean;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.Encoding          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).Encoding;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.EncodeStringsJSON := hEncodeStrings;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsEmpty2Null    := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsEmpty2Null;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim2Len      := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim2Len;
           If DWParams.ItemsString['Params'] <> Nil Then
            Begin
             DWParamsD := TDWParams.Create;
             DWParamsD.FromJSON(DWParams.ItemsString['Params'].Value);
            End;
           If DWParams.ItemsString['SQL'] <> Nil Then
            vSQL := DWParams.ItemsString['SQL'].Value;
           Try
            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.PrepareConnection(ConnectionDefs);
            vTempJSON := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.ApplyUpdates(DWParams.ItemsString['Massive'].Value,
                                                                                                    vSQL,
                                                                                                    DWParamsD, vError, vMessageError);
           Except
            On E : Exception Do
             Begin
              vMessageError := e.Message;
              vError        := True;
             End;
           End;
           If DWParamsD <> Nil Then
            DWParamsD.Free;
           If vMessageError <> '' Then
            DWParams.ItemsString['MessageError'].AsString := vMessageError;
           DWParams.ItemsString['Error'].AsBoolean        := vError;
           If DWParams.ItemsString['Result'] <> Nil Then
            Begin
             If vTempJSON <> Nil Then
              Begin
               DWParams.ItemsString['Result'].SetValue(vTempJSON.ToJSON, DWParams.ItemsString['Result'].Encoded);
               vTempJSON.Free;
              End
             Else
              DWParams.ItemsString['Result'].SetValue('');
            End;
          End;
         Break;
        End;
      End;
    End;
  End;
End;

Procedure TRESTServicePooler.ExecuteCommandJSON(ServerMethodsClass : TComponent;
                                                Var Pooler         : String;
                                                Var DWParams       : TDWParams;
                                                ConnectionDefs     : TConnectionDefs;
                                                hEncodeStrings     : Boolean;
                                                AccessTag          : String);
Var
 I         : Integer;
 vError,
 vExecute  : Boolean;
 vTempJSON,
 vMessageError : String;
 DWParamsD     : TDWParams;
Begin
 DWParamsD := Nil;
 vTempJSON := '';
 If ServerMethodsClass <> Nil Then
  Begin
   For I := 0 To ServerMethodsClass.ComponentCount -1 Do
    Begin
     If ServerMethodsClass.Components[i] is TRESTDWPoolerDB Then
      Begin
       If UpperCase(Pooler) = UpperCase(Format('%s.%s', [ServerMethodsClass.ClassName, ServerMethodsClass.Components[i].Name])) then
        Begin
         If Trim(TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag) <> '' Then
          Begin
           If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag <> AccessTag Then
            Begin
             DWParams.ItemsString['MessageError'].AsString := 'Invalid Access tag...';
             DWParams.ItemsString['Error'].AsBoolean       := True;
             Exit;
            End;
          End;
         If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver <> Nil Then
          Begin
           vExecute := DWParams.ItemsString['Execute'].AsBoolean;
           vError   := DWParams.ItemsString['Error'].AsBoolean;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.Encoding          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).Encoding;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.EncodeStringsJSON := hEncodeStrings;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsEmpty2Null    := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsEmpty2Null;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim2Len      := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim2Len;
           If DWParams.ItemsString['Params'] <> Nil Then
            Begin
             DWParamsD := TDWParams.Create;
             DWParamsD.FromJSON(DWParams.ItemsString['Params'].Value);
            End;
           Try
            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.PrepareConnection(ConnectionDefs);
            If DWParamsD <> Nil Then
             Begin
              vTempJSON := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.ExecuteCommand(DWParams.ItemsString['SQL'].Value,
                                                                                                       DWParamsD, vError, vMessageError,
                                                                                                       vExecute);
              DWParamsD.Free;
             End
            Else
             vTempJSON := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.ExecuteCommand(DWParams.ItemsString['SQL'].Value,
                                                                                                      vError,
                                                                                                      vMessageError,
                                                                                                      vExecute);
           Except
            On E : Exception Do
             Begin
              vMessageError := e.Message;
              vError        := True;
             End;
           End;
           If vMessageError <> '' Then
            DWParams.ItemsString['MessageError'].AsString := vMessageError;
           DWParams.ItemsString['Error'].AsBoolean        := vError;
           If DWParams.ItemsString['Result'] <> Nil Then
            Begin
             If Not(vError) And(vTempJSON <> '') Then
              DWParams.ItemsString['Result'].SetValue(vTempJSON, DWParams.ItemsString['Result'].Encoded)
             Else
              DWParams.ItemsString['Result'].SetValue('');
            End;
          End;
         Break;
        End;
      End;
    End;
  End;
End;

Function TRESTServicePooler.ReturnContext(ServerMethodsClass      : TComponent;
                                          Var Pooler,
                                          vResult,
                                          urlContext,
                                          ContentType             : String;
                                          Var ServerContextStream : TMemoryStream;
                                          Var Error               : Boolean;
                                          Const DWParams          : TDWParams;
                                          Const RequestType       : TRequestType;
                                          mark                    : String) : Boolean;
Var
 I            : Integer;
 vRejected,
 vTagService,
 vDefaultPage : Boolean;
 vErrorMessage,
 vBaseHeader,
 vRootContext : String;
Begin
 Result        := False;
 vDefaultPage  := False;
 vRejected     := False;
 Error         := False;
 vTagService   := Result;
 vRootContext  := '';
 vErrorMessage := '';
 If (Pooler <> '') And (urlContext = '') Then
  Begin
   urlContext := Pooler;
   Pooler     := '';
  End;
 If ServerMethodsClass <> Nil Then
  Begin
   For I := 0 To ServerMethodsClass.ComponentCount -1 Do
    Begin
     If ServerMethodsClass.Components[i] is TDWServerContext Then
      Begin
       If (LowerCase(urlContext) = LowerCase(TDWServerContext(ServerMethodsClass.Components[i]).BaseContext)) Then
        Begin
         vRootContext := TDWServerContext(ServerMethodsClass.Components[i]).RootContext;
         If (Pooler = '') And (vRootContext <> '') Then
          Pooler := vRootContext;
         vTagService := TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler] <> Nil;
        End;
       If vTagService Then
        Begin
         Result   := False;
         If (RequestTypeToRoute(RequestType) In TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].Routes) Or
            (crAll in TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].Routes) Then
          Begin
           If Assigned(TDWServerContext(ServerMethodsClass.Components[i]).OnBeforeRenderer) Then
            TDWServerContext(ServerMethodsClass.Components[i]).OnBeforeRenderer(ServerMethodsClass.Components[i]);
           If Assigned(TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].OnAuthRequest) Then
            TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].OnAuthRequest(DWParams, vRejected, vErrorMessage);
           If Not vRejected Then
            Begin
             Result  := True;
             vResult := '';
             Try
              ContentType := TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].ContentType;
              If mark <> '' Then
               Begin
                vResult    := '';
                Result     := Assigned(TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].ContextRules);
                If Result Then
                 Begin
                  Result   := TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].ContextRules.Items.MarkByName[mark] <> Nil;
                  If Result Then
                   Begin
                    Result := Assigned(TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].ContextRules.Items.MarkByName[mark].OnRequestExecute);
                    If Result Then
                     Begin
                      ContentType := 'application/json';
                      TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].ContextRules.Items.MarkByName[mark].OnRequestExecute(DWParams, ContentType, vResult);
//                      vResult := utf8Encode(vResult);
                     End;
                   End;
                 End;
               End
              Else If Assigned(TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].ContextRules) Then
               Begin
                vBaseHeader := '';
                ContentType := TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].ContextRules.ContentType;
                vResult := TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].ContextRules.BuildContext(TDWServerContext(ServerMethodsClass.Components[i]).BaseHeader,
                                                                                                                                          TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].IgnoreBaseHeader);
               End
              Else
               Begin
                If Assigned(TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].OnBeforeCall) Then
                 TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].OnBeforeCall(TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler]);
                vDefaultPage := Not Assigned(TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].OnReplyRequest);
                If Not vDefaultPage Then
                 TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].OnReplyRequest(DWParams, ContentType, vResult, RequestType);
                If Assigned(TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].OnReplyRequestStream) Then
                 Begin
                  vDefaultPage := False;
                  TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].OnReplyRequestStream(DWParams, ContentType, ServerContextStream, RequestType);
                 End;
                If vDefaultPage Then
                 Begin
                  vBaseHeader := '';
                  If Assigned(TDWServerContext(ServerMethodsClass.Components[i]).BaseHeader) Then
                   vBaseHeader := TDWServerContext(ServerMethodsClass.Components[i]).BaseHeader.Text;
                  vResult := TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].DefaultHtml.Text;
                  If Assigned(TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].OnBeforeRenderer) Then
                   TDWServerContext(ServerMethodsClass.Components[i]).ContextList.ContextByName[Pooler].OnBeforeRenderer(vBaseHeader, ContentType, vResult, RequestType);
                 End;
               End;
             Except
              On E : Exception Do
               Begin
                vResult := e.Message;
                Error   := True;
                Exit;
               End;
             End;
            End
           Else
            Begin
             If vErrorMessage <> '' Then
              Begin
               ContentType := 'text/html';
               vResult     := vErrorMessage;
              End
             Else
              vResult   := 'The Requested URL was Rejected';
            End;
           If Trim(vResult) = '' Then
            vResult := TReplyOK;
          End
         Else
          vResult   := 'Request not found...';
         Break;
        End;
      End;
    End;
  End;
End;

Function TRESTServicePooler.ReturnEvent(ServerMethodsClass : TComponent;
                                        Var Pooler,
                                        vResult,
                                        urlContext         : String;
                                        Var DWParams       : TDWParams;
                                        Var JsonMode       : TJsonMode;
                                        Var ErrorCode      : Integer;
                                        Var ContentType    : String;
                                        Const RequestType  : TRequestType) : Boolean;
Var
 I             : Integer;
 vRejected,
 vTagService   : Boolean;
 vErrorMessage : String;
Begin
 Result        := False;
 vRejected     := False;
 vTagService   := Result;
 vErrorMessage := '';
 If ServerMethodsClass <> Nil Then
  Begin
   For I := 0 To ServerMethodsClass.ComponentCount -1 Do
    Begin
     If ServerMethodsClass.Components[i] is TDWServerEvents Then
      Begin
       If (LowerCase(urlContext) = LowerCase(TDWServerEvents(ServerMethodsClass.Components[i]).ContextName)) Or
          (LowerCase(urlContext) = LowerCase(ServerMethodsClass.Components[i].Name)) Then
        vTagService := TDWServerEvents(ServerMethodsClass.Components[i]).Events.EventByName[Pooler] <> Nil;
       If vTagService Then
        Begin
         Result   := True;
         JsonMode := jmPureJSON;
         If (RequestTypeToRoute(RequestType) In TDWServerEvents(ServerMethodsClass.Components[i]).Events.EventByName[Pooler].Routes) Or
            (crAll in TDWServerEvents(ServerMethodsClass.Components[i]).Events.EventByName[Pooler].Routes) Then
          Begin
           vResult := '';
           TDWServerEvents(ServerMethodsClass.Components[i]).CreateDWParams(Pooler, DWParams);
           If Assigned(TDWServerEvents(ServerMethodsClass.Components[i]).Events.EventByName[Pooler].OnAuthRequest) Then
            TDWServerEvents(ServerMethodsClass.Components[i]).Events.EventByName[Pooler].OnAuthRequest(DWParams, vRejected, vErrorMessage);
           If Not vRejected Then
            Begin
             Try
              If Assigned(TDWServerEvents(ServerMethodsClass.Components[i]).Events.EventByName[Pooler].OnBeforeExecute) Then
               TDWServerEvents(ServerMethodsClass.Components[i]).Events.EventByName[Pooler].OnBeforeExecute(TDWServerEvents(ServerMethodsClass.Components[i]).Events.EventByName[Pooler]);
              If Assigned(TDWServerEvents(ServerMethodsClass.Components[i]).Events.EventByName[Pooler].OnReplyEventByType) Then
               TDWServerEvents(ServerMethodsClass.Components[i]).Events.EventByName[Pooler].OnReplyEventByType(DWParams, vResult, RequestType)
              Else If Assigned(TDWServerEvents(ServerMethodsClass.Components[i]).Events.EventByName[Pooler].OnReplyEvent) Then
               TDWServerEvents(ServerMethodsClass.Components[i]).Events.EventByName[Pooler].OnReplyEvent(DWParams, vResult);
              JsonMode := TDWServerEvents(ServerMethodsClass.Components[i]).Events.EventByName[Pooler].JsonMode;
             Except
              On E : Exception Do
               Begin
                vResult := e.Message;
                Result  := True;
                If Not vTagService Then
                 ErrorCode := 500;
                Exit;
               End;
             End;
            End
           Else
            Begin
             If vErrorMessage <> '' Then
              Begin
               ContentType := 'text/html';
               vResult     := vErrorMessage;
              End
             Else
              vResult   := 'The Requested URL was Rejected';
             ErrorCode := 500;
            End;
           If Trim(vResult) = '' Then
            vResult := TReplyOK;
          End
         Else
          Begin
           vResult   := 'Request not found...';
           ErrorCode := 500;
          End;
         Break;
        End
       Else
        Begin
         vResult := 'Event not found...';
//         Result  := True;
        End;
      End;
    End;
  End;
 If Not vTagService Then
  ErrorCode := 404;
End;

Procedure TRESTServicePooler.GetEvents(ServerMethodsClass : TComponent;
                                       Var Pooler,
                                       urlContext         : String;
                                       Var DWParams       : TDWParams);
Var
 I         : Integer;
 vError    : Boolean;
 vTempJSON : String;
Begin
 vTempJSON := '';
 If ServerMethodsClass <> Nil Then
  Begin
   For I := 0 To ServerMethodsClass.ComponentCount -1 Do
    Begin
     If (ServerMethodsClass.Components[i] is TDWServerEvents) Then
      Begin
       If (LowerCase(urlContext) = LowerCase(TDWServerEvents(ServerMethodsClass.Components[i]).ContextName)) or
          (LowerCase(urlContext) = LowerCase(ServerMethodsClass.Components[i].Name)) Then
        Begin
         If vTempJSON = '' Then
          vTempJSON := Format('%s', [TDWServerEvents(ServerMethodsClass.Components[i]).Events.ToJSON])
         Else
          vTempJSON := vTempJSON + Format(', %s', [TDWServerEvents(ServerMethodsClass.Components[i]).Events.ToJSON]);
        End;
      End;
    End;
   vError := vTempJSON = '';
   If vError Then
    DWParams.ItemsString['MessageError'].AsString := 'Event Not Found';
   DWParams.ItemsString['Error'].AsBoolean        := vError;
   If DWParams.ItemsString['Result'] <> Nil Then
    Begin
     If vTempJSON <> '' Then
      DWParams.ItemsString['Result'].SetValue(Format('[%s]', [vTempJSON]), DWParams.ItemsString['Result'].Encoded)
     Else
      DWParams.ItemsString['Result'].SetValue('');
    End;
  End;
End;

Procedure TRESTServicePooler.OpenDatasets(ServerMethodsClass : TComponent;
                                          Var Pooler         : String;
                                          Var DWParams       : TDWParams;
                                          ConnectionDefs     : TConnectionDefs;
                                          hEncodeStrings     : Boolean;
                                          AccessTag          : String);
Var
 I         : Integer;
 vTempJSON : TJSONValue;
 vError    : Boolean;
 vMessageError : String;
Begin
 If ServerMethodsClass <> Nil Then
  Begin
   For I := 0 To ServerMethodsClass.ComponentCount -1 Do
    Begin
     If ServerMethodsClass.Components[i] is TRESTDWPoolerDB Then
      Begin
       If UpperCase(Pooler) = UpperCase(Format('%s.%s', [ServerMethodsClass.ClassName, ServerMethodsClass.Components[i].Name])) then
        Begin
         If Trim(TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag) <> '' Then
          Begin
           If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).AccessTag <> AccessTag Then
            Begin
             DWParams.ItemsString['MessageError'].AsString := 'Invalid Access tag...';
             DWParams.ItemsString['Error'].AsBoolean       := True;
             Exit;
            End;
          End;
         If TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver <> Nil Then
          Begin
           vError   := DWParams.ItemsString['Error'].AsBoolean;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.Encoding          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).Encoding;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.EncodeStringsJSON := hEncodeStrings;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim          := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsEmpty2Null    := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsEmpty2Null;
           TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.StrsTrim2Len      := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).StrsTrim2Len;
           Try
            TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.PrepareConnection(ConnectionDefs);
            vTempJSON := TRESTDWPoolerDB(ServerMethodsClass.Components[i]).RESTDriver.OpenDatasets(DWParams.ItemsString['LinesDataset'].Value,
                                                                                                   vError, vMessageError);
           Except
            On E : Exception Do
             Begin
              vMessageError := e.Message;
              vError        := True;
             End;
           End;
           If vMessageError <> '' Then
            DWParams.ItemsString['MessageError'].AsString := vMessageError;
           DWParams.ItemsString['Error'].AsBoolean        := vError;
           If DWParams.ItemsString['Result'] <> Nil Then
            Begin
             If vTempJSON <> Nil Then
              Begin
               DWParams.ItemsString['Result'].StringToBytes(vTempJSON.ToJSON, True);
               FreeAndNil(vTempJSON);
              End
             Else
              DWParams.ItemsString['Result'].SetValue('');
            End;
          End;
         Break;
        End;
      End;
    End;
  End;
End;

Function TRESTServicePooler.ServiceMethods(BaseObject              : TComponent;
                                           AContext                : TIdContext;
                                           UrlMethod               : String;
                                           Var urlContext          : String;
                                           Var DWParams            : TDWParams;
                                           Var JSONStr             : String;
                                           Var JsonMode            : TJsonMode;
                                           Var ErrorCode           : Integer;
                                           Var ContentType         : String;
                                           Var ServerContextCall   : Boolean;
                                           Var ServerContextStream : TMemoryStream;
                                           ConnectionDefs          : TConnectionDefs;
                                           hEncodeStrings          : Boolean;
                                           AccessTag               : String;
                                           WelcomeAccept           : Boolean;
                                           Const RequestType       : TRequestType;
                                           mark                    : String) : Boolean;
Var
 vJsonMSG,
 vResult,
 vResultIP,
 vUrlMethod   :  String;
 vError,
 vInvalidTag  : Boolean;
 JSONParam    : TJSONParam;
Begin
 Result       := False;
 vUrlMethod   := UpperCase(UrlMethod);
 If WelcomeAccept Then
  Begin
   If vUrlMethod = UpperCase('GetPoolerList') Then
    Begin
     Result     := True;
     GetPoolerList(BaseObject, vResult, AccessTag);
     If DWParams.ItemsString['Result'] = Nil Then
      Begin
       JSONParam                 := TJSONParam.Create(DWParams.Encoding);
       JSONParam.ParamName       := 'Result';
       JSONParam.ObjectDirection := odOut;
       DWParams.Add(JSONParam);
      End;
     DWParams.ItemsString['Result'].SetValue(vResult,
                                             DWParams.ItemsString['Result'].Encoded);
     JSONStr    := TReplyOK;
    End
   Else If vUrlMethod = UpperCase('GetServerEventsList') Then
    Begin
     Result     := True;
     GetServerEventsList(BaseObject, vResult, AccessTag);
     If DWParams.ItemsString['Result'] = Nil Then
      Begin
       JSONParam                 := TJSONParam.Create(DWParams.Encoding);
       JSONParam.ParamName       := 'Result';
       JSONParam.ObjectDirection := odOut;
       DWParams.Add(JSONParam);
      End;
     DWParams.ItemsString['Result'].SetValue(vResult,
                                             DWParams.ItemsString['Result'].Encoded);
     JSONStr    := TReplyOK;
    End
   Else If vUrlMethod = UpperCase('EchoPooler') Then
    Begin
     vJsonMSG := TReplyNOK;
     If DWParams.ItemsString['Pooler'] <> Nil Then
      Begin
       vResult    := DWParams.ItemsString['Pooler'].Value;
       EchoPooler(BaseObject, AContext, vResult, vResultIP, AccessTag, vInvalidTag);
       If DWParams.ItemsString['Result'] <> Nil Then
        DWParams.ItemsString['Result'].SetValue(vResultIP,
                                                DWParams.ItemsString['Result'].Encoded);
      End;
     Result     := vResultIP <> '';
     If Result Then
      JSONStr    := TReplyOK
     Else
      Begin
       If vInvalidTag Then
        JSONStr    := TReplyTagError
       Else
        JSONStr    := TReplyInvalidPooler;
       ErrorCode   := 404;
      End;
    End
   Else If vUrlMethod = UpperCase('ExecuteCommandPureJSON') Then
    Begin
     vResult    := DWParams.ItemsString['Pooler'].Value;
     ExecuteCommandPureJSON(BaseObject, vResult, DWParams, ConnectionDefs, hEncodeStrings, AccessTag);
     Result     := True;
     If Not(DWParams.ItemsString['Error'].AsBoolean) Then
      JSONStr    := TReplyOK
     Else
      Begin
       If DWParams.ItemsString['MessageError'] <> Nil Then
        JSONStr   := DWParams.ItemsString['MessageError'].AsString
       Else
        Begin
         JSONStr   := TReplyNOK;
         ErrorCode  := 500;
        End;
      End;
    End
   Else If vUrlMethod = UpperCase('ExecuteCommandJSON') Then
    Begin
     vResult    := DWParams.ItemsString['Pooler'].Value;
     ExecuteCommandJSON(BaseObject, vResult, DWParams, ConnectionDefs, hEncodeStrings, AccessTag);
     Result     := True;
     If Not(DWParams.ItemsString['Error'].AsBoolean) Then
      JSONStr    := TReplyOK
     Else
      Begin
       If DWParams.ItemsString['MessageError'] <> Nil Then
        JSONStr   := DWParams.ItemsString['MessageError'].AsString
       Else
        Begin
         JSONStr   := TReplyNOK;
         ErrorCode  := 500;
        End;
      End;
    End
   Else If vUrlMethod = UpperCase('ApplyUpdates') Then
    Begin
     vResult    := DWParams.ItemsString['Pooler'].Value;
     ApplyUpdatesJSON(BaseObject, vResult, DWParams, ConnectionDefs, hEncodeStrings, AccessTag);
     Result     := True;
     If Not(DWParams.ItemsString['Error'].AsBoolean) Then
      JSONStr    := TReplyOK
     Else
      Begin
       If DWParams.ItemsString['MessageError'] <> Nil Then
        JSONStr   := DWParams.ItemsString['MessageError'].AsString
       Else
        Begin
         JSONStr   := TReplyNOK;
         ErrorCode  := 500;
        End;
      End;
    End
   Else If vUrlMethod = UpperCase('ApplyUpdates_MassiveCache') Then
    Begin
     vResult    := DWParams.ItemsString['Pooler'].Value;
     ApplyUpdates_MassiveCache(BaseObject, vResult, DWParams, ConnectionDefs, hEncodeStrings, AccessTag);
     Result     := True;
     If Not(DWParams.ItemsString['Error'].AsBoolean) Then
      JSONStr    := TReplyOK
     Else
      Begin
       If DWParams.ItemsString['MessageError'] <> Nil Then
        JSONStr   := DWParams.ItemsString['MessageError'].AsString
       Else
        Begin
         JSONStr   := TReplyNOK;
         ErrorCode  := 500;
        End;
      End;
    End
   Else If vUrlMethod = UpperCase('InsertMySQLReturnID_PARAMS') Then
    Begin
     vResult    := DWParams.ItemsString['Pooler'].Value;
     InsertMySQLReturnID(BaseObject, vResult, DWParams, ConnectionDefs, hEncodeStrings, AccessTag);
     Result     := True;
     If Not(DWParams.ItemsString['Error'].AsBoolean) Then
      JSONStr    := TReplyOK
     Else
      Begin
       If DWParams.ItemsString['MessageError'] <> Nil Then
        JSONStr   := DWParams.ItemsString['MessageError'].AsString
       Else
        Begin
         JSONStr   := TReplyNOK;
         ErrorCode  := 500;
        End;
      End;
    End
   Else If vUrlMethod = UpperCase('InsertMySQLReturnID') Then
    Begin
     vResult    := DWParams.ItemsString['Pooler'].Value;
     InsertMySQLReturnID(BaseObject, vResult, DWParams, ConnectionDefs, hEncodeStrings, AccessTag);
     Result     := True;
     If Not(DWParams.ItemsString['Error'].AsBoolean) Then
      JSONStr    := TReplyOK
     Else
      Begin
       If DWParams.ItemsString['MessageError'] <> Nil Then
        JSONStr   := DWParams.ItemsString['MessageError'].AsString
       Else
        Begin
         JSONStr   := TReplyNOK;
         ErrorCode  := 500;
        End;
      End;
    End
   Else If vUrlMethod = UpperCase('OpenDatasets') Then
    Begin
     vResult     := DWParams.ItemsString['Pooler'].Value;
     OpenDatasets(BaseObject, vResult, DWParams, ConnectionDefs, hEncodeStrings, AccessTag);
     Result      := True;
     If Not(DWParams.ItemsString['Error'].AsBoolean) Then
      JSONStr    := TReplyOK
     Else
      Begin
       If DWParams.ItemsString['MessageError'] <> Nil Then
        JSONStr   := DWParams.ItemsString['MessageError'].AsString
       Else
        Begin
         JSONStr   := TReplyNOK;
         ErrorCode  := 500;
        End;
      End;
    End
   Else If vUrlMethod = UpperCase('GETEVENTS') Then
    Begin
     If DWParams.ItemsString['Error'] = Nil Then
      Begin
       JSONParam                 := TJSONParam.Create(DWParams.Encoding);
       JSONParam.ParamName       := 'Error';
       JSONParam.ObjectDirection := odOut;
       DWParams.Add(JSONParam);
      End;
     If DWParams.ItemsString['MessageError'] = Nil Then
      Begin
       JSONParam                 := TJSONParam.Create(DWParams.Encoding);
       JSONParam.ParamName       := 'MessageError';
       JSONParam.ObjectDirection := odOut;
       DWParams.Add(JSONParam);
      End;
     If DWParams.ItemsString['Result'] = Nil Then
      Begin
       JSONParam                 := TJSONParam.Create(DWParams.Encoding);
       JSONParam.ParamName       := 'Result';
       JSONParam.ObjectDirection := odOut;
       DWParams.Add(JSONParam);
      End;
     GetEvents(BaseObject, vResult, urlContext, DWParams);
     If Not(DWParams.ItemsString['Error'].AsBoolean) Then
      JSONStr    := TReplyOK
     Else
      Begin
       If DWParams.ItemsString['MessageError'] <> Nil Then
        JSONStr   := DWParams.ItemsString['MessageError'].AsString
       Else
        Begin
         JSONStr   := TReplyNOK;
         ErrorCode  := 500;
        End;
      End;
     Result      := JSONStr = TReplyOK;
    End
   Else
    Begin
     If ReturnEvent(BaseObject, vUrlMethod, vResult, urlContext, DWParams, JsonMode, ErrorCode, ContentType, RequestType) Then
      Begin
       JSONStr := vResult;
       Result  := JSONStr <> '';
      End
     Else
      Begin
       Result  := ReturnContext(BaseObject, vUrlMethod, vResult, urlContext, ContentType, ServerContextStream, vError, DWParams, RequestType, Mark);
       If Not (Result) Or (vError) Then
        Begin
         If Not WelcomeAccept Then
          Begin
           JsonMode   := jmPureJSON;
           JSONStr    := TReplyInvalidWelcome;
           ErrorCode  := 500;
          End
         Else
          Begin
           JsonMode   := jmPureJSON;
           JSONStr    := vResult;
           ErrorCode  := 404;
          End;
         If vError Then
          Result := True;
        End
       Else
        Begin
         ServerContextCall := True;
         JsonMode  := jmPureJSON;
         JSONStr   := vResult;
         ErrorCode := 200;
        End;
      End;
    End;
  End
 Else If (vUrlMethod = UpperCase('GETEVENTS')) And (Not (vForceWelcomeAccess)) Then
  Begin
   If DWParams.ItemsString['Error'] = Nil Then
    Begin
     JSONParam                 := TJSONParam.Create(DWParams.Encoding);
     JSONParam.ParamName       := 'Error';
     JSONParam.ObjectDirection := odOut;
     DWParams.Add(JSONParam);
    End;
   If DWParams.ItemsString['MessageError'] = Nil Then
    Begin
     JSONParam                 := TJSONParam.Create(DWParams.Encoding);
     JSONParam.ParamName       := 'MessageError';
     JSONParam.ObjectDirection := odOut;
     DWParams.Add(JSONParam);
    End;
   If DWParams.ItemsString['Result'] = Nil Then
    Begin
     JSONParam                 := TJSONParam.Create(DWParams.Encoding);
     JSONParam.ParamName       := 'Result';
     JSONParam.ObjectDirection := odOut;
     DWParams.Add(JSONParam);
    End;
   GetEvents(BaseObject, vResult, urlContext, DWParams);
   If Not(DWParams.ItemsString['Error'].AsBoolean) Then
    JSONStr    := TReplyOK
   Else
    Begin
     If DWParams.ItemsString['MessageError'] <> Nil Then
      JSONStr   := DWParams.ItemsString['MessageError'].AsString
     Else
      Begin
       JSONStr   := TReplyNOK;
       ErrorCode  := 500;
      End;
    End;
   Result      := JSONStr = TReplyOK;
  End
 Else If (Not (vForceWelcomeAccess)) Then
  Begin
   If Not WelcomeAccept Then
    JSONStr := TReplyInvalidWelcome
   Else
    Begin
     If ReturnEvent(BaseObject, vUrlMethod, vResult, urlContext, DWParams, JsonMode, ErrorCode, ContentType, RequestType) Then
      Begin
       JSONStr := vResult;
       Result  := JSONStr <> '';
      End
     Else
      Begin
       Result  := ReturnContext(BaseObject, vUrlMethod, vResult, urlContext, ContentType, ServerContextStream, vError, DWParams, RequestType, Mark);
       If Not (Result) Or (vError) Then
        Begin
         If Not WelcomeAccept Then
          Begin
           JsonMode   := jmPureJSON;
           JSONStr    := TReplyInvalidWelcome;
           ErrorCode  := 500;
          End
         Else
          Begin
           JsonMode   := jmPureJSON;
           JSONStr := vResult;
           ErrorCode  := 404;
           Result  := False;
          End;
        End
       Else
        Begin
         JsonMode  := jmPureJSON;
         JSONStr   := vResult;
         ErrorCode := 200;
        End;
      End;
    End;
  End
 Else
  Begin
   If Not WelcomeAccept Then
    JSONStr := TReplyInvalidWelcome
   Else
    JSONStr := TReplyNOK;
   Result  := False;
   If DWParams.ItemsString['Error']        <> Nil Then
    DWParams.ItemsString['Error'].AsBoolean := True;
   If DWParams.ItemsString['MessageError'] <> Nil Then
    DWParams.ItemsString['MessageError'].AsString := 'Invalid welcomemessage...'
   Else
    ErrorCode  := 500;
  End;
End;

Procedure TRESTServicePooler.aCommandGet(AContext      : TIdContext;
                                         ARequestInfo  : TIdHTTPRequestInfo;
                                         AResponseInfo : TIdHTTPResponseInfo);
Var
 I, vErrorCode      : Integer;
 JsonMode           : TJsonMode;
 DWParams           : TDWParams;
 vOldMethod,
 vBasePath,
 vObjectName,
 vAccessTag,
 vWelcomeMessage,
 boundary,
 startboundary,
 vReplyString,
 vReplyStringResult,
 urlContext,
 baseEventUnit,
 serverEventsName,
 Cmd, vmark,
 UrlMethod,
 tmp, JSONStr,
 ReturnObject,
 sFile,
 sContentType,
 vContentType,
 LocalDoc,
 sCharSet            : String;
 vdwConnectionDefs   : TConnectionDefs;
 vTempServerMethods  : TObject;
 newdecoder,
 Decoder             : TIdMessageDecoder;
 JSONParam           : TJSONParam;
 JSONValue           : TJSONValue;
 dwassyncexec,
 vFileExists,
 vSpecialServer,
 vServerContextCall,
 vTagReply,
 WelcomeAccept,
 encodestrings,
 compresseddata,
 msgEnd              : Boolean;
 ServerContextStream,
 mb2                 : TMemoryStream;
 mb,
 ms                  : TStringStream;
 RequestType         : TRequestType;
 Function GetParamsReturn(Params : TDWParams) : String;
 Var
  A, I : Integer;
 Begin
  A := 0;
  If Assigned(Params) Then
   Begin
    For I := 0 To Params.Count -1 Do
     Begin
      If TJSONParam(TList(Params).Items[I]^).ObjectDirection in [odOUT, odINOUT] Then
       Begin
        If A = 0 Then
         Result := TJSONParam(TList(Params).Items[I]^).ToJSON
        Else
         Result := Result + ', ' + TJSONParam(TList(Params).Items[I]^).ToJSON;
        Inc(A);
       End;
     End;
   End;
 End;
 Function ExcludeTag(Value : String) : String;
 Begin
  Result := Value;
  If (UpperCase(Copy (Value, InitStrPos, 3)) = 'GET')    or
     (UpperCase(Copy (Value, InitStrPos, 4)) = 'POST')   or
     (UpperCase(Copy (Value, InitStrPos, 3)) = 'PUT')    or
     (UpperCase(Copy (Value, InitStrPos, 6)) = 'DELETE') or
     (UpperCase(Copy (Value, InitStrPos, 5)) = 'PATCH')  Then
   Begin
    While (Result <> '') And (Result[InitStrPos] <> '/') Do
     Delete(Result, InitStrPos, 1);
   End;
  If Result <> '' Then
   If Result[InitStrPos] = '/' Then
    Delete(Result, InitStrPos, 1);
  Result := Trim(Result);
 End;
 Function GetFileOSDir(Value : String) : String;
 Begin
  Result := vBasePath + Value;
  {$IFDEF MSWINDOWS}
   Result := StringReplace(Result, '/', '\', [rfReplaceAll]);
  {$ENDIF}
 End;
 Function GetLastMethod(Value : String) : String;
 Var
  I : Integer;
 Begin
  Result := '';
  If Value <> '' Then
   Begin
    If Value[Length(Value) - FinalStrPos] <> '/' Then
     Begin
      For I := (Length(Value) - FinalStrPos) Downto InitStrPos Do
       Begin
        If Value[I] <> '/' Then
         Result := Value[I] + Result
        Else
         Break;
       End;
     End;
   End;
 End;
Begin
 JsonMode           := jmDataware;
 baseEventUnit      := '';
 vBasePath          := ExtractFilePath(ParamStr(0));
 vContentType       := vContentType;
 vdwConnectionDefs  := Nil;
 vTempServerMethods := Nil;
 DWParams           := Nil;
 ServerContextStream := Nil;
 compresseddata     := False;
 encodestrings      := False;
 vTagReply          := False;
 vServerContextCall := False;
 vErrorCode         := 200;
 Cmd := Trim(ARequestInfo.RawHTTPCommand);

 {$IFNDEF FPC}
  {$if CompilerVersion > 21}
   AResponseInfo.CustomHeaders.AddValue('Access-Control-Allow-Origin','*');
   If vCORS Then
    Begin
     AResponseInfo.CustomHeaders.AddValue('Access-Control-Allow-Methods','GET, POST, PATCH, PUT, DELETE, OPTIONS');
     AResponseInfo.CustomHeaders.AddValue('Access-Control-Allow-Headers','*');
    End;
  {$ELSE}
   AResponseInfo.CustomHeaders.Add     ('Access-Control-Allow-Origin=*');
   If vCORS Then
    Begin
     AResponseInfo.CustomHeaders.Add     ('Access-Control-Allow-Methods=GET, POST, PATCH, PUT, DELETE, OPTIONS');
     AResponseInfo.CustomHeaders.Add     ('*');
    End;
  {$IFEND}
 {$ELSE}
  AResponseInfo.CustomHeaders.AddValue('Access-Control-Allow-Origin','*');
  If vCORS Then
   Begin
    AResponseInfo.CustomHeaders.AddValue('Access-Control-Allow-Methods','GET, POST, PATCH, PUT, DELETE, OPTIONS');
    AResponseInfo.CustomHeaders.AddValue('*');
   End;
 {$ENDIF}
 sCharSet := '';
 If (UpperCase(Copy (Cmd, 1, 3)) = 'GET')    Then
  Begin
   If     (Pos('.HTML', UpperCase(Cmd)) > 0) Then
    Begin
     sContentType:='text/html';
	   sCharSet := 'utf-8';
    End
   Else If (Pos('.PNG', UpperCase(Cmd)) > 0) Then
    sContentType := 'image/png'
   Else If (Pos('.ICO', UpperCase(Cmd)) > 0) Then
    sContentType := 'image/ico'
   Else If (Pos('.GIF', UpperCase(Cmd)) > 0) Then
    sContentType := 'image/gif'
   Else If (Pos('.JPG', UpperCase(Cmd)) > 0) Then
    sContentType := 'image/jpg'
   Else If (Pos('.JS',  UpperCase(Cmd)) > 0) Then
    sContentType := 'application/javascript'
   Else If (Pos('.PDF', UpperCase(Cmd)) > 0) Then
    sContentType := 'application/pdf'
   Else If (Pos('.CSS', UpperCase(Cmd)) > 0) Then
    sContentType:='text/css';
   {$IFNDEF FPC}
    {$if CompilerVersion > 21}
     sFile := FRootPath+ARequestInfo.URI;
    {$ELSE}
     sFile := FRootPath+ARequestInfo.Command;
    {$IFEND}
   {$ELSE}
    sFile := FRootPath+ARequestInfo.URI;
   {$ENDIF}
   If DWFileExists(sFile, FRootPath) then
    Begin
     AResponseInfo.ContentType := GetMIMEType(sFile);
     {$IFNDEF FPC}
      {$if CompilerVersion > 21}
     	 If (sCharSet <> '') Then
        AResponseInfo.CharSet := sCharSet;
      {$IFEND}
     {$ENDIF}
     AResponseInfo.ContentStream := TIdReadFileExclusiveStream.Create(sFile);
     AResponseInfo.WriteContent;
     Exit;
    End;
  End;
 If Assigned(ARequestInfo.PostStream) Then
  Begin
   Try
    If ARequestInfo.PostStream.Size > 0 Then
     Begin
       ARequestInfo.PostStream.Position := 0;
       mb       := TStringStream.Create('');
       try
         mb.CopyFrom(ARequestInfo.PostStream, ARequestInfo.PostStream.Size);
         ARequestInfo.PostStream.Position := 0;
         mb.Position := 0;
         If pos('--', mb.DataString) > 0 Then
         Begin
           msgEnd   := False;
           boundary := ExtractHeaderSubItem(ARequestInfo.ContentType, 'boundary', QuoteHTTP);
           startboundary := '--' + boundary;
           Repeat
             tmp := ReadLnFromStream(ARequestInfo.PostStream, -1, True);
           until tmp = startboundary;
         End;
       finally
        if Assigned(mb) then
          FreeAndNil(mb);
       end;
     End;
    tmp := '';
   Except
    If Assigned(ServerContextStream) Then
     ServerContextStream.Free;
   End;
  End;
 Try
  Cmd := Trim(ARequestInfo.RawHTTPCommand);
  Cmd := StringReplace(Cmd, ' HTTP/1.0', '', [rfReplaceAll]);
  Cmd := StringReplace(Cmd, ' HTTP/1.1', '', [rfReplaceAll]);
  Cmd := StringReplace(Cmd, ' HTTP/2.0', '', [rfReplaceAll]);
  Cmd := StringReplace(Cmd, ' HTTP/2.1', '', [rfReplaceAll]);
  If ((vCORS) And (UpperCase(Copy (Cmd, 1, 7)) <> 'OPTIONS') And (vServerParams.HasAuthentication)) Or
     (vServerParams.HasAuthentication) Then
   Begin
    If Not ((ARequestInfo.AuthUsername = vServerParams.Username)  And
            (ARequestInfo.AuthPassword = vServerParams.Password)) Then
     Begin
      AResponseInfo.AuthRealm := AuthRealm;
      AResponseInfo.WriteContent;
      Exit;
     End;
   End;
  If (UpperCase(Copy (Cmd, 1, 3)) = 'GET' )   OR
     (UpperCase(Copy (Cmd, 1, 4)) = 'POST')   OR
     (UpperCase(Copy (Cmd, 1, 3)) = 'PUT')    OR
     (UpperCase(Copy (Cmd, 1, 4)) = 'DELE')   OR
     (UpperCase(Copy (Cmd, 1, 4)) = 'PATC')   Then
   Begin
    RequestType := rtGet;
    If (UpperCase(Copy (Cmd, 1, 4)) = 'POST')      Then
     RequestType := rtPost
    Else If (UpperCase(Copy (Cmd, 1, 3)) = 'PUT')  Then
     RequestType := rtPut
    Else If (UpperCase(Copy (Cmd, 1, 4)) = 'DELE') Then
     RequestType := rtDelete
    Else If (UpperCase(Copy (Cmd, 1, 4)) = 'PATC') Then
     RequestType := rtPatch;
    If ARequestInfo.URI <> '/favicon.ico' Then
     Begin
      If (ARequestInfo.Params.Count > 0) And (RequestType = rtGet) Then
       Begin
        DWParams := TServerUtils.ParseWebFormsParams (ARequestInfo.Params, ARequestInfo.URI,
                                                      ARequestInfo.QueryParams,
                                                      UrlMethod, urlContext, vmark, VEncondig);
        If DWParams <> Nil Then
         Begin
          If DWParams.ItemsString['dwwelcomemessage'] <> Nil Then
           vWelcomeMessage := DecodeStrings(DWParams.ItemsString['dwwelcomemessage'].AsString{$IFDEF FPC}, csUndefined{$ENDIF});
          If DWParams.ItemsString['accesstag'] <> Nil Then
           vAccessTag := DecodeStrings(DWParams.ItemsString['accesstag'].AsString{$IFDEF FPC}, csUndefined{$ENDIF});
          If DWParams.ItemsString['datacompression'] <> Nil Then
           compresseddata := StringToBoolean(DWParams.ItemsString['datacompression'].AsString);
          If DWParams.ItemsString['dwencodestrings'] <> Nil Then
           encodestrings  := StringToBoolean(DWParams.ItemsString['dwencodestrings'].AsString);
          If DWParams.ItemsString['dwservereventname'] <> Nil Then
           urlContext := DWParams.ItemsString['dwservereventname'].AsString;
         End;
       End
      Else
       Begin
        If (RequestType = rtGet) Then
         Begin
          DWParams  := TServerUtils.ParseRESTURL (ARequestInfo.URI, VEncondig, UrlMethod, urlContext, vmark);
          vOldMethod := UrlMethod;
          If DWParams <> Nil Then
           Begin
            If DWParams.ItemsString['dwwelcomemessage'] <> Nil Then
             vWelcomeMessage := DecodeStrings(DWParams.ItemsString['dwwelcomemessage'].AsString{$IFDEF FPC}, csUndefined{$ENDIF});
            If DWParams.ItemsString['accesstag'] <> Nil Then
             vAccessTag := DecodeStrings(DWParams.ItemsString['accesstag'].AsString{$IFDEF FPC}, csUndefined{$ENDIF});
            If DWParams.ItemsString['datacompression'] <> Nil Then
             compresseddata := StringToBoolean(DWParams.ItemsString['datacompression'].AsString);
            If DWParams.ItemsString['dwencodestrings'] <> Nil Then
             encodestrings  := StringToBoolean(DWParams.ItemsString['dwencodestrings'].AsString);
            If DWParams.ItemsString['dwservereventname'] <> Nil Then
             urlContext := DWParams.ItemsString['dwservereventname'].AsString;
           End;
         End
        Else
         Begin
          If Not(RequestType in [rtPatch, rtDelete]) Then
           Begin
            If Assigned(ARequestInfo.PostStream) Then
             Begin
              If (ARequestInfo.PostStream.Size > 0) And (boundary <> '') Then
               Begin
                Try
                 Repeat
                  decoder              := TIdMessageDecoderMIME.Create(nil);
                  TIdMessageDecoderMIME(decoder).MIMEBoundary := boundary;
                  decoder.SourceStream := ARequestInfo.PostStream;
                  decoder.FreeSourceStream := False;
                  decoder.ReadHeader;
      //            Inc(I);
                  Case Decoder.PartType of
                   mcptAttachment,
                   mcptText :
                    Begin
                     If (Decoder.PartType = mcptAttachment) And
                        (boundary <> '')                    Then
                      Begin
                       sFile := '';
                       If ServerContextStream = Nil Then
                        Begin
                         ServerContextStream := TMemoryStream.Create;
                         sFile := ExtractFileName(Decoder.FileName);
                         Decoder := Decoder.ReadBody(ServerContextStream, MsgEnd);  //TODO XyberX
                         ServerContextStream.Position := 0;
                        End;
                       If (DWParams = Nil) Then
                        Begin
                         If (ARequestInfo.Params.Count = 0) Then
                          Begin
                           DWParams           := TDWParams.Create;
                           DWParams.Encoding  := VEncondig;
                          End
                         Else
                          DWParams := TServerUtils.ParseWebFormsParams (ARequestInfo.Params, ARequestInfo.URI,
                                                                        ARequestInfo.QueryParams,
                                                                        UrlMethod, urlContext, vmark, VEncondig);
                        End;
                       vObjectName := 'dwfilename';
                       JSONParam   := TJSONParam.Create(DWParams.Encoding);
                       JSONParam.ParamName := vObjectName;
                       JSONParam.SetValue(sFile, JSONParam.Encoded);
                       DWParams.Add(JSONParam);
                       If Assigned(Decoder) Then
                        FreeAndNil(Decoder);
                      End
                     Else If Boundary <> '' Then
                      Begin
                      {$IFDEF FPC}
                       ms := TStringStream.Create('');
                      {$ELSE}
                       ms := TStringStream.Create(''{$if CompilerVersion > 21}, TEncoding.UTF8{$IFEND});
                      {$ENDIF}
                       ms.Position := 0;
                       newdecoder  := Decoder.ReadBody(ms, msgEnd);
                       tmp         := Decoder.Headers.Text;
                       FreeAndNil(Decoder);
                       Decoder     := newdecoder;
                       vObjectName := '';
                       If Decoder <> Nil Then
                        TIdMessageDecoderMIME(Decoder).MIMEBoundary := Boundary;
                       If pos('dwwelcomemessage', lowercase(tmp)) > 0 Then
                        vWelcomeMessage := DecodeStrings(ms.DataString{$IFDEF FPC}, csUndefined{$ENDIF})
                       Else If pos('accesstag', lowercase(tmp)) > 0 Then
                        vAccessTag := DecodeStrings(ms.DataString{$IFDEF FPC}, csUndefined{$ENDIF})
                       Else If pos('datacompression', lowercase(tmp)) > 0 Then
                        compresseddata := StringToBoolean(ms.DataString)
                       Else If pos('dwencodestrings', lowercase(tmp)) > 0 Then
                        encodestrings  := StringToBoolean(ms.DataString)
                       Else If pos('dwconnectiondefs', lowercase(tmp)) > 0 Then
                        Begin
                         vdwConnectionDefs   := TConnectionDefs.Create;
                         JSONValue           := TJSONValue.Create;
                         Try
                          JSONValue.Encoding  := VEncondig;
                          JSONValue.Encoded  := True;
                          JSONValue.LoadFromJSON(ms.DataString);
                          vdwConnectionDefs.LoadFromJSON(JSONValue.Value);
                         Finally
                          FreeAndNil(JSONValue);
                         End;
                        End
                       Else If pos('dwservereventname', lowercase(tmp)) > 0  Then
                        Begin
                         JSONValue           := TJSONValue.Create;
                         Try
                          JSONValue.Encoding  := VEncondig;
                          JSONValue.Encoded  := True;
                          JSONValue.LoadFromJSON(ms.DataString);
                          urlContext := JSONValue.Value;
                          If Pos('.', urlContext) > 0 Then
                           Begin
                            baseEventUnit := Copy(urlContext, InitStrPos, Pos('.', urlContext) - 1 - FinalStrPos);
                            urlContext    := Copy(urlContext, Pos('.', urlContext) + 1, Length(urlContext));
                           End;
                         Finally
                          FreeAndNil(JSONValue);
                         End;
                        End
                       Else
                        Begin
                         If DWParams = Nil Then
                          Begin
                           DWParams           := TDWParams.Create;
                           DWParams.Encoding  := VEncondig;
                          End;
                         vObjectName := Copy(lowercase(tmp), Pos('; name="', lowercase(tmp)) + length('; name="'),  length(lowercase(tmp)));
                         vObjectName := Copy(vObjectName, InitStrPos, Pos('"', vObjectName) -1);
                         JSONParam   := TJSONParam.Create(DWParams.Encoding);
                         JSONParam.FromJSON(ms.DataString);
                         JSONParam.ParamName := vObjectName;
                         DWParams.Add(JSONParam);
                        End;
                       {$IFNDEF FPC}ms.Size := 0;{$ENDIF}
                       FreeAndNil(ms);
                       {ico}
                       FreeAndNil(newdecoder);
                       {ico}
                      End
                     Else
                      Begin
                       DWParams := TServerUtils.ParseWebFormsParams (ARequestInfo.Params, ARequestInfo.URI,
                                                                     ARequestInfo.QueryParams,
                                                                     UrlMethod, urlContext, vmark, VEncondig);
                       FreeAndNil(Decoder);
                      End;
                    End;
                   mcptIgnore :
                    Begin
                     Try
                      If decoder <> Nil Then
                       FreeAndNil(decoder);
                      decoder := TIdMessageDecoderMIME.Create(Nil);
                      TIdMessageDecoderMIME(decoder).MIMEBoundary := boundary;
                     Finally
                     End;
                    End;
                   mcptEOF:
                    Begin
                     FreeAndNil(decoder);
                     msgEnd := True
                    End;
                   End;
                 Until (Decoder = Nil) Or (msgEnd);
                Finally
                 If decoder <> nil then
                  FreeAndNil(decoder);
                End;
               End
              Else
               Begin
                If (ARequestInfo.PostStream.Size > 0) And (boundary = '') Then
                 Begin
                  ARequestInfo.PostStream.Position := 0;
                  mb       := TStringStream.Create('');
                  mb.CopyFrom(ARequestInfo.PostStream, ARequestInfo.PostStream.Size);
                  ARequestInfo.PostStream.Position := 0;
                  mb.Position := 0;
                  Try
                   If DWParams = Nil Then
                    DWParams := TServerUtils.ParseWebFormsParams (ARequestInfo.Params, ARequestInfo.URI,
                                                                  ARequestInfo.QueryParams,
                                                                  UrlMethod, urlContext, vmark, VEncondig);
                   TServerUtils.ParseDWParamsURL(mb.DataString, VEncondig, DWParams);
                  Finally
                   mb.Free;
                  End;    
                 End;
                If ARequestInfo.RawHeaders.Count > 0 Then
                 Begin
                  For I := 0 To ARequestInfo.RawHeaders.Count -1 Do
                   Begin
                    tmp := ARequestInfo.RawHeaders.Names[I];
                    If pos('dwwelcomemessage', lowercase(tmp)) > 0 Then
                     vWelcomeMessage := DecodeStrings(ARequestInfo.RawHeaders.Values[tmp]{$IFDEF FPC}, csUndefined{$ENDIF})
                    Else If pos('accesstag', lowercase(tmp)) > 0 Then
                     vAccessTag := DecodeStrings(ARequestInfo.RawHeaders.Values[tmp]{$IFDEF FPC}, csUndefined{$ENDIF})
                    Else If pos('datacompression', lowercase(tmp)) > 0 Then
                     compresseddata := StringToBoolean(ARequestInfo.RawHeaders.Values[tmp])
                    Else If pos('dwencodestrings', lowercase(tmp)) > 0 Then
                     encodestrings  := StringToBoolean(ARequestInfo.RawHeaders.Values[tmp])
                    Else If pos('dwconnectiondefs', lowercase(tmp)) > 0 Then
                     Begin
                      vdwConnectionDefs   := TConnectionDefs.Create;
                      JSONValue           := TJSONValue.Create;
                      Try
                       JSONValue.Encoding  := VEncondig;
                       JSONValue.Encoded  := True;
                       JSONValue.LoadFromJSON(ARequestInfo.RawHeaders.Values[tmp]);
                       vdwConnectionDefs.LoadFromJSON(JSONValue.Value);
                      Finally
                       FreeAndNil(JSONValue);
                      End;
                     End
                    Else If pos('dwservereventname', lowercase(tmp)) > 0  Then
                     Begin
                      JSONValue           := TJSONValue.Create;
                      Try
                       JSONValue.Encoding  := VEncondig;
                       JSONValue.Encoded  := True;
                       JSONValue.LoadFromJSON(ARequestInfo.RawHeaders.Values[tmp]);
                       urlContext := JSONValue.Value;
                       If Pos('.', urlContext) > 0 Then
                        Begin
                         baseEventUnit := Copy(urlContext, InitStrPos, Pos('.', urlContext) - 1 - FinalStrPos);
                         urlContext    := Copy(urlContext, Pos('.', urlContext) + 1, Length(urlContext));
                        End;
                      Finally
                       FreeAndNil(JSONValue);
                      End;
                     End
                    Else
                     Begin
                      If DWParams = Nil Then
                       Begin
                        DWParams := TServerUtils.ParseWebFormsParams (ARequestInfo.Params, ARequestInfo.URI,
                                                                      ARequestInfo.QueryParams,
                                                                      UrlMethod, urlContext, vmark, VEncondig);
                       End;
                      JSONParam                 := TJSONParam.Create(DWParams.Encoding);
                      JSONParam.ObjectDirection := odIN;
                      JSONParam.ParamName       := lowercase(tmp);
                      tmp                       := ARequestInfo.RawHeaders.Values[tmp];
                      If Pos('{"ObjectType":"toParam", "Direction":"', tmp) = InitStrPos Then
                       JSONParam.FromJSON(tmp)
                      Else
                       JSONParam.AsString  := tmp;
                      DWParams.Add(JSONParam);
                     End;
                   End;
                 End;
               End;
             End
            Else
             Begin
              {$IFDEF FPC}
              If ARequestInfo.FormParams <> '' Then
               Begin
                If Trim(ARequestInfo.QueryParams) <> '' Then
                 DWParams := TServerUtils.ParseRESTURL (ARequestInfo.URI + '?' + ARequestInfo.QueryParams + '&' + ARequestInfo.FormParams, VEncondig, UrlMethod, urlContext, vmark)
                Else
                 DWParams := TServerUtils.ParseRESTURL (ARequestInfo.URI + '?' + ARequestInfo.FormParams, VEncondig, UrlMethod, urlContext, vmark);
               End
              Else
               DWParams := TServerUtils.ParseWebFormsParams (ARequestInfo.Params, ARequestInfo.URI,
                                                             ARequestInfo.QueryParams,
                                                             UrlMethod, urlContext, vmark, VEncondig);
              {$ELSE}
              If ARequestInfo.FormParams <> '' Then
               Begin
                If Trim(ARequestInfo.QueryParams) <> '' Then
                 DWParams := TServerUtils.ParseRESTURL (ARequestInfo.URI + '?' + ARequestInfo.QueryParams + '&' + ARequestInfo.FormParams, VEncondig, UrlMethod, urlContext, vmark)
                Else
                 DWParams := TServerUtils.ParseRESTURL (ARequestInfo.URI + '?' + ARequestInfo.FormParams, VEncondig, UrlMethod, urlContext, vmark);
               End
              Else
               DWParams := TServerUtils.ParseWebFormsParams (ARequestInfo.Params, ARequestInfo.URI,
                                                             ARequestInfo.QueryParams,
                                                             UrlMethod, urlContext, vmark, VEncondig);
              {$ENDIF}
             End;
           End
          Else
           Begin
            DWParams := TServerUtils.ParseWebFormsParams (ARequestInfo.Params, ARequestInfo.URI,
                                                          ARequestInfo.QueryParams,
                                                          UrlMethod, urlContext, vmark, VEncondig);
           End;
         End;
       End;
      WelcomeAccept     := True;
      If Assigned(vServerMethod) Then
       Begin
        vTempServerMethods:=vServerMethod.Create(nil);
        If vServerBaseMethod = TServerMethods Then
         Begin
          TServerMethods(vTempServerMethods).SetClientWelcomeMessage(vWelcomeMessage);
          If Assigned(TServerMethods(vTempServerMethods).OnWelcomeMessage) then
           TServerMethods(vTempServerMethods).OnWelcomeMessage(vWelcomeMessage, vAccessTag, vdwConnectionDefs, WelcomeAccept);
         End
        Else If vServerBaseMethod = TServerMethodDatamodule Then
         Begin
          TServerMethodDatamodule(vTempServerMethods).SetClientWelcomeMessage(vWelcomeMessage);
          If Assigned(TServerMethodDatamodule(vTempServerMethods).OnWelcomeMessage) then
           TServerMethodDatamodule(vTempServerMethods).OnWelcomeMessage(vWelcomeMessage, vAccessTag, vdwConnectionDefs, WelcomeAccept);
         End;
       End
      Else
       JSONStr := GetPairJSON(-5, 'Server Methods Cannot Assigned');
      Try
       If Assigned(vLastRequest) Then
        Begin
        {$IFNDEF FPC}
          {$IF CompilerVersion > 21}
          {$IFDEF WINDOWS}
           InitializeCriticalSection(vCriticalSection);
           EnterCriticalSection(vCriticalSection);
          {$ELSE}
           if Not Assigned(vCriticalSection) Then
            vCriticalSection := TCriticalSection.Create;
           vCriticalSection.Acquire;
          {$ENDIF}
         {$ELSE}
          if Not Assigned(vCriticalSection) Then
           vCriticalSection := TCriticalSection.Create;
          vCriticalSection.Acquire;
         {$IFEND}
         {$ELSE}
          InitCriticalSection(vCriticalSection);
          EnterCriticalSection(vCriticalSection);
         {$ENDIF}
          Try
          vLastRequest(ARequestInfo.UserAgent + #13#10 +
                      ARequestInfo.RawHTTPCommand);
         Finally
         {$IFNDEF FPC}
          {$IF CompilerVersion > 21}
          {$IFDEF WINDOWS}
           LeaveCriticalSection(vCriticalSection);
           DeleteCriticalSection(vCriticalSection);
          {$ELSE}
           vCriticalSection.Release;
           FreeAndNil(vCriticalSection);
          {$ENDIF}
         {$ELSE}
           vCriticalSection.Release;
           FreeAndNil(vCriticalSection);
         {$IFEND}
         {$ELSE}
          LeaveCriticalSection(vCriticalSection);
          DoneCriticalSection(vCriticalSection);
         {$ENDIF}
         End;
        End;
       If Assigned(vServerMethod) Then
        Begin
         If UrlMethod = '' Then
          Begin
           If ARequestInfo.URI <> '' Then
            Begin
             UrlMethod := Trim(ARequestInfo.URI);
             If UrlMethod <> '' Then
              If UrlMethod[1] = '/' then
               Delete(UrlMethod, 1, 1);
             If Pos('/', UrlMethod) > 0 then
              Begin
               urlContext := Copy(UrlMethod, 1, Pos('/', UrlMethod) -1);
               UrlMethod  := Copy(UrlMethod, Pos('/', UrlMethod) +1, Length(UrlMethod));
              End;
            End
           Else
            Begin
             While (Length(UrlMethod) > 0) Do
              Begin
               If Pos('/', UrlMethod) > 0 then
                Delete(UrlMethod, 1, 1)
               Else
                Begin
                 UrlMethod := Trim(UrlMethod);
                 Break;
                End;
              End;
            End;
          End;
         If (UrlMethod = '') And (urlContext = '') Then
          UrlMethod := vOldMethod;
         vSpecialServer := False;
         If vTempServerMethods <> Nil Then
          Begin
           AResponseInfo.ContentType   := 'application/json'; //'text';//'application/octet-stream';
           If UrlMethod = '' Then
            Begin
             vReplyString := TServerStatusHTML;
             vErrorCode   := 200;
             AResponseInfo.ContentType := 'text/html';
            End
           Else
            Begin
             If VEncondig = esUtf8 Then
              AResponseInfo.ContentEncoding       := 'utf-8'
             Else
              AResponseInfo.ContentEncoding       := 'ansi';
             dwassyncexec := False;
             If DWParams.ItemsString['dwassyncexec'] <> Nil Then
              Begin
               dwassyncexec := DWParams.ItemsString['dwassyncexec'].AsBoolean;
               If dwassyncexec Then
                Begin
                 AResponseInfo.ResponseNo               := 200;
                 {$IFNDEF FPC}
                  {$IF CompilerVersion > 21}
                   mb                                   := TStringStream.Create(AssyncCommandMSG{$IFNDEF FPC}{$IF CompilerVersion > 21}, TEncoding.UTF8{$IFEND}{$ENDIF});
                   mb.Position                          := 0;
                   AResponseInfo.FreeContentStream      := True;
                   AResponseInfo.ContentStream          := mb;
                   AResponseInfo.ContentStream.Position := 0;
                   AResponseInfo.ContentLength          := mb.Size;
                  {$ELSE}
                   AResponseInfo.ContentLength         := -1;
                   AResponseInfo.ContentText            := vReplyString;
                   AResponseInfo.WriteHeader;
                  {$IFEND}
                 {$ELSE}
                  mb                                   := TStringStream.Create(AssyncCommandMSG);
                  mb.Position                          := 0;
                  AResponseInfo.FreeContentStream      := True;
                  AResponseInfo.ContentStream          := mb;
                  AResponseInfo.ContentStream.Position := 0;
                  AResponseInfo.ContentLength          := -1;//mb.Size;
                 {$ENDIF}
                End;
              End;
             If Not ServiceMethods(TComponent(vTempServerMethods), AContext,     UrlMethod, urlContext, DWParams,
                                   JSONStr, JsonMode, vErrorCode,  vContentType, vServerContextCall, ServerContextStream,
                                   vdwConnectionDefs,  EncodeStrings, vAccessTag, WelcomeAccept, RequestType, vMark) Or (lowercase(vContentType) = 'application/php') Then
              Begin
               If Not dwassyncexec Then
                Begin
                 {$IFNDEF FPC}
                  {$IF Defined(HAS_FMX)}
                   {$IFDEF WINDOWS}
                    If Assigned(CGIRunner) Then
                     Begin
                      If Pos('.php', UrlMethod) <> 0 then
                       Begin
                        vContentType := 'text/html';
                        LocalDoc := CGIRunner.PHPIniPath + CGIRunner.PHPModule;
                       End;
                      For I := 0 To CGIRunner.CGIExtensions.Count -1 Do
                       Begin
                        If Pos(LowerCase(CGIRunner.CGIExtensions[I]), LowerCase(aRequestInfo.Document)) <> 0 then
                         Begin
                          LocalDoc := ExpandFilename(FRootPath + aRequestInfo.Document);
                          Break;
                         End;
                       End;
                      If LocalDoc <> '' then
                       Begin
                        vSpecialServer := True;
                        If DWFileExists(LocalDoc) Then
                         Begin
                          CGIRunner.Execute(LocalDoc, AContext, aRequestInfo, aResponseInfo, FRootPath, JSONStr);
                          vTagReply := True;
                         End
                        Else
                         Begin
                          aResponseInfo.ContentText := '<H1><center>Script not found</center></H1>';
                          aResponseInfo.ResponseNo := 404; // Not found
                         End;
                       End;
                      End;
                   {$ENDIF}
                  {$ELSE}
                   If Assigned(CGIRunner) Then
                    Begin
                     If Pos('.php', UrlMethod) <> 0 then
                      Begin
                       vContentType := 'text/html';
                       LocalDoc := CGIRunner.PHPIniPath + CGIRunner.PHPModule;
                      End;
                     For I := 0 To CGIRunner.CGIExtensions.Count -1 Do
                      Begin
                       If Pos(LowerCase(CGIRunner.CGIExtensions[I]), LowerCase(aRequestInfo.Document)) <> 0 then
                        Begin
                         LocalDoc := ExpandFilename(FRootPath + aRequestInfo.Document);
                         Break;
                        End;
                      End;
                     If (LocalDoc <> '') or (lowercase(vContentType) = 'application/php') then
                      Begin
                       vSpecialServer := True;
                       If DWFileExists(LocalDoc, FRootPath) or (lowercase(vContentType) = 'application/php') Then
                        Begin
                         CGIRunner.Execute(LocalDoc, AContext, aRequestInfo, aResponseInfo, FRootPath, JSONStr);
                         vTagReply := True;
                        End
                       Else
                        Begin
                         aResponseInfo.ContentText := '<H1><center>Script not found</center></H1>';
                         aResponseInfo.ResponseNo := 404; // Not found
                        End;
                      End;
                     End;
                  {$IFEND}
                 {$ENDIF}
                 If Not vSpecialServer Then
                  Begin
                   If ARequestInfo.URI <> '' Then
                    sFile := GetFileOSDir(ExcludeTag(tmp + ARequestInfo.URI))
                   Else
                    sFile := GetFileOSDir(ExcludeTag(Cmd));
                   vFileExists := DWFileExists(sFile, FRootPath);
                   If Not vFileExists Then
                    Begin
                     tmp := '';
                     If ARequestInfo.Referer <> '' Then
                      tmp := GetLastMethod(ARequestInfo.Referer);
                     If ARequestInfo.URI <> '' Then
                      sFile := GetFileOSDir(ExcludeTag(tmp + ARequestInfo.URI))
                     Else
                      sFile := GetFileOSDir(ExcludeTag(Cmd));
                     vFileExists := DWFileExists(sFile, FRootPath);
                    End;
                   vTagReply := vFileExists or scripttags(ExcludeTag(Cmd));
                   If vTagReply Then
                    Begin
                     AResponseInfo.FreeContentStream      := True;
                     AResponseInfo.ContentType            := GetMIMEType(sFile);
                     If scripttags(ExcludeTag(Cmd)) and Not vFileExists Then
                      AResponseInfo.ContentStream         := TMemoryStream.Create
                     Else
                      AResponseInfo.ContentStream         := TIdReadFileExclusiveStream.Create(sFile);
                     AResponseInfo.ContentStream.Position := 0;
                     AResponseInfo.ResponseNo             := 200;
                     AResponseInfo.WriteContent;
                    End;
                  End;
                End;
              End;
            End;
          End;
        End;
       Try
        If Not dwassyncexec Then
         Begin
          If Not vTagReply Then
           Begin
            If VEncondig = esUtf8 Then
             AResponseInfo.Charset := 'utf-8'
            Else
             AResponseInfo.Charset := 'ansi';
            If vContentType <> '' Then
             AResponseInfo.ContentType := vContentType;
            If Not vServerContextCall Then
             Begin
              If (UrlMethod <> '') Then
               Begin
                If JsonMode = jmDataware Then
                 Begin
                  If Trim(JSONStr) <> '' Then
                   Begin
                    If Not(((Pos('{', JSONStr) > 0)   And
                            (Pos('}', JSONStr) > 0))  Or
                           ((Pos('[', JSONStr) > 0)   And
                            (Pos(']', JSONStr) > 0))) Then
                     Begin
                      If Not((JSONStr[InitStrPos] = '"') And
                             (JSONStr[Length(JSONStr)] = '"')) Then
                       JSONStr := '"' + JSONStr + '"';
                     End;
                   End;
                  vReplyString := Format(TValueDisp, [GetParamsReturn(DWParams), JSONStr]);
                 End
                Else If JsonMode in [jmPureJSON, jmMongoDB] Then
                 Begin
                  If DWParams.CountOutParams < 2 Then
                   ReturnObject := '%s'
                  Else
                   ReturnObject := '[%s]';
                  vReplyString                        := Format(ReturnObject, [JSONStr]); //GetParamsReturn(DWParams)]);
                  If vReplyString = '' Then
                   vReplyString                       := JSONStr;
                 End;
               End;
  {
              If VEncondig = esUtf8 Then
               AResponseInfo.Charset := 'utf-8'
              Else
               AResponseInfo.Charset := 'ansi';
  }
              AResponseInfo.ResponseNo             := vErrorCode;
              If compresseddata Then
               Begin
                ZCompressStr(vReplyString, vReplyStringResult);
                mb                                 := TStringStream.Create(vReplyStringResult{$IFNDEF FPC}{$IF CompilerVersion > 21}, TEncoding.UTF8{$IFEND}{$ENDIF});
                mb.Position                          := 0;
                AResponseInfo.FreeContentStream      := True;
                AResponseInfo.ContentStream          := mb;
                AResponseInfo.ContentStream.Position := 0;
                AResponseInfo.ContentLength          := mb.Size;
               End
              Else
               Begin
                {$IFNDEF FPC}
                 {$IF CompilerVersion > 21}
                  mb                                 := TStringStream.Create(vReplyString{$IFNDEF FPC}{$IF CompilerVersion > 21}, TEncoding.UTF8{$IFEND}{$ENDIF});
                  mb.Position                          := 0;
                  AResponseInfo.FreeContentStream      := True;
                  AResponseInfo.ContentStream          := mb;
                  AResponseInfo.ContentStream.Position := 0;
                  AResponseInfo.ContentLength          := mb.Size;
                 {$ELSE}
                  AResponseInfo.ContentLength         := -1;
                  AResponseInfo.ContentText            := vReplyString;
                  AResponseInfo.WriteHeader;
                 {$IFEND}
                {$ELSE}
                 mb                                 := TStringStream.Create(vReplyString);
                 mb.Position                          := 0;
                 AResponseInfo.FreeContentStream      := True;
                 AResponseInfo.ContentStream          := mb;
                 AResponseInfo.ContentStream.Position := 0;
                 AResponseInfo.ContentLength          := -1;//mb.Size;
                {$ENDIF}
               End;
             End
            Else
             Begin
              LocalDoc := '';
              If TEncodeSelect(VEncondig) = esUtf8 Then
               AResponseInfo.Charset := 'utf-8'
              Else If TEncodeSelect(VEncondig) = esASCII Then
               AResponseInfo.Charset := 'ansi';
              If Not vSpecialServer Then
               Begin
                AResponseInfo.ResponseNo             := vErrorCode;
                If ServerContextStream <> Nil Then
                 Begin
                  AResponseInfo.FreeContentStream      := True;
                  AResponseInfo.ContentStream          := ServerContextStream;
                  AResponseInfo.ContentStream.Position := 0;
                  AResponseInfo.ContentLength          := ServerContextStream.Size;
                 End
                Else
                 Begin
                  {$IFDEF FPC}
                   mb                                   := TStringStream.Create(JSONStr);
                   mb.Position                          := 0;
                   AResponseInfo.FreeContentStream      := True;
                   AResponseInfo.ContentStream          := mb;
                   AResponseInfo.ContentStream.Position := 0;
                   AResponseInfo.ContentLength          := -1;//mb.Size;
                  {$ELSE}
                   {$IF CompilerVersion > 21}
                    mb                                   := TStringStream.Create(JSONStr{$IFNDEF FPC}{$IF CompilerVersion > 21}, TEncoding.UTF8{$IFEND}{$ENDIF});
                    mb.Position                          := 0;
                    AResponseInfo.FreeContentStream      := True;
                    AResponseInfo.ContentStream          := mb;
                    AResponseInfo.ContentStream.Position := 0;
                    AResponseInfo.ContentLength          := mb.Size;
                   {$ELSE}
                    AResponseInfo.ContentLength          := -1;
                    AResponseInfo.ContentText            := JSONStr;
                    AResponseInfo.WriteHeader;
                   {$IFEND}
  //                 AResponseInfo.ContentLength          := -1; //Length(JSONStr);
  //                 AResponseInfo.ContentText            := JSONStr;
                  {$ENDIF}
                 End;
               End;
             End;
    //        AResponseInfo.ContentText            := mb.Datastring;
    //        AResponseInfo.WriteHeader;
            AResponseInfo.WriteContent;
           End;
         End;
       Finally
//        FreeAndNil(mb);
       End;
       If Assigned(vLastResponse) Then
        Begin
         {$IFNDEF FPC}
          {$IF CompilerVersion > 21}
          {$IFDEF WINDOWS}
           InitializeCriticalSection(vCriticalSection);
           EnterCriticalSection(vCriticalSection);
          {$ELSE}
           if Not Assigned(vCriticalSection) Then
            vCriticalSection := TCriticalSection.Create;
           vCriticalSection.Acquire;
          {$ENDIF}
         {$ELSE}
           if Not Assigned(vCriticalSection) Then
            vCriticalSection := TCriticalSection.Create;
           vCriticalSection.Acquire;
         {$IFEND}
         {$ELSE}
          InitCriticalSection(vCriticalSection);
          EnterCriticalSection(vCriticalSection);
         {$ENDIF}
         Try
          vLastResponse(vReplyString);
         Finally
         {$IFNDEF FPC}
          {$IF CompilerVersion > 21}
          {$IFDEF WINDOWS}
           LeaveCriticalSection(vCriticalSection);
           DeleteCriticalSection(vCriticalSection);
          {$ELSE}
           vCriticalSection.Release;
           FreeAndNil(vCriticalSection);
          {$ENDIF}
         {$ELSE}
           vCriticalSection.Release;
           FreeAndNil(vCriticalSection);
         {$IFEND}
         {$ELSE}
          LeaveCriticalSection(vCriticalSection);
          DoneCriticalSection(vCriticalSection);
         {$ENDIF}
         End;
        End;
      Finally
       If Assigned(vServerMethod) Then
        If Assigned(vTempServerMethods) Then
         Begin
          Try
           {$IFDEF POSIX} //no linux nao precisa libertar porque é [weak]
           {$ELSE}
           FreeAndNil(vTempServerMethods); //.free;
           {$ENDIF}
          Except
          End;
         End;
      End;
     End;
   End;
 Finally
  If Assigned(DWParams) Then
   FreeAndNil(DWParams);
  If Assigned(vdwConnectionDefs) Then
   FreeAndNil(vdwConnectionDefs);
 End;
End;

Procedure TRESTServicePooler.aCommandOther(AContext      : TIdContext;
                                           ARequestInfo  : TIdHTTPRequestInfo;
                                           AResponseInfo : TIdHTTPResponseInfo);
Begin
 aCommandGet(AContext, ARequestInfo, AResponseInfo);
end;

{$IFDEF FPC}
{$ELSE}
{$IF Defined(HAS_FMX)}
{$IFDEF WINDOWS}
Procedure TRESTServicePooler.SetISAPIRunner(Value : TDWISAPIRunner);
Begin
 If Assigned(vDWISAPIRunner) And (Value = Nil) Then
  vDWISAPIRunner.Server := Nil;
 vDWISAPIRunner := Value;
 If Assigned(vDWISAPIRunner) Then
  vDWISAPIRunner.Server := HTTPServer;
End;
Procedure TRESTServicePooler.SetCGIRunner  (Value : TDWCGIRunner);
Begin
 If Assigned(vDWCGIRunner) And (Value = Nil) Then
  vDWCGIRunner.Server := Nil;
 vDWCGIRunner := Value;
 If Assigned(vDWCGIRunner) Then
  vDWCGIRunner.Server := HTTPServer;
End;
{$ENDIF}
{$ELSE}
Procedure TRESTServicePooler.SetISAPIRunner(Value : TDWISAPIRunner);
Begin
 If Assigned(vDWISAPIRunner) And (Value = Nil) Then
  vDWISAPIRunner.Server := Nil;
 vDWISAPIRunner := Value;
 If Assigned(vDWISAPIRunner) Then
  vDWISAPIRunner.Server := HTTPServer;
End;

Procedure TRESTServicePooler.SetCGIRunner  (Value : TDWCGIRunner);
Begin
If Assigned(vDWCGIRunner) And (Value = Nil) Then
vDWCGIRunner.Server := Nil;
vDWCGIRunner := Value;
If Assigned(vDWCGIRunner) Then
vDWCGIRunner.Server := HTTPServer;
End;
{$IFEND}
{$ENDIF}

Constructor TRESTServicePooler.Create(AOwner: TComponent);
Begin
 Inherited;
 vProxyOptions                   := TProxyOptions.Create;
 HTTPServer                      := TIdHTTPServer.Create(Nil);
 lHandler                        := TIdServerIOHandlerSSLOpenSSL.Create;
 {$IFDEF FPC}
 HTTPServer.OnCommandGet         := @aCommandGet;
 HTTPServer.OnCommandOther       := @aCommandOther;
 {$ELSE}
 HTTPServer.OnCommandGet         := aCommandGet;
 HTTPServer.OnCommandOther       := aCommandOther;
 {$ENDIF}
 vServerParams                   := TServerParams.Create(Self);
 vActive                         := False;
 vServerParams.HasAuthentication := True;
 vServerParams.UserName          := 'testserver';
 vServerParams.Password          := 'testserver';
 vServerContext                  := 'restdataware';
 VEncondig                       := esUtf8;
 vServicePort                    := 8082;
 vForceWelcomeAccess             := False;
 vCORS                           := False;
 FRootPath                       := '/';
End;

Destructor TRESTServicePooler.Destroy;
Begin
 FreeAndNil(vProxyOptions);
 HTTPServer.Active := False;
 HTTPServer.Free;
 vServerParams.Free;
 lHandler.Free;
 Inherited;
End;

Function TRESTServicePooler.GetSecure : Boolean;
Begin
 Result:= vActive And (HTTPServer.IOHandler is TIdServerIOHandlerSSLBase);
End;

Procedure TRESTServicePooler.GetSSLPassWord(var Password: {$IFNDEF FPC}{$IF (CompilerVersion = 23) OR (CompilerVersion = 24)}
                                                                                     AnsiString
                                                                                    {$ELSE}
                                                                                     String
                                                                                    {$IFEND}
                                                                                    {$ELSE}
                                                                                     String
                                                                                    {$ENDIF});
Begin
 Password := aSSLPrivateKeyPassword;
End;

Procedure TRESTServicePooler.SetActive(Value : Boolean);
Begin
 If (Value)                   And
    (Not (HTTPServer.Active)) Then
  Begin
   Try
    If (ASSLPrivateKeyFile <> '')     And
       (ASSLPrivateKeyPassword <> '') And
       (ASSLCertFile <> '')           Then
     Begin
      lHandler.SSLOptions.Method                := aSSLMethod;
      lHandler.SSLOptions.SSLVersions           :=aSSLVersions;
      {$IFDEF FPC}
      lHandler.OnGetPassword                    := @GetSSLPassword;
      lHandler.OnVerifyPeer                     := @SSLVerifyPeer;
      {$ELSE}
      lHandler.OnGetPassword                    := GetSSLPassword;
      lHandler.OnVerifyPeer                     := SSLVerifyPeer;
      {$ENDIF}
      lHandler.SSLOptions.CertFile              := ASSLCertFile;
      lHandler.SSLOptions.KeyFile               := ASSLPrivateKeyFile;
      lHandler.SSLOptions.VerifyMode            := vSSLVerifyMode;
      lHandler.SSLOptions.VerifyDepth           := vSSLVerifyDepth;
      HTTPServer.IOHandler := lHandler;
     End
    Else
     HTTPServer.IOHandler  := Nil;
    If HTTPServer.Bindings.Count > 0 Then
     HTTPServer.Bindings.Clear;
    HTTPServer.Bindings.DefaultPort := vServicePort;
    HTTPServer.DefaultPort          := vServicePort;
    HTTPServer.Active               := True;
   Except
    On E : Exception do
     Begin
      Raise Exception.Create(PChar(E.Message));
     End;
   End;
  End
 Else If Not(Value) Then
  HTTPServer.Active := False;
 vActive := HTTPServer.Active;
End;


Procedure TRESTServicePooler.SetServerMethod(Value : TComponentClass);
Begin
 If (Value.ClassParent      = TServerMethods) Or
    (Value                  = TServerMethods) Then
  Begin
   vServerMethod     := Value;
   vServerBaseMethod := TServerMethods;
  End
 Else If (Value.ClassParent = TServerMethodDatamodule) Or
         (Value             = TServerMethodDatamodule) Then
  Begin
   vServerMethod := Value;
   vServerBaseMethod := TServerMethodDatamodule;
  End;
End;

function TRESTServicePooler.SSLVerifyPeer(Certificate: TIdX509; AOk: Boolean;
  ADepth, AError: Integer): Boolean;
begin
  if ADepth = 0 then
  begin
    Result := AOk;
  end
  else
  begin
    Result := True;
  end
end;

{TThread_Request}
constructor TThread_Request.Create;
begin
inherited Create(True);
FHttpRequest:=TIdHTTP.Create(NIL);
FreeOnTerminate := True;
vTransparentProxy               := TIdProxyConnectionInfo.Create;
//RBody :=TStringStream.Create;
Params := TDWParams.Create;
end;

destructor TThread_Request.Destroy; //override;
begin
  FHttpRequest.Free;
  //RBody.free;
  Params.Free;
  FreeAndNil(vTransparentProxy);
  inherited Destroy;

end;


Procedure TThread_Request.SetParams(HttpRequest:TIdHTTP);
Begin
 HttpRequest.Request.BasicAuthentication := vAuthentication;
 If HttpRequest.Request.BasicAuthentication Then
  Begin
   If HttpRequest.Request.Authentication = Nil Then
    HttpRequest.Request.Authentication         := TIdBasicAuthentication.Create;
   HttpRequest.Request.Authentication.Password := vPassword;
   HttpRequest.Request.Authentication.Username := vUserName;
  End;
// HttpRequest.ProxyParams := vTransparentProxy;
 HttpRequest.ProxyParams.BasicAuthentication   := vTransparentProxy.BasicAuthentication;
 HttpRequest.ProxyParams.ProxyUsername         := vTransparentProxy.ProxyUsername;
 HttpRequest.ProxyParams.ProxyServer           := vTransparentProxy.ProxyServer;
 HttpRequest.ProxyParams.ProxyPassword         := vTransparentProxy.ProxyPassword;
 HttpRequest.ProxyParams.ProxyPort             := vTransparentProxy.ProxyPort;
 HttpRequest.ReadTimeout                       := vRequestTimeout;
End;

Function TThread_Request.GetHttpRequest : TIdHTTP;
Begin
 Result := FHttpRequest;
End;

procedure TThread_Request.Execute;
Var
 SResult,
 vResult,
 vURL,
 vTpRequest    : String;
 vResultParams : TMemoryStream;
 StringStream  : TStringStream;
 SendParams    : TIdMultipartFormDataStream;
 ss            : TStringStream;
 {$IF Defined(HAS_FMX)} //Alterado para IOS Brito
 Procedure SetData( InputValue     : String;
                   Var ParamsData : TDWParams;
                   Var ResultJSON : String);
 Var
  bJsonOBJ,
  bJsonValue   : TJsonObject;
  bJsonOBJTemp : TJSONArray;
  JSONParam,
  JSONParamNew : TJSONParam;
  A, InitPos   : Integer;
  vValue,
  vTempValue   : String;
 Begin
  ResultJSON := InputValue;
  If Pos(', "RESULT":[', InputValue) = 0 Then
   Exit;
  Try
   InitPos    := Pos('"RESULT":[', InputValue) + 10;
   vTempValue := Copy(InputValue, InitPos, Pos(']}', InputValue) - InitPos);
   Delete(InputValue, InitPos, Pos(']}', InputValue) - InitPos);
   If Params <> Nil Then
    Begin
      bJsonValue:= TJSONObject.ParseJSONValue(InputValue) as TJSONObject;
      bJsonOBJTemp:= bJsonValue.GetValue('PARAMS') as TJSONArray;
     If bJsonOBJTemp.count > 0 Then
      Begin
       For A := 0 To bJsonValue.count -1 Do
        Begin
         bJsonOBJ :=  bJsonOBJTemp.get(A) as TJSONObject;
         If bJsonOBJ.count = 0 Then
          Continue;
         JSONParam := TJSONParam.Create(vRSCharset);
         Try
          JSONParam.ParamName       := stringreplace(bJsonOBJ.pairs[4].JsonString.tostring, '"', '',[rfReplaceAll, rfIgnoreCase]);
          JSONParam.ObjectValue     := GetValueType(bJsonOBJ.getvalue('ValueType').value);
          JSONParam.ObjectDirection := GetDirectionName(bJsonOBJ.getvalue('Direction').value);
          JSONParam.Encoded         := GetBooleanFromString(bJsonOBJ.GetValue('Encoded').value);
          If JSONParam.Encoded Then
           DecodeStrings(stringreplace(bJsonOBJ.pairs[4].JsonValue.tostring, '"', '',[rfReplaceAll, rfIgnoreCase]) )
          Else
           vValue := stringreplace(bJsonOBJ.pairs[4].JsonValue.tostring, '"', '',[rfReplaceAll, rfIgnoreCase]);
          JSONParam.SetValue(vValue, JSONParam.Encoded);
          bJsonOBJ.Free;
          //parametro criandos no servidor
          If ParamsData.ItemsString[JSONParam.ParamName] = Nil Then
           Begin
            JSONParamNew           := TJSONParam.Create(ParamsData.Encoding);
            JSONParamNew.ParamName := JSONParam.ParamName;
            JSONParamNew.SetValue(JSONParam.Value, JSONParam.Encoded);
            ParamsData.Add(JSONParamNew);
           End
          Else If Not (JSONParam.Binary) Then
           ParamsData.ItemsString[JSONParam.ParamName].Value := JSONParam.Value //, JSONParam.Encoded);
          Else
           ParamsData.ItemsString[JSONParam.ParamName].SetValue(vValue, JSONParam.Encoded);
         Finally
          JSONParam.Free;
         End;
        End;
      End;
     bJsonValue.Free;
    End;
  Finally
   If vTempValue <> '' Then
    Begin
     ResultJSON := vTempValue;
    End;
  End;
 End;
 {$ELSE}
 Procedure SetData(InputValue     : String;
                   Var ParamsData : TDWParams;
                   Var ResultJSON : String);
 Var
  bJsonOBJ,
  bJsonValue   : TJsonObject;
  bJsonOBJTemp : TJSONArray;
  JSONParam,
  JSONParamNew : TJSONParam;
  A, InitPos   : Integer;
  vValue,
  vTempValue   : String;
 Begin
  ResultJSON := InputValue;
  If Pos(', "RESULT":[', InputValue) = 0 Then
   Exit;
  Try
   InitPos    := Pos('"RESULT":[', InputValue) + 10;
   vTempValue := Copy(InputValue, InitPos, Pos(']}', InputValue) - InitPos);
   Delete(InputValue, InitPos, Pos(']}', InputValue) - InitPos);
   If Params <> Nil Then
    Begin
     bJsonValue    := TJsonObject.Create(InputValue);
     InputValue    := '';
     bJsonOBJTemp  := bJsonValue.getJSONArray(bJsonValue.names.get(0).ToString); //TJSONArray.Create(bJsonValue.opt(bJsonValue.names.get(0).ToString).ToString);
     If bJsonOBJTemp.length > 0 Then
      Begin
       For A := 0 To bJsonValue.names.length -1 Do
        Begin
         bJsonOBJ := bJsonOBJTemp.getJSONObject(A); //TJsonObject.Create(bJsonOBJTemp.get(A).ToString);
         If Length(bJsonOBJ.opt(bJsonOBJ.names.get(0).ToString).ToString) = 0 Then
          Continue;
         JSONParam := TJSONParam.Create(vRSCharset);
         Try
          JSONParam.ParamName       := bJsonOBJ.names.get(4).ToString;
          JSONParam.ObjectValue     := GetValueType(bJsonOBJ.opt(bJsonOBJ.names.get(3).ToString).ToString);
          JSONParam.ObjectDirection := GetDirectionName(bJsonOBJ.opt(bJsonOBJ.names.get(1).ToString).ToString);
          JSONParam.Encoded         := GetBooleanFromString(bJsonOBJ.opt(bJsonOBJ.names.get(2).ToString).ToString);
          If JSONParam.Encoded Then
           vValue := DecodeStrings(bJsonOBJ.opt(bJsonOBJ.names.get(4).ToString).ToString{$IFDEF FPC}, csUndefined{$ENDIF})
          Else
           vValue := bJsonOBJ.opt(bJsonOBJ.names.get(4).ToString).ToString;
          JSONParam.SetValue(vValue, JSONParam.Encoded);
//          bJsonOBJ.Free;
          //parametro criandos no servidor
          If ParamsData.ItemsString[JSONParam.ParamName] = Nil Then
           Begin
            JSONParamNew           := TJSONParam.Create(ParamsData.Encoding);
            JSONParamNew.ParamName := JSONParam.ParamName;
            JSONParamNew.SetValue(JSONParam.Value, JSONParam.Encoded);
            ParamsData.Add(JSONParamNew);
           End
          Else If Not (JSONParam.Binary) Then
           ParamsData.ItemsString[JSONParam.ParamName].Value := JSONParam.Value //, JSONParam.Encoded);
          Else
           ParamsData.ItemsString[JSONParam.ParamName].SetValue(vValue, JSONParam.Encoded);
         Finally
          JSONParam.Free;
         End;
        End;
      End;
     bJsonValue.Free;
    End;
  Finally
   If vTempValue <> '' Then
    Begin
     ResultJSON := vTempValue;
    End;
  End;
 End;
 {$IFEND}
 Procedure SetParamsValues(DWParams : TDWParams; SendParamsData : TIdMultipartFormDataStream);
 Var
  I : Integer;
 Begin
  If DWParams <> Nil Then
   Begin
    For I := 0 To DWParams.Count -1 Do
     Begin
      If DWParams.Items[I].ObjectValue in [ovWideMemo, ovBytes, ovVarBytes, ovBlob,
                                           ovMemo,   ovGraphic, ovFmtMemo,  ovOraBlob, ovOraClob] Then
       Begin
        ss := TStringStream.Create(DWParams.Items[I].ToJSON);
        SendParamsData.AddObject(DWParams.Items[I].ParamName, 'multipart/form-data', HttpRequest.Request.Charset, ss);
       End
      Else
       SendParamsData.AddFormField(DWParams.Items[I].ParamName, DWParams.Items[I].ToJSON);
     End;
   End;
 End;
Begin
 If Assigned(FCallSendEvent) Then
      {$IFDEF FPC}
       FCallSendEvent(EventData  ,
                        Params ,
                       EventType  ,
                       jmDataware,
                       '',
                       FCallBack  );
      {$ELSE}
       {$if CompilerVersion > 21}
        Synchronize(CurrentThread, Procedure ()
                                 Begin
                                     FCallSendEvent(EventData  ,
                                                      Params ,
                                                     EventType  ,
                                                     jmDataware,
                                                     '',
                                                     FCallBack  );
                                 End);
       {$ELSE}
               FCallSendEvent(EventData  ,
                        Params ,
                       EventType  ,
                       jmDataware,
                       '',
                       FCallBack  );
       {$IFEND}
      {$ENDIF}
     Terminate;
     exit;

 // INICIO   TThread_Request
 ss            := Nil;
 SendParams    := Nil;
 vResultParams := TMemoryStream.Create;
 If vTypeRequest = trHttp Then
  vTpRequest := 'http'
 Else If vTypeRequest = trHttps Then
  vTpRequest := 'https';
 SetParams(FHttpRequest);
 Try
  vURL := LowerCase(Format(UrlBase, [vTpRequest, vHost, vPort, vUrlPath])) + EventData;
  If vRSCharset = esUtf8 Then
   HttpRequest.Request.Charset := 'utf-8'
  Else If vRSCharset = esASCII Then
   HttpRequest.Request.Charset := 'ansi';
  Case EventType Of
   seGET :
    Begin
     HttpRequest.Request.ContentType := 'application/json';
     SResult := HttpRequest.Get(EventData);
     If Assigned(FCallBack) Then
      {$IFDEF FPC}
       FCallBack(SResult, Params);
      {$ELSE}
       {$if CompilerVersion > 21}
        Synchronize(CurrentThread, Procedure ()
                                 Begin
                                  FCallBack(SResult,Params)
                                 End);
       {$ELSE}
        FCallBack(SResult, Params);
       {$IFEND}
      {$ENDIF}
     Terminate;
    End;
   sePOST,
   sePUT,
   seDELETE :
    Begin;
     If EventType = sePOST Then
      Begin
       If Params <> Nil Then
        Begin
         SendParams := TIdMultiPartFormDataStream.Create;
         SetParamsValues(Params, SendParams);
         HttpRequest.Request.ContentType     := 'application/x-www-form-urlencoded';
         HttpRequest.Request.ContentEncoding := 'multipart/form-data';
         StringStream          := TStringStream.Create('');
         HttpRequest.Post(vURL, SendParams, StringStream);
         StringStream.Position := 0;
        End
       Else
        Begin
         HttpRequest.Request.ContentType := 'application/json';
         HttpRequest.Request.ContentEncoding := '';
         vResult      := HttpRequest.Get(EventData);
         StringStream := TStringStream.Create(vResult);
        End;
//       StringStream.WriteBuffer(#0' ', 1);
       StringStream.Position := 0;
       Try
        SetData(StringStream.DataString, Params, SResult);
        If Assigned(FCallBack) Then
         {$IFDEF FPC}
          FCallBack(SResult, Params);
         {$ELSE}
          {$if CompilerVersion > 21}
           Synchronize(CurrentThread, Procedure
                                      Begin
                                       FCallBack(SResult,Params)
                                      End);
          {$ELSE}
           FCallBack(SResult, Params);
          {$IFEND}
         {$ENDIF}
        Terminate;
       Finally
        StringStream.Free;
       End;
      End
     Else If EventType = sePUT Then
      Begin
       If SendParams = Nil Then
        SendParams := TIdMultiPartFormDataStream.Create;
       HttpRequest.Request.ContentType := 'application/x-www-form-urlencoded';
       StringStream  := TStringStream.Create('');
       HttpRequest.Post(vURL, SendParams, StringStream);
       StringStream.WriteBuffer(#0' ', 1);
       StringStream.Position := 0;
       Try
        SetData(StringStream.DataString, Params, SResult);
        If Assigned(FCallBack) Then
         {$IFDEF FPC}
          FCallBack(SResult, Params);
         {$ELSE}
          {$if CompilerVersion > 21}
           Synchronize(CurrentThread, Procedure
                                      Begin
                                       FCallBack(SResult,Params)
                                      End);
          {$ELSE}
           FCallBack(SResult, Params);
          {$IFEND}
         {$ENDIF}
        Terminate;
       Finally
        StringStream.Free;
       End;
      End
     Else If EventType = seDELETE Then
      Begin
       Try
         HttpRequest.Request.ContentType := 'application/json';
         HttpRequest.Delete(vURL);
         SResult := GetPairJSON('OK', 'DELETE COMMAND OK');
         If Assigned(FCallBack) Then
          {$IFDEF FPC}
           FCallBack(SResult, Params);
          {$ELSE}
           {$if CompilerVersion > 21}
            Synchronize(CurrentThread, Procedure
                                       Begin
                                        FCallBack(SResult,Params)
                                       End);
           {$IFEND}
          {$ENDIF}
         Terminate;
       Except
        On e:exception Do
         Begin
          SResult := GetPairJSON('NOK', e.Message);
          If Assigned(FCallBack) Then
           {$IFDEF FPC}
            FCallBack(SResult, Params);
           {$ELSE}
            {$if CompilerVersion > 21}
             Synchronize(CurrentThread, Procedure
                                        Begin
                                         FCallBack(SResult,Params);
                                        End);
            {$IFEND}
           {$ENDIF}
          Terminate;
         End;
       End;
      End;
    End;
  End;
 Except
  On E : Exception Do
   Begin
    {Todo: Acrescentado}
    Raise Exception.Create(e.Message);
   End;
 End;
 vResultParams.Free;
end;

{ TRESTDWServiceNotification }

Constructor TRESTDWServiceNotification.Create(AOwner : TComponent);
Begin
 Inherited;
 vGarbageTime        := 60000;
 vQueueNotifications := 50;
End;

Destructor TRESTDWServiceNotification.Destroy;
Begin

 Inherited;
End;

Function TRESTDWServiceNotification.GetAccessTag : String;
Begin
 Result := vAccessTag;
End;

Function TRESTDWServiceNotification.GetNotifications(LastNotification : String) : String;
Begin

End;

Procedure TRESTDWServiceNotification.SetAccessTag(Value : String);
Begin
 vAccessTag := Value;
End;

end.

