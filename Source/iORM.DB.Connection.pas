{
  ****************************************************************************
  *                                                                          *
  *           iORM - (interfaced ORM)                                        *
  *                                                                          *
  *           Copyright (C) 2015-2023 Maurizio Del Magno                     *
  *                                                                          *
  *           mauriziodm@levantesw.it                                        *
  *           mauriziodelmagno@gmail.com                                     *
  *           https://github.com/mauriziodm/iORM.git                         *
  *                                                                          *
  ****************************************************************************
  *                                                                          *
  * This file is part of iORM (Interfaced Object Relational Mapper).         *
  *                                                                          *
  * Licensed under the GNU Lesser General Public License, Version 3;         *
  *  you may not use this file except in compliance with the License.        *
  *                                                                          *
  * iORM is free software: you can redistribute it and/or modify             *
  * it under the terms of the GNU Lesser General Public License as published *
  * by the Free Software Foundation, either version 3 of the License, or     *
  * (at your option) any later version.                                      *
  *                                                                          *
  * iORM is distributed in the hope that it will be useful,                  *
  * but WITHOUT ANY WARRANTY; without even the implied warranty of           *
  * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            *
  * GNU Lesser General Public License for more details.                      *
  *                                                                          *
  * You should have received a copy of the GNU Lesser General Public License *
  * along with iORM.  If not, see <http://www.gnu.org/licenses/>.            *
  *                                                                          *
  ****************************************************************************
}
unit iORM.DB.Connection;

interface
{$I ioGlobalDef.inc}   // iORM global definitions

uses
  iORM.DB.Interfaces,
  FireDAC.Stan.Def,
  FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteWrapper.Stat,
  FireDAC.Phys.FB,
  FireDAC.Stan.ExprFuncs,
  FireDAC.Stan.Intf,
  FireDAC.Phys,
  FireDAC.DApt,
  FireDAC.UI.Intf,
{$IFDEF CONSOLE}  // Non pi� necessaria???
  FireDAC.ConsoleUI.Wait,
{$ENDIF}
  FireDAC.Stan.Async,
  FireDAC.Comp.UI;


type

  // This is the base class for all connections
  TioConnectionBase = class(TInterfacedObject, IioConnection)
  strict private
    FConnectionInfo: IioConnectionInfo;
    FTransactionCounter: Integer;
  strict protected
    procedure DoStartTransaction; virtual; abstract;
    procedure DoCommitTransaction; virtual; abstract;
    procedure DoRollbackTransaction; virtual; abstract;
  public
    constructor Create(const AConnectionInfo: IioConnectionInfo);
    function IsDBConnection: Boolean;
    function IsHttpConnection: Boolean;
    function AsDBConnection: IioConnectionDB; virtual;
    function AsHttpConnection: IioConnectionHttp; virtual;
    function GetConnectionInfo: IioConnectionInfo;
    function InTransaction: Boolean; virtual; abstract;
    procedure StartTransaction;
    procedure Commit;
    procedure Rollback;
  end;

  // This is the specialized class for DB connections
  TioConnectionDB = class(TioConnectionBase, IioConnectionDB)
  strict private
    FConnection: TioInternalSqlConnection;
    FFDGUIxWaitCursor: TFDGUIxWaitCursor;
    FQueryContainer: IioQueryContainer;
    FTransactionTimestamp: TDateTime;
    function GetCurrentTimeStamp: TDateTime;
  strict protected
    procedure DoStartTransaction; override;
    procedure DoCommitTransaction; override;
    procedure DoRollbackTransaction; override;
  public
    constructor Create(const AConnection: TioInternalSqlConnection; const AQueryContainer:IioQueryContainer; const AConnectionInfo: IioDBConnectionInfo);
    destructor Destroy; override;
    procedure LastTransactionTimestampReset;
    function LastTransactionTimestamp: TDateTime;
    function AsDBConnection: IioConnectionDB; override;
    function QueryContainer: IioQueryContainer;
    function GetConnection: TioInternalSqlConnection;
    function InTransaction: Boolean; override;
  end;

implementation

uses
  iORM.DB.Factory, iORM.Exceptions, System.SysUtils;

{ TioConnectionSqLite }

function TioConnectionBase.AsDBConnection: IioConnectionDB;
begin
  if not Self.IsDBConnection then
    raise EioException.Create(Self.ClassName + '.AsDBConnection: Operation not allowed by this connection type.');
end;

function TioConnectionBase.AsHttpConnection: IioConnectionHttp;
begin
  if not Self.IsHttpConnection then
    raise EioException.Create(Self.ClassName + '.AsHttpConnection: Operation not allowed by this connection type.');
end;

procedure TioConnectionBase.Commit;
begin
  inherited;
  Dec(FTransactionCounter);
  if FTransactionCounter > 0 then Exit;
  DoCommitTransaction;
  // Free connection if needed (if not persistent)
  if not FConnectionInfo.Persistent then
    TioDBFactory.ConnectionContainer.FreeConnection(Self);
