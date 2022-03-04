unit iORM.LiveBindings.BSPersistence;

interface

uses
  iORM.LiveBindings.Interfaces,
  iORM.LiveBindings.BSPersistence.SmartDeleteSystem,
  iORM.LiveBindings.BSPersistence.SmartUpdateDetection,
  ObjMapper.Attributes;

type

  TioBSPersistenceState = (osUnassigned, osUnsaved, osSaved, osChanged);
  TioBSOnRecordChangeAction = (rcDoNothing, rcPersistIfChanged, rcPersistAlways, rcAbortIfChanged, rcAbortAlways);
  TioBSOnEditAction = (eaDoNothing, eaSaveRevertPoint, eaAbortIfNotSaved);
  TioBSOnDeleteAction = (daDoNothing, daSetObjStatusIfExists, daSetSmartDeleteSystem);
  TioBSOnUpdateAction = (uaDoNothing, uaSetObjStatusIfExists, uaSetSmartUpdateStateLess, uaSetSmartUpdateStateFull);
  TioOnInsertAction = (iaDoNothing, iaSaveRevertPoint);

  TioBSPersistence = class;

  IioBSPersistenceClient = interface
    ['{8B930CF9-0EDC-483E-86A2-39C6CFD82D9D}']
    function Current: TObject;
    procedure Delete;
    function GetActiveBindSourceAdapter: IioActiveBindSourceAdapter;
    function IsActive: Boolean;
    procedure PersistCurrent;
    procedure Refresh(const ANotify: Boolean = True);
    procedure Append; overload;
    procedure Append(AObject: TObject); overload;
    procedure Append(AObject: IInterface); overload;
    procedure Insert; overload;
    procedure Insert(AObject: TObject); overload;
    procedure Insert(AObject: IInterface); overload;
    // Persistence property
    function GetPersistence: TioBSPersistence;
    property Persistence: TioBSPersistence read GetPersistence;
    // OnDeleteAction property
    function GetOnDeleteAction: TioBSOnDeleteAction;
    procedure SetOnDeleteAction(const Value: TioBSOnDeleteAction);
    property OnDeleteAction: TioBSOnDeleteAction read GetOnDeleteAction write SetOnDeleteAction;
    // OnEditAction property
    // ObjState property
    function GetOnEditAction: TioBSOnEditAction;
    procedure SetOnEditAction(const Value: TioBSOnEditAction);
    property OnEditAction: TioBSOnEditAction read GetOnEditAction write SetOnEditAction;
    // OnInsertUpdateAction property
    function GetOnInsertUpdateAction: TioBSOnUpdateAction;
    procedure SetOnInsertUpdateAction(const Value: TioBSOnUpdateAction);
    property OnInsertUpdateAction: TioBSOnUpdateAction read GetOnInsertUpdateAction write SetOnInsertUpdateAction;
    // OnRecordChangeAction property
    function GetOnRecordChangeAction: TioBSOnRecordChangeAction;
    procedure SetOnRecordChangeAction(const Value: TioBSOnRecordChangeAction);
    property OnRecordChangeAction: TioBSOnRecordChangeAction read GetOnRecordChangeAction write SetOnRecordChangeAction;
  end;

  TioBSPersistence = class
  private
    [DoNotSerializeAttribute] FBindSource: IioBSPersistenceClient;
    [DoNotSerializeAttribute] FSavedState: String;
    FSmartDeleteSystem: TioSmartDeleteSystem;
    FSmartUpdateDetection: IioSmartUpdateDetection;
    function GetCurrentAsString: String;
    function GetState: TioBSPersistenceState;
    function GetStateAsString: String;
    procedure CheckUnassigned(const AMethodName: String);
    procedure CheckRaiseIfSavedOrChengesExists(const AMethodName: String; const ARaiseIfSaved, ARaiseIfChangesExists: Boolean);
  public
    constructor Create(const ABSPersistenceClient: IioBSPersistenceClient);
    destructor Destroy; override;
    procedure SaveRevertPoint(const ARaiseIfAlreadySaved: Boolean = True);
    procedure Revert(const ARaiseIfNoChanges: Boolean = False; const AClear: Boolean = True);
    procedure Clear(const ARaiseIfChangesExists: Boolean = True);
    procedure Persist(const ARaiseIfNoChanges: Boolean = False; const AClear: Boolean = True);
    procedure Delete(const ARaiseIfSaved: Boolean = False; const ARaiseIfChangesExists: Boolean = False);
    procedure Reload(const ARaiseIfSaved: Boolean = False; const ARaiseIfChangesExists: Boolean = False);
    procedure Append(const ARaiseIfSaved: Boolean = False; const ARaiseIfChangesExists: Boolean = False); overload;
    procedure Append(AObject: TObject; const ARaiseIfSaved: Boolean = False; const ARaiseIfChangesExists: Boolean = False); overload;
    procedure Append(AObject: IInterface; const ARaiseIfSaved: Boolean = False; const ARaiseIfChangesExists: Boolean = False); overload;
    procedure Insert(const ARaiseIfSaved: Boolean = False; const ARaiseIfChangesExists: Boolean = False); overload;
    procedure Insert(AObject: TObject; const ARaiseIfSaved: Boolean = False; const ARaiseIfChangesExists: Boolean = False); overload;
    procedure Insert(AObject: IInterface; const ARaiseIfSaved: Boolean = False; const ARaiseIfChangesExists: Boolean = False); overload;
    function CanInsert: Boolean;
    function CanInsertDetail: Boolean;
    function CanPersist: Boolean;
    function CanClear: Boolean;
    function CanDelete: Boolean;
    function CanDeleteDetail: Boolean;
    function CanDoSelection: Boolean;
    function CanReload: Boolean;
    function CanRevert: Boolean;
    function CanSave: Boolean;
    function IsActive: Boolean;
    function IsChanged: Boolean;
    function IsSaved: Boolean;
    function IsClear: Boolean;
    function IsSmartUpdateDetectionEnabled: Boolean;
    procedure NotifyBeforeScroll;
    procedure NotifySaveRevertPoint;
    property SavedObjState: string read FSavedState;
    property SmartDeleteSystem: TioSmartDeleteSystem read FSmartDeleteSystem;
    property SmartUpdateDetection: IioSmartUpdateDetection read FSmartUpdateDetection write FSmartUpdateDetection;
    property State: TioBSPersistenceState read GetState;
    property StateAsString: string read GetStateAsString;
  end;

