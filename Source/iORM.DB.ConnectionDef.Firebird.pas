unit iORM.DB.ConnectionDef.Firebird;

interface

uses
  System.Classes,
  iORM.DB.Interfaces,
  iORM.CommonTypes,
  iORM.DBBuilder.Interfaces,
  iORM.DB.ConnectionDef

  ;


type
  // Class for Firebird connection
  TioFirebirdConnectionDef = class(TioDBConnectionDef)
  strict private
    FSQLDialect: TioSQLDialect;
  protected
    function GetConnectionDef: IIoConnectionDef; override;
    procedure InitConnectionDef; override;
  public
    constructor Create(AOwner: TComponent); override;

    function DBBuilder: IioDBBuilderEngine; override;
    // Properties
    property ConnectionDef;
  published
    // Properties
    property AsDefault;
    property AutoCreateDB;
    property CharSet;
    property Collation;
    property Database;
    property DatabaseStdFolder;
    property OSAuthent;
    property Password;
    property Persistent;
    property Pooled;
    property Port;
    property Protocol;
    property QuotedIdentifiers;
    property Server;
    property SQLDialect: TioSQLDialect read FSQLDialect write FSQLDialect;
    property UserName;
    // Events
    property OnAfterCreateOrAlterDB;
    property OnBeforeCreateOrAlterDB;
  end;

implementation

uses
  System.IOUtils,
  System.SysUtils,
  iORM.DB.ConnectionContainer,
  iORM,
  iORM.DBBuilder.Factory

  ;

{ TioFirebirdConnectionDef }

constructor TioFirebirdConnectionDef.Create(AOwner: TComponent);
begin
  inherited;
  FSQLDialect := TioSQLDialect.sqlDialect3;
  QuotedIdentifiers := True;
  Port := 3050;
end;

function TioFirebirdConnectionDef.DBBuilder: IioDBBuilderEngine;
begin
  inherited
  // Only to elevate the method visibility
end;

function TioFirebirdConnectionDef.GetConnectionDef: IIoConnectionDef;
begin
  Result := TioConnectionManager.NewFirebirdConnectionDef(Server, GetFullPathDatabase, UserName, Password, CharSet,
    AsDefault, Persistent, Pooled, Name);
end;

procedure TioFirebirdConnectionDef.InitConnectionDef;
begin
  inherited;

  // OSAuthent
  case OSAuthent of
    TioOSAuthent.oaNo:
      ConnectionDef.Params.Values['OSAuthent'] := 'No';
    TioOSAuthent.oaYes:
      ConnectionDef.Params.Values['OSAuthent'] := 'Yes';
  end;
  // Port
  ConnectionDef.Params.Values['Port'] := Port.ToString;
  // Protocol
  case Protocol of
    TioProtocol.pTCPIP:
      ConnectionDef.Params.Values['Protocol'] := 'TCPIP';
    TioProtocol.pLocal:
      ConnectionDef.Params.Values['Protocol'] := 'Local';
    TioProtocol.pNetBEUI:
      ConnectionDef.Params.Values['Protocol'] := 'NetBEUI';
    TioProtocol.pSPX:
      ConnectionDef.Params.Values['Protocol'] := 'SPX';
  end;
  // SQL dialect
  case SQLDialect of
    TioSQLDialect.sqlDialect3:
      ConnectionDef.Params.Values['SQLDialect'] := '3';
    TioSQLDialect.sqlDialect2:
      ConnectionDef.Params.Values['SQLDialect'] := '2';
    TioSQLDialect.sqlDialect1:
      ConnectionDef.Params.Values['SQLDialect'] := '1';
  end;
  // OpenMode
  if AutoCreateDB.Enabled then
    ConnectionDef.Params.Values['OpenMode'] := 'OpenOrCreate'
  else
    ConnectionDef.Params.Values['OpenMode'] := 'Open';
end;

end.
