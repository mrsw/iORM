unit iORM.FMX.FastReport.Register;

interface


procedure Register;

implementation

uses
  System.Classes,
  FMX.Controls,

  iORM.MVVM.FMX.FastReportModelPresenter,
  iORM.MVVM.FMX.FastReportDataset

  ;




procedure Register;
begin
  GroupDescendentsWith(TioFastReportModelPresenterDataset, FMX.Controls.TControl);
  GroupDescendentsWith(TioFastReportDatasetDataset, FMX.Controls.TControl);
  RegisterComponents('iORM - FastReport', [TioFastReportModelPresenterDataset, TioFastReportDatasetDataset]);
end;


end.