implementation

uses
  ObjMapper, iORM.Exceptions, System.SysUtils, iORM.Utilities,
  iORM.LiveBindings.CommonBSAPersistence;

{ TioBindSourceObjState }

procedure TioBSPersistence.Append(const ARaiseIfSaved: Boolean; const ARaiseIfChangesExists: Boolean);
begin
  CheckUnassigned('Append');
  CheckRaiseIfSavedOrChengesExists('Append', ARaiseIfSaved, ARaiseIfChangesExists);
  FBindSource.Append;
end;

procedure TioBSPersistence.Append(AObject: TObject; const ARaiseIfSaved: Boolean = False; const ARaiseIfChangesExists: Boolean = False);
begin
  CheckUnassigned('Append');
  CheckRaiseIfSavedOrChengesExists('Append', ARaiseIfSaved, ARaiseIfChangesExists);
  NotifyBeforeScroll; // Check if you can leave the current record
  FBindSource.Append(AObject);
end;

procedure TioBSPersistence.Append(AObject: IInterface; const ARaiseIfSaved: Boolean = False; const ARaiseIfChangesExists: Boolean = False);
begin
  CheckUnassigned('Append');
  CheckRaiseIfSavedOrChengesExists('Append', ARaiseIfSaved, ARaiseIfChangesExists);
  FBindSource.Append(AObject);
end;

function TioBSPersistence.CanClear: Boolean;
begin
  Result := GetState > osUnsaved;
end;

function TioBSPersistence.CanDelete: Boolean;
begin
  Result := GetState >= osUnassigned;
end;

function TioBSPersistence.CanDeleteDetail: Boolean;
begin
  Result := (GetState >= osSaved) or (FBindSource.OnEditAction < eaAbortIfNotSaved);
end;

function TioBSPersistence.CanDoSelection: Boolean;
begin
  Result := (GetState >= osSaved) or (FBindSource.OnEditAction < eaAbortIfNotSaved);
