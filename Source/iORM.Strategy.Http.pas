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
unit iORM.Strategy.Http;

interface

uses
  iORM.Strategy.Interfaces, iORM.Where.Interfaces, iORM.DB.Interfaces,
  FireDAC.Comp.DataSet, iORM.LiveBindings.BSPersistence;

type

  // Strategy class for database
  TioStrategyHttp = class(TioStrategyIntf)
  private
    // class var FTransactionGUID: String; NB: Hint prevention "symbol declared but never used"
    // class function NewGUIDAsString: String; NB: Hint prevention "symbol declared but never used" (codice presente sotto)
    // class function GetTransactionGUID: String;
  protected
    // ---------- Begin intercepted methods (StrategyInterceptors) ----------
    class procedure _DoPersistObject(const AObj: TObject; const ARelationPropertyName: String; const ARelationOID: Integer; const ABlindInsert: boolean;
      const AMasterBSPersistence: TioBSPersistence; const AMasterPropertyName, AMasterPropertyPath: String); override;
    class procedure _DoPersistList(const AList: TObject; const ARelationPropertyName: String; const ARelationOID: Integer; const ABlindInsert: boolean;
      const AMasterBSPersistence: TioBSPersistence; const AMasterPropertyName, AMasterPropertyPath: String); override;
    class procedure _DoDeleteObject(const AObj: TObject); override;
    class procedure _DoDeleteList(const AList: TObject); override;
    class procedure _DoLoadList(const AWhere: IioWhere; const AList: TObject); override;
    class function _DoLoadObject(const AWhere: IioWhere; const AObj: TObject): TObject; override;
    // ---------- End intercepted methods (StrategyInterceptors) ----------
  public
    class procedure StartTransaction(const AConnectionName: String); override;
    class procedure CommitTransaction(const AConnectionName: String); override;
    class procedure RollbackTransaction(const AConnectionName: String); override;
    class function InTransaction(const AConnectionName: String): boolean; override;
    class procedure Delete(const AWhere: IioWhere); override;
    class function LoadObjectByClassOnly(const AWhere: IioWhere; const AObj: TObject): TObject; override;
    class procedure LoadDataSet(const AWhere: IioWhere; const ADestDataSet: TFDDataSet); override;
    class function Count(const AWhere: IioWhere): Integer; override;
    // SQLDestinations
    class procedure SQLDest_LoadDataSet(const ASQLDestination: IioSQLDestination; const ADestDataSet: TFDDataSet); override;
    class procedure SQLDest_Execute(const ASQLDestination: IioSQLDestination); override;
  end;

implementation

uses
  System.JSON, iORM, System.Classes, iORM.Strategy.DB, iORM.DB.ConnectionContainer,
  iORM.DB.Factory, System.Generics.Collections, iORM.Utilities,
  iORM.DuckTyped.Interfaces, iORM.Http.Interfaces, iORM.Http.Factory,
  iORM.Exceptions, System.SysUtils, FireDAC.Stan.Intf, FireDAC.Stan.StorageJSON,
  iORM.Context.Container, DJSON;

{ TioStrategyHttp }

class procedure TioStrategyHttp.CommitTransaction(const AConnectionName: String);
begin
  inherited;
  TioDBFactory.Connection(AConnectionName).Commit;
end;

class function TioStrategyHttp.Count(const AWhere: IioWhere): Integer;
var
  LConnection: IioConnectionHttp;
begin
  inherited;
  // Get the connection, set the request and execute it
  LConnection := TioDBFactory.Connection('').AsHttpConnection;
  // Start transaction
  // NB: In this strategy (REST) call the Connection.StartTransaction (not the Self.StartTransaction
  // nor io.StartTransaction) because is only for the lifecicle of the connection itself and do not
  // perform any http call to the server at this point.
  LConnection.StartTransaction;
  try
    LConnection.RequestBody.Clear;
    LConnection.RequestBody.Where := AWhere;
    LConnection.Execute('Count');
    // Deserialize the JSONDataValue to the result object
    // M.M. 12/06/21
    Result := LConnection.ResponseBody.JSONDataValue.AsType<Integer>;
    // Commit
    LConnection.Commit;
  except
    // Rollback
    LConnection.Rollback;
    raise;
  end;
end;

class procedure TioStrategyHttp.Delete(const AWhere: IioWhere);
var
  LConnection: IioConnectionHttp;
begin
  inherited;
  // Get the connection, set the request and execute it
  LConnection := TioDBFactory.Connection('').AsHttpConnection;
  // Start transaction
  // NB: In this strategy (REST) call the Connection.StartTransaction (not the Self.StartTransaction
  // nor io.StartTransaction) because is only for the lifecicle of the connection itself and do not
  // perform any http call to the server at this point.
  LConnection.StartTransaction;
  try
    LConnection.RequestBody.Clear;
    LConnection.RequestBody.Where := AWhere;
    LConnection.Execute('Delete');
    // Commit
    LConnection.Commit;
  except
    // Rollback
    LConnection.Rollback;
    raise;
  end;
end;

class procedure TioStrategyHttp._DoDeleteList(const AList: TObject);
var
  LConnection: IioConnectionHttp;
begin
  inherited;
  // Check
  if not Assigned(AList) then
    Exit;
  // Get the connection, set the request and execute it
  LConnection := TioDBFactory.Connection('').AsHttpConnection;
  // Start transaction
  // NB: In this strategy (REST) call the Connection.StartTransaction (not the Self.StartTransaction
  // nor io.StartTransaction) because is only for the lifecicle of the connection itself and do not
  // perform any http call to the server at this point.
  LConnection.StartTransaction;
  try
    LConnection.RequestBody.Clear;
    LConnection.RequestBody.DataObject := AList;
    LConnection.Execute('PersistCollection');
    // Commit
    LConnection.Commit;
  except
    // Rollback
    LConnection.Rollback;
    raise;
  end;
end;

class procedure TioStrategyHttp._DoDeleteObject(const AObj: TObject);
var
  LConnectionDefName: String;
  LConnection: IioConnectionHttp;
begin
  inherited;
  // Check
  if not Assigned(AObj) then
    Exit;
  // Get the connection, set the request and execute it
  LConnectionDefName := TioMapContainer.GetConnectionDefName(AObj.ClassName);
  LConnection := TioDBFactory.Connection(LConnectionDefName).AsHttpConnection;
  // Start transaction
  // NB: In this strategy (REST) call the Connection.StartTransaction (not the Self.StartTransaction
  // nor io.StartTransaction) because is only for the lifecicle of the connection itself and do not
  // perform any http call to the server at this point.
  LConnection.StartTransaction;
  try
    LConnection.RequestBody.Clear;
    LConnection.RequestBody.DataObject := AObj;
    LConnection.Execute('DeleteObject');
    // Commit
    LConnection.Commit;
  except
    // Rollback
    LConnection.Rollback;
    raise;
  end;
end;

class function TioStrategyHttp.InTransaction(const AConnectionName: String): boolean;
begin
  inherited;
  Result := TioDBFactory.Connection(AConnectionName).InTransaction;
end;

// class function TioStrategyREST.GetTransactionGUID: String;
// begin
// // Set the fixed part of the TransactionGUID if empty
// if FTransactionGUID.IsEmpty then
// FTransactionGUID := Self.NewGUIDAsString;
// // Generate a TransactionGUID (Fixed GUID + Current thread ID
// Result := System.Classes.TThread.CurrentThread.ThreadID.ToString + '-' + FTransactionGUID;
// end;

class procedure TioStrategyHttp.LoadDataSet(const AWhere: IioWhere; const ADestDataSet: TFDDataSet);
var
  LConnection: IioConnectionHttp;
begin
  inherited;
  // Get the connection, set the request and execute it
  LConnection := TioDBFactory.Connection('').AsHttpConnection;
  // Start transaction
  // NB: In this strategy (REST) call the Connection.StartTransaction (not the Self.StartTransaction
  // nor io.StartTransaction) because is only for the lifecicle of the connection itself and do not
  // perform any http call to the server at this point.
  LConnection.StartTransaction;
  try
    LConnection.RequestBody.Clear;
    LConnection.RequestBody.Where := AWhere;
    LConnection.Execute('LoadDataSet');
    // Load the dataset
    ADestDataSet.LoadFromStream(LConnection.ResponseBody.Stream, TFDStorageFormat.sfJSON);
    // Commit
    LConnection.Commit;
  except
    // Rollback
    LConnection.Rollback;
    raise;
  end;
end;

class procedure TioStrategyHttp._DoLoadList(const AWhere: IioWhere; const AList: TObject);
var
  LConnection: IioConnectionHttp;
begin
  inherited;
  // Get the connection, set the request and execute it
  LConnection := TioDBFactory.Connection('').AsHttpConnection;
  // Start transaction
  // NB: In this strategy (REST) call the Connection.StartTransaction (not the Self.StartTransaction
  // nor io.StartTransaction) because is only for the lifecicle of the connection itself and do not
  // perform any http call to the server at this point.
  LConnection.StartTransaction;
  try
    LConnection.RequestBody.Clear;
    LConnection.RequestBody.Where := AWhere;
    LConnection.Execute('LoadList');
    // Deserialize  the JSONDataValue to the result object
    // NB: Mauri 15/08/2023 (fix issue winth paging when using http connection):
    //      Ho eliminato il "ClearCollection" dalla chiamata a DJSON perch� altrimenti non funzionava bene
    //      il paging ti tipo progressive. In questo modo invece sembra funzionare bene. Spero che la cosa non causi problemi
    //      in altri contesti. Lascio anche a vecchia versione commentata, poi vedremo.
