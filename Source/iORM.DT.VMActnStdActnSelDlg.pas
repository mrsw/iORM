unit iORM.DT.VMActnStdActnSelDlg;

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, System.Generics.Collections,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.Buttons, Vcl.CheckLst,
  iORM.MVVM.VMAction;

type
  TioVMStdActionSelectDialog = class(TForm)
    pnlBottom: TPanel;
    btnOK: TBitBtn;
    btnCancel: TBitBtn;
    pnlClient: TPanel;
    Splitter1: TSplitter;
    pnlCategories: TPanel;
    lblCategories: TLabel;
    lbCategories: TListBox;
    pnlActionClasses: TPanel;
    lblActionClasses: TLabel;
    clbActionClasses: TCheckListBox;
    procedure lbCategoriesClick(Sender: TObject);
  private
    FSelectedClasses: TList<TioVMActionCustomClass>;
    procedure LoadCategories;
    procedure LoadActionClasses(const ACategoryName: string);
    procedure SaveCheckedClasses;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    class function Execute(AOwner: TComponent): TArray<TioVMActionCustomClass>;
  end;

implementation

{$R *.dfm}

{ TioVMStdActionSelectDialog }

constructor TioVMStdActionSelectDialog.Create(AOwner: TComponent);
begin
  inherited;
  FSelectedClasses := TList<TioVMActionCustomClass>.Create;
  LoadCategories;
end;

destructor TioVMStdActionSelectDialog.Destroy;
begin
  FSelectedClasses.Free;
  inherited;
end;

procedure TioVMStdActionSelectDialog.lbCategoriesClick(Sender: TObject);
begin
  SaveCheckedClasses;
  if lbCategories.ItemIndex >= 0 then
    LoadActionClasses(lbCategories.Items[lbCategories.ItemIndex]);
end;

procedure TioVMStdActionSelectDialog.LoadCategories;
begin
  lbCategories.Items.Clear;
  EnumRegisteredVMActions(
    procedure(const ACategoryName: string; AActionClass: TioVMActionCustomClass)
    begin
      if lbCategories.Items.IndexOf(ACategoryName) < 0 then
        lbCategories.Items.Add(ACategoryName);
    end);
  if lbCategories.Count > 0 then
  begin
    lbCategories.ItemIndex := 0;
    LoadActionClasses(lbCategories.Items[0]);
  end;
end;

procedure TioVMStdActionSelectDialog.LoadActionClasses(const ACategoryName: string);
var
  LIndex: Integer;
begin
  clbActionClasses.Items.Clear;
  EnumRegisteredVMActions(
    procedure(const ACategory: string; AActionClass: TioVMActionCustomClass)
    begin
      LIndex := clbActionClasses.Items.AddObject(AActionClass.ClassName, TObject(AActionClass));
      clbActionClasses.Checked[LIndex] := FSelectedClasses.Contains(AActionClass);
    end,
    ACategoryName);
end;

procedure TioVMStdActionSelectDialog.SaveCheckedClasses;
var
  I: Integer;
  LClass: TioVMActionCustomClass;
begin
  for I := 0 to clbActionClasses.Count - 1 do
  begin
    LClass := TioVMActionCustomClass(clbActionClasses.Items.Objects[I]);
    if clbActionClasses.Checked[I] then
    begin
      if not FSelectedClasses.Contains(LClass) then
        FSelectedClasses.Add(LClass);
    end
    else
      FSelectedClasses.Remove(LClass);
  end;
end;

class function TioVMStdActionSelectDialog.Execute(AOwner: TComponent): TArray<TioVMActionCustomClass>;
var
  LDialog: TioVMStdActionSelectDialog;
begin
  Result := [];
  LDialog := TioVMStdActionSelectDialog.Create(AOwner);
  try
    if LDialog.ShowModal = mrOK then
    begin
      LDialog.SaveCheckedClasses;
      Result := LDialog.FSelectedClasses.ToArray;
    end;
  finally
    LDialog.Free;
  end;
end;

end.