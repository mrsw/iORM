unit iORM.DBBuilder.Interfaces;

interface

uses
  System.Generics.Collections, iORM.Context.Table.Interfaces, iORM.Context.Properties.Interfaces;

type

  IioDBBuilderSchemaFK = interface
    ['{1F653F52-570B-4381-930D-FB3945025DA2}']
    function ReferenceTableName: String;
    function ReferenceFieldName: String;
    function DependentTableName: String;
    function DependentFieldName: String;
  end;

  IioDBBuilderSchemaField = interface
    ['{D06F09FD-7252-46E3-A955-E6C2A3095E77}']
    function FieldName: String;
    function GetProperty: IioContextProperty;
    // IsSqlField
    function GetIsConcreteField: Boolean;
    procedure SetIsConcreteField(AValue: Boolean);
    property IsConcreteField: Boolean read GetIsConcreteField write SetIsConcreteField;
  end;

  TioDBBuilderSchemaFieldList = TList<IioDBBuilderSchemaField>;
  TioDBBuilderSchemaIndexList = TioIndexList;
  TioDBBuilderSchemaFKList = TList<IioDBBuilderSchemaFK>;

  IioDBBuilderSchemaTable = interface
    ['{2AFBE991-7E33-42DB-892E-01F8C98A5B8F}']
    function FieldExists(AFieldName: String): Boolean;
    function FieldList: TioDBBuilderSchemaFieldList;
    function FKList: TioDBBuilderSchemaFKList;
    function IDField: IioDBBuilderSchemaField;
    function IndexList: TioDBBuilderSchemaFieldList;
    function IndexListExists: Boolean;
    function IsClassFromField: Boolean;
    function IsForThisConnection(const AConnectionDefNameToCheck: String): Boolean;
    function TableName: String;
  end;

  TioDBBuilderSchemaTableList = TList<IioDBBuilderSchemaTable>;

  IioDBBuilderSchema = interface
    ['{1AEDB134-1ECB-490E-A53A-973BEDE509E5}']
    function SqlScript: TStringList;
    function TableList: TioDBBuilderSchemaTableList;
  end;

  IioDBBuilderStrategyIndex = interface
    ['{F72823BF-2611-439B-A8A3-D0427E017133}']
  end;

  IioDBBuilderStrategyFK = interface
    ['{936AFB28-FAFE-4A8C-AD97-3A9994D3A598}']
  end;

  IioDBBuilderStrategyField = interface
    ['{FBD4F76B-FF89-4CE3-A673-E6963E08257B}']
  end;

  IioDBBuilderStrategyTable = interface
    ['{7F5DEC8D-F22B-4F53-8C6F-2A829FDB6ED4}']
  end;

  IioDBBuilderStrategyDB = interface
    ['{EA9C37F2-705C-4C9D-969B-75D2E97605B5}']
  end;

  IioDBBuilderSqlGenerator = interface
    ['{9B5DE886-BE08-4422-9D6C-A92ABF948CD9}']
  end;

implementation

end.
