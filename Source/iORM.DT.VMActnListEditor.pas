unit iORM.DT.VMActnListEditor;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.ToolWin, System.Actions, Vcl.ActnList,
  System.ImageList, Vcl.ImgList, Vcl.Menus,

  ToolsApi,
  DesignIntf,

  iORM.MVVM.VMAction

  ;

type
  TioVMActionListEditor = class(TForm)
    ToolBar1: TToolBar;
    btnAdd: TToolButton;
    btnDelete: TToolButton;
    pnlCategories: TPanel;
    pnlActions: TPanel;
    lbCategories: TListBox;
    lbActions: TListBox;
    lblCategoriesTitle: TLabel;
    lblActionsTitle: TLabel;
    pnlClient: TPanel;
    Splitter1: TSplitter;
    ActionList1: TActionList;
    ImageList1: TImageList;
    actDelete: TAction;
    actAddNewVMAction: TAction;
    actAddNewStdAction: TAction;
    pupNewAction: TPopupMenu;
    NewVMAction1: TMenuItem;
    NewStandardVMAction1: TMenuItem;
    pupListsMenu: TPopupMenu;
    NewVMAction2: TMenuItem;
    NewStandardVMAction2: TMenuItem;
    N1: TMenuItem;
    Delete1: TMenuItem;
    actNewActionFromLastAddedActionClass: TAction;
    actNewActionFromLastAddedActionClass1: TMenuItem;
    procedure actAddNewVMActionExecute(Sender: TObject);
    procedure actAddNewStdActionExecute(Sender: TObject);
    procedure lbCategoriesClick(Sender: TObject);
    procedure actDeleteExecute(Sender: TObject);
    procedure lbActionsClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure actDeleteUpdate(Sender: TObject);
    procedure lbActionsDblClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure actNewActionFromLastAddedActionClassUpdate(Sender: TObject);
    procedure actNewActionFromLastAddedActionClassExecute(Sender: TObject);
  private
    FActionList: TioVMActionList;
    FLastAddedActionClass: TioVMActionCustomClass;
    procedure CreateOrShowExecuteEventHandler;
    procedure DoAddNewAction(const AActionClass: TioVMActionCustomClass = nil);
    procedure DoDeleteActions;
    function GetDesigner: IDesigner;
    function GetNewActionName(const AActionClass: TioVMActionCustomClass): string;
    function GetSelectedAction: TioVMActionCustom;
    procedure LoadEditorSettings;
    procedure SaveEditorSettings;
    procedure SelectAction(const AAction: TioVMActionCustom);
    procedure SelectCategory(const ACategoryName: string);
    procedure SetActionList(const Value: TioVMActionList);
    procedure UpdateActionListBox;
    procedure UpdateCategoriesListBox;
    procedure UpdateListCtrls;
    procedure UpdateCaption;
    procedure UpdateObjectInspector;

    property Designer: IDesigner read GetDesigner;
    property SelectedAction: TioVMActionCustom read GetSelectedAction;
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    class function Execute(AOwner: TComponent;
      AActionList: TioVMActionList): TioVMActionListEditor;

    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    property ActionList: TioVMActionList read FActionList write SetActionList;
  end;

var
  ioVMActionListEditor: TioVMActionListEditor;

implementation

{$R *.dfm}

uses
  Registry,
  iORM.MVVM.ViewModel,
  iORM.DT.VMActnStdActnSelDlg;


const
  SNOCATEGORY = '(No Category)';
  SALLACTIONS = '(All Actions)';


{ TForm1 }

procedure TioVMActionListEditor.actAddNewVMActionExecute(Sender: TObject);
begin
  DoAddNewAction;
end;

procedure TioVMActionListEditor.actAddNewStdActionExecute(Sender: TObject);
var
  LSelectedClasses: TArray<TioVMActionCustomClass>;
  LActionClass: TioVMActionCustomClass;
begin
  LSelectedClasses := TioVMStdActionSelectDialog.Execute(Application);
  for LActionClass in LSelectedClasses do
    DoAddNewAction(LActionClass);
end;

procedure TioVMActionListEditor.actDeleteExecute(Sender: TObject);
begin
  DoDeleteActions;
end;

procedure TioVMActionListEditor.actDeleteUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := lbActions.SelCount > 0;
end;

procedure TioVMActionListEditor.actNewActionFromLastAddedActionClassExecute(
  Sender: TObject);
begin
  DoAddNewAction(FLastAddedActionClass);
end;

procedure TioVMActionListEditor.actNewActionFromLastAddedActionClassUpdate(
  Sender: TObject);
