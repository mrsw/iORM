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
unit iORM.MVVM.ViewRegister;

interface

uses
  System.Generics.Collections, iORM.MVVM.ViewRegisterItem, System.Classes, iORM.MVVM.ViewContextProvider, iORM.MVVM.Interfaces, System.SysUtils,
  iORM.Abstraction;

type

  TioViewRegisterBase = class(TInterfacedObject, IioViewRegisterBase)
  private
    FInternalContainer: TList<TioViewContextRegisterItem>;
    function FindItemByView(const AView: TComponent): TioViewContextRegisterItem;
    function FindItemByViewContext(const AViewContext: TComponent): TioViewContextRegisterItem;
    function ContainsView(const AView: TComponent): Boolean;
    function ContainsViewContext(const AViewContext: TComponent): Boolean;
    function GetItemByView(const AView: TComponent): TioViewContextRegisterItem;
    function GetItemByViewContext(const AViewContext: TComponent): TioViewContextRegisterItem;
    function GetCount: Integer;
    function GetView(const Index: Integer): TComponent;
  public
    constructor Create;
    destructor Destroy; override;
    procedure AddOrUpdate(const AView, AViewContext: TComponent; const AViewContextProvider: TioViewContextProvider; const AViewContextFreeMethod: TProc);
    property Count: Integer read GetCount;
    property ItemByView[const AView: TComponent]: TioViewContextRegisterItem read GetItemByView;
    property ItemByViewContext[const AViewContext: TComponent]: TioViewContextRegisterItem read GetItemByViewContext;
    property View[const ViewIndex: Integer]: TComponent read GetView;
  end;

  TioViewRegisterMVVM = class(TioViewRegisterBase, IioViewRegisterMVVM)
  private
    FFreeViewsTimer: TioTimer;
    procedure _FreeViewTimerEventHandler(Sender: TObject);
    procedure _PostponedReleaseAllViewContexts;
  public
    constructor Create;
    destructor Destroy; override;
    procedure ReleaseAllViewContexts;
    procedure HideAllViewContexts;
    procedure ShowAllViewContexts;
  end;

  TioSimpleViewRegister = class
  private
    class var FInternalRegister: IioViewRegisterBase;
  public
    class procedure _Build;
    class procedure AddOrUpdate(const AView, AViewContext: TComponent; const AViewContextProvider: TioViewContextProvider; const AViewContextFreeMethod: TProc);
    class procedure CloseView(const AView: TComponent);
    class procedure HideView(const AView: TComponent);
    class procedure ShowView(const AView: TComponent);
    class function ContainsView(const AView: TComponent): Boolean;
  end;

implementation

uses
  iORM.Exceptions, iORM.MVVM.Factory;

{ TioViewContextRegister }

procedure TioViewRegisterBase.AddOrUpdate(const AView, AViewContext: TComponent; const AViewContextProvider: TioViewContextProvider;
  const AViewContextFreeMethod: TProc);
var
  LItem: TioViewContextRegisterItem;
