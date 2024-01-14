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
unit iORM.DB.Interfaces;

interface

uses
  iORM.Context.Properties.Interfaces,
  iORM.Context.Interfaces,
  iORM.Context.Table.Interfaces,
  iORM.Interfaces,
  System.Classes,
  System.Rtti,
  FireDAC.Comp.Client, FireDAC.Stan.Param,
  Data.DB, FireDAC.Stan.Intf, iORM.CommonTypes,
  System.JSON, iORM.Where.Interfaces,
  FireDAC.Comp.DataSet, iORM.LiveBindings.BSPersistence,
  iORM.Where.SqlItems.Interfaces, iORM.Context.Map.Interfaces;

const
  OBJVERSION_NULL = 0;
  TRANSACTION_TIMESTAMP_NULL = 0;

  KEY_WHERE = 'Where';
  KEY_SQLDESTINATION = 'SQLDestination';
  KEY_DATAOBJECT = 'DataObj';
  KEY_JSONDATAVALUE = 'JSONDataValue';
  KEY_RELATIONPROPERTYNAME = 'RelPropName';
  KEY_RELATIONOID = 'RelOID';
  KEY_BLINDINSERT = 'Blind';
  KEY_STREAM = 'Stream';

type

  TioInternalSqlConnection = TFDConnection;
  TioInternalSqlQuery = TFDQuery;
  TioFields = TFields;
  TioParam = TFDParam;
  TioParams = TFDParams;

  // Strategy class reference
  TioStrategyRef = class of TioStrategyIntf;

  TioConnectionType = (ctFirebird, ctSQLite,
{$IFNDEF ioDelphiProfessional}
    ctSQLServer,
{$ENDIF}
    ctMySQL, ctHTML);

  TioKeyGenerationTime = (kgtUndefined, kgtAfterInsert, kgtBeforeInsert);

