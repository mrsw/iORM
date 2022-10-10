unit MicroVM.OrderRow;

interface

uses
  System.SysUtils,
  System.Classes,
  iORM,
  iORM.Attributes,
  iORM.CommonTypes,
  iORM.Where.Interfaces,
  iORM.MVVM.Interfaces,
  iORM.MVVM.ViewModel,
  Model.OrderRow, iORM.MVVM.ModelPresenter.Custom, iORM.MVVM.ModelPresenter.Detail, iORM.MVVM.ModelPresenter.Master, iORM.MVVM.VMAction;

type

  [diViewModelFor(TPizzaOrderRow), diViewModelFor(TCustomOrderRow)]
  TMicroVMOrderRows = class(TioViewModel)
    MPOrderRow: TioModelPresenterDetail;
    acRefresh: TioVMAction;
    procedure acRefreshExecute(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{%CLASSGROUP 'System.Classes.TPersistent'}

{$R *.dfm}

procedure TMicroVMOrderRows.acRefreshExecute(Sender: TObject);
begin
  MPOrderRow.Refresh;
end;

end.