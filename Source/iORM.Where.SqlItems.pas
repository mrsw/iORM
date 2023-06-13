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

unit iORM.Where.SqlItems;

interface

uses
  iORM.SqlItems,
  iORM.Where.SqlItems.Interfaces,
  System.Rtti, iORM.Context.Map.Interfaces, iORM.CommonTypes, iORM.Interfaces;

type

  // Base class for specialized SqlItemWhere needing reference ContextProperties
  TioSqlItemsWhere = class(TioSqlItem, IioSqlItemWhere)
  public
    function GetSql(const AMap: IioMap): String; reintroduce; virtual; abstract;
    function GetSqlParamName(const AMap: IioMap): String; virtual;
    function GetValue(const AMap: IioMap): TValue; virtual;
    function HasParameter: Boolean; virtual; abstract;
  end;

  // Specialized SqlItemWhere for property (PropertyName to FieldName)
  // NB: Property.Name is in FSqlText ancestor field
  TioSqlItemsWhereProperty = class(TioSqlItemsWhere)
  strict private
    function IsNestedPropName(const APropName: String): boolean;
    function ResolveNestedWhereProperty(const AMasterMap: IioMap; ANestedPropName: String): String;
  public
    function GetSql(const AMap: IioMap): String; override;
    function HasParameter: Boolean; override;
  end;

  // Specialized SqlItemWhere for OID property of the referenced class
  // return che OID property sql field name
  TioSqlItemsWherePropertyOID = class(TioSqlItemsWhereProperty)
  public
    constructor Create; reintroduce; overload;
    function GetSql(const AMap: IioMap): String; override;
    function HasParameter: Boolean; override;
  end;

  // Specialized SqlItemWhere returning an SQL compatible representation
  // of TValue
  TioSqlItemsWhereTValue = class(TioSqlItemsWhere)
  strict private
    FValue: TValue;
  public
    constructor Create(const ASqlText: String); reintroduce; overload; // raise exception
    constructor Create(const AValue: TValue); reintroduce; overload;
    function GetSql(const AMap: IioMap): String; override;
    function HasParameter: Boolean; override;
  end;

  // Specialized SqlItemWhere for text conditions with tags translating
  // property to fieldname
  TioSqlItemsWhereText = class(TioSqlItemsWhere)
  public
    function GetSql(const AMap: IioMap): String; override;
    function HasParameter: Boolean; override;
  end;

  // Specialized SqlItemWhere for ORDER BY with tags translating
  // property to fieldname
  TioSqlItemsOrderBy = class(TioSqlItemsWhereText)
    function GetSql(const AMap: IioMap): String; override;
  end;

  // Specialized SqlItemWhere for property equals to for param (best for internal use)
  TioSqlItemsWherePropertyEqualsTo = class(TioSqlItemsWhere)
  strict private
    FValue: TValue;
  public
    constructor Create(const ASqlText: String); reintroduce; overload; // raise exception
    constructor Create(const ASqlText: String; const AValue: TValue); reintroduce; overload;
    function GetSql(const AMap: IioMap): String; override;
    function GetSqlParamName(const AMap: IioMap): String; override;
    function GetValue(const AMap: IioMap): TValue; override;
    function HasParameter: Boolean; override;
  end;

  // Specialized SqlItemWhere for propertyID equals to for param (best for internal use)
  TioSqlItemsWherePropertyIDEqualsTo = class(TioSqlItemsWhere)
  strict private
    FValue: TValue;
  public
    constructor Create(const ASqlText: String); reintroduce; overload; // raise exception
    constructor Create(const AValue: TValue); reintroduce; overload;
    function GetSql(const AMap: IioMap): String; override;
    function GetSqlParamName(const AMap: IioMap): String; override;
    function GetValue(const AMap: IioMap): TValue; override;
    function HasParameter: Boolean; override;
  end;

  TioSqlItemsCriteria = class(TioSqlItemsWhere)
  strict private
    FCompareOpSqlItem: IioSqlItem;
    FPropertySqlItem: IioSqlItemWhere;
    FValueSqlItem: IioSqlItemWhere;
  strict protected
    constructor _Create(const APropertyName: String; const ACompareOperator: TioCompareOp; const AValue: TValue); reintroduce; overload;
  public
    constructor Create(const ASqlText: String); reintroduce; overload; // raise exception
    constructor Create(const APropertyName: String; const ACompareOperator: TioCompareOp); reintroduce; overload;
    constructor Create(const APropertyName: String; const ACompareOperator: TioCompareOp; const AValue: Variant); reintroduce; overload;
    constructor Create(const APropertyName: String; const ACompareOperator: TioCompareOp; const AObject: TObject); reintroduce; overload;
    constructor Create(const APropertyName: String; const ACompareOperator: TioCompareOp; const AInterfce: IInterface); reintroduce; overload;
    function GetSql(const AMap: IioMap): String; override;
    property CompareOpSqlItem: IioSqlItem read FCompareOpSqlItem;
    property PropertySqlItem: IioSqlItemWhere read FPropertySqlItem;
    property ValueSqlItem: IioSqlItemWhere read FValueSqlItem;
  end;

