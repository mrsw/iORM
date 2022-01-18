unit iORM.LiveBindings.CommonBSBehavior;

interface

uses
  iORM.LiveBindings.Interfaces, iORM.LiveBindings.Notification,
  iORM.CommonTypes;

type

  // Methods and functionalities common to all BindSouces (ioDataSet also)
  TioCommonBSBehavior = class
  private
  public
    // NB: Common code for ABSA to manage notifications
    class procedure Notify(const ASender: TObject; const ATargetBS: IioNotifiableBindSource; const [Ref] ANotification: TioBSNotification);
    class function CanDoSelection(const ASender: TObject; const ASelectionDestBSA: IioActiveBindSourceAdapter): Boolean;
    class procedure Select<T>(const ASender: TObject; const ATargetBS: IioNotifiableBindSource; ASelected: T;
      ASelectionType: TioSelectionType = TioSelectionType.stAppend);
  end;

implementation

uses
  Data.Bind.ObjectScope, System.SysUtils,
  iORM.LiveBindings.BSPersistence, System.Rtti, iORM.Exceptions;

{ TioCommonBSBehavior }

class function TioCommonBSBehavior.CanDoSelection(const ASender: TObject; const ASelectionDestBSA: IioActiveBindSourceAdapter): Boolean;
var
  LNotification: TioBSNotification;
begin
  LNotification := TioBSNotification.Create(TioBSNotificationType.ntCanDoSelection);
  ASelectionDestBSA.Notify(ASender, LNotification);
  Result := LNotification.Response;
end;

class procedure TioCommonBSBehavior.Notify(const ASender: TObject; const ATargetBS: IioNotifiableBindSource; const [Ref] ANotification: TioBSNotification);
var
  LBSPersistenceClient: IioBSPersistenceClient;
  LNotificationPointer: PioBSNotification;
begin
  case ANotification.NotificationType of
    // Execute the AutoRefresh if enabled by the specific property
    ntRefresh:
      if (ATargetBS.AutoRefreshOnNotification > arDisabled) and (ATargetBS.State <> TBindSourceAdapterState.seInactive) then
        ATargetBS.Refresh(ATargetBS.AutoRefreshOnNotification = TioAutoRefreshType.arEnabledReload, False);
    // Actually used for paging purposes (ObjState moved on "OnBeforeScroll" directly in the BindSource/DataSet/ModelPresenter master)
    ntScroll:
      ATargetBS.Paging.NotifyItemIndexChanged(ATargetBS.GetActiveBindSourceAdapter.ItemIndex);
    // Actually used for BSPersistence purposes
    ntSaveRevertPoint:
      if Supports(ATargetBS, IioBSPersistenceClient, LBSPersistenceClient) then
        LBSPersistenceClient.Persistence.NotifySaveObjState;
    // Set the response to True if the MasterBS has saved revert point or AutoSaveRevertPoint is possible
    ntCanDoSelection:
      if Supports(ATargetBS, IioBSPersistenceClient, LBSPersistenceClient) then
      begin
        LNotificationPointer := @ANotification;
        LNotificationPointer^.Response := LBSPersistenceClient.Persistence.CanDoSelection;
      end;
    // Actually used for BSPersistence purposes:
    // if enabled save a reference to the deleted object to perform a delete query when persist
    ntDelete:
      begin
        Sleep(1);
      end;
  end;
end;

class procedure TioCommonBSBehavior.Select<T>(const ASender: TObject; const ATargetBS: IioNotifiableBindSource; ASelected: T;
  ASelectionType: TioSelectionType = TioSelectionType.stAppend);
var
  LDestBSA: IioActiveBindSourceAdapter;
  LValue: TValue;
begin
  // Some checks
  if not Assigned(ATargetBS) then
    raise EioException.Create(ClassName, 'Select<T>', '"SelectorFor" property not assigned.');
  if not ATargetBS.AdapterExists then
    raise EioException.Create(ClassName, 'Select<T>', 'Selection destination ActiveBindSourceAdapter, non present.');
  // Get the selection destination BindSourceAdapter
  LDestBSA := ATargetBS.GetActiveBindSourceAdapter;
  // If the selection is allowed then send a ntSaveRevertPoint notification
  if TioCommonBSBehavior.CanDoSelection(ASender, LDestBSA) then
    LDestBSA.Notify(ASender, TioBSNotification.Create(TioBSNotificationType.ntSaveRevertPoint))
  else
    raise EioException.Create(ClassName, 'Select<T>', 'Destination BindSource hasn''t saved a revert point');
  // Encapsulate the SelectedInstance into a TValue then assign it
  // as selection in a proper way
  // NB: Lasciare assolutamente cos� perch� ho gi� provato in vari modi ma mi dava sempre un errore
  // facendo cos' invece (cio� passando per un TValue) funziona correttamente.
  LValue := TValue.From<T>(ASelected);
  if LValue.Kind = TTypeKind.tkInterface then
    LDestBSA.ReceiveSelection(LValue.AsInterface, ASelectionType)
  else if LValue.Kind = TTypeKind.tkClass then
    LDestBSA.ReceiveSelection(LValue.AsObject, ASelectionType)
  else
    raise EioException.Create(ClassName, 'Select<T>', 'Wrong LValue kind.');
end;

end.