//  TioConnectionInfo = record
//    BaseURL: String;
//    ConnectionName: String;
//    ConnectionType: TioConnectionType;
//    KeyGenerationTime: TioKeyGenerationTime;
//    Password: String;
//    Persistent: Boolean;
//    Strategy: TioStrategyRef;
//    UserName: String;
//    constructor Create(const AConnectionName: String; const AConnectionType: TioConnectionType; const APersistent: Boolean;
//      const AKeyGenerationTime: TioKeyGenerationTime);
//  end;

  IioConnectionInfo = interface
    ['{05368F43-8543-4263-8AD9-1E2BB3C05EDF}']
    function GetConnectionName: string;
    function GetConnectionType: TioConnectionType;
    function GetPassword: string;
    function GetPersistent: Boolean;
    function GetStrategy: TioStrategyRef;
    function GetUserName: String;
    property ConnectionName: string read GetConnectionName;
    property ConnectionType: TioConnectionType read GetConnectionType;
    property Password: string read GetPassword;
    property Persistent: Boolean read GetPersistent;
    property Strategy: TioStrategyRef read GetStrategy;
    property UserName: String read GetUserName;
  end;

  TioConnectionInfo = class(TInterfacedObject, IioConnectionInfo)
  private
    FConnectionName: String;
    FConnectionType: TioConnectionType;
    FPassword: String;
    FPersistent: Boolean;
    FStrategy: TioStrategyRef;
    FUserName: String;
    function GetConnectionName: string;
    function GetConnectionType: TioConnectionType;
    function GetPassword: string;
    function GetPersistent: Boolean;
    function GetStrategy: TioStrategyRef;
    function GetUserName: String;
  public
    constructor Create(const AConnectionName: String; const AConnectionType: TioConnectionType; const APersistent: Boolean);
    property ConnectionName: string read GetConnectionName;
    property ConnectionType: TioConnectionType read GetConnectionType;
    property Password: string read GetPassword;
    property Persistent: Boolean read GetPersistent;
    property Strategy: TioStrategyRef read GetStrategy;
    property UserName: String read GetUserName;
  end;


  IioDBConnectionInfo = interface(IioConnectionInfo)
    ['{D2B16BBA-F685-4A53-86C6-478604F9EC2A}']
    function GetCharSet: String;
    function GetCollation: string;
    function GetQuotedIdentifiers: Boolean;
    function GetKeyGenerationTime: TioKeyGenerationTime;
    property CharSet: String read GetCharSet;
    property Collation: String read GetCollation;
    property KeyGenerationTime: TioKeyGenerationTime read GetKeyGenerationTime;
    property QuotedIdentifiers: Boolean read GetQuotedIdentifiers;
  end;

  TioDBConnectionInfo = class(TioConnectionInfo, IioDBConnectionInfo)
  private
    FKeyGenerationTime: TioKeyGenerationTime;
    FCharSet: string;
    FCollation: String;
    FQuotedIdentifiers: Boolean;
    function GetKeyGenerationTime: TioKeyGenerationTime;
    function GetCollation: String;
    function GetQuotedIdentifiers: Boolean;
    function GetCharSet: string;
  public
    constructor Create(const AConnectionName: String; const AConnectionType: TioConnectionType; const APersistent: Boolean;
      const AKeyGenerationTime: TioKeyGenerationTime{; const ACharSet, ACollation: String; const QuotedIdentifiers: Boolean}); reintroduce;

    property CharSet: string read GetCharSet;
    property Collation: String read GetCollation;
    property KeyGenerationTime: TioKeyGenerationTime read GetKeyGenerationTime;
    property QuotedIdentifiers: Boolean read GetQuotedIdentifiers;
  end;

  IioHTTPConnectionInfo = interface(IioConnectionInfo)
    ['{B1FF22C2-780C-401A-A251-272505F0782D}']
    function GetBaseURL: string;
    property BaseURL: string read GetBaseURL;
  end;

  TioHTTPConnectionInfo = class(TioConnectionInfo, IioHTTPConnectionInfo)
  private
    FBaseURL: String;
    function GetBaseURL: string;
  public
    constructor Create(const AConnectionName: String; const APersistent: Boolean; ABaseURL: String); reintroduce;

    property BaseURL: string read GetBaseURL;
  end;


  TioCompareOperatorRef = class of TioCompareOperator;
  TioLogicRelationRef = class of TioLogicRelation;
  TioSqlDataConverterRef = class of TioSqlDataConverter;
  TioSqlGeneratorRef = class of TioSqlGenerator;

  // -Classe per il connection manager che funge da repository dei parametri di tutte
  // connessioni e da gestore del connection pooling
  // -Interfaccia per oggetti contenenti i parametri di una connessione da inserire
  // nel connection manager
  // In pratica utilizzo l'interfaccia "IFDStanConnectionDef" fornita da FireDAC
  IIoConnectionDef = IFDStanConnectionDef;

  // Forward declaration
  IioQuery = interface;

  // Interfaccia per il QueryContainer che contiene la collezione di tutte gli oggetti IioQuery creati
  // per una connessione. In pratica ogni connessione (IioConnection) contiene la collezione di query
  // create per la connessione stessa in modo da poterle riutilizzare. Il ciclo di vita di questi oggetti query
  // coincide quindi con quello della connessione che a sua volta coincide con quello della transazione.
  IioQueryContainer = interface
    ['{9CF03765-6685-48A3-8DCC-85C7040D676D}']
    function TryGetQuery(AQueryIdentity: String; out ResultQuery: IioQuery): Boolean;
    procedure AddQuery(AQueryIdentity: String; AQuery: IioQuery);
    procedure CleanQueryConnectionsRef;
  end;

  // Interfaccia per il componente connection da fornire alla query per la
  // connessione al database
  IioConnectionDB = interface;
  IioConnectionHttp = interface;

  IioConnection = interface
    ['{FF5D54D7-7EBE-4E6E-830E-E091BA7AE929}']
    procedure Free;
    function IsDBConnection: Boolean;
    function IsHttpConnection: Boolean;
    function AsDBConnection: IioConnectionDB;
    function AsHttpConnection: IioConnectionHttp;
    function GetConnectionInfo: IioConnectionInfo;
    function InTransaction: Boolean;
    procedure StartTransaction;
    procedure Commit;
    procedure Rollback;
  end;

  IioConnectionDB = interface(IioConnection)
    ['{997CFE22-031A-468A-BF67-E076C43DC0E2}']
    function GetConnection: TioInternalSqlConnection;
    function QueryContainer: IioQueryContainer;
    function LastTransactionTimestamp: TDateTime;
    procedure LastTransactionTimestampReset;
  end;

  IioHttpRequestBody = interface;
  IioHttpResponseBody = interface;

  IioConnectionHttp = interface(IioConnection)
    ['{E29F952A-E7E5-44C7-A3BE-09C4F2939060}']
    procedure Execute(const AResource: String);
    // ioRequestBody property
    function GetRequestBody: IioHttpRequestBody;
    property RequestBody: IioHttpRequestBody read GetRequestBody;
    // ioResponseBody property
    function GetResponseBody: IioHttpResponseBody;
    property ResponseBody: IioHttpResponseBody read GetResponseBody;
  end;

  // Interfaccia che contiene info sulla connessione e sull'utente correnti
  IioCurrentConnectionInfo = interface
    function GetCurrentConnectionName: String;
    function GetCurrentUserID: Integer;
    function GetCurrentUserName: String;
    procedure SetCurrentConnectionName(const Value: String);
    procedure SetCurrentUserID(const Value: Integer);
    procedure SetCurrentUserName(const Value: String);
    property CurrentConnectionName: String read GetCurrentConnectionName write SetCurrentConnectionName;
    property CurrentUserName: String read GetCurrentUserName write SetCurrentUserName;
    property CurrentUserID: Integer read GetCurrentUserID write SetCurrentUserID;
  end;

  // Interfaccia per il componente Query, cio� del componente che si
  // occuper� di eseguire il codice SQL o altro per caricare/modificare/eliminare
  // il dato
  IioQuery = interface
    ['{E8CFB984-2572-4D6F-BC4B-A4454F1EEDAA}']
    function GetQuery: TioInternalSqlQuery;
    procedure Next;
    function Eof: Boolean;
    function GetValue(const AProperty: IioProperty; const AContext: IioContext): TValue;
    procedure Open;
    procedure Close;
    function IsEmpty: Boolean;
    function IsSqlEmpty: Boolean;
    function IsActive: Boolean;
    function ExecSQL: Integer;
    function Fields: TioFields;
    function ExtractTrueClassName(const AContext: IioContext): String;
    procedure FillQueryWhereParams(const AContext: IioContext);
    procedure CleanConnectionRef;
    function CreateBlobStream(const AProperty: IioProperty; const Mode: TBlobStreamMode): TStream;
    procedure ParamByName_SetValue(const AParamName: String; const AValue: Variant);
    procedure ParamByProp_Clear(const AProp: IioProperty; const ADataType: TFieldType);
    procedure ParamByProp_SetValue(const AProp: IioProperty; const AValue: Variant);
    // procedure ParamByProp_SetValueAsString(const AProp: IioProperty; const AValue: String);
    procedure ParamByProp_SetValueAsDateTime(const AProp: IioProperty; const AValue: TDateTime);
    procedure ParamByProp_SetValueAsDate(const AProp: IioProperty; const AValue: TDate);
    procedure ParamByProp_SetValueAsTime(const AProp: IioProperty; const AValue: TTime);
    // procedure ParamByProp_SetValueAsFloat(const AProp: IioProperty; const AValue: Double);
    procedure ParamByProp_SetValueByContext(const AProp: IioProperty; const AContext: IioContext);
    procedure ParamByProp_SetValueAsIntegerNullIfZero(const AProp: IioProperty; const AValue: Integer);
    procedure ParamByProp_LoadAsStreamObj(const AObj: TObject; const AProperty: IioProperty);
    procedure ParamObjVersion_SetValue(const AContext: IioContext);
    procedure ParamObjCreated_SetValue(const AContext: IioContext);
    procedure ParamObjCreatedUserID_SetValue(const AContext: IioContext);
    procedure ParamObjCreatedUserName_SetValue(const AContext: IioContext);
    procedure ParamObjUpdated_SetValue(const AContext: IioContext);
    procedure ParamObjUpdatedUserID_SetValue(const AContext: IioContext);
    procedure ParamObjUpdatedUserName_SetValue(const AContext: IioContext);
    // procedure WhereParamByProp_SetValue(const AProp: IioProperty; const AValue: Variant);
    // procedure WhereParamByProp_SetValueAsDateTime(const AProp: IioProperty; const AValue: TDateTime);
    // procedure WhereParamByProp_SetValueAsFloat(const AProp: IioProperty; const AValue: Double);
    procedure WhereParamObjID_SetValue(const AContext: IioContext);
    procedure WhereParamObjVersion_SetValue(const AContext: IioContext);

    // Connection property
    function GetConnection: IioConnectionDB;
    property Connection: IioConnectionDB read GetConnection;
    // SQL property
    function GetSQL: TStrings;
    property SQL: TStrings read GetSQL;
  end;

  // Interfaccia per la classe che esegue script sul DB (usato dal DBBuilder)
  IioScript = interface
    ['{DF0FA3CE-233A-454E-A501-4FFDAE0CD713}']
    procedure Execute;
  end;

  // Interfaccia per le classi che si occupano di convertire i dati in
  // rappresentazioni degli stessi da inserire nel testo delle query,
  TioSqlDataConverter = class abstract
  public
    class function StringToSQL(const AString: String): String; virtual; abstract;
    class function FloatToSQL(const AFloat: Extended): String; virtual; abstract;
    class function PropertyToFieldType(const AProp: IioProperty): String; virtual; abstract;
    class function TValueToSql(const AValue: TValue): String; virtual; abstract;
    class function QueryToTValue(const AQuery: IioQuery; const AProperty: IioProperty): TValue; virtual; abstract;
    class procedure SetQueryParamByContext(const AQuery: IioQuery; const AProp: IioProperty; const AContext: IioContext); virtual; abstract;
    class function FieldNameToSqlFieldName(const AFieldName: string): string; virtual; abstract;
  end;

  // INterfaccia per le classi che devono generare i vari tipi di query
  // Select/Update/Insert/Delete
  TioSqlGenerator = class abstract
  strict protected
    class procedure LoadSqlParamsFromContext(const AQuery: IioQuery; const AContext: IioContext);
    // N.B. M.M. 11/08/18 Spostata come protected per poterla eventualmente ridefinire per database dove esiste una lunghezza massima dei nomi degli indici
  protected
    class function BuildIndexName(const AContext: IioContext; const ACommaSepFieldList: String; const AIndexOrientation: TioIndexOrientation;
      const AUnique: Boolean): String; virtual;
  public
    class procedure GenerateSqlCount(const AQuery: IioQuery; const AContext: IioContext); virtual;
    class procedure GenerateSqlCreateIndex(const AQuery: IioQuery; const AContext: IioContext; AIndexName: String; const ACommaSepFieldList: String;
      const AIndexOrientation: TioIndexOrientation; const AUnique: Boolean); virtual; abstract;
    class procedure GenerateSqlCurrentTimestamp(const AQuery: IioQuery); virtual; abstract;
    class procedure GenerateSqlDelete(const AQuery: IioQuery; const AContext: IioContext); virtual;
    class procedure GenerateSqlDropIndex(const AQuery: IioQuery; const AContext: IioContext; AIndexName: String); virtual; abstract;
    class procedure GenerateSqlExists(const AQuery: IioQuery; const AContext: IioContext); virtual; abstract;
    class procedure GenerateSqlInsert(const AQuery: IioQuery; const AContext: IioContext); virtual;
    class function GenerateSqlJoinSectionItem(const AJoinItem: IioJoinItem): String; virtual;
    class procedure GenerateSqlNextID(const AQuery: IioQuery; const AContext: IioContext); virtual; abstract;
    class procedure GenerateSqlSelect(const AQuery: IioQuery; const AContext: IioContext); virtual;
    class procedure GenerateSqlUpdate(const AQuery: IioQuery; const AContext: IioContext); virtual;
    class function GenerateSqlSelectNestedWhere_OLD(const AMap: IioMap; const ANestedCriteria: IioSqlItemCriteria): String; virtual;
  end;

  // Interfaccia per le classi che devono generare le LogicRelations
  TioLogicRelation = class abstract
    class function LogicOpToLogicRelation(const ALogicOp: TioLogicOp): IioSqlItem; virtual;
    class function _And: IioSqlItem; virtual;
    class function _Or: IioSqlItem; virtual;
    class function _Not: IioSqlItem; virtual;
    class function _OpenPar: IioSqlItem; virtual;
    class function _ClosePar: IioSqlItem; virtual;
  end;

  { TODO : Si potrebbe lasciare solo il metodo NewCompareOperator ed eliminare tutto il resto (anche le LogicRelations) }
  // Interfaccia per le classi che devono generare operatori di comparazione
  TioCompareOperator = class abstract
    class function CompareOpToCompareOperator(const ACompareOp: TioCompareOp): IioSqlItem; virtual;
    class function _Equal: IioSqlItem; virtual;
    class function _NotEqual: IioSqlItem; virtual;
    class function _Greater: IioSqlItem; virtual;
    class function _Lower: IioSqlItem; virtual;
    class function _GreaterOrEqual: IioSqlItem; virtual;
    class function _LowerOrEqual: IioSqlItem; virtual;
    class function _Like: IioSqlItem; virtual;
    class function _NotLike: IioSqlItem; virtual;
    class function _IsNull: IioSqlItem; virtual;
    class function _IsNotNull: IioSqlItem; virtual;
  end;

  // Interface for TransactionColection
  IioTransactionCollection = interface
    ['{27836795-C804-4CB2-8A5A-98491643D5D9}']
    procedure StartTransaction(AConnectionName: String = '');
    procedure CommitAll;
    procedure RollbackAll;
  end;

  // Interface for SQLDestination
  IioSQLDestination = interface
    ['{B96F4E95-5609-4577-9C0D-E01013EE0093}']
    // Destinations
    { TO 5DO -oOwner -cGeneral : Un altro overload di Trabslate che accetta un'interfaccia e che genera automaticamente una query che fa l'UNION ALL di tutte le classi che implementano l'interfaccia stessa }
    procedure Execute(const AIgnoreObjNotExists: Boolean = False); overload;
    function ToMemTable: TFDMemTable; overload;
    procedure ToMemTable(const AMemTable: TFDMemTable); overload;
    // Informations
    function Connection(const AConnectionDefName: String): IioSQLDestination;
    function DoNotTranslate: IioSQLDestination;
    function QualifiedFieldName(const AQualifiedFieldName: Boolean = True): IioSQLDestination;
    function SelfClass(const ASelfClassName: String): IioSQLDestination; overload;
    function SelfClass(const ASelfClassRef: TioClassRef): IioSQLDestination; overload;
    // Getters
    function GetConnectionDefName: String;
    function GetIgnoreObjNotExists: Boolean;
    function GetSQL: String;
  end;

  IioHttpRequestBody = interface
    ['{83DE9ECE-47EA-4814-B40E-3E39FAA210A2}']
    procedure Clear;
    function ToJSONObject: TJSONObject;
    // Where
    procedure SetWhere(const Value: IioWhere);
    function GetWhere: IioWhere;
    property Where: IioWhere read GetWhere write SetWhere;
    // SQLDestination
    procedure SetSQLDestination(const Value: IioSQLDestination);
    function GetSQLDestination: IioSQLDestination;
    property SQLDestination: IioSQLDestination read GetSQLDestination write SetSQLDestination;
    // DataObject
    procedure SetDataObject(const Value: TObject);
    function GetDataObject: TObject;
    property DataObject: TObject read GetDataObject write SetDataObject;
    // RelationPropertyName
    procedure SetRelationPropertyName(const Value: String);
    function GetRelationPropertyName: String;
    property RelationPropertyName: String read GetRelationPropertyName write SetRelationPropertyName;
    // RelationOID
    procedure SetRelationOID(const Value: Integer);
    function GetRelationOID: Integer;
    property RelationOID: Integer read GetRelationOID write SetRelationOID;
    // BlindInsert
    procedure SetBlindInsert(const Value: Boolean);
    function GetBlindInsert: Boolean;
    property BlindInsert: Boolean read GetBlindInsert write SetBlindInsert;
  end;

  IioHttpResponseBody = interface
    ['{E5A14525-308F-4877-99B7-C270D691FC6D}']
    function ToJSONObject: TJSONObject;
    // JSONDataValue
    procedure SetJSONDataValue(const Value: TJSONValue);
    function GetJSONDataValue: TJSONValue;
    property JSONDataValue: TJSONValue read GetJSONDataValue write SetJSONDataValue;
    // DataObject
    procedure SetDataObject(const Value: TObject);
    function GetDataObject: TObject;
    property DataObject: TObject read GetDataObject write SetDataObject;
    // Stream
    function GetStream: TStream;
    property Stream: TStream read GetStream;
  end;

  // Base class for strategy (Static class as an interface)
  // Note: {$DEFINE ioStrategyInterceptorsOff} to disable strategy interceptors
  TioStrategyIntf = class abstract
  protected
    // ---------- Begin intercepted methods (StrategyInterceptors) ----------
    class procedure _DoPersistObject(const AObj: TObject; const ARelationPropertyName: String; const ARelationOID: Integer; const ABlindInsert: Boolean;
      const AMasterBSPersistence: TioBSPersistence; const AMasterPropertyName, AMasterPropertyPath: String); virtual; abstract;
    class procedure _DoPersistList(const AList: TObject; const ARelationPropertyName: String; const ARelationOID: Integer; const ABlindInsert: Boolean;
      const AMasterBSPersistence: TioBSPersistence; const AMasterPropertyName, AMasterPropertyPath: String); virtual; abstract;
    class procedure _DoDeleteObject(const AObj: TObject); virtual; abstract;
    class procedure _DoDeleteList(const AList: TObject); virtual; abstract;
    class procedure _DoLoadList(const AWhere: IioWhere; const AList: TObject); virtual; abstract;
    class function _DoLoadObject(const AWhere: IioWhere; const AObj: TObject): TObject; virtual; abstract;
    // ---------- End intercepted methods (StrategyInterceptors) ----------
  public
    class procedure StartTransaction(const AConnectionName: String); virtual; abstract;
    class procedure CommitTransaction(const AConnectionName: String); virtual; abstract;
    class procedure RollbackTransaction(const AConnectionName: String); virtual; abstract;
    class function InTransaction(const AConnectionName: String): Boolean; virtual; abstract;
    class procedure Delete(const AWhere: IioWhere); virtual; abstract;
    class function LoadObjectByClassOnly(const AWhere: IioWhere; const AObj: TObject): TObject; virtual; abstract;
    class procedure LoadDataSet(const AWhere: IioWhere; const ADestDataSet: TFDDataSet); virtual; abstract;
    class function Count(const AWhere: IioWhere): Integer; virtual; abstract;
    // SQLDestinations
    class procedure SQLDest_LoadDataSet(const ASQLDestination: IioSQLDestination; const ADestDataSet: TFDDataSet); virtual; abstract;
    class procedure SQLDest_Execute(const ASQLDestination: IioSQLDestination); virtual; abstract;
    // ---------- Begin intercepted methods (StrategyInterceptors) ----------
    class procedure PersistObject(const AObj: TObject; const ARelationPropertyName: String; const ARelationOID: Integer; const ABlindInsert: Boolean;
      const AMasterBSPersistence: TioBSPersistence; const AMasterPropertyName, AMasterPropertyPath: String);
    class procedure PersistList(const AList: TObject; const ARelationPropertyName: String; const ARelationOID: Integer; const ABlindInsert: Boolean;
      const AMasterBSPersistence: TioBSPersistence; const AMasterPropertyName, AMasterPropertyPath: String);
    class procedure DeleteObject(const AObj: TObject);
    class procedure DeleteList(const AList: TObject);
    class procedure LoadList(const AWhere: IioWhere; const AList: TObject);
    class function LoadObject(const AWhere: IioWhere; const AObj: TObject): TObject;
    // ---------- End intercepted methods (StrategyInterceptors) ----------
  end;

implementation

uses
  iORM.SqlTranslator, iORM.Strategy.Factory, System.SysUtils, iORM.Attributes,
  iORM.Exceptions, iORM.Utilities, iORM.SqlItems,
  System.StrUtils, iORM.Context.Container, iORM.Resolver.Interfaces,
  iORM.Resolver.Factory, iORM.Interceptor.Strategy.Register;

{ TioSqlGenerator }

class function TioSqlGenerator.BuildIndexName(const AContext: IioContext; const ACommaSepFieldList: String; const AIndexOrientation: TioIndexOrientation;
  const AUnique: Boolean): String;
var
  LFieldList: TStrings;
  LField: String;
begin
  // Build the indexname
  Result := 'IDX_' + AContext.GetTable.TableName;
  // Field list
  LFieldList := TStringList.Create;
  try
    LFieldList.Delimiter := ',';
    LFieldList.DelimitedText := ACommaSepFieldList;
    for LField in LFieldList do
      Result := Result + '_' + LField;
  finally
    LFieldList.Free;
  end;
  // Index orientation
  case AIndexOrientation of
    ioAscending:
      Result := Result + '_A';
    ioDescending:
      Result := Result + '_D';
  end;
  // Unique
  if AUnique then
    Result := Result + '_U';
  // Translate
  Result := TioSqlTranslator.Translate(Result, AContext.GetClassRef.ClassName, False);
end;

class procedure TioSqlGenerator.GenerateSqlCount(const AQuery: IioQuery; const AContext: IioContext);
begin
  // Build the query text
  // -----------------------------------------------------------------
  // Select Count From
  AQuery.SQL.Add('SELECT COUNT(*) FROM ' + AContext.GetTable.GetSQL);
  // Join
  AQuery.SQL.Add(AContext.GetTable.GetJoin.GetSQL);
  // If a Where exist then the query is an external query else
  // is an internal query.
  if AContext.WhereExist then
    AQuery.SQL.Add(AContext.Where.GetSqlWithTrueClass(AContext.Map, AContext.IsTrueClass, AContext.GetTrueClass))
  else
    AQuery.SQL.Add(Format('WHERE %s := %s', [AContext.GetProperties.GetIdProperty.GetSqlFieldName, AContext.GetProperties.GetIdProperty.GetSqlWhereParamName]));
  // GroupBy
  AQuery.SQL.Add(AContext.GetGroupBySql);
end;

class procedure TioSqlGenerator.GenerateSqlDelete(const AQuery: IioQuery; const AContext: IioContext);
begin
  // Build the query text
  // -----------------------------------------------------------------
  AQuery.SQL.Add('DELETE FROM ' + AContext.GetTable.GetSQL);
  // If a Where exist then the query is an external query else
  // is an internal query.
  if AContext.WhereExist then
    // AQuery.SQL.Add(AContext.Where.GetSql(AContext.Map))
    AQuery.SQL.Add(AContext.Where.GetSqlWithTrueClass(AContext.Map, AContext.IsTrueClass, AContext.GetTrueClass))
  else
    AQuery.SQL.Add('WHERE ' + AContext.GetProperties.GetIdProperty.GetSqlFieldName + '=:' + AContext.GetProperties.GetIdProperty.GetSqlWhereParamName);
  // -----------------------------------------------------------------
end;

class procedure TioSqlGenerator.GenerateSqlInsert(const AQuery: IioQuery; const AContext: IioContext);
var
  LInsertFields, LInsertValues: String;
  LComma: String;
  LIDIsNull: Boolean;
  LProp: IioProperty;
begin
  // Prepare fields and values
  LComma := '';
  LInsertFields := '';
  LInsertValues := '';
  LIDIsNull := AContext.IdIsNull;
  for LProp in AContext.GetProperties do
    if LProp.IsSqlInsertRequestCompliant(LIDIsNull) then
    begin
      LInsertFields := LInsertFields + LComma + LProp.GetSqlFieldName;
      LInsertValues := LInsertValues + LComma + ':' + LProp.GetSqlParamName;
      LComma := ', ';
    end;
  // Build the query text
  // -----------------------------------------------------------------
  AQuery.SQL.Add('INSERT INTO ' + AContext.GetTable.GetSQL);
  AQuery.SQL.Add('(');
  // Add field list (TrueClass if enabled)
  AQuery.SQL.Add(LInsertFields);
  if AContext.IsTrueClass then
    AQuery.SQL.Add(',' + AContext.GetTrueClass.GetSqlFieldName);
  // -----------------------------------------------------------------
  AQuery.SQL.Add(') VALUES (');
  // -----------------------------------------------------------------
  // Add values (TrueClass if enabled)
  AQuery.SQL.Add(LInsertValues);
  if AContext.IsTrueClass then
    AQuery.SQL.Add(',:' + AContext.GetTrueClass.GetSqlParamName);
  AQuery.SQL.Add(')');
  // -----------------------------------------------------------------
end;

class procedure TioSqlGenerator.GenerateSqlUpdate(const AQuery: IioQuery; const AContext: IioContext);
var
  LProp: IioProperty;
  LComma: String;
begin
  // Build the query text
  // -----------------------------------------------------------------
  AQuery.SQL.Add('UPDATE ' + AContext.GetTable.GetSQL + ' SET');
  // Add properties
  LComma := '';
  for LProp in AContext.GetProperties do
    if LProp.IsSqlUpdateRequestCompliant then
    begin
      AQuery.SQL.Add(LComma + LProp.GetSqlFieldName + ' = :' + LProp.GetSqlParamName);
      LComma := ', ';
    end;
  // Add the ioTrueClass if enabled
  if AContext.IsTrueClass then
    AQuery.SQL.Add(',' + AContext.GetTrueClass.GetSqlFieldName + '=:' + AContext.GetTrueClass.GetSqlParamName);
  // Where conditions (with ObjVersion if exists for this entity type)
  AQuery.SQL.Add('WHERE ' + AContext.GetProperties.GetIdProperty.GetSqlFieldName + '=:' + AContext.GetProperties.GetIdProperty.GetSqlWhereParamName);
  if AContext.GetProperties.ObjVersionPropertyExist then
    AQuery.SQL.Add('AND ' + AContext.GetProperties.ObjVersionProperty.GetSqlFieldName + '=:' + AContext.GetProperties.ObjVersionProperty.GetSqlWhereParamName);
  // -----------------------------------------------------------------
end;

class function TioSqlGenerator.GenerateSqlJoinSectionItem(const AJoinItem: IioJoinItem): String;
begin
  // Join
  case AJoinItem.GetJoinType of
    jtCross:
      Result := 'CROSS JOIN ';
    jtInner:
      Result := 'INNER JOIN ';
    jtLeftOuter:
      Result := 'LEFT OUTER JOIN ';
    jtRightOuter:
      Result := 'RIGHT OUTER JOIN ';
    jtFullOuter:
      Result := 'FULL OUTER JOIN ';
  else
    raise EioException.Create(Self.ClassName + ': Join type not valid.');
  end;
  // Joined table name
  Result := Result + '[' + AJoinItem.GetJoinClassRef.ClassName + ']';
  // Conditions
  if AJoinItem.GetJoinType <> jtCross then
    Result := Result + ' ON (' + AJoinItem.GetJoinCondition + ')';
end;

class procedure TioSqlGenerator.GenerateSqlSelect(const AQuery: IioQuery; const AContext: IioContext);
var
  LProp: IioProperty;
  LComma: String;
begin
  // Build the query text
  // -----------------------------------------------------------------
  // Select
  AQuery.SQL.Add('SELECT');
  // Field list
  LComma := '';
  for LProp in AContext.GetProperties do
    if LProp.IsSqlSelectRequestCompliant then
    begin
      if LProp.LoadSqlExist then
        AQuery.SQL.Add(LComma + LProp.GetLoadSql)
      else
        AQuery.SQL.Add(LComma + LProp.GetSqlFullQualifiedFieldName);
      LComma := ', ';
    end;
  // TrueClass
  if AContext.IsTrueClass then
    AQuery.SQL.Add(',' + AContext.GetTrueClass.GetSqlFieldName);
  // From
  AQuery.SQL.Add('FROM ' + AContext.GetTable.GetSQL);
  // Join
  AQuery.SQL.Add(AContext.GetTable.GetJoin.GetSQL);
  // If a Where exist then the query is an external query else
  // is an internal query.
  if AContext.WhereExist then
    AQuery.SQL.Add(AContext.Where.GetSqlWithTrueClass(AContext.Map, AContext.IsTrueClass, AContext.GetTrueClass))
  else
    AQuery.SQL.Add(Format('WHERE %s := %s', [AContext.GetProperties.GetIdProperty.GetSqlFieldName, AContext.GetProperties.GetIdProperty.GetSqlWhereParamName]));
  // GroupBy
  AQuery.SQL.Add(AContext.GetGroupBySql);
  // OrderBy
  AQuery.SQL.Add(AContext.GetOrderBySql);
end;

class function TioSqlGenerator.GenerateSqlSelectNestedWhere_OLD(const AMap: IioMap; const ANestedCriteria: IioSqlItemCriteria): String;
var
  LDotPos: Integer;
  FQualifiedStartingPropertyName: String;
  procedure _RecursiveGenerateNestedWhere(const NMasterMap: IioMap; const NNestedPropName: String; const NPreviousBuildingResult: String;
    var NFinalResult: String; const NIsFirstLoop: Boolean);
  var
    LFirstDotPos, LSecondDotPos: Integer;
    LMasterPropName, LDetailPropName, LRemainingPropName, LTempPropName: String;
    LDetailMap: IioMap;
    LMasterProp, LDetailProp, LRelationChildProp: IioProperty;
    LResolvedTypeList: IioResolvedTypeList;
    LResolvedTypeName: String;
    LCurrentBuildingResult: String;
    LIsFinalLoop: Boolean;
  begin
    // Extract the position of the first and second dots in the ANestedPropName string parameter
    // and set the RemainingPropName for the next recursion if needed,
    // if the second dot does not exists then set its position to the length of the whole string and stop the recursion
    LFirstDotPos := Pos('.', NNestedPropName);
    LSecondDotPos := PosEx('.', NNestedPropName, LFirstDotPos + 1);
    LRemainingPropName := String.Empty;
    if LSecondDotPos > 0 then
      LRemainingPropName := Copy(NNestedPropName, LFirstDotPos + 1, Length(NNestedPropName))
    else
      LSecondDotPos := NNestedPropName.Length + 1;
    // Get the master and detail prop name
    LMasterPropName := Copy(NNestedPropName, 1, LFirstDotPos - 1);
    LDetailPropName := Copy(NNestedPropName, LFirstDotPos + 1, LSecondDotPos - LFirstDotPos - 1);
    // Get the master property
    LMasterProp := NMasterMap.GetProperties.GetPropertyByName(LMasterPropName);
    // Resolve the type and alias then loop for all classes in the resolved type list
    LResolvedTypeList := TioResolverFactory.GetResolver(rsByDependencyInjection).Resolve(LMasterProp.GetRelationChildTypeName,
      LMasterProp.GetRelationChildTypeAlias, rmAllDistinctByConnectionAndTable);
    for LResolvedTypeName in LResolvedTypeList do
    begin
      // Get the detail Map but if the current resolved class is not a persisted entity then skip it
      LDetailMap := TioMapContainer.GetMap(LResolvedTypeName);
      if LDetailMap.GetTable.IsNotPersistedEntity then
        Continue;
      // Get the detail Property but if not exists in the current resolved class then skip it
      if not LDetailMap.GetProperties.PropertyExists(LDetailPropName) then
        Continue;
      LDetailProp := LDetailMap.GetProperties.GetPropertyByName(LDetailPropName);
      // If the current resolved type is not for the same connection the skip it
      if not LDetailMap.GetTable.IsForThisConnection(NMasterMap.GetTable.GetConnectionDefName) then
        Continue;
      // If the LRemainingPropName is empty then we are in the final loop (recursion is ending)
      LIsFinalLoop := LRemainingPropName.IsEmpty;
      // Get the relation type
      // NB: If the relation type of the DetailProp is rtHasMany/rtHasOne then use it else use those of the MasterProp
      // if (LDetailProp.GetRelationType = rtHasMany) or (LDetailProp.GetRelationType = rtHasOne) then
      // LRelationType := LDetailProp.GetRelationType
      // else
      // LRelationType := LMasterProp.GetRelationType;
      // Depending on relation type...
      case LMasterProp.GetRelationType of
        // BelongsTo relation type...
        rtBelongsTo:
          if LIsFinalLoop then
            NFinalResult := Format('%s%s(SELECT %s FROM %s WHERE %s = %s)%s%s', [NFinalResult, IfThen(NFinalResult.IsEmpty, '', ' OR '),
              LDetailProp.GetSqlQualifiedFieldName, LDetailMap.GetTable.GetSQL, LDetailMap.GetProperties.GetIdProperty.GetSqlQualifiedFieldName,
              NPreviousBuildingResult, ANestedCriteria.CompareOpSqlItem.GetSQL, ANestedCriteria.ValueSqlItem.GetSQL(LDetailMap)])
          else
          begin
            if (LDetailProp.GetRelationType = rtHasMany) or (LDetailProp.GetRelationType = rtHasOne) then
              LTempPropName := LDetailMap.GetProperties.GetIdProperty.GetSqlQualifiedFieldName
            else
              LTempPropName := LDetailProp.GetSqlQualifiedFieldName;
            LCurrentBuildingResult := Format('(SELECT %s FROM %s WHERE %s = %s)', [LTempPropName, LDetailMap.GetTable.GetSQL,
              LDetailMap.GetProperties.GetIdProperty.GetSqlQualifiedFieldName, NPreviousBuildingResult]);
            _RecursiveGenerateNestedWhere(LDetailMap, LRemainingPropName, LCurrentBuildingResult, NFinalResult, False); // Recursion
          end;
        // HasOne or HasMany relation type
        rtHasMany, rtHasOne:
          begin
            LRelationChildProp := LDetailMap.GetProperties.GetPropertyByName(LMasterProp.GetRelationChildPropertyName);
            if LIsFinalLoop then
              NFinalResult := Format('%s%sEXISTS (SELECT 1 FROM %s WHERE %s = %s AND %s %s %s)', [NFinalResult, IfThen(NFinalResult.IsEmpty, '', ' OR '),
                LDetailMap.GetTable.GetSQL, LRelationChildProp.GetSqlQualifiedFieldName,
                IfThen(NIsFirstLoop, NMasterMap.GetProperties.GetIdProperty.GetSqlQualifiedFieldName, NPreviousBuildingResult),
                LDetailProp.GetSqlQualifiedFieldName, ANestedCriteria.CompareOpSqlItem.GetSQL, ANestedCriteria.ValueSqlItem.GetSQL(LDetailMap)])
            else
            begin
              LCurrentBuildingResult := Format('(SELECT %s FROM %s WHERE %s = %s)', [LDetailMap.GetProperties.GetIdProperty.GetSqlQualifiedFieldName,
                LDetailMap.GetTable.GetSQL, LRelationChildProp.GetSqlQualifiedFieldName, NMasterMap.GetProperties.GetIdProperty.GetSqlQualifiedFieldName]);
              _RecursiveGenerateNestedWhere(LDetailMap, LRemainingPropName, LCurrentBuildingResult, NFinalResult, False); // Recursion
            end;
          end;
      else
        raise EioException.Create(ClassName, 'GenerateSqlSelectNestedWhere', Format('Wrong relation type (%s) on property "%s" of class "%s"',
          [TioUtilities.EnumToString<TioRelationType>(LMasterProp.GetRelationType), LMasterProp.GetName, NMasterMap.GetClassName]));
      end;
    end;
  end;

begin
  Result := String.Empty;
  LDotPos := Pos('.', ANestedCriteria.PropertyName);
  if LDotPos > 0 then
  begin
    // Ricorda che il parametro "NPreviousBuildingResult" deve essere valorizzato con il GetSqlQualifiedFieldName della propriet� di inizio (es: ORDER.CUSTOMER)
    // Extract the qualified name of the first property in the nested property name
    FQualifiedStartingPropertyName := Copy(ANestedCriteria.PropertyName, 1, LDotPos - 1);
    FQualifiedStartingPropertyName := AMap.GetProperties.GetPropertyByName(FQualifiedStartingPropertyName).GetSqlQualifiedFieldName;
    // Recursion entry point and final build of the result
    _RecursiveGenerateNestedWhere(AMap, ANestedCriteria.PropertyName, FQualifiedStartingPropertyName, Result, True);
    Result := Format('(%s)', [Result]);
  end
  else
    raise EioException.Create(ClassName, 'GenerateSqlSelectNestedWhere', 'Dot char not found on nested property name.');
end;

class procedure TioSqlGenerator.LoadSqlParamsFromContext(const AQuery: IioQuery; const AContext: IioContext);
var
  Prop: IioProperty;
begin
  // Load query parameters from context
  for Prop in AContext.GetProperties do
    if Prop.IsBlob then
      AQuery.ParamByProp_LoadAsStreamObj(Prop.GetValue(AContext.DataObject).AsObject, Prop);
end;

{ TioConnectionInfo }

constructor TioConnectionInfo.Create(const AConnectionName: String; const AConnectionType: TioConnectionType;
  const APersistent: Boolean); // const AKeyGenerationTime: TioKeyGenerationTime);
begin
  FConnectionName := AConnectionName;
  FConnectionType := AConnectionType;
//  FKeyGenerationTime := AKeyGenerationTime;
  FPersistent := APersistent;
  FStrategy := TioStrategyFactory.ConnectionTypeToStrategy(AConnectionType);
end;

//function TioConnectionInfo.GetBaseURL: string;
//begin
//  Result := FBaseURL;
//end;

function TioConnectionInfo.GetConnectionName: string;
begin
  Result := FConnectionName;
end;

function TioConnectionInfo.GetConnectionType: TioConnectionType;
begin
  Result := FConnectionType;
end;

//function TioConnectionInfo.GetKeyGenerationTime: TioKeyGenerationTime;
//begin
//  Result := FKeyGenerationTime;
//end;

function TioConnectionInfo.GetPassword: string;
begin
  Result := FPassword;
end;

function TioConnectionInfo.GetPersistent: Boolean;
begin
  Result := FPersistent;
end;

function TioConnectionInfo.GetStrategy: TioStrategyRef;
begin
  Result := FStrategy;
end;

function TioConnectionInfo.GetUserName: String;
begin
  Result := FUserName;
end;

{ TioCompareOperator }

class function TioCompareOperator.CompareOpToCompareOperator(const ACompareOp: TioCompareOp): IioSqlItem;
begin
  case ACompareOp of
    coEquals:
      Result := _Equal;
    coNotEquals:
      Result := _NotEqual;
    coGreater:
      Result := _Greater;
    coLower:
      Result := _Lower;
    coGreaterOrEqual:
      Result := _GreaterOrEqual;
    coLowerOrEqual:
      Result := _LowerOrEqual;
    coLike:
      Result := _Like;
    coNotLike:
      Result := _NotLike;
    coIsNull:
      Result := _IsNull;
    coIsNotNull:
      Result := _IsNotNull;
  else
    raise EioException.Create(Self.ClassName, 'CompareOpToCompareOperator', Format('Invalid CompareOp value "%s"',
      [TioUtilities.EnumToString<TioCompareOp>(ACompareOp)]));
  end;
end;

class function TioCompareOperator._Equal: IioSqlItem;
begin
  Result := TioSqlItem.Create(' = ');
end;

class function TioCompareOperator._Greater: IioSqlItem;
begin
  Result := TioSqlItem.Create(' > ');
end;

class function TioCompareOperator._GreaterOrEqual: IioSqlItem;
begin
  Result := TioSqlItem.Create(' >= ');
end;

class function TioCompareOperator._IsNotNull: IioSqlItem;
begin
  Result := TioSqlItem.Create(' IS NOT NULL ');
end;

class function TioCompareOperator._IsNull: IioSqlItem;
begin
  Result := TioSqlItem.Create(' IS NULL ');
end;

class function TioCompareOperator._Like: IioSqlItem;
begin
  Result := TioSqlItem.Create(' LIKE ');
end;

class function TioCompareOperator._Lower: IioSqlItem;
begin
  Result := TioSqlItem.Create(' < ');
end;

class function TioCompareOperator._LowerOrEqual: IioSqlItem;
begin
  Result := TioSqlItem.Create(' <= ');
end;

class function TioCompareOperator._NotEqual: IioSqlItem;
begin
  Result := TioSqlItem.Create(' <> ');
end;

class function TioCompareOperator._NotLike: IioSqlItem;
begin
  Result := TioSqlItem.Create(' NOT LIKE ');
end;

{ TioLogicRelation }

class function TioLogicRelation.LogicOpToLogicRelation(const ALogicOp: TioLogicOp): IioSqlItem;
begin
  case ALogicOp of
    loAnd:
      Result := _And;
    loOr:
      Result := _Or;
    loNot:
      Result := _Not;
    loOpenPar:
      Result := _OpenPar;
    loClosePar:
      Result := _ClosePar;
  else
    raise EioException.Create(Self.ClassName, 'LogicOpToLogicRelation', Format('Invalid LogicOp value "%s"',
      [TioUtilities.EnumToString<TioLogicOp>(ALogicOp)]));
  end;
end;

class function TioLogicRelation._And: IioSqlItem;
begin
  Result := TioSqlItem.Create(' AND ');
end;

class function TioLogicRelation._ClosePar: IioSqlItem;
begin
  Result := TioSqlItem.Create(')');
end;

class function TioLogicRelation._Not: IioSqlItem;
begin
  Result := TioSqlItem.Create(' NOT ');
end;

class function TioLogicRelation._OpenPar: IioSqlItem;
begin
  Result := TioSqlItem.Create('(');
end;

class function TioLogicRelation._Or: IioSqlItem;
begin
  Result := TioSqlItem.Create(' OR ');
end;

{ TioStrategyIntf }

class procedure TioStrategyIntf.DeleteList(const AList: TObject);
{$IFNDEF ioStrategyInterceptorsOff}
var
  LDone: Boolean;
{$ENDIF}
begin
{$IFNDEF ioStrategyInterceptorsOff}
  LDone := False;
  TioStrategyInterceptorRegister.BeforeDeleteList(AList, LDone);
  if LDone then
    Exit;
{$ENDIF}
  _DoDeleteList(AList);
{$IFNDEF ioStrategyInterceptorsOff}
  TioStrategyInterceptorRegister.AfterDeleteList(AList);
{$ENDIF}
end;

class procedure TioStrategyIntf.DeleteObject(const AObj: TObject);
{$IFNDEF ioStrategyInterceptorsOff}
var
  LDone: Boolean;
{$ENDIF}
begin
{$IFNDEF ioStrategyInterceptorsOff}
  LDone := False;
  TioStrategyInterceptorRegister.BeforeDeleteObject(AObj, LDone);
  if LDone then
    Exit;
{$ENDIF}
  _DoDeleteObject(AObj);
{$IFNDEF ioStrategyInterceptorsOff}
  TioStrategyInterceptorRegister.AfterDeleteObject(AObj);
{$ENDIF}
end;

class procedure TioStrategyIntf.LoadList(const AWhere: IioWhere; const AList: TObject);
{$IFNDEF ioStrategyInterceptorsOff}
var
  LDone: Boolean;
{$ENDIF}
begin
{$IFNDEF ioStrategyInterceptorsOff}
  LDone := False;
  TioStrategyInterceptorRegister.BeforeLoadList(AWhere, AList, LDone);
  if LDone then
    Exit;
{$ENDIF}
  _DoLoadList(AWhere, AList);
{$IFNDEF ioStrategyInterceptorsOff}
  TioStrategyInterceptorRegister.AfterLoadList(AWhere, AList);
{$ENDIF}
end;

class function TioStrategyIntf.LoadObject(const AWhere: IioWhere; const AObj: TObject): TObject;
{$IFNDEF ioStrategyInterceptorsOff}
var
  LDone: Boolean;
{$ENDIF}
begin
  Result := AObj;
{$IFNDEF ioStrategyInterceptorsOff}
  LDone := False;
  Result := TioStrategyInterceptorRegister.BeforeLoadObject(AWhere, Result, LDone);
  if LDone then
    Exit;
{$ENDIF}
  Result := _DoLoadObject(AWhere, Result);
{$IFNDEF ioStrategyInterceptorsOff}
  Result := TioStrategyInterceptorRegister.AfterLoadObject(AWhere, Result);
{$ENDIF}
end;

class procedure TioStrategyIntf.PersistList(const AList: TObject; const ARelationPropertyName: String; const ARelationOID: Integer; const ABlindInsert: Boolean;
  const AMasterBSPersistence: TioBSPersistence; const AMasterPropertyName, AMasterPropertyPath: String);
{$IFNDEF ioStrategyInterceptorsOff}
var
  LDone: Boolean;
{$ENDIF}
begin
{$IFNDEF ioStrategyInterceptorsOff}
  LDone := False;
  TioStrategyInterceptorRegister.BeforePersistList(AList, LDone);
  if LDone then
    Exit;
{$ENDIF}
  _DoPersistList(AList, ARelationPropertyName, ARelationOID, ABlindInsert, AMasterBSPersistence, AMasterPropertyName, AMasterPropertyPath);
{$IFNDEF ioStrategyInterceptorsOff}
  TioStrategyInterceptorRegister.AfterPersistList(AList);
{$ENDIF}
end;

class procedure TioStrategyIntf.PersistObject(const AObj: TObject; const ARelationPropertyName: String; const ARelationOID: Integer;
  const ABlindInsert: Boolean; const AMasterBSPersistence: TioBSPersistence; const AMasterPropertyName, AMasterPropertyPath: String);
{$IFNDEF ioStrategyInterceptorsOff}
var
  LDone: Boolean;
{$ENDIF}
begin
{$IFNDEF ioStrategyInterceptorsOff}
  LDone := False;
  TioStrategyInterceptorRegister.BeforePersistObject(AObj, LDone);
  if LDone then
    Exit;
{$ENDIF}
  _DoPersistObject(AObj, ARelationPropertyName, ARelationOID, ABlindInsert, AMasterBSPersistence, AMasterPropertyName, AMasterPropertyPath);
{$IFNDEF ioStrategyInterceptorsOff}
  TioStrategyInterceptorRegister.AfterPersistObject(AObj);
{$ENDIF}
end;

{ TioHTTPConnectionInfo }

constructor TioHTTPConnectionInfo.Create(const AConnectionName: String; const APersistent: Boolean; ABaseURL: String);
begin
  inherited Create(AConnectionName, ctHTML, APersistent);

  FBaseURL := ABaseURL;
end;

function TioHTTPConnectionInfo.GetBaseURL: string;
begin
  Result := FBaseURL;
end;

{ TioDBConnectionInfo }

constructor TioDBConnectionInfo.Create(const AConnectionName: String; const AConnectionType: TioConnectionType;
  const APersistent: Boolean; const AKeyGenerationTime: TioKeyGenerationTime{; const ACharSet, ACollation: String;
  const QuotedIdentifiers: Boolean});
begin
  if AConnectionType = ctHTML then
    raise EioException.Create(Self.ClassName, 'Create', Format('Invalid ConnectionType value "%s" for database connection',
      [TioUtilities.EnumToString<TioConnectionType>(AConnectionType)]));

  inherited Create(AConnectionName, AConnectionType, APersistent);

//  FCharSet := ACharSet;
//  FCollation := ACollation;
  FKeyGenerationTime := AKeyGenerationTime;
  FQuotedIdentifiers := QuotedIdentifiers;
end;

function TioDBConnectionInfo.GetCharSet: string;
begin
  Result := FCharSet;
end;

function TioDBConnectionInfo.GetCollation: String;
begin
  Result := FCollation;
end;

function TioDBConnectionInfo.GetKeyGenerationTime: TioKeyGenerationTime;
begin
  Result := FKeyGenerationTime;
end;

function TioDBConnectionInfo.GetQuotedIdentifiers: Boolean;
begin
  Result := FQuotedIdentifiers;
end;

end.