implementation

uses
  iORM.Exceptions, iORM.DB.Factory, iORM.SqlTranslator,
  iORM.Context.Properties.Interfaces, System.SysUtils, System.Types,
  iORM.Context.Container, SYstem.StrUtils;

{ TioSqlItemsWhereValue }

constructor TioSqlItemsWhereTValue.Create(const AValue: TValue);
begin
  FValue := AValue;
end;

constructor TioSqlItemsWhereTValue.Create(const ASqlText: String);
begin
  raise EioException.Create('TioSqlItemsWhereValue wrong constructor called');
end;

function TioSqlItemsWhereTValue.GetSql(const AMap: IioMap): String;
begin
  // NB: No inherited
  Result := TioDBFactory.SqlDataConverter(AMap.GetTable.GetConnectionDefName).TValueToSql(FValue);
end;

function TioSqlItemsWhereTValue.HasParameter: Boolean;
begin
  Result := False;
end;

{ TioSqlItemsWhereProperty }

function TioSqlItemsWhereProperty.IsNestedPropName(const APropName: String): boolean;
begin
  Result := APropName.Contains('.');
end;

function TioSqlItemsWhereProperty.ResolveNestedWhereProperty(const AMasterMap: IioMap; ANestedPropName: String): String;
var
  LFirstDotPos, LSecondDotPos: Integer;
  LMasterPropName, LDetailPropName: String;
  LMasterProp: IioProperty;
  LDetailMap: IioMap;
begin
  // Extract the position of the first and second dots in the ANestedPropName string parameter,
  //  if the second dot does not exists then set its position to the length of the whole string
  LFirstDotPos := Pos('.', ANestedPropName);
  LSecondDotPos := PosEx('.', ANestedPropName, LFirstDotPos+1);
  if LSecondDotPos = 0 then
    LSecondDotPos := ANestedPropName.Length+1;
  // Gte the master and detail prop name
  LMasterPropName := Copy(ANestedPropName, 1, LFirstDotPos-1);
  LDetailPropName := Copy(ANestedPropName, LFirstDotPos+1, LSecondDotPos-1);
  // Get the detail Map
  LDetailMap := TioMapContainer.GetMap(LMasterProp.GetTypeName);


  LMasterProp := AMasterMap.GetProperties.GetPropertyByName(LMasterPropName);


end;

function TioSqlItemsWhereProperty.GetSql(const AMap: IioMap): String;
begin
  // NB: No inherited
  Result := AMap.GetProperties.GetPropertyByName(FSqlText).GetSqlQualifiedFieldName;
end;

function TioSqlItemsWhereProperty.HasParameter: Boolean;
begin
  Result := False;
end;

{ TioSqlItemsWherePropertyOID }

constructor TioSqlItemsWherePropertyOID.Create;
begin
  // Nothing
end;

function TioSqlItemsWherePropertyOID.GetSql(const AMap: IioMap): String;
begin
  Result := AMap.GetProperties.GetIdProperty.GetSqlQualifiedFieldName;
end;

function TioSqlItemsWherePropertyOID.HasParameter: Boolean;
begin
  Result := False;
end;

{ TioSqlItemsWhereText }

function TioSqlItemsWhereText.GetSql(const AMap: IioMap): String;
begin
  // NB: No inherited
  Result := TioSqlTranslator.Translate(FSqlText, AMap.GetClassName);
end;

function TioSqlItemsWhereText.HasParameter: Boolean;
begin
  Result := False;
end;

{ TioSqlItemsWherePropertyEqualsTo }

constructor TioSqlItemsWherePropertyEqualsTo.Create(const ASqlText: String);
begin
  raise EioException.Create(Self.ClassName + ': wrong constructor called');
end;

constructor TioSqlItemsWherePropertyEqualsTo.Create(const ASqlText: String; const AValue: TValue);
begin
  inherited Create(ASqlText);
  FValue := AValue;
