unit iORM.MVVM.FMX.FastReportDataset;

interface

uses
  System.SysUtils,
  System.Classes,
  Data.DB,
  FMX.Controls,

  FMX.frxClass,

  iORM.DB.DataSet.Custom

  ;


type
  TioFastReportDataSetDataSet = class(TfrxUserDataSet)
  private
    FRecordCount: integer;
    FDataset: TioDatasetCustom;
    function IsDesignMode: boolean;
    function CheckDataset: Boolean;
    procedure SetDataset(const Value: TioDatasetCustom);
  protected
    function GetValue(AFieldName: String): Variant; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    /// <summary>
    ///   Opens the dataset.
    /// </summary>
    procedure Open; override;
    /// <summary>
    ///   Closes the dataset.
    /// </summary>
    procedure Close; override;
    /// <summary>
    ///   Sets the cursor to the first record.
    /// </summary>
    procedure First; override;
    /// <summary>
    ///   Moves the cursor to the next record.
    /// </summary>
    procedure Next; override;
    /// <summary>
    ///   Moves the cursor to the previous record. This method is used only
    ///   when printing groups.
    /// </summary>
    procedure Prior; override;
    /// <summary>
    ///   Function returns True if end of the dataset is reached.
    /// </summary>
    function Eof: Boolean; override;
    /// <summary>
    ///   Returns records count if DataSet supports it.
    /// </summary>
    function RecordCount: Integer; override;
  published
    property Dataset: TioDatasetCustom read FDataset write SetDataset;
  end;



implementation

uses
  iORM.Utilities,
  iORM.CommonTypes

  ;



type
  TioDatasetAccess = class(TioDatasetCustom);







{ TioFastReportDatasetDataSet }

function TioFastReportDataSetDataSet.CheckDataset: Boolean;
begin
  Result := Assigned(FDataset);
end;

procedure TioFastReportDataSetDataSet.Close;
begin
  if not IsDesignMode and CheckDataset then
    TioDatasetAccess(FDataset).Close;
end;

function TioFastReportDataSetDataSet.Eof: Boolean;
begin
  if not IsDesignMode and CheckDataset then
    Result := (FRecNo = Succ(RecordCount)) or TioDatasetAccess(FDataset).EOF;
end;

procedure TioFastReportDataSetDataSet.First;
begin
  FRecNo := 0;

  if not IsDesignMode and CheckDataset then
  begin
    FDataset.First;
    FRecNo := 1;
  end;
end;

function TioFastReportDataSetDataSet.GetValue(AFieldName: String): Variant;
var
  LCurrentObject: TObject;
begin
  Result := varEmpty;

  if not IsDesignMode and CheckDataset then
  begin
    LCurrentObject := TioDatasetAccess(FDataset).Current;

    if Assigned(LCurrentObject) then
      Result := TioUtilities.GetRttiProperty(
        TioUtilities.ClassNameToClassRef(LCurrentObject.ClassName), AFieldName).GetValue(LCurrentObject).AsVariant;
  end;
end;

function TioFastReportDataSetDataSet.IsDesignMode: boolean;
begin
  Result := csDesigning in ComponentState;
end;

procedure TioFastReportDataSetDataSet.Next;
begin
  if not IsDesignMode and CheckDataset then
  begin
    FDataset.Next;
    Inc(FRecNo);
  end;
end;

procedure TioFastReportDataSetDataSet.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited;

  if (AComponent = FDataset) and (Operation = opRemove) then
    FDataset := nil;
end;

procedure TioFastReportDataSetDataSet.Open;
begin
  FRecNo := 0;

  if not IsDesignMode and CheckDataset then
    TioDatasetAccess(FDataset).Open;
end;

procedure TioFastReportDataSetDataSet.Prior;
begin
  if not IsDesignMode and CheckDataset then
  begin
    FDataset.Prior;
    Dec(FRecNo);
  end;
end;

function TioFastReportDataSetDataSet.RecordCount: Integer;
begin
  if not IsDesignMode and CheckDataset then
    Result := FDataset.RecordCount
  else
    Result := 0;
end;

procedure TioFastReportDataSetDataSet.SetDataset(const Value: TioDatasetCustom);
begin
  if not Assigned(Value) and Assigned(FDataset) then
    FDataset.RemoveFreeNotification(Self);

  FDataset := Value;

  if Assigned(FDataset) then
    FDataset.FreeNotification(Self);
end;

end.
