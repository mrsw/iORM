unit iORM.MVVM.VMActionList;

interface

uses
  System.Classes,
  System.Generics.Collections,

  iORM.MVVM.VMAction

  ;


type
  TioCustomVMActionList = class(TComponent)
  private
    FActions: TList<TioVMActionCustom>;
    function GetAction(Index: Integer): TioVMActionCustom;
    function GetActionCount: Integer;
    procedure SetAction(Index: Integer; const Value: TioVMActionCustom);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    property Actions[Index: Integer]: TioVMActionCustom read GetAction write SetAction; default;
    property ActionCount: Integer read GetActionCount;
  end;

implementation

uses
  System.SysUtils

  ;


{ TioCustomVMActionList }

constructor TioCustomVMActionList.Create(AOwner: TComponent);
begin
  inherited;

  FActions := TList<TioVMActionCustom>.Create;
end;

destructor TioCustomVMActionList.Destroy;
begin
  FreeAndNil(FActions);

  inherited;
end;

function TioCustomVMActionList.GetAction(Index: Integer): TioVMActionCustom;
begin
  Result := FActions[Index];
end;

function TioCustomVMActionList.GetActionCount: Integer;
begin
  Result := FActions.Count;
end;

procedure TioCustomVMActionList.SetAction(Index: Integer; const Value: TioVMActionCustom);
begin
  FActions[Index].Assign(Value);
end;

end.