begin
  // Check parameters validity
  // NB: Mauri 04/12/2022: Da ora deve essere possibile registrare una vista anche in assenza di un ViewModel,
  // mi serve per gestire correttamente le BSCloseQueryActions anche per quelle viste che non hanno un
  // ViewContext (es: la MainForm di alcuni esempi). Quindi commento le righe qui sotto.
  // if not Assigned(AViewContext) then
  // raise EioException.Create('TioViewContextRegister', 'Add', 'The ViewContext must be assigned.');
  if not Assigned(AView) then
    raise EioException.Create('TioViewContextRegister', 'Add', 'The View must be assigned.');
  // Avoid duplicated Views or ViewContexts
  // NB: Il codice commentato qui sotto � stato sistutuito con l'if sottostante per risolvere
  // l'errore che si creva nel caso in cui una View (e relativo ViewModel) fosse registrata (nel D.I.C.) come
  // AsSingleton e quindi rimanendo vivi quando non servivano pi�, ma poi riutilizzati in seguito, ne causava
  // una ulteriore registrazione della vista stessa nel ViewRegister del ViewModel (sempre quello) con conseguente
  // errore di "Vista registrata due volte". Cos� sembra funzionare bene, vedere nel tempo se da problemi in altri casi.
  // NB: Mauri 04/12/2022: Ripensandoci perch� c'� il "ContainsViewContext(AViewContext)" ???
  // in fondo pu� essere che assegno un ViewContext a pi� di una vista (es: Pizz'Amore che nell'ordine assegna la stessa
  // ScrollBox a tutte le microviste delle righe. Provo a togliere il controllo sul VM gi� registrato e vediamo come va.

  // if ContainsView(Aview) then
  // raise EioException.Create('TioViewContextRegister', 'Add', 'Duplicated View.');
  // if ContainsViewContext(AViewContext) then
  // raise EioException.Create('TioViewContextRegister', 'Add', 'Duplicated ViewContext.');

  // if ContainsView(Aview) or ContainsViewContext(AViewContext) then

  // if ContainsView(Aview) then
  // Exit;

  LItem := FindItemByView(AView);
  if Assigned(LItem) then
  begin
    LItem.ViewContext := AViewContext;
    LItem.ViewContextProvider := AViewContextProvider;
    LItem.ViewContextFreeMethod := AViewContextFreeMethod;
  end
  else
  begin
    LItem := TioViewContextRegisterItem.Create(AView, AViewContext, AViewContextProvider, AViewContextFreeMethod);
    FInternalContainer.Add(LItem);
  end;
end;

function TioViewRegisterBase.ContainsView(const AView: TComponent): Boolean;
begin
  Result := Assigned(FindItemByView(AView));
end;

function TioViewRegisterBase.ContainsViewContext(const AViewContext: TComponent): Boolean;
begin
  Result := Assigned(FindItemByViewContext(AViewContext));
end;

constructor TioViewRegisterBase.Create;
begin
  inherited;
  FInternalContainer := TList<TioViewContextRegisterItem>.Create;
end;

destructor TioViewRegisterBase.Destroy;
begin
  FInternalContainer.Free;
  inherited;
end;

function TioViewRegisterBase.FindItemByView(const AView: TComponent): TioViewContextRegisterItem;
var
  LItem: TioViewContextRegisterItem;
begin
  Result := nil;
  for LItem in FInternalContainer do
    if LItem.View = AView then
      Exit(LItem);
end;

function TioViewRegisterBase.FindItemByViewContext(const AViewContext: TComponent): TioViewContextRegisterItem;
var
  LItem: TioViewContextRegisterItem;
begin
  Result := nil;
  for LItem in FInternalContainer do
    if LItem.ViewContext = AViewContext then
      Exit(LItem);
end;

function TioViewRegisterBase.GetCount: Integer;
begin
  Result := FInternalContainer.Count;
end;

function TioViewRegisterBase.GetItemByView(const AView: TComponent): TioViewContextRegisterItem;
begin
  Result := FindItemByView(AView);
  if not Assigned(Result) then
    raise EioException.Create('TioViewContextRegister', 'GetItemByView', 'View not found.');
end;

function TioViewRegisterBase.GetItemByViewContext(const AViewContext: TComponent): TioViewContextRegisterItem;
begin
  Result := FindItemByViewContext(AViewContext);
  if not Assigned(Result) then
    raise EioException.Create('TioViewContextRegister', 'GetItemByViewContext', 'ViewContext not found.');
end;

function TioViewRegisterBase.GetView(const Index: Integer): TComponent;
begin
  Result := FInternalContainer[Index].View;
end;

{ TioSimpleViewRegister }

class procedure TioSimpleViewRegister.AddOrUpdate(const AView, AViewContext: TComponent; const AViewContextProvider: TioViewContextProvider;
  const AViewContextFreeMethod: TProc);
