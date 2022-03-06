unit iORM.StdAction.Fmx.DesignTime;

interface

procedure Register;

implementation

uses
  System.Actions, iORM.StdActions.Fmx;

procedure Register;
begin
  RegisterActions('iORM-BSPersistence', [TioBSPersistenceAppend], nil);
  RegisterActions('iORM-BSPersistence', [TioBSPersistenceClear], nil);
  RegisterActions('iORM-BSPersistence', [TioBSPersistenceDelete], nil);
  RegisterActions('iORM-BSPersistence', [TioBSPersistenceInsert], nil);
  RegisterActions('iORM-BSPersistence', [TioBSPersistencePersist], nil);
  RegisterActions('iORM-BSPersistence', [TioBSPersistenceReload], nil);
  RegisterActions('iORM-BSPersistence', [TioBSPersistenceRevert], nil);
  RegisterActions('iORM-BSPersistence', [TioBSPersistenceSaveRevertPoint], nil);
end;

end.