end;

function TioBSPersistence.CanInsert: Boolean;
begin
  Result := GetState >= osUnassigned;
end;

function TioBSPersistence.CanInsertDetail: Boolean;
begin
  Result := (GetState >= osSaved) or (FBindSource.OnEditAction < eaAbortIfNotSaved);
end;

function TioBSPersistence.CanPersist: Boolean;
begin
  Result := GetState >= osSaved;
end;

function TioBSPersistence.CanReload: Boolean;
begin
  Result := GetState >= osUnassigned;
end;

function TioBSPersistence.CanRevert: Boolean;
begin
  Result := GetState >= osSaved;
end;

function TioBSPersistence.CanSave: Boolean;
begin
  Result := GetState = osUnsaved;
end;

procedure TioBSPersistence.CheckRaiseIfSavedOrChengesExists(const AMethodName: String; const ARaiseIfSaved, ARaiseIfChangesExists: Boolean);
begin
  if ARaiseIfSaved and (State > osUnsaved) then
    raise EioBindSourceObjStateException.Create(ClassName, AMethodName, 'A previously saved revert point exists, it must be cleared before');
  if ARaiseIfChangesExists and (State > osSaved) then
    raise EioBindSourceObjStateException.Create(ClassName, AMethodName, 'Pending changes exists');
end;

procedure TioBSPersistence.CheckUnassigned(const AMethodName: String);
begin
  if State = osUnassigned then
    raise EioBindSourceObjStateException.Create(ClassName, AMethodName, 'Unassigned current object (maybe the bindsource is not active or empty)');
end;

procedure TioBSPersistence.Clear(const ARaiseIfChangesExists: Boolean);
begin
  if ARaiseIfChangesExists and (State > osSaved) then
    raise EioBindSourceObjStateException.Create(ClassName, 'Clear', 'Pending changes exists');
  FSavedState := '';
  FSmartDeleteSystem.Clear;
  if Assigned(FSmartUpdateDetection) then
    FSmartUpdateDetection.Clear;
end;

constructor TioBSPersistence.Create(const ABSPersistenceClient: IioBSPersistenceClient);
begin
  inherited Create;
  FBindSource := ABSPersistenceClient;
  FSmartDeleteSystem := TioSmartDeleteSystem.Create;
  FSmartUpdateDetection := TioSmartUpdateDetectionFaxtory.NewSmartUpdateDetectionSystem(False);
  Clear(False);
end;

procedure TioBSPersistence.Delete(const ARaiseIfSaved: Boolean = False; const ARaiseIfChangesExists: Boolean = False);
begin
  CheckUnassigned('Delete');
  CheckRaiseIfSavedOrChengesExists('Delete', ARaiseIfSaved, ARaiseIfChangesExists);
  TioCommonBSAPersistence.BSPersistenceDelete(FBindSource);
end;

destructor TioBSPersistence.Destroy;
begin
  FSmartDeleteSystem.Free;
  inherited;
end;

procedure TioBSPersistence.Insert(const ARaiseIfSaved: Boolean = False; const ARaiseIfChangesExists: Boolean = False);
begin
  CheckUnassigned('Insert');
  CheckRaiseIfSavedOrChengesExists('Insert', ARaiseIfSaved, ARaiseIfChangesExists);
  FBindSource.Insert;
end;

procedure TioBSPersistence.Insert(AObject: TObject; const ARaiseIfSaved: Boolean = False; const ARaiseIfChangesExists: Boolean = False);
begin
  CheckUnassigned('Insert');
  CheckRaiseIfSavedOrChengesExists('Insert', ARaiseIfSaved, ARaiseIfChangesExists);
  FBindSource.Insert(Aobject);
end;

procedure TioBSPersistence.Insert(AObject: IInterface; const ARaiseIfSaved: Boolean = False; const ARaiseIfChangesExists: Boolean = False);
begin
  CheckUnassigned('Insert');
  CheckRaiseIfSavedOrChengesExists('Insert', ARaiseIfSaved, ARaiseIfChangesExists);
  FBindSource.Insert(AObject);
end;

function TioBSPersistence.IsActive: Boolean;
begin
  Result := GetState > osUnassigned;
