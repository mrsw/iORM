unit iORM.DB.ConnectionDef.MySql;

interface

uses
  System.Classes,
  iORM.DB.Interfaces,
  iORM.CommonTypes,
  iORM.DBBuilder.Interfaces,
  iORM.DB.ConnectionDef

  ;


type
  // Class for MySQL connection
  TioMySQLConnectionDef = class(TioDBConnectionDef)
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
    property Password;
    property Persistent;
    property Pooled;
    property Port;
    property Server;
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


{ TioMySQLConnectionDef }

constructor TioMySQLConnectionDef.Create(AOwner: TComponent);
begin
  inherited;
  Port := 3306;
end;

function TioMySQLConnectionDef.DBBuilder: IioDBBuilderEngine;
begin
  inherited
  // Only to elevate the method visibility
end;

function TioMySQLConnectionDef.GetConnectionDef: IIoConnectionDef;
begin
  Result := TioConnectionManager.NewMySQLConnectionDef(Server, GetFullPathDatabase, UserName, Password, CharSet,
    AsDefault, Persistent, Pooled, Name);
end;

procedure TioMySQLConnectionDef.InitConnectionDef;
begin
  inherited;

  // Port
  ConnectionDef.Params.Values['Port'] := Port.ToString;
end;

end.