end;

function TioSqlItemsWherePropertyEqualsTo.GetSql(const AMap: IioMap): String;
var
  AProp: IioProperty;
begin
  // NB: No inherited
  AProp := AMap.GetProperties.GetPropertyByName(FSqlText);
  Result := AProp.GetSqlQualifiedFieldName + TioDBFactory.CompareOperator._Equal.GetSql + ':' + AProp.GetSqlParamName;
end;

function TioSqlItemsWherePropertyEqualsTo.GetSqlParamName(const AMap: IioMap): String;
begin
  Result := AMap.GetProperties.GetPropertyByName(FSqlText).GetSqlParamName;
end;

function TioSqlItemsWherePropertyEqualsTo.GetValue(const AMap: IioMap): TValue;
begin
  Result := FValue;
end;

function TioSqlItemsWherePropertyEqualsTo.HasParameter: Boolean;
begin
  Result := True;
end;

{ TioSqlItemsWherePropertyOIDEqualsTo }

constructor TioSqlItemsWherePropertyIDEqualsTo.Create(const ASqlText: String);
begin
  raise EioException.Create(Self.ClassName + ': wrong constructor called');
end;

constructor TioSqlItemsWherePropertyIDEqualsTo.Create(const AValue: TValue);
begin
  inherited Create('');
  FValue := AValue;
end;

function TioSqlItemsWherePropertyIDEqualsTo.GetSql(const AMap: IioMap): String;
begin
  // NB: No inherited
  Result := AMap.GetProperties.GetIdProperty.GetSqlQualifiedFieldName + TioDBFactory.CompareOperator._Equal.GetSql +
    ':' + AMap.GetProperties.GetIdProperty.GetSqlParamName;
end;

function TioSqlItemsWherePropertyIDEqualsTo.GetSqlParamName(const AMap: IioMap): String;
begin
  Result := AMap.GetProperties.GetIdProperty.GetSqlParamName;
end;

function TioSqlItemsWherePropertyIDEqualsTo.GetValue(const AMap: IioMap): TValue;
begin
  Result := FValue;
end;

function TioSqlItemsWherePropertyIDEqualsTo.HasParameter: Boolean;
begin
  Result := True;
end;

{ TioSqlItemsWhere }

function TioSqlItemsWhere.GetSqlParamName(const AMap: IioMap): String;
begin
  // Default
  Result := '';
end;

function TioSqlItemsWhere.GetValue(const AMap: IioMap): TValue;
begin
  // Default
  Result := nil;
end;

{ TioSqlItemsOrderBy }

function TioSqlItemsOrderBy.GetSql(const AMap: IioMap): String;
begin
  Result := 'ORDER BY ' + inherited GetSql(AMap);
end;

{ TioSqlItemsCriteria }

constructor TioSqlItemsCriteria.Create(const ASqlText: String);
begin
  raise EioException.Create(Self.ClassName + ': wrong constructor called');
end;

constructor TioSqlItemsCriteria._Create(const APropertyName: String; const ACompareOperator: TioCompareOp; const AValue: TValue);
begin
  inherited Create(APropertyName);
  FPropertySqlItem := TioDbFactory.WhereItemProperty(APropertyName);
  FCompareOpSqlItem := TioDbFactory.CompareOperator.CompareOpToCompareOperator(ACompareOperator);
  FValueSqlItem := TioDbFactory.WhereItemTValue(AValue);
end;

constructor TioSqlItemsCriteria.Create(const APropertyName: String; const ACompareOperator: TioCompareOp);
begin
  _Create(APropertyName, ACompareOperator, nil);
end;

constructor TioSqlItemsCriteria.Create(const APropertyName: String; const ACompareOperator: TioCompareOp; const AValue: Variant);
begin
  _Create(APropertyName, ACompareOperator, TValue.FromVariant(AValue));
end;

constructor TioSqlItemsCriteria.Create(const APropertyName: String; const ACompareOperator: TioCompareOp; const AObject: TObject);
begin
  _Create(APropertyName, ACompareOperator, TValue.From<TObject>(AObject));
end;

constructor TioSqlItemsCriteria.Create(const APropertyName: String; const ACompareOperator: TioCompareOp; const AInterfce: IInterface);
begin
  _Create(APropertyName, ACompareOperator, TValue.From<IInterface>(AInterfce));
end;

function TioSqlItemsCriteria.GetSql(const AMap: IioMap): String;
begin

end;

end.