end;

constructor TioConnectionBase.Create(const AConnectionInfo: IioConnectionInfo);
begin
  inherited Create;
  FConnectionInfo := AConnectionInfo;
  FTransactionCounter := 0;
end;

function TioConnectionBase.GetConnectionInfo: IioConnectionInfo;
begin
  Result := FConnectionInfo;
end;

function TioConnectionBase.IsDBConnection: Boolean;
begin
  Result := (FConnectionInfo.ConnectionType <> TioConnectionType.ctHTML);
end;

function TioConnectionBase.IsHttpConnection: Boolean;
begin
  Result := (FConnectionInfo.ConnectionType = TioConnectionType.ctHTML);
end;

procedure TioConnectionBase.Rollback;
begin
  DoRollbackTransaction;
  FTransactionCounter := 0;
  // Free connection if needed (if not persistent)
  if not FConnectionInfo.Persistent then
    TioDBFactory.ConnectionContainer.FreeConnection(Self);
end;

procedure TioConnectionBase.StartTransaction;
begin
  inherited;
  if FTransactionCounter <= 0 then
  begin
    DoStartTransaction;
    FTransactionCounter := 0;
  end;
  inc(FTransactionCounter);
end;

{ TioConnectionDB }

function TioConnectionDB.AsDBConnection: IioConnectionDB;
begin
  inherited;
  Result := Self;
end;

constructor TioConnectionDB.Create(const AConnection: TioInternalSqlConnection;
  const AQueryContainer: IioQueryContainer;
  const AConnectionInfo: IioDBConnectionInfo);
begin
  inherited Create(AConnectionInfo);
  FFDGUIxWaitCursor := TFDGUIxWaitCursor.Create(nil);

{$IFDEF CONSOLE}
  FFDGUIxWaitCursor.Provider := 'Console';
{$ELSE}
  {$IFDEF ioVCL}
    FFDGUIxWaitCursor.Provider := 'Forms';
  {$ELSE}
    FFDGUIxWaitCursor.Provider := 'FMX';
  {$ENDIF}
{$ENDIF}

  FConnection := AConnection;
  FQueryContainer := AQueryContainer;
  LastTransactionTimestampReset;
end;

destructor TioConnectionDB.Destroy;
begin
  FConnection.Free;
  FFDGUIxWaitCursor.Free;
  inherited;
end;

procedure TioConnectionDB.DoCommitTransaction;
begin
  inherited;
  FConnection.Commit;
end;

procedure TioConnectionDB.DoRollbackTransaction;
begin
  inherited;
  FConnection.Rollback;
end;

procedure TioConnectionDB.DoStartTransaction;
begin
  inherited;
  FConnection.StartTransaction;
  LastTransactionTimestampReset;
end;

function TioConnectionDB.GetConnection: TioInternalSqlConnection;
begin
  Result := FConnection;
end;

function TioConnectionDB.InTransaction: Boolean;
begin
  inherited;
  Result := FConnection.InTransaction;
end;

function TioConnectionDB.QueryContainer: IioQueryContainer;
begin
  Result := FQueryContainer;
end;

function TioConnectionDB.GetCurrentTimeStamp: TDateTime;
var
  LQuery: IioQuery;
  function SQLiteDateTimeToDateTime(const AStrDateTime: String): TDateTime;
  var
    LFormatSettings: TFormatSettings;
  begin
    LFormatSettings := TFormatSettings.Create;
    LFormatSettings.DateSeparator := '-';
    LFormatSettings.ShortDateFormat := 'yyyy-MM-dd';
    LFormatSettings.TimeSeparator := ':';
    LFormatSettings.ShortTimeFormat := 'hh:mm';
    LFormatSettings.LongTimeFormat := 'hh:mm:ss.zzz';
    Result := StrToDateTime(AStrDateTime, LFormatSettings);
  end;
begin
  LQuery := TioDBFactory.QueryEngine.GetQueryCurrentTimestamp(FConnection.ConnectionDefName);
  LQuery.Open;
  try
    // NB: SQLite ritorna i current_timestamp come una stringa che poi va convertita in
    //      TDateTime, invece per gli altri DB non c'� bisogno di questa conversione.
    if GetConnectionInfo.ConnectionType = TioConnectionType.ctSQLite then
      Result := SQLiteDateTimeToDateTime(LQuery.Fields[0].AsString)
    else
      Result := LQuery.Fields[0].AsDateTime;
  finally
    LQuery.Close;
  end;
end;

function TioConnectionDB.LastTransactionTimestamp: TDateTime;
begin
  if FTransactionTimestamp = TRANSACTION_TIMESTAMP_NULL then
    FTransactionTimestamp := GetCurrentTimeStamp;
  Result := FTransactionTimestamp;
end;

procedure TioConnectionDB.LastTransactionTimestampReset;
begin
  FTransactionTimestamp := TRANSACTION_TIMESTAMP_NULL;
end;

end.


