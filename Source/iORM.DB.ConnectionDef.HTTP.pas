unit iORM.DB.ConnectionDef.HTTP;

interface

uses
  System.Classes,
  iORM.DB.Interfaces,
  iORM.CommonTypes,
  iORM.DBBuilder.Interfaces,
  iORM.DB.ConnectionDef

  ;


type
  // Class for http connection
  TioHttpConnectionDef = class(TioCustomConnectionDef)
  strict private
    // Fields
    FBaseURL: String;
    FPassword: String;
    FUserName: String;
  protected
    procedure InitConnectionDef; override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property AsDefault;
    property BaseURL: String read FBaseURL write FBaseURL;
    property Password: String read FPassword write FPassword;
    property Persistent;
    property UserName: String read FUserName write FUserName;
  end;


implementation

uses
  iORM.DB.ConnectionContainer

  ;

{ TioHttpConnectionDef }

constructor TioHttpConnectionDef.Create(AOwner: TComponent);
begin
  inherited;
  Persistent := True;
end;

procedure TioHttpConnectionDef.InitConnectionDef;
begin
  inherited;

  TioConnectionManager.NewHttpConnection(BaseURL, AsDefault, Persistent, Name);
end;

end.