begin
  if Assigned(FLastAddedActionClass) then
    TAction(Sender).Caption := Format('New %s', [FLastAddedActionClass.ClassName]);

  TAction(Sender).Visible := Assigned(FLastAddedActionClass);
end;

constructor TioVMActionListEditor.Create(AOwner: TComponent);
begin
  inherited;

  LoadEditorSettings;
end;

procedure TioVMActionListEditor.CreateOrShowExecuteEventHandler;
var
  LSelectedAction: TioVMActionCustom;
begin
  LSelectedAction := SelectedAction;

  if Assigned(LSelectedAction) and Assigned(Designer) then
    Designer.Edit(LSelectedAction);
end;

destructor TioVMActionListEditor.Destroy;
begin
  inherited;
end;

procedure TioVMActionListEditor.DoAddNewAction(const AActionClass: TioVMActionCustomClass);
var
  LAction: TioVMActionCustom;
  LActionClass: TioVMActionCustomClass;
begin
  if not Assigned(AActionClass) then
    LActionClass := TioVMAction
  else
    LActionClass := AActionClass;

  LAction := LActionClass.Create(ActionList.Owner);
  LAction.Name := GetNewActionName(LActionClass);
  ActionList.AddAction(LAction);

  FLastAddedActionClass := LActionClass;

  SaveEditorSettings;
  // When the new action is added it doesn't have a category specified so
  // there's no need to update the category list control

  // It must select new added action
  SelectAction(LAction);
end;

procedure TioVMActionListEditor.DoDeleteActions;
var
  I: Integer;
  LAction: TioVMActionCustom;
begin
  for I := lbActions.Count - 1 downto 0 do
  begin
    if lbActions.Selected[I] then
    begin
      LAction := TioVMActionCustom(lbActions.Items.Objects[I]);
      ActionList.RemoveAction(LAction);
      lbActions.Items.Delete(I);
      LAction.Free;
    end;
  end;
end;

class function TioVMActionListEditor.Execute(AOwner: TComponent;
  AActionList: TioVMActionList): TioVMActionListEditor;
begin
  Result := TioVMActionListEditor.Create(AOwner);
  Result.ActionList := AActionList;
  Result.Show;
end;

procedure TioVMActionListEditor.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  SaveEditorSettings;
  Action := caFree;
end;

procedure TioVMActionListEditor.FormResize(Sender: TObject);
begin
  SaveEditorSettings;
end;

function TioVMActionListEditor.GetDesigner: IDesigner;
begin
  Result := FindRootDesigner(ActionList) as IDesigner;
end;

function TioVMActionListEditor.GetNewActionName(const AActionClass: TioVMActionCustomClass): string;
begin
  if Assigned(AActionClass) and Assigned(Designer) then
    Result := Designer.UniqueName(AActionClass.ClassName);
end;

function TioVMActionListEditor.GetSelectedAction: TioVMActionCustom;
begin
  Result := nil;

  if lbActions.ItemIndex = -1 then
    exit;

  Result := TioVMActionCustom(lbActions.Items.Objects[lbActions.ItemIndex]);
end;

procedure TioVMActionListEditor.lbActionsClick(Sender: TObject);
begin
  UpdateObjectInspector;
end;

procedure TioVMActionListEditor.lbActionsDblClick(Sender: TObject);
begin
  if Assigned(SelectedAction) then
    CreateOrShowExecuteEventHandler;
end;

procedure TioVMActionListEditor.lbCategoriesClick(Sender: TObject);
begin
  UpdateActionListBox;
end;

procedure TioVMActionListEditor.LoadEditorSettings;
var
  LRegistry: TRegistry;
  LRegistryKey: string;
  LLastAddedActionClassName: string;
begin
  LRegistryKey := (BorlandIDEServices as IOTAServices).GetBaseRegistryKey;

  LRegistry := TRegistry.Create;

  try
    LRegistry.RootKey := HKEY_CURRENT_USER;

    if LRegistry.OpenKey(LRegistryKey, True) then
    begin
      // Load last added action type
      if LRegistry.ValueExists('LastAddedActionClass') then
      begin
        LLastAddedActionClassName := LRegistry.ReadString('LastAddedActionClass');

        if not LLastAddedActionClassName.IsEmpty then
          FLastAddedActionClass := TioVMActionCustomClass(GetClass(LLastAddedActionClassName));
      end;

      // Load position
      if LRegistry.ValueExists('XPos') then
        Left := LRegistry.ReadInteger('XPos');

      if LRegistry.ValueExists('YPos') then
        Top := LRegistry.ReadInteger('YPos');

      // Load size
      if LRegistry.ValueExists('Width') then
        Width := LRegistry.ReadInteger('Width');

      if LRegistry.ValueExists('Height') then
        Height:= LRegistry.ReadInteger('Height');
    end;
  finally
    LRegistry.Free;
  end;

