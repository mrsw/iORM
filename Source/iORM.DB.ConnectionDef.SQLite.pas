unit iORM.DB.ConnectionDef.SQLite;

interface

uses
  System.Classes,
  iORM.DB.ConnectionDef,
  iORM.DB.Interfaces,
  iORM.CommonTypes,
  iORM.DBBuilder.Interfaces

  ;

type
  // Class for SQLite connection
  TioSQLiteConnectionDef = class(TioDBConnectionDef)
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
    property Collation;
    property Database;
    property DatabaseStdFolder;
    property Encrypt;
    property NewPassword;
    property Password;
    property Persistent;
    property Pooled;
    property QuotedIdentifiers;
    // Events
    property OnAfterCreateOrAlterDB;
    property OnBeforeCreateOrAlterDB;
  end;

implementation

uses
  System.IOUtils, iORM.DB.ConnectionContainer, System.SysUtils,
  iORM, iORM.DBBuilder.Factory;

{ TioSQLiteConnectionDef }

constructor TioSQLiteConnectionDef.Create(AOwner: TComponent);
begin
  inherited;

  QuotedIdentifiers := True;
end;

function TioSQLiteConnectionDef.DBBuilder: IioDBBuilderEngine;
begin
  inherited
  // Only to elevate the method visibility
end;

function TioSQLiteConnectionDef.GetConnectionDef: IIoConnectionDef;
begin
  Result := TioConnectionManager.NewSQLiteConnectionDef(GetFullPathDatabase, AsDefault, Persistent, Pooled, Name);
end;

procedure TioSQLiteConnectionDef.InitConnectionDef;
begin
  inherited;

  // Encript
  if not Encrypt.IsEmpty then
    ConnectionDef.Params.Values['Encrypt'] := Encrypt;
  // NewPassword
  if not NewPassword.IsEmpty then
    ConnectionDef.Params.NewPassword := NewPassword;
  // Password
  if not Password.IsEmpty then
    ConnectionDef.Params.Password := Password;
end;

end.
