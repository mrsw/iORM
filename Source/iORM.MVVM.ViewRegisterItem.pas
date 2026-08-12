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
unit iORM.MVVM.ViewRegisterItem;

interface

uses
  System.Classes, iORM.MVVM.ViewContextProvider, System.Generics.Collections, System.SysUtils;

type

  TioViewContextRegisterItem = class(TComponent)
  private
    FView: TComponent;
    FViewContext: TComponent;
    FViewContextProvider: TioViewContextProvider;
    FViewContextFreeMethod: TProc;
    FViewContextFreeMethodIsPresent: Boolean;
    FReleasingViewContext: Boolean;
    procedure SetView(const AView:TComponent);
    procedure SetViewContext(const AViewContext:TComponent);
    procedure SetViewContextProvider(const AViewContextProvider:TioViewContextProvider);
    procedure SetViewContextFreeMethod(const Value: TProc);
    procedure CheckForLife;
//    function GetViewContext: TComponent; NB: Hint prevention "symbol declared but never used" (codice presente sotto)
//    function GetViewContextProvider: TioViewContextProvider; NB: Hint prevention "symbol declared but never used" (codice presente sotto)
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(const AView, AViewContext: TComponent; const AViewContextProvider:TioViewContextProvider;
      const AViewContextFreeMethod:TProc); reintroduce; overload;
    procedure ReleaseViewContext;
    procedure ShowViewContext;
    procedure HideViewContext;
    property View:TComponent read FView write SetView;
    property ViewContext:TComponent read FViewContext write SetViewContext;
    property ViewContextProvider:TioViewContextProvider read FViewContextProvider write SetViewContextProvider;
    property ViewContextFreeMethod: TProc read FViewContextFreeMethod write SetViewContextFreeMethod;
  end;

implementation

{ TioViewContextRegisterItem }

procedure TioViewContextRegisterItem.CheckForLife;
begin
  if (not Assigned(FView)) and (not FReleasingViewContext) then
    ReleaseViewContext;
  // NB: "not FReleasingViewContext" added below for the same reason it is
  // already used in the check above: if the View/ViewContext notification
  // that leads here fires synchronously from inside our own ReleaseViewContext
  // (e.g. via FViewContextProvider.ReleaseViewContext -> DoOnRelease -> the
  // application's OnRelease handler destroying FViewContext), DisposeOf would
  // destroy Self while ReleaseViewContext is still executing on it, so the
  // remaining statements there (FViewContextFreeMethodIsPresent/
  // FViewContextFreeMethod) would run against already-freed memory.
  if (not Assigned(FView)) and (not Assigned(FViewContext)) and (not FReleasingViewContext) and not (csDestroying in Self.ComponentState) then
    DisposeOf;
end;

constructor TioViewContextRegisterItem.Create(const AView, AViewContext: TComponent;
      const AViewContextProvider:TioViewContextProvider;
      const AViewContextFreeMethod:TProc);
begin
  inherited Create(nil);
  FReleasingViewContext := False;
  SetView(AView);
  SetViewContext(AViewContext);
  SetViewContextProvider(AViewContextProvider);
  SetViewContextFreeMethod(AViewContextFreeMethod);
end;

//function TioViewContextRegisterItem.GetViewContext: TComponent;
//begin
//  Result := FViewContext;
//end;

//function TioViewContextRegisterItem.GetViewContextProvider: TioViewContextProvider;
//begin
//  Result := FViewContextProvider;
//end;

procedure TioViewContextRegisterItem.HideViewContext;
begin
  if not Assigned(FViewContext) then
    Exit;
  if Assigned(FViewContextProvider) then
    FViewContextProvider.HideViewContext(FView, FViewContext);
end;

procedure TioViewContextRegisterItem.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;
  // If AComponent is the View or the ViewContext then clear the proper field
  if AComponent = FView then
    SetView(nil)
  else if AComponent = FViewContext then
    SetViewContext(nil)
  else if AComponent = FViewContextProvider then
    SetViewContextProvider(nil);
end;

procedure TioViewContextRegisterItem.ReleaseViewContext;
begin
  // If already destroyed then exit
  FReleasingViewContext := True;
  try
    // View
    if Assigned(FView) then
      FreeAndNil(FView);
    // ViewContext
    if Assigned(FViewContext) then
    begin
      if Assigned(FViewContextProvider) then
        FViewContextProvider.ReleaseViewContext(FView, FViewContext);
      // NB: Ho sostituito il test Assigned con una apposita variabile "FViewContextFreeMethodIsPresent" settata nel costruttore
      //      perch� altrimenti capitava che su android 10 "FViewContextFreeMethod" cambiasse senza apparente mitovo e da nil
      //      assumesse un altro valore non nil che poi causava un AV (perch� l'anonimous method in realt� non c'era.
  //    if Assigned(FViewContextFreeMethod) then
      if FViewContextFreeMethodIsPresent then
        FViewContextFreeMethod;
    end;
  finally
    // NB: reset before the CheckForLife-equivalent check below (not via
    // CheckForLife itself, to avoid re-entering ReleaseViewContext through
    // its first condition) so Self can still be disposed once it is
    // actually safe to do so - see the matching guard in CheckForLife: while
    // FReleasingViewContext stayed True forever, DisposeOf never fired again
    // for this item, leaking every TioViewContextRegisterItem that ever went
    // through this method.
    FReleasingViewContext := False;
    if (not Assigned(FView)) and (not Assigned(FViewContext)) and not (csDestroying in Self.ComponentState) then
      DisposeOf;
  end;
end;

procedure TioViewContextRegisterItem.SetView(const AView: TComponent);
begin
  if AView = FView then
    Exit;
  FView := AView;
  if Assigned(FView) then
    FView.FreeNotification(Self);
  CheckForLife;
end;

procedure TioViewContextRegisterItem.SetViewContext(
  const AViewContext: TComponent);
begin
  if AViewContext = FViewContext then
    Exit;
  FViewContext := AViewContext;
  if Assigned(FViewContext) then
    FViewContext.FreeNotification(Self);
  CheckForLife;
end;

procedure TioViewContextRegisterItem.SetViewContextFreeMethod(const Value: TProc);
begin
  FViewContextFreeMethod := Value;
  FViewContextFreeMethodIsPresent := Assigned(FViewContextFreeMethod);
end;

procedure TioViewContextRegisterItem.SetViewContextProvider(
  const AViewContextProvider: TioViewContextProvider);
begin
  if AViewContextProvider = FViewContextProvider then
    Exit;
  FViewContextProvider := AViewContextProvider;
  if Assigned(FViewContextProvider) then
    FViewContextProvider.FreeNotification(Self);
end;

procedure TioViewContextRegisterItem.ShowViewContext;
begin
  if not Assigned(FViewContext) then
    Exit;
  if Assigned(FViewContextProvider) then
    FViewContextProvider.ShowViewContext(FView, FViewContext);
end;

end.