//    dj.FromJSON(LConnection.ResponseBody.JSONDataValue).OpType(ssHTTP).byFields.ClearCollection.TypeAnnotationsON.&To(AList); // OLD CODE
    dj.FromJSON(LConnection.ResponseBody.JSONDataValue).OpType(ssHTTP).byFields.TypeAnnotationsON.&To(AList);
    // Commit
    LConnection.Commit;
  except
    // Rollback
    LConnection.Rollback;
    raise;
  end;
end;

class function TioStrategyHttp._DoLoadObject(const AWhere: IioWhere; const AObj: TObject): TObject;
var
  LConnection: IioConnectionHttp;
begin
  inherited;
  Result := AObj;
  // Get the connection, set the request and execute it
  LConnection := TioDBFactory.Connection('').AsHttpConnection;
  // Start transaction
  // NB: In this strategy (REST) call the Connection.StartTransaction (not the Self.StartTransaction
  // nor io.StartTransaction) because is only for the lifecicle of the connection itself and do not
  // perform any http call to the server at this point.
  LConnection.StartTransaction;
  try
    LConnection.RequestBody.Clear;
    LConnection.RequestBody.Where := AWhere;
    LConnection.Execute('LoadObject');
    // Deserialize  the JSONDataValue to the result object
    if Assigned(AObj) then
      dj.FromJSON(LConnection.ResponseBody.JSONDataValue).OpType(ssHTTP).byFields.ClearCollection.TypeAnnotationsON.&To(Result)
    else
      Result := dj.FromJSON(LConnection.ResponseBody.JSONDataValue).OpType(ssHTTP).byFields.ClearCollection.TypeAnnotationsON.ToObject;
    // Commit
    LConnection.Commit;
  except
    // Rollback
    LConnection.Rollback;
    raise;
  end;
end;

class function TioStrategyHttp.LoadObjectByClassOnly(const AWhere: IioWhere; const AObj: TObject): TObject;
begin
  // This method is only used internally by the Object Maker,
  // and then you do not need to implement it in RESTStrategy.
  raise EioException.Create(Self.ClassName + ': "LoadObjectByClassOnly", method not implemented in this strategy.');
end;

// class function TioStrategyREST.NewGUIDAsString: String;
// var
// LGUID: TGUID;
// begin
// CreateGUID(LGUID);
// Result := GUIDToString(LGUID);
// end;

{ TODO : DA AGGIUNGERE GESTIONE DEI 3 PARAMETRI AGGIUNTI ALLA FINE PER IL SUD }
class procedure TioStrategyHttp._DoPersistList(const AList: TObject; const ARelationPropertyName: String; const ARelationOID: Integer;
  const ABlindInsert: boolean; const AMasterBSPersistence: TioBSPersistence; const AMasterPropertyName, AMasterPropertyPath: String);
var
  LConnection: IioConnectionHttp;
begin
  inherited;
  // Check
  if not Assigned(AList) then
    Exit;
  // Get the connection, set the request and execute it
  LConnection := TioDBFactory.Connection('').AsHttpConnection;
  // Start transaction
  // NB: In this strategy (REST) call the Connection.StartTransaction (not the Self.StartTransaction
  // nor io.StartTransaction) because is only for the lifecicle of the connection itself and do not
  // perform any http call to the server at this point.
  LConnection.StartTransaction;
  try
    LConnection.RequestBody.Clear;
    LConnection.RequestBody.RelationPropertyName := ARelationPropertyName;
    LConnection.RequestBody.RelationOID := ARelationOID;
    LConnection.RequestBody.BlindInsert := ABlindInsert;
    LConnection.RequestBody.DataObject := AList;
    LConnection.Execute('PersistCollection');
    // Deserialize the JSONDataValue to update the object with the IDs (after Insert)
    if not ABlindInsert then
      dj.FromJSON(LConnection.ResponseBody.JSONDataValue).OpType(ssHTTP).byFields.ClearCollection.TypeAnnotationsON.&To(AList);
    // Commit
    LConnection.Commit;
  except
    // Rollback
    LConnection.Rollback;
    raise;
  end;
end;

