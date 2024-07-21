unit iORM.DT.VMActionEditor;

interface

uses
  DesignEditors, DesignMenus, DesignIntf, Classes, System.Generics.Collections;


type
  TioVMActionEditor = class(TDefaultEditor)
  protected
    procedure EditProperty(const PropertyEditor: IProperty; var Continue: Boolean); override;
  end;

implementation

uses
  System.SysUtils

  ;


{ TVMActionEditor }

procedure TioVMActionEditor.EditProperty(const PropertyEditor: IProperty;
  var Continue: Boolean);
begin
  if CompareText(PropertyEditor.GetName, 'OnExecute') = 0 then
    inherited;
end;

end.
