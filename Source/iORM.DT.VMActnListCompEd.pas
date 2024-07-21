unit iORM.DT.VMActnListCompEd;

interface

uses
  DesignEditors, DesignMenus, DesignIntf, Classes, System.Generics.Collections,
  iORM.DT.VMActnListEditor;

type

{ TVMActionlistEditor }

  TioVMActionListCompEditor = class(TComponentEditor)
  private
    function FindOpenedEditor: TioVMActionListEditor;
    procedure ShowEditor;
  public
    procedure ExecuteVerb(Index: Integer); override;
    function GetVerb(Index: Integer): string; override;
    function GetVerbCount: Integer; override;
    procedure Edit; override;
  end;

implementation

uses
  System.SysUtils,
  ToolsApi,
  Vcl.Forms,
  Vcl.Dialogs,

  iORM.MVVM.VMAction

  ;


{ TVMActionListEditor }

procedure TioVMActionListCompEditor.Edit;
begin
  inherited;

  //No need to implement because the default behavior is to execute the first verb
end;

procedure TioVMActionListCompEditor.ExecuteVerb(Index: Integer);

begin
  inherited;

  ShowEditor;
end;

function TioVMActionListCompEditor.FindOpenedEditor: TioVMActionListEditor;
var
  I: Integer;
begin
  Result := nil;

  for I := 0 to Screen.FormCount - 1 do
  begin
    if (Screen.Forms[I].ClassName = TioVMActionListEditor.ClassName) and
      (TioVMActionListEditor(Screen.Forms[I]).ActionList = Component) then
    begin
      Result := TioVMActionListEditor(Screen.Forms[I]);
      exit;
    end;
  end;
end;

function TioVMActionListCompEditor.GetVerb(Index: Integer): string;
begin
  case Index of
    0: Result := 'ViewModel Action List Editor...';
  else
    raise ENotImplemented.Create('TioVMActionListCompEditor implements only one verb.');
  end;
end;

function TioVMActionListCompEditor.GetVerbCount: Integer;
begin
  Result := 1;
end;

procedure TioVMActionListCompEditor.ShowEditor;
var
 LDesignerEditor: TioVMActionListEditor;
begin
  LDesignerEditor := FindOpenedEditor;

  if Assigned(LDesignerEditor)  then
    LDesignerEditor.BringToFront
  else
    LDesignerEditor := TioVMActionListEditor.Execute(Application, TioVMActionList(Component));
end;

end.