end;

function TioBSPersistence.IsChanged: Boolean;
begin
  Result := GetState = osChanged;
end;

function TioBSPersistence.IsClear: Boolean;
begin
  Result := GetState = osUnsaved;
end;

function TioBSPersistence.IsSaved: Boolean;
begin
  Result := GetState > osUnsaved;
end;

function TioBSPersistence.IsSmartUpdateDetectionEnabled: Boolean;
begin
  Result := FBindSource.OnInsertUpdateAction >= uaSetSmartUpdateStateLess;
end;

procedure TioBSPersistence.NotifySaveRevertPoint;
begin
  if (FBindSource.OnEditAction = eaSaveRevertPoint) and IsClear then
    SaveRevertPoint
  else
  if (FBindSource.OnEditAction = eaAbortIfNotSaved) and IsClear then
    Abort;
end;

procedure TioBSPersistence.NotifyBeforeScroll;
begin
  if ((FBindSource.OnRecordChangeAction = rcPersistAlways) and IsSaved) or ((FBindSource.OnRecordChangeAction = rcPersistIfChanged) and IsChanged) then
    Persist
  else
  if ((FBindSource.OnRecordChangeAction = rcAbortAlways) and IsSaved) or ((FBindSource.OnRecordChangeAction = rcAbortIfChanged) and IsChanged) then
    Abort
  else
  if IsSaved then
    Clear(False);
end;

function TioBSPersistence.GetState: TioBSPersistenceState;
begin
  if (FBindSource = nil) or (not FBindSource.IsActive) or (FBindSource.Current = nil) then
    Result := osUnassigned
  else
  if FSavedState.IsEmpty then
    Result := osUnsaved
  else if GetCurrentAsString <> FSavedState then
    Result := osChanged
  else
    Result := osSaved;
end;

function TioBSPersistence.GetStateAsString: String;
begin
  Result := TioUtilities.EnumToString<TioBSPersistenceState>(State);
end;

procedure TioBSPersistence.Persist(const ARaiseIfNoChanges: Boolean = False; const AClear: Boolean = True);
begin
  CheckUnassigned('Persist');
  if ARaiseIfNoChanges and (State < osChanged) then
    raise EioBindSourceObjStateException.Create(ClassName, 'Persist', 'There are''t changes to persist');
  FBindSource.PersistCurrent;
  if AClear then
    Clear(False);
end;

procedure TioBSPersistence.Reload(const ARaiseIfSaved: Boolean; const ARaiseIfChangesExists: Boolean);
begin
  CheckUnassigned('Reload');
  CheckRaiseIfSavedOrChengesExists('Reload', ARaiseIfSaved, ARaiseIfChangesExists);
  FBindSource.GetActiveBindSourceAdapter.Reload;
  Clear(ARaiseIfChangesExists);
end;

procedure TioBSPersistence.Revert(const ARaiseIfNoChanges: Boolean = False; const AClear: Boolean = True);
begin
  CheckUnassigned('Revert');
  if State < osSaved then
    raise EioBindSourceObjStateException.Create(ClassName, 'Revert', 'There isn''t a saved state you can revert to. (call "Save" method before)');
  if ARaiseIfNoChanges and (State < osChanged) then
    raise EioBindSourceObjStateException.Create(ClassName, 'Revert', 'There where no changes');
  om.FromJSON(FSavedState).byFields.TypeAnnotationsON.ClearListBefore.&To(FBindSource.Current);
  if AClear then
    Clear(False);
  FBindSource.Refresh(True);
end;

procedure TioBSPersistence.SaveRevertPoint(const ARaiseIfAlreadySaved: Boolean);
begin
  CheckUnassigned('Save');
  if ARaiseIfAlreadySaved and (State > osUnsaved) then
    raise EioBindSourceObjStateException.Create(ClassName, 'Save', 'A previously saved revert point exists, it must be cleared before');
  FSavedState := GetCurrentAsString
end;

function TioBSPersistence.GetCurrentAsString: String;
begin
  if FBindSource.Current <> nil then
    Result := om.From(FBindSource.Current).byFields.TypeAnnotationsON.ToString
  else
    Result := '';
end;

end.
