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
unit iORM.DuckTyped.StreamObject;

interface

uses
  iORM.DuckTyped.Interfaces, System.Classes, System.Rtti, iORM.Attributes;

type

  // DuckTypedStreamObject
  //  NB: IWrappedObject interface is for DMVC ObjectsMappers adapter
  TioDuckTypedStreamObject = class(TInterfacedObject, IioDuckTypedStreamObject)
  strict
  private
    FObj: TObject;
    FLoadFromStreamMethod: TRttiMethod;
    FSaveToStreamMethod: TRttiMethod;
    FIsEmptyMethod: TRttiMethod;
    FCountProperty: TRttiProperty;
    FSizeProperty: TRttiProperty;
  public
    constructor Create(AObj: TObject);
    procedure LoadFromStream(AStream: TStream); virtual;
    procedure SaveToStream(AStream: TStream); virtual;
    function IsEmpty: Boolean; virtual;
  end;

implementation

uses
  iORM.RttiContext.Factory, iORM.Exceptions, iORM, System.SysUtils;

{ TioDuckTypedStreamObject }

constructor TioDuckTypedStreamObject.Create(AObj: TObject);
var
  Ctx: TRttiContext;
  Typ: TRttiType;
begin
  inherited Create;
  FObj := AObj;
  // Init Rtti
  Ctx := TioRttiFactory.GetRttiContext;
  Typ := Ctx.GetType(AObj.ClassInfo);
  // LoadFromStreamMethod method
  FLoadFromStreamMethod := Typ.GetMethod('LoadFromStream');
  if not Assigned(FLoadFromStreamMethod) then
    raise EioException.Create(ClassName, 'TioDuckTypedStreamObject', Format('"LoadFromStream" method not found in the object of "%s" class.', [AObj.ClassName]));
  // SaveFromStreamMethod method
  FSaveToStreamMethod := Typ.GetMethod('SaveToStream');
  if not Assigned(FSaveToStreamMethod) then
    raise EioException.Create(ClassName, 'TioDuckTypedStreamObject', Format('"SaveToStream" method not found in the object of "%s" class.', [AObj.ClassName]));
  // IsEmpty method
  FIsEmptyMethod := Typ.GetMethod('IsEmpty');
  if not Assigned(FIsEmptyMethod) then
    FIsEmptyMethod := Typ.GetMethod('Empty');
  // Count property method
  FCountProperty := Typ.GetProperty('Count');
end;

function TioDuckTypedStreamObject.IsEmpty: Boolean;
begin
  if Assigned(FIsEmptyMethod) then
    Result := FIsEmptyMethod.Invoke(FObj, []).AsBoolean
  else
  if Assigned(FCountProperty) then
    Result := (FCountProperty.GetValue(FObj).AsInteger = 0)
  else
  if Assigned(FSizeProperty) then
    Result := (FSizeProperty.GetValue(FObj).AsInteger = 0)
  else
    Result := False;
end;

procedure TioDuckTypedStreamObject.LoadFromStream(AStream: TStream);
begin
  if AStream.Size <> 0 then
    FLoadFromStreamMethod.Invoke(FObj, [AStream]);
end;

procedure TioDuckTypedStreamObject.SaveToStream(AStream: TStream);
begin
  if not IsEmpty then
    FSaveToStreamMethod.Invoke(FObj, [AStream]);
end;

end.