end;

procedure TioVMActionListEditor.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;

  if Operation = opRemove then
  begin
    if (AComponent is TioVMActionList) then
    begin
      FActionList := nil;
      Close;
    end;
  end;
end;

procedure TioVMActionListEditor.SaveEditorSettings;
var
  LRegistry: TRegistry;
  LRegistryKey: string;
begin
  LRegistryKey := (BorlandIDEServices as IOTAServices).GetBaseRegistryKey;

  LRegistry := TRegistry.Create;

  try
    LRegistry.RootKey := HKEY_CURRENT_USER;

    if LRegistry.OpenKey(LRegistryKey, True) then
    begin
      // Save last added action type
      if Assigned(FLastAddedActionClass) then
        LRegistry.WriteString('LastAddedActionClass', FLastAddedActionClass.ClassName);

      // Save position
      LRegistry.WriteInteger('XPos', Left);
      LRegistry.WriteInteger('YPos', Top);

      // Save size
      LRegistry.WriteInteger('Width', Width);
      LRegistry.WriteInteger('Height', Height);
    end;
  finally
    LRegistry.Free;
  end;
end;

procedure TioVMActionListEditor.SelectAction(const AAction: TioVMActionCustom);
begin
  if not Assigned(AAction) then
    exit;

  SelectCategory(AAction.Category);
  lbActions.ItemIndex := lbActions.Items.IndexOfObject(AAction);

  if lbActions.ItemIndex > -1 then
  begin
    lbActions.SetFocus;
    lbActions.OnClick(lbActions);
  end;
end;

procedure TioVMActionListEditor.SelectCategory(const ACategoryName: string);
var
  LCategoryName: string;
begin
  if lbCategories.Items.Count = 0 then
    exit;

  if ACategoryName.IsEmpty then
    LCategoryName := SNOCATEGORY
  else
    LCategoryName := ACategoryName;

  lbCategories.ItemIndex := lbCategories.Items.IndexOf(LCategoryName);

  if lbCategories.ItemIndex > -1 then
    lbCategories.OnClick(lbCategories);
end;

procedure TioVMActionListEditor.SetActionList(const Value: TioVMActionList);
begin
  FActionList := Value;

  if Assigned(FActionList) then
    FActionList.FreeNotification(Self);

  UpdateCaption;
  UpdateListCtrls;
end;

procedure TioVMActionListEditor.UpdateActionListBox;
var
  LCategory: string;
  LAllActions: Boolean;
  I: Integer;
begin
  lbActions.Items.Clear;

  if (ActionList.ActionCount = 0) or (lbCategories.ItemIndex = -1) then
    exit;

  LAllActions := False;

  LCategory := lbCategories.Items[lbCategories.ItemIndex];

  if (LCategory = SNOCATEGORY) then
    LCategory := EmptyStr
  else if (LCategory = SALLACTIONS) then
    LAllActions := True;

  for I := 0 to ActionList.ActionCount - 1 do
  begin
    if ActionList[I].Category.Equals(LCategory) or LAllActions then
    begin
      lbActions.Items.AddObject(ActionList[I].Name, ActionList[I]);
    end;
  end;
end;

procedure TioVMActionListEditor.UpdateCaption;
begin
  if Assigned(ActionList) then
    Caption := Format('Editing %s', [ActionList.QualifiedClassName])
  else
    Caption := 'Editing VMActionList';
end;

procedure TioVMActionListEditor.UpdateCategoriesListBox;
var
  I: Integer;
  LNotCategorizedCount,
  LCategorizedCount: integer;
begin
  lbCategories.Items.Clear;

  lbCategories.Items.Add(SNOCATEGORY);
  LNotCategorizedCount := 0;
  LCategorizedCount := 0;

  for I := 0 to ActionList.ActionCount - 1 do
  begin
    if ActionList[I].Category.IsEmpty then
      Inc(LNotCategorizedCount)
    else
      Inc(LCategorizedCount);
  end;

  if (LNotCategorizedCount > 0) and (LCategorizedCount > 0) then
    lbCategories.Items.Add(SALLACTIONS);
end;

procedure TioVMActionListEditor.UpdateListCtrls;
begin
  UpdateCategoriesListBox;
  UpdateActionListBox;
end;

procedure TioVMActionListEditor.UpdateObjectInspector;
var
  LSelectedAction: TioVMActionCustom;
begin
  LSelectedAction := SelectedAction;

  if Assigned(Designer) then
    Designer.SelectComponent(LSelectedAction);
end;

end.