begin
  FInternalRegister.AddOrUpdate(AView, AViewContext, AViewContextProvider, AViewContextFreeMethod);
end;

class procedure TioSimpleViewRegister.CloseView(const AView: TComponent);
begin
  FInternalRegister.ItemByView[AView].ReleaseViewContext;
end;

class function TioSimpleViewRegister.ContainsView(const AView: TComponent): Boolean;
begin
  Result := FInternalRegister.ContainsView(AView);
end;

class procedure TioSimpleViewRegister.HideView(const AView: TComponent);
begin
  FInternalRegister.ItemByView[AView].HideViewContext;
end;

class procedure TioSimpleViewRegister.ShowView(const AView: TComponent);
begin
  FInternalRegister.ItemByView[AView].ShowViewContext;
end;

class procedure TioSimpleViewRegister._Build;
begin
  FInternalRegister := TioMVVMFactory.NewViewRegisterBase;
end;

{ TioViewRegisterMVVM }

constructor TioViewRegisterMVVM.Create;
begin
  inherited;
  // NB: If we are on an uniGUI application then doesn't use the timers but runs the code right away
  if TioApplication.ProjectPlatform <> ppUniGUI then
  begin
    FFreeViewsTimer := TioTimer.CreateNewTimer;
    FFreeViewsTimer.Enabled := False;
    FFreeViewsTimer.OnTimer := _FreeViewTimerEventHandler;
    FFreeViewsTimer.Interval := 100;
  end;
end;

destructor TioViewRegisterMVVM.Destroy;
begin
  // NB: If we are on an uniGUI application then doesn't use the timers but runs the code right away
  if TioApplication.ProjectPlatform <> ppUniGUI then
    FFreeViewsTimer.Free;
  inherited;
end;

procedure TioViewRegisterMVVM.HideAllViewContexts;
var
  I: Integer;
begin
  for I := FInternalContainer.Count - 1 downto 0 do
    FInternalContainer.Items[I].HideViewContext;
end;

procedure TioViewRegisterMVVM.ReleaseAllViewContexts;
begin
  // Avvia il timer per il release posticipato di tutti i ViewContexts
  // e, di conseguenza, di tutte le viste.
  // NB: Ho dovuto posticiparlo con un timer perch� altrimenti con i TcxButton
  // della DevExpress c'erano dei problemi in alcuni casi
  // NB: If we are on an uniGUI application then doesn't use the timers but runs the code right away
  if TioApplication.ProjectPlatform <> ppUniGUI then
    FFreeViewsTimer.Enabled := True
  else
    _PostponedReleaseAllViewContexts;
end;

procedure TioViewRegisterMVVM.ShowAllViewContexts;
var
  I: Integer;
begin
  for I := FInternalContainer.Count - 1 downto 0 do
    FInternalContainer.Items[I].ShowViewContext;
end;

procedure TioViewRegisterMVVM._FreeViewTimerEventHandler(Sender: TObject);
begin
  FFreeViewsTimer.Enabled := False;
  _PostponedReleaseAllViewContexts;
end;

procedure TioViewRegisterMVVM._PostponedReleaseAllViewContexts;
var
  // LItem: TioViewContextRegisterItem;
  I: Integer;
begin
  // for LItem in FInternalContainer do
  // LItem.ReleaseViewContext;
  // NB: Il codice sopra dava dei problemi perch�, con Marco Mottadelli, abbiamo notato
  // che quando viene chiamato il metoto "FreeViews" poi gli viene distrutto il
  // register stesso e questo causava un errore se usavamo il for-in. Con un
  // norlame ciclo for invece sembra andare bene.
  for I := FInternalContainer.Count - 1 downto 0 do
    FInternalContainer.Items[I].ReleaseViewContext;
end;

initialization

TioSimpleViewRegister._Build;

end.