{ TODO : DA AGGIUNGERE GESTIONE DEI 3 PARAMETRI AGGIUNTI ALLA FINE PER IL SUD }
class procedure TioStrategyHttp._DoPersistObject(const AObj: TObject; const ARelationPropertyName: String; const ARelationOID: Integer;
  const ABlindInsert: boolean; const AMasterBSPersistence: TioBSPersistence; const AMasterPropertyName, AMasterPropertyPath: String);
var
  LConnectionDefName: String;
  LConnection: IioConnectionHttp;
begin
  inherited;
  // Check
  if not Assigned(AObj) then
    Exit;
  // Get the connection, set the request and execute it
  LConnectionDefName := TioMapContainer.GetConnectionDefName(AObj.ClassName);
  LConnection := TioDBFactory.Connection(LConnectionDefName).AsHttpConnection;
  // Start transaction
  // NB: In this strategy (REST) call the Connection.StartTransaction (not the Self.StartTransaction
  // nor io.StartTransaction) because is only for the lifecicle of the connection itself and do not
  // perform any http call to the server at this point.
  LConnection.StartTransaction;
  try
    LConnection.RequestBody.Clear;
    LConnection.RequestBody.RelationPropertyName := ARelationPropertyName;
    LConnection.RequestBody.RelationOID := ARelationOID;
    LConnection.RequestBody.BlindInsert := ABlindInsert;
    LConnection.RequestBody.DataObject := AObj;
    LConnection.Execute('PersistObject');
    // Deserialize the JSONDataValue to update the object with the IDs (after Insert)
    if not ABlindInsert then
      dj.FromJSON(LConnection.ResponseBody.JSONDataValue).OpType(ssHTTP).byFields.ClearCollection.TypeAnnotationsON.&To(AObj);
    // Commit
    LConnection.Commit;
  except
    // Rollback
    LConnection.Rollback;
    raise;
  end;
end;

class procedure TioStrategyHttp.RollbackTransaction(const AConnectionName: String);
begin
  inherited;
  TioDBFactory.Connection(AConnectionName).Rollback;
end;

class procedure TioStrategyHttp.SQLDest_Execute(const ASQLDestination: IioSQLDestination);
var
  LConnection: IioConnectionHttp;
  LJSONValue: TJSONValue;
begin
  inherited;
  // Get the connection, set the request and execute it
  LConnection := TioDBFactory.Connection(ASQLDestination.GetConnectionDefName).AsHttpConnection;
  // Start transaction
  // NB: In this strategy (REST) call the Connection.StartTransaction (not the Self.StartTransaction
  // nor io.StartTransaction) because is only for the lifecicle of the connection itself and do not
  // perform any http call to the server at this point.
  LConnection.StartTransaction;
  try
    LConnection.RequestBody.Clear;
    LConnection.RequestBody.SQLDestination := ASQLDestination;
    LConnection.Execute('SQLDestExecute');
    // Get the number of records affected by the SQL command
    LJSONValue := LConnection.ResponseBody.JSONDataValue;
    if Assigned(LJSONValue) and (LJSONValue is TJSONNumber) then
      // Result := TJSONNumber(LJSONValue).AsInt
    else
      raise EioException.Create(Self.ClassName + ': wrong JSONValue (SQLDest_Execute).');
    // Commit
    LConnection.Commit;
  except
    // Rollback
    LConnection.Rollback;
    raise;
  end;
end;

class procedure TioStrategyHttp.SQLDest_LoadDataSet(const ASQLDestination: IioSQLDestination; const ADestDataSet: TFDDataSet);
var
  LConnection: IioConnectionHttp;
begin
  inherited;
  // Get the connection, set the request and execute it
  LConnection := TioDBFactory.Connection('').AsHttpConnection;
  // Start transaction
  // NB: In this strategy (REST) call the Connection.StartTransaction (not the Self.StartTransaction
  // nor io.StartTransaction) because is only for the lifecicle of the connection itself and do not
  // perform any http call to the server at this point.
  LConnection.StartTransaction;
  try
    LConnection.RequestBody.Clear;
    LConnection.RequestBody.SQLDestination := ASQLDestination;
    LConnection.Execute('SQLDestLoadDataSet');
    // Load the dataset
    ADestDataSet.LoadFromStream(LConnection.ResponseBody.Stream, TFDStorageFormat.sfJSON);
    // Commit
    LConnection.Commit;
  except
    // Rollback
    LConnection.Rollback;
    raise;
  end;
end;

class procedure TioStrategyHttp.StartTransaction(const AConnectionName: String);
begin
  inherited;
  TioDBFactory.Connection(AConnectionName).StartTransaction;
end;

end.
