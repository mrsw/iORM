{ *************************************************************************** }
{ }
{ iORM - (interfaced ORM) }
{ }
{ Copyright (C) 2015-2016 Maurizio Del Magno }
{ }
{ mauriziodm@levantesw.it }
{ mauriziodelmagno@gmail.com }
{ https://github.com/mauriziodm/iORM.git }
{ }
{ }
{ *************************************************************************** }
{ }
{ This file is part of iORM (Interfaced Object Relational Mapper). }
{ }
{ Licensed under the GNU Lesser General Public License, Version 3; }
{ you may not use this file except in compliance with the License. }
{ }
{ iORM is free software: you can redistribute it and/or modify }
{ it under the terms of the GNU Lesser General Public License as published }
{ by the Free Software Foundation, either version 3 of the License, or }
{ (at your option) any later version. }
{ }
{ iORM is distributed in the hope that it will be useful, }
{ but WITHOUT ANY WARRANTY; without even the implied warranty of }
{ MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the }
{ GNU Lesser General Public License for more details. }
{ }
{ You should have received a copy of the GNU Lesser General Public License }
{ along with iORM.  If not, see <http://www.gnu.org/licenses/>. }
{ }
{ *************************************************************************** }

unit iORM.Context.Properties;

interface

uses
  iORM.Context.Properties.Interfaces,
  iORM.CommonTypes,
  iORM.Attributes,
  iORM.SqlItems,
  System.Rtti,
  System.Generics.Collections, iORM.Context.Table.Interfaces, System.Classes,
  System.TypInfo;

type

  // Classe che rappresenta una propriet�
  TioProperty = class(TInterfacedObject, IioProperty)
  strict private
    FIsID: Boolean;
    FTransient: Boolean;
    FIDSkipOnInsert: Boolean;
    FRttiProperty: TRttiProperty;
    FTypeAlias: String;
    FFieldDefinitionString, FSqlFieldTableName, FSqlFieldName, FSqlFieldAlias: String;
    FLoadSql: String;
    FFieldType: String;
    FRelationType: TioRelationType;
    FRelationChildTypeName: String;
    FRelationChildTypeAlias: String;
    FRelationChildPropertyName: String;
    FRelationChildPropertyPath: TStrings;
    FRelationLoadType: TioLoadType;
    FNotHasMany: Boolean;
    FTable: IioTable;
    FReadWrite: TioLoadPersist;
    // M.M. 01/08/18 - MetadataType used by DBBuilder
    FMetadata_FieldType: TioMetadataFieldType;
    FMetadata_FieldLength: Integer;
    FMetadata_FieldPrecision: Integer;
    FMetadata_FieldScale: Integer;
    FMetadata_FieldNotNull: Boolean;
    FMetadata_FieldUnicode: Boolean;
    FMetadata_CustomFieldType: string;
    FMetadata_Default: TValue;
    FMetadata_FieldSubType: string;
    FMetadata_FKCreate: TioFKCreate;
    FMetadata_FKOnDeleteAction: TioFKAction;
    FMetadata_FKOnUpdateAction: TioFKAction;
    procedure SetRelationChildNameAndPath(const AQualifiedChildPropertyName: String);
    procedure SetFieldData;
    procedure SetLoadSqlData;
  strict protected
    constructor Create(const ATable: IioTable; const ATypeAlias, AFieldDefinitionString, ALoadSql, AFieldType: String;
      const ATransient, AIsID, AIDSkipOnInsert: Boolean; const AReadWrite: TioLoadPersist; const ARelationType: TioRelationType;
      const ARelationChildTypeName, ARelationChildTypeAlias, ARelationChildPropertyName: String; const ARelationLoadType: TioLoadType;
      const ANotHasMany: Boolean; const AMetadata_FieldType: TioMetadataFieldType; const AMetadata_FieldLength: Integer;
      const AMetadata_FieldPrecision: Integer; const AMetadata_FieldScale: Integer; const AMetadata_FieldNotNull: Boolean; const AMetadata_Default: TValue;
      const AMetadata_FieldUnicode: Boolean; const AMetadata_CustomFieldType: string; const AMetadata_FieldSubType: string;
      const AMetadata_FKCreate: TioFKCreate; const AMetadata_FKOnDeleteAction, AMetadata_FKOnUpdateAction: TioFKAction); overload;
  public
    constructor Create(const ARttiProperty: TRttiProperty; const ATable: IioTable;
      const ATypeAlias, AFieldDefinitionString, ALoadSql, AFieldType: String; const ATransient, AIsID, AIDSkipOnInsert: Boolean;
      const AReadWrite: TioLoadPersist; const ARelationType: TioRelationType; const ARelationChildTypeName, ARelationChildTypeAlias,
      ARelationChildPropertyName: String; const ARelationLoadType: TioLoadType; const ANotHasMany: Boolean; const AMetadata_FieldType: TioMetadataFieldType;
      const AMetadata_FieldLength: Integer; const AMetadata_FieldPrecision: Integer; const AMetadata_FieldScale: Integer; const AMetadata_FieldNotNull: Boolean;
      const AMetadata_Default: TValue; const AMetadata_FieldUnicode: Boolean; const AMetadata_CustomFieldType: string; const AMetadata_FieldSubType: string;
      const AMetadata_FKCreate: TioFKCreate; const AMetadata_FKOnDeleteAction, AMetadata_FKOnUpdateAction: TioFKAction); overload;
    function GetLoadSql: String;
    function LoadSqlExist: Boolean;
    function GetName: String; virtual;
    function GetSqlQualifiedFieldName: String;
    function GetSqlFullQualifiedFieldName: String;
    function GetSqlFieldTableName: String;
    function GetSqlFieldName(const AClearDelimiters: Boolean = False): String; virtual;
    function GetSqlFieldAlias: String; virtual;
    function GetSqlParamName: String; virtual;
    function GetSqlWhereParamName: String; virtual;
    function GetFieldType: String;
    function GetValue(const Instance: Pointer): TValue; virtual;
    function GetValueAsObject(const Instance: Pointer): TObject; virtual;
    procedure SetValue(const Instance: Pointer; const AValue: TValue); virtual;
    function GetSqlValue(const ADataObject: TObject): String;
    function GetRttiType: TRttiType; virtual;
    function GetTypeInfo: PTypeInfo; virtual;
    function GetTypeName: String;
    function GetTypeAlias: String;
    function GetRelationType: TioRelationType;
    function GetRelationChildTypeName: String;
    function GetRelationChildTypeAlias: String;
    function GetRelationChildPropertyName: String;
    function RelationChildPropertyPathAssigned: Boolean;
    function GetRelationChildPropertyPath: TStrings;
    function GetRelationLoadType: TioLoadType;
    function GetRelationChildObject(const Instance: Pointer; const AResolvePropertyPath: Boolean = True): TObject;
    function GetRelationChildObjectID(const Instance: Pointer): Integer;
    procedure SetTable(const ATable: IioTable);
    procedure SetIsID(const AValue: Boolean);
    procedure SetIDSkipOnInsert(const AIDSkipOnInsert: Boolean);
    function IDSkipOnInsert: Boolean;

    function IsSqlRequestCompliant(const ASqlRequestType: TioSqlRequestType): Boolean;
    function IsID: Boolean;
    function IsInterface: Boolean;
    function IsDBWriteEnabled: Boolean;
    function IsDBReadEnabled: Boolean;
    function IsInstance: Boolean;
    function IsWritable: Boolean; virtual;
    function IsTransient: Boolean;
    function IsBlob: Boolean;
    function IsStream: Boolean;
    function HasAutodetectedHasManyRelation: Boolean;
    function isHasManyChildVirtualProperty: Boolean; virtual;

    procedure SetMetadata_FieldType(const AMetadata_FieldType: TioMetadataFieldType);
    procedure SetMetadata_FieldLength(const AMetadata_FieldLength: Integer);
    procedure SetMetadata_FieldPrecision(const AMetadata_FieldPrecision: Integer);
    procedure SetMetadata_FieldScale(const AMetadata_FieldScale: Integer);
    procedure SetMetadata_FieldNotNull(const AMetadata_FieldNotNull: Boolean);
    procedure SetMetadata_FieldUnicode(const AMetadata_FieldUnicode: Boolean);
    procedure SetMetadata_CustomFieldType(const AMetadata_CustomFieldType: string);
    procedure SetMetadata_FKCreate(const AMetadata_FKCreate: TioFKCreate);
    procedure SetMetadata_FieldSubType(const AMetadata_FieldSubType: string);
    procedure SetMetadata_Default(const AMetadata_Default: TValue);
    procedure SetMetadata_FKOnDeleteAction(const AOnDeleteAction: TioFKAction);
    procedure SetMetadata_FKOnUpdateAction(const AOnUpdateAction: TioFKAction);
    function GetMetadata_FieldType: TioMetadataFieldType;
    function GetMetadata_FieldLength: Integer;
    function GetMetadata_FieldPrecision: Integer;
    function GetMetadata_FieldScale: Integer;
    function GetMetadata_FieldNotNull: Boolean;
    function GetMetadata_FieldUnicode: Boolean;
    function GetMetadata_CustomFieldType: string;
    function GetMetadata_FieldSubType: string;
    function GetMetadata_Default: TValue;
    function GetMetadata_FKCreate: TioFKCreate;
    function GetMetadata_FKOnDeleteAction: TioFKAction;
    function GetMetadata_FKOnUpdateAction: TioFKAction;
  end;

  // Autodetected HasMany relation child virtual property (foreign key)
  TioHasManyChildVirtualProperty = class(TioProperty)
  strict private
    FRttiType: TRttiType;
  public
    constructor Create(const ATable: IioTable);
    function GetName: String; override;
    function GetSqlFieldName(const AClearDelimiters: Boolean = False): String; override;
    function GetSqlFieldAlias: String; override;
    function GetSqlParamName: String; override;
    function GetSqlWhereParamName: String; override;
    function GetValue(const Instance: Pointer): TValue; override;
    procedure SetValue(const Instance: Pointer; const AValue: TValue); override;
    function GetRttiType: TRttiType; override;
    function GetTypeInfo: PTypeInfo; override;
    function IsWritable: Boolean; override;
    function isHasManyChildVirtualProperty: Boolean; override;
  end;

  // Classe che rappresenta un field della classe
  TioField = class(TioProperty)
  strict private
    FRttiProperty: TRttiField;
    FName: String;
  public
    constructor Create(const ARttiField: TRttiField; const ATable: IioTable; const ATypeAlias, AFieldDefinitionString, ALoadSql, AFieldType: String;
      const ATransient, AIsID, AIDSkipOnInsert: Boolean; const AReadWrite: TioLoadPersist; const ARelationType: TioRelationType;
      const ARelationChildTypeName, ARelationChildTypeAlias, ARelationChildPropertyName: String; const ARelationLoadType: TioLoadType;
      const ANotHasMany: Boolean; const AMetadata_FieldType: TioMetadataFieldType; const AMetadata_FieldLength: Integer;
      const AMetadata_FieldPrecision: Integer; const AMetadata_FieldScale: Integer; const AMetadata_FieldNotNull: Boolean; const AMetadata_Default: TValue;
      const AMetadata_FieldUnicode: Boolean; const AMetadata_CustomFieldType: string; const AMetadata_FieldSubType: string;
      const AMetadata_FKCreate: TioFKCreate; const AMetadata_FKOnDeleteAction, AMetadata_FKOnUpdateAction: TioFKAction); overload;
    class function Remove_F_FromName(const AFieldName: String): String;
    function GetName: String; override;
    function GetValue(const Instance: Pointer): TValue; override;
    procedure SetValue(const Instance: Pointer; const AValue: TValue); override;
    function GetRttiType: TRttiType; override;
    function GetTypeInfo: PTypeInfo; override;
    function IsWritable: Boolean; override;
  end;

  // Classe con l'elenco delle propriet� della classe
  TioPropertiesGetSqlFunction = reference to function(AProperty: IioProperty): String;

  TioProperties = class(TioSqlItem, IioProperties)
  strict private
    FPropertyItems: TList<IioProperty>;
    FIdProperty: IioProperty;
    FObjStatusProperty: IioProperty;
    FObjVersionProperty: IioProperty;
    FBlobFieldExists: Boolean;
  private
    function InternalGetSql(const ASqlRequestType: TioSqlRequestType; const AFunc: TioPropertiesGetSqlFunction): String;
    // ObjStatus property
    function GetObjStatusProperty: IioProperty;
    procedure SetObjStatusProperty(const AValue: IioProperty);
    // ObjVersion property
    function GetObjVersionProperty: IioProperty;
    procedure SetObjVersionProperty(const AValue: IioProperty);
  public
    constructor Create; reintroduce;
    destructor Destroy; override;
    function GetEnumerator: TEnumerator<IioProperty>;
    function GetSql: String; reintroduce; overload;
    function GetSql(const ASqlRequestType: TioSqlRequestType = ioAll): String; reintroduce; overload;
    procedure Add(const AProperty: IioProperty);
    function PropertyExists(const APropertyName: String): Boolean;
    function GetIdProperty: IioProperty;
    function GetPropertyByName(const APropertyName: String): IioProperty;
    procedure SetTable(const ATable: IioTable);
    // Blob field present
    function BlobFieldExists: Boolean;
    // ObjectStatus Exist
    function ObjStatusExist: Boolean;
    // ObjectVersion Exist
    function ObjVersionExist: Boolean;
    function IsObjVersionProperty(const AProperty: IioProperty): Boolean;
    // ObjStatus property
    property ObjStatusProperty: IioProperty read GetObjStatusProperty write SetObjStatusProperty;
    // ObjVersion property
    property ObjVersionProperty: IioProperty read GetObjVersionProperty write SetObjVersionProperty;
  end;

implementation

uses
  iORM.Context.Interfaces,
  iORM.DB.Factory, iORM.Exceptions, System.SysUtils, iORM.SqlTranslator,
  System.StrUtils, iORM.Context.Map.Interfaces, iORM.Utilities,
  iORM.DB.ConnectionContainer, iORM.DB.Interfaces, iORM.Context.Container;

{ TioProperty }

constructor TioProperty.Create(const ARttiProperty: TRttiProperty; const ATable: IioTable;
  const ATypeAlias, AFieldDefinitionString, ALoadSql, AFieldType: String; const ATransient, AIsID, AIDSkipOnInsert: Boolean; const AReadWrite: TioLoadPersist;
  const ARelationType: TioRelationType; const ARelationChildTypeName, ARelationChildTypeAlias, ARelationChildPropertyName: String;
  const ARelationLoadType: TioLoadType; const ANotHasMany: Boolean; const AMetadata_FieldType: TioMetadataFieldType; const AMetadata_FieldLength: Integer;
  const AMetadata_FieldPrecision: Integer; const AMetadata_FieldScale: Integer; const AMetadata_FieldNotNull: Boolean; const AMetadata_Default: TValue;
  const AMetadata_FieldUnicode: Boolean; const AMetadata_CustomFieldType: string; const AMetadata_FieldSubType: string; const AMetadata_FKCreate: TioFKCreate;
  const AMetadata_FKOnDeleteAction, AMetadata_FKOnUpdateAction: TioFKAction);
begin
  // NB: No inherited here
  Self.Create(ATable, ATypeAlias, AFieldDefinitionString, ALoadSql, AFieldType, ATransient, AIsID, AIDSkipOnInsert, AReadWrite, ARelationType,
    ARelationChildTypeName, ARelationChildTypeAlias, ARelationChildPropertyName, ARelationLoadType, ANotHasMany, AMetadata_FieldType, AMetadata_FieldLength,
    AMetadata_FieldPrecision, AMetadata_FieldScale, AMetadata_FieldNotNull, AMetadata_Default, AMetadata_FieldUnicode, AMetadata_CustomFieldType,
    AMetadata_FieldSubType, AMetadata_FKCreate, AMetadata_FKOnDeleteAction, AMetadata_FKOnUpdateAction);

  FRttiProperty := ARttiProperty;
end;

constructor TioProperty.Create(const ATable: IioTable; const ATypeAlias, AFieldDefinitionString, ALoadSql, AFieldType: String;
  const ATransient, AIsID, AIDSkipOnInsert: Boolean; const AReadWrite: TioLoadPersist; const ARelationType: TioRelationType;
  const ARelationChildTypeName, ARelationChildTypeAlias, ARelationChildPropertyName: String; const ARelationLoadType: TioLoadType; const ANotHasMany: Boolean;
  const AMetadata_FieldType: TioMetadataFieldType; const AMetadata_FieldLength: Integer; const AMetadata_FieldPrecision: Integer;
  const AMetadata_FieldScale: Integer; const AMetadata_FieldNotNull: Boolean; const AMetadata_Default: TValue; const AMetadata_FieldUnicode: Boolean;
  const AMetadata_CustomFieldType: string; const AMetadata_FieldSubType: string; const AMetadata_FKCreate: TioFKCreate;
  const AMetadata_FKOnDeleteAction, AMetadata_FKOnUpdateAction: TioFKAction);
begin
  inherited Create;
  FTable := ATable;
  FTypeAlias := ATypeAlias;
  FFieldDefinitionString := AFieldDefinitionString;
  FFieldType := AFieldType;
  FTransient := ATransient;
  FIsID := AIsID;
  FIDSkipOnInsert := AIDSkipOnInsert;
  FReadWrite := AReadWrite;
  FLoadSql := ALoadSql;
  // Relation fields
  FRelationType := ARelationType;
  FRelationChildTypeName := ARelationChildTypeName;
  FRelationChildTypeAlias := ARelationChildTypeAlias;
  FRelationLoadType := ARelationLoadType;
  FNotHasMany := ANotHasMany;
  // M.M. 01/08/18 - MetadataType used by DBBuilder
  FMetadata_FieldType := AMetadata_FieldType;
  FMetadata_FieldLength := AMetadata_FieldLength;
  FMetadata_FieldPrecision := AMetadata_FieldPrecision;
  FMetadata_FieldScale := AMetadata_FieldScale;
  FMetadata_FieldNotNull := AMetadata_FieldNotNull;
  FMetadata_FieldUnicode := AMetadata_FieldUnicode;
  FMetadata_CustomFieldType := AMetadata_CustomFieldType;
  FMetadata_FieldSubType := AMetadata_FieldSubType;
  FMetadata_Default := AMetadata_Default;
  FMetadata_FKCreate := AMetadata_FKCreate;
  FMetadata_FKOnDeleteAction := AMetadata_FKOnDeleteAction;
  FMetadata_FKOnUpdateAction := AMetadata_FKOnUpdateAction;
  // Set the RelationChildPropertyName & RelationChildPropertyPath
  SetRelationChildNameAndPath(ARelationChildPropertyName);
  // --------------------------------
  // Quando si fa un Join in una classe (attributo ioJoin) poi nelle propriet� che ricevono il valore dai campi della
  //  joined class/table si deve usare anche l'attributo "ioField" per indicare ad iORM in che modo reperirne poi il
  //  valore anche in caso di ambiguit� dovuta campi con lo stesso nome nelle tabelle coinvolte.
  //  Esempio:
  // Classe: [ioJoin(jtInner, TCostGeneric, '[TCostGeneric.CostType] = [TCostType.ID]')]
  // Propriet�: >>>>>>>> [ioField('[TCostGeneric].TravelID')]  <<<<<<<<<
  // --------------------------------
  SetFieldData;
  // Translate the LoadSQLData statement if needed
  SetLoadSqlData;
end;

function TioProperty.GetFieldType: String;
begin
  // ================================================================================
  // NB: Questa funzione � usata solo da questa classe stessa (Self.IsBlob) e dalla
  // creazione automatica del DB per determinare il tipo di campo. Siccome
  // l'unicoDB per il quale � disponibile la creazione automatica del DB � SQLite
  // non � necessario che questa funzione si adatti ai diversi RDBMS e quindi la lascio
  // fissa cos�. Questo va bene anche all'interno della funzione Self.IsBlob
  // perch� questa verifica solo se il tipo comincia per BLOB e uesto va bene per
  // qualunque DB.
  // ================================================================================
  // If the FField is not empty then return it
  if not FFieldType.IsEmpty then
    Exit(FFieldType);
  // According to the RelationType of the property...
  case Self.GetRelationType of
    // Normal property, no relation, field type is by TypeKind of the property itself
    rtNone:
      begin
        case Self.GetRttiType.TypeKind of
          tkInt64, tkInteger, tkEnumeration:
            Result := 'INTEGER';
          tkFloat:
            Result := 'REAL';
          tkString, tkUString, tkWChar, tkLString, tkWString, tkChar:
            Result := 'TEXT';
          tkClass, tkInterface:
            Result := 'BLOB';
        end;
      end;
    // If it is an ioRTEmbedded property then the field type is always BLOB
    rtEmbeddedHasMany, rtEmbeddedHasOne:
      Result := 'BLOB';
    // If it's a BelongsTo relation property then field type is always INTEGER
    // because the ID fields always are INTEGERS values
    rtBelongsTo:
      Result := 'INTEGER';
    // Otherwise return NULL field type
  else
    Result := 'NULL';
  end;
end;

function TioProperty.GetLoadSql: String;
begin
  Result := '(' + Self.FLoadSql + ') AS ' + Self.GetSqlFieldAlias;
end;

function TioProperty.GetMetadata_CustomFieldType: string;
begin
  Result := FMetadata_CustomFieldType;
end;

function TioProperty.GetMetadata_Default: TValue;
begin
  Result := FMetadata_Default;
end;

function TioProperty.GetMetadata_FKCreate: TioFKCreate;
begin
  Result := FMetadata_FKCreate;
end;

function TioProperty.GetMetadata_FieldSubType: string;
begin
  Result := FMetadata_FieldSubType;
end;

function TioProperty.GetMetadata_FieldLength: Integer;
begin
  Result := FMetadata_FieldLength;
end;

function TioProperty.GetMetadata_FieldNotNull: Boolean;
begin
  Result := FMetadata_FieldNotNull or Self.IsID;
end;

function TioProperty.GetMetadata_FieldPrecision: Integer;
begin
  Result := FMetadata_FieldPrecision;
end;

function TioProperty.GetMetadata_FieldScale: Integer;
begin
  Result := FMetadata_FieldScale;
end;

function TioProperty.GetMetadata_FieldType: TioMetadataFieldType;
begin
  Result := FMetadata_FieldType;
end;

function TioProperty.GetMetadata_FieldUnicode: Boolean;
begin
  Result := FMetadata_FieldUnicode;
end;

function TioProperty.GetMetadata_FKOnDeleteAction: TioFKAction;
begin
  Result := FMetadata_FKOnDeleteAction;
end;

function TioProperty.GetMetadata_FKOnUpdateAction: TioFKAction;
begin
  Result := FMetadata_FKOnUpdateAction;
end;

function TioProperty.GetSqlFullQualifiedFieldName: String;
begin
  Result := GetSqlQualifiedFieldName + ' AS ' + FSqlFieldAlias;
end;

function TioProperty.GetName: String;
begin
  Result := FRttiProperty.Name;
end;

function TioProperty.GetRelationChildTypeAlias: String;
begin
  Result := FRelationChildTypeAlias;
end;

function TioProperty.GetRelationChildTypeName: String;
begin
  Result := FRelationChildTypeName;
end;

function TioProperty.GetRelationChildObject(const Instance: Pointer; const AResolvePropertyPath: Boolean): TObject;
var
  AValue: TValue;
begin
  // Extract the child related object
  AValue := Self.GetValue(Instance);
  Result := TioUtilities.TValueToObject(AValue, True);
  // If a RelationChildPropertyPath is assigned then resolve it
  if Self.RelationChildPropertyPathAssigned and AResolvePropertyPath then
    Result := TioUtilities.ResolveChildPropertyPath(Result, FRelationChildPropertyPath);
end;

function TioProperty.GetRelationChildObjectID(const Instance: Pointer): Integer;
var
  FChildMap: IioMap;
  FChildObject: TObject;
begin
  // Init
  Result := IO_INTEGER_NULL_VALUE;
  // Extract the child related object
  FChildObject := Self.GetRelationChildObject(Instance);
  // If the related child object not exists then exit (return 'NULL')
  if not Assigned(FChildObject) then
    Exit;
  // Else create the ioContext for the object and return the ID
  FChildMap := TioMapContainer.GetMap(FChildObject.ClassName);
  Result := FChildMap.GetProperties.GetIdProperty.GetValue(FChildObject).AsInteger;
end;

function TioProperty.GetRelationChildPropertyName: String;
begin
  Result := FRelationChildPropertyName;
end;

function TioProperty.GetRelationChildPropertyPath: TStrings;
begin
  Result := FRelationChildPropertyPath;
end;

function TioProperty.GetRelationLoadType: TioLoadType;
begin
  Result := FRelationLoadType;
end;

function TioProperty.GetRelationType: TioRelationType;
begin
  Result := FRelationType;
end;

function TioProperty.GetRttiType: TRttiType;
begin
  Result := FRttiProperty.PropertyType;
end;

function TioProperty.GetTypeAlias: String;
begin
  Result := FTypeAlias;
end;

function TioProperty.GetTypeInfo: PTypeInfo;
begin
  Result := FRttiProperty.PropertyType.Handle;
end;

function TioProperty.GetTypeName: String;
begin
  Result := Self.GetRttiType.Name;
end;

function TioProperty.GetSqlFieldAlias: String;
begin
  Result := FSqlFieldAlias;
end;

function TioProperty.GetSqlFieldName(const AClearDelimiters: Boolean): String;
begin
  // Result := FSqlFieldName;
  if AClearDelimiters then
    Result := FSqlFieldName
  else
    Result := TioDbFactory.SqlDataConverter(FTable.GetConnectionDefName).FieldNameToSqlFieldName(FSqlFieldName);
end;

function TioProperty.GetSqlFieldTableName: String;
begin
  Result := FSqlFieldTableName;
end;

function TioProperty.GetSqlQualifiedFieldName: String;
begin
  // Result := FQualifiedSqlFieldName;
  Result := TioDbFactory.SqlDataConverter(FTable.GetConnectionDefName).FieldNameToSqlFieldName(FSqlFieldTableName) + '.' +
    TioDbFactory.SqlDataConverter(FTable.GetConnectionDefName).FieldNameToSqlFieldName(FSqlFieldName);
end;

function TioProperty.GetSqlParamName: String;
begin
  Result := 'P_' + Self.GetSqlFieldAlias;
end;

function TioProperty.GetSqlValue(const ADataObject: TObject): String;
begin
  Result := TioDbFactory.SqlDataConverter(FTable.GetConnectionDefName).TValueToSql(Self.GetValue(ADataObject));
end;

function TioProperty.GetSqlWhereParamName: String;
begin
  Result := 'W_' + Self.GetSqlFieldAlias;
end;

function TioProperty.GetValue(const Instance: Pointer): TValue;
begin
  Result := FRttiProperty.GetValue(Instance);
end;

function TioProperty.GetValueAsObject(const Instance: Pointer): TObject;
var
  AValue: TValue;
begin
  AValue := Self.GetValue(Instance);
  Result := TioUtilities.TValueToObject(AValue, False)
end;

function TioProperty.IDSkipOnInsert: Boolean;
begin
  Result := FIDSkipOnInsert;
end;

function TioProperty.HasAutodetectedHasManyRelation: Boolean;
begin
  Result := (FRelationType = rtHasMany) and (FRelationChildPropertyName = IO_AUTODETECTED_RELATIONS_MASTER_PROPERTY_NAME);
end;

function TioProperty.IsBlob: Boolean;
begin
  Result := ((FRelationType = rtNone) or (FRelationType = rtEmbeddedHasMany) or (FRelationType = rtEmbeddedHasOne)) and Self.GetFieldType.StartsWith('BLOB');
end;

function TioProperty.IsID: Boolean;
begin
  Result := FIsID;
end;

function TioProperty.IsInstance: Boolean;
begin
  Result := Self.GetRttiType.IsInstance;
end;

function TioProperty.IsInterface: Boolean;
begin
  Result := (Self.GetRttiType.TypeKind = tkInterface);
end;

function TioProperty.IsDBReadEnabled: Boolean;
begin
  Result := (FReadWrite <= lpLoadAndPersist) and not FTransient;
end;

function TioProperty.IsTransient: Boolean;
begin
  Result := FTransient;
end;

function TioProperty.IsSqlRequestCompliant(const ASqlRequestType: TioSqlRequestType): Boolean;
begin
  case ASqlRequestType of
    ioSelect:
      Result := (FReadWrite <= lpLoadAndPersist) and not FTransient;
    ioInsert:
      begin
        Result := (FReadWrite >= lpLoadAndPersist) and not FTransient;
        // NB: Se la propriet� � l'ID e stiamo utilizzando una connessione a SQLServer
        // e il flag IDSkipOnInsert = True evita di inserire anche questa propriet�
        // nell'elenco (della query insert).
        if Self.IsID and Self.IDSkipOnInsert and (TioConnectionManager.GetConnectionInfo(FTable.GetConnectionDefName).ConnectionType = cdtSQLServer) then
          Result := False;
      end;
    ioUpdate:
      Result := (FReadWrite >= lpLoadAndPersist) and not FTransient;
  else
    Result := True;
  end;
end;

function TioProperty.IsStream: Boolean;
begin
  Result := (Self.GetRttiType.IsInstance) and (Self.GetRttiType.AsInstance.MetaclassType.InheritsFrom(TStream));
end;

function TioProperty.IsWritable: Boolean;
begin
  Result := FRttiProperty.IsWritable;
end;

function TioProperty.IsDBWriteEnabled: Boolean;
begin
  Result := (FReadWrite >= lpLoadAndPersist) and not FTransient;
end;

function TioProperty.isHasManyChildVirtualProperty: Boolean;
begin
  Result := False;
end;

function TioProperty.LoadSqlExist: Boolean;
begin
  Result := Self.FLoadSql <> '';
end;

function TioProperty.RelationChildPropertyPathAssigned: Boolean;
begin
  Result := Assigned(FRelationChildPropertyPath);
end;

procedure TioProperty.SetFieldData;
var
  LDotPos, LAsPos: Smallint;
  LValue: String;
begin
  // --------------------------------
  // Quando si fa un Join in una classe (attributo ioJoin) poi nelle propriet� che ricevono il valore dai campi della
  //  joined class/table si deve usare anche l'attributo "ioField" per indicare ad iORM in che modo reperirne poi il
  //  valore anche in caso di ambiguit� dovuta campi con lo stesso nome nelle tabelle coinvolte.
  //  Esempio:
  // Classe: [ioJoin(jtInner, TCostGeneric, '[TCostGeneric.CostType] = [TCostType.ID]')]
  // Propriet�: >>>>>>>> [ioField('[TCostGeneric].TravelID')]  <<<<<<<<<
  // --------------------------------
  LValue := FFieldDefinitionString;
  // Translate (if contains tags)
  LValue := TioSqlTranslator.Translate(LValue, FTable.GetClassName);
  // Retrieve the markers position
  LDotPos := Pos('.', LValue);
  LAsPos := Pos(' AS ', LValue, LDotPos);
  if LAsPos = 0 then
    LAsPos := LValue.Length + 1;
  // Retrieve Table reference
  FSqlFieldTableName := LeftStr(LValue, LDotPos - 1);
  if FSqlFieldTableName = '' then
    FSqlFieldTableName := FTable.TableName;
  // Retrieve FieldName
  FSqlFieldName := MidStr(LValue, LDotPos + 1, LAsPos - LDotPos - 1);
  // Retrieve Field Alias
  FSqlFieldAlias := MidStr(LValue, LAsPos + 4, LValue.Length);
  if FSqlFieldAlias = '' then
    FSqlFieldAlias := FSqlFieldTableName + '_' + FSqlFieldName;
end;

procedure TioProperty.SetIDSkipOnInsert(const AIDSkipOnInsert: Boolean);
begin
  FIDSkipOnInsert := AIDSkipOnInsert;
end;

procedure TioProperty.SetIsID(const AValue: Boolean);
begin
  FIsID := AValue;
end;

procedure TioProperty.SetLoadSqlData;
begin
  // Set LoadSql statement (if exist)
  if Self.FLoadSql <> '' then
    FLoadSql := TioSqlTranslator.Translate(FLoadSql, FTable.GetClassName);
end;

procedure TioProperty.SetMetadata_CustomFieldType(const AMetadata_CustomFieldType: string);
begin
  FMetadata_CustomFieldType := AMetadata_CustomFieldType;
end;

procedure TioProperty.SetMetadata_Default(const AMetadata_Default: TValue);
begin
  FMetadata_Default := AMetadata_Default;
end;

procedure TioProperty.SetMetadata_FKCreate(const AMetadata_FKCreate: TioFKCreate);
begin
  FMetadata_FKCreate := AMetadata_FKCreate;
end;

procedure TioProperty.SetMetadata_FieldSubType(const AMetadata_FieldSubType: string);
begin
  FMetadata_FieldSubType := AMetadata_FieldSubType;
end;

procedure TioProperty.SetMetadata_FieldLength(const AMetadata_FieldLength: Integer);
begin
  FMetadata_FieldLength := AMetadata_FieldLength;
end;

procedure TioProperty.SetMetadata_FieldNotNull(const AMetadata_FieldNotNull: Boolean);
begin
  FMetadata_FieldNotNull := AMetadata_FieldNotNull;
end;

procedure TioProperty.SetMetadata_FieldPrecision(const AMetadata_FieldPrecision: Integer);
begin
  FMetadata_FieldPrecision := AMetadata_FieldPrecision;
end;

procedure TioProperty.SetMetadata_FieldScale(const AMetadata_FieldScale: Integer);
begin
  FMetadata_FieldScale := AMetadata_FieldScale;
end;

procedure TioProperty.SetMetadata_FieldType(const AMetadata_FieldType: TioMetadataFieldType);
begin
  FMetadata_FieldType := AMetadata_FieldType;
end;

procedure TioProperty.SetMetadata_FieldUnicode(const AMetadata_FieldUnicode: Boolean);
begin
  FMetadata_FieldUnicode := AMetadata_FieldUnicode;
end;

procedure TioProperty.SetMetadata_FKOnDeleteAction(const AOnDeleteAction: TioFKAction);
begin
  FMetadata_FKOnDeleteAction := AOnDeleteAction;
end;

procedure TioProperty.SetMetadata_FKOnUpdateAction(const AOnUpdateAction: TioFKAction);
begin
  FMetadata_FKOnUpdateAction := AOnUpdateAction;
end;

procedure TioProperty.SetRelationChildNameAndPath(const AQualifiedChildPropertyName: String);
begin
  // If the AQualifiedChildPropertyName is empty then exit
  if AQualifiedChildPropertyName.IsEmpty then
    Exit;
  // Create the StringList, set the Delimiter and DelimitedText
  FRelationChildPropertyPath := TStringList.Create;
  FRelationChildPropertyPath.Delimiter := '.';
  FRelationChildPropertyPath.DelimitedText := AQualifiedChildPropertyName;
  // The last element is the ChildPropertyName
  FRelationChildPropertyName := FRelationChildPropertyPath[FRelationChildPropertyPath.Count - 1];
  // Remove the last element
  FRelationChildPropertyPath.Delete(FRelationChildPropertyPath.Count - 1);
  // If the remaining list is empty then free it (optimization)
  if FRelationChildPropertyPath.Count = 0 then
    FreeAndNil(FRelationChildPropertyPath);
end;

procedure TioProperty.SetTable(const ATable: IioTable);
begin
  FTable := ATable;
end;

procedure TioProperty.SetValue(const Instance: Pointer; const AValue: TValue);
begin
  FRttiProperty.SetValue(Instance, AValue);
  // ***ChildPropertyPath***
end;

{ TioProperties }

procedure TioProperties.Add(const AProperty: IioProperty);
begin
  FPropertyItems.Add(AProperty);
  if AProperty.IsID then
    FIdProperty := AProperty;
  if AProperty.IsBlob then
    FBlobFieldExists := True;
end;

function TioProperties.BlobFieldExists: Boolean;
begin
  Result := FBlobFieldExists;
end;

constructor TioProperties.Create;
begin
  FBlobFieldExists := False;
  FObjStatusProperty := nil;
  FObjVersionProperty := nil;
  FPropertyItems := TList<IioProperty>.Create;
end;

destructor TioProperties.Destroy;
begin
  FPropertyItems.Free;
  inherited;
end;

function TioProperties.PropertyExists(const APropertyName: String): Boolean;
var
  CurrProp: IioProperty;
begin
  for CurrProp in FPropertyItems do
    if CurrProp.GetName.ToUpper.Equals(APropertyName.ToUpper) then
      Exit(True);
  Result := False;
end;

function TioProperties.GetEnumerator: TEnumerator<IioProperty>;
begin
  Result := FPropertyItems.GetEnumerator;
end;

function TioProperties.GetIdProperty: IioProperty;
begin
  Result := FIdProperty;
end;

function TioProperties.GetObjStatusProperty: IioProperty;
begin
  Result := FObjStatusProperty;
end;

function TioProperties.GetObjVersionProperty: IioProperty;
begin
  Result := FObjVersionProperty;
end;

function TioProperties.GetPropertyByName(const APropertyName: String): IioProperty;
var
  CurrProp: IioProperty;
begin
  for CurrProp in FPropertyItems do
    if CurrProp.GetName.ToUpper.Equals(APropertyName.ToUpper) then
      Exit(CurrProp);
  raise EioException.Create(Self.ClassName + ': Context property "' + APropertyName + '" not found');
end;

function TioProperties.GetSql: String;
begin
  // Use Internal function with an anonomous method
  Result := Self.InternalGetSql(ioAll,
    function(AProp: IioProperty): String
    begin
      Result := AProp.GetSqlFieldName;
    end);
end;

function TioProperties.GetSql(const ASqlRequestType: TioSqlRequestType): String;
var
  AFunc: TioPropertiesGetSqlFunction;
begin
  // Get the function by ASqlRequestType value
  case ASqlRequestType of
    ioSelect:
      AFunc :=
              function(AProp: IioProperty): String
    begin
      if AProp.LoadSqlExist then
        Result := AProp.GetLoadSql
      else
        Result := AProp.GetSqlFullQualifiedFieldName;
    end;
  else
    AFunc :=
          function(AProp: IioProperty): String
    begin
      Result := AProp.GetSqlFieldName;
    end;
  end;
  // Use Internal function with an anonomous method
  Result := Self.InternalGetSql(ASqlRequestType, AFunc);
end;

function TioProperties.InternalGetSql(const ASqlRequestType: TioSqlRequestType; const AFunc: TioPropertiesGetSqlFunction): String;
var
  Prop: IioProperty;
begin
  for Prop in FPropertyItems do
  begin
    // If the property is not compliant with the request then skip it
    if not Prop.IsSqlRequestCompliant(ASqlRequestType) then
      Continue;
    // If current prop is a list of HasMany or HasOne related objects skip this property
    if (Prop.GetRelationType = rtHasMany) or (Prop.GetRelationType = rtHasOne) then
      Continue;
    // Add the current property
    if Result <> '' then
      Result := Result + ', ';
    Result := Result + AFunc(Prop);
  end;
end;

function TioProperties.IsObjVersionProperty(const AProperty: IioProperty): Boolean;
begin
  Result := Assigned(AProperty) and (AProperty = FObjVersionProperty);
end;

function TioProperties.ObjStatusExist: Boolean;
begin
  Result := Assigned(FObjStatusProperty);
end;

function TioProperties.ObjVersionExist: Boolean;
begin
  Result := Assigned(FObjVersionProperty);
end;

procedure TioProperties.SetObjStatusProperty(const AValue: IioProperty);
begin
  FObjStatusProperty := AValue;
end;

procedure TioProperties.SetObjVersionProperty(const AValue: IioProperty);
begin
  FObjVersionProperty := AValue;
end;

procedure TioProperties.SetTable(const ATable: IioTable);
var
  AProperty: IioProperty;
begin
  for AProperty in FPropertyItems do
    AProperty.SetTable(ATable);
end;

{ TioField }

constructor TioField.Create(const ARttiField: TRttiField; const ATable: IioTable; const ATypeAlias, AFieldDefinitionString, ALoadSql, AFieldType: String;
  const ATransient, AIsID, AIDSkipOnInsert: Boolean; const AReadWrite: TioLoadPersist; const ARelationType: TioRelationType;
  const ARelationChildTypeName, ARelationChildTypeAlias, ARelationChildPropertyName: String; const ARelationLoadType: TioLoadType; const ANotHasMany: Boolean;
  const AMetadata_FieldType: TioMetadataFieldType; const AMetadata_FieldLength: Integer; const AMetadata_FieldPrecision: Integer;
  const AMetadata_FieldScale: Integer; const AMetadata_FieldNotNull: Boolean; const AMetadata_Default: TValue; const AMetadata_FieldUnicode: Boolean;
  const AMetadata_CustomFieldType: string; const AMetadata_FieldSubType: string; const AMetadata_FKCreate: TioFKCreate;
  const AMetadata_FKOnDeleteAction, AMetadata_FKOnUpdateAction: TioFKAction);
begin
  // NB: No inherited here
  Self.Create(ATable, ATypeAlias, AFieldDefinitionString, ALoadSql, AFieldType, ATransient, AIsID, AIDSkipOnInsert, AReadWrite, ARelationType,
    ARelationChildTypeName, ARelationChildTypeAlias, ARelationChildPropertyName, ARelationLoadType, ANotHasMany, AMetadata_FieldType, AMetadata_FieldLength,
    AMetadata_FieldPrecision, AMetadata_FieldScale, AMetadata_FieldNotNull, AMetadata_Default, AMetadata_FieldUnicode, AMetadata_CustomFieldType,
    AMetadata_FieldSubType, AMetadata_FKCreate, AMetadata_FKOnDeleteAction, AMetadata_FKOnUpdateAction);

  FRttiProperty := ARttiField;
  FName := Self.Remove_F_FromName(ARttiField.Name);
end;

function TioField.GetName: String;
begin
  // No inherited
  Result := FName;
end;

function TioField.GetRttiType: TRttiType;
begin
  // No inherited
  Result := FRttiProperty.FieldType;
end;

function TioField.GetTypeInfo: PTypeInfo;
begin
  // No inherited
  Result := FRttiProperty.FieldType.Handle;
end;

function TioField.GetValue(const Instance: Pointer): TValue;
begin
  // No inherited
  Result := FRttiProperty.GetValue(Instance);
end;

function TioField.IsWritable: Boolean;
begin
  // A private field is always writable
  Result := True;
end;

class function TioField.Remove_F_FromName(const AFieldName: String): String;
begin
  if Uppercase(AFieldName).StartsWith('F') then
    Result := AFieldName.Substring(1); // Elimina il primo carattere (di solito la F)
end;

procedure TioField.SetValue(const Instance: Pointer; const AValue: TValue);
begin
  // No inherited
  FRttiProperty.SetValue(Instance, AValue);
end;

{ TioHasManyChildVirtualProperty }

constructor TioHasManyChildVirtualProperty.Create(const ATable: IioTable);
begin
  inherited Create(ATable, '', '', '', '', False, False, False, lpLoadAndPersist, rtNone, '', '', '', ltEagerLoad, False, ioMdInteger, IO_DEFAULT_FIELD_LENGTH,
    IO_DEFAULT_FIELD_PRECISION, IO_DEFAULT_FIELD_SCALE, True, TValue.Empty, True, '', '', fkCreate, fkUnspecified, fkUnspecified);
  FRttiType := TRttiContext.Create.GetType(TypeInfo(Integer));
end;

function TioHasManyChildVirtualProperty.GetName: String;
begin
  // No inherited
  Result := IO_AUTODETECTED_RELATIONS_MASTER_PROPERTY_NAME;
end;

function TioHasManyChildVirtualProperty.GetRttiType: TRttiType;
begin
  // No inherited
  Result := FRttiType;
end;

function TioHasManyChildVirtualProperty.GetSqlFieldAlias: String;
begin
  // No inherited
  Result := GetSqlFieldTableName + '_' + IO_AUTODETECTED_RELATIONS_MASTER_PROPERTY_NAME;
end;

function TioHasManyChildVirtualProperty.GetSqlFieldName(const AClearDelimiters: Boolean): String;
begin
  // No inherited
  Result := IO_AUTODETECTED_RELATIONS_MASTER_PROPERTY_NAME;
end;

function TioHasManyChildVirtualProperty.GetSqlParamName: String;
begin
  // No inherited
  Result := 'P_' + GetSqlFieldTableName + '_' + IO_AUTODETECTED_RELATIONS_MASTER_PROPERTY_NAME;
end;

function TioHasManyChildVirtualProperty.GetSqlWhereParamName: String;
begin
  // No inherited
  Result := 'W_' + GetSqlFieldTableName + '_' + IO_AUTODETECTED_RELATIONS_MASTER_PROPERTY_NAME;
end;

function TioHasManyChildVirtualProperty.GetTypeInfo: PTypeInfo;
begin
  // No inherited
  Result := FRttiType.Handle;
end;

function TioHasManyChildVirtualProperty.GetValue(const Instance: Pointer): TValue;
begin
  // No inherited
  EioException.Create(ClassName, 'GetValue', 'Method not implemented on this class');
end;

function TioHasManyChildVirtualProperty.isHasManyChildVirtualProperty: Boolean;
begin
  // No inherited
  Result := True;
end;

function TioHasManyChildVirtualProperty.IsWritable: Boolean;
begin
  // No inherited
  Result := False;
end;

procedure TioHasManyChildVirtualProperty.SetValue(const Instance: Pointer; const AValue: TValue);
begin
  // No inherited
  EioException.Create(ClassName, 'GetValue', 'Method not implemented on this class');
end;

end.
