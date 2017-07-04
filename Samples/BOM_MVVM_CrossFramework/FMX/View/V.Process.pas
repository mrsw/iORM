unit V.Process;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  V.Material, Fmx.Bind.GenData, Data.Bind.GenData, Data.Bind.EngExt,
  Fmx.Bind.DBEngExt, System.Rtti, System.Bindings.Outputs, Fmx.Bind.Editors,
  Data.Bind.Components, iORM.MVVM.Components.ViewModelBridge,
  Data.Bind.ObjectScope, iORM.LiveBindings.ModelBindSource, FMX.Edit,
  FMX.ListBox, FMX.Layouts, FMX.Controls.Presentation, FMX.Objects, V.Interfaces,
  iORM.Attributes;

type

//  [diImplements(IArticleView, 'TProcess')]
  [diViewFor('TProcess')]
  TProcessView = class(TMaterialView)
    ListBoxItem5: TListBoxItem;
    EditTime: TEdit;
    LinkControlToField5: TLinkControlToField;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.fmx}

end.
