unit uLoginTest;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, estoh.sqljson,
  estoh.utils, uCollectionTable;

type

  { TfrmLogin }

  TfrmLogin = class(TForm)
    btnLogin: TButton;
    edUsername: TEdit;
    edPassword: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    procedure btnLoginClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    MySQL: TMySQLJSON;
  public

  end;

var
  frmLogin: TfrmLogin;

implementation

{$R *.lfm}

{ TfrmLogin }

procedure TfrmLogin.btnLoginClick(Sender: TObject);
var
  ValidLogin: Boolean = False;
begin
  MySQL.SQL := 'select * from systemuser where NmUser = "'+
      UpperCase(edUsername.Text) + '"';
  MySQL.Open;
  if MySQL.Rows.Count > 0 then
  begin
    if (UpperCase(MySQL.Rows[0]['NmUser'].AsString) = UpperCase(edUsername.Text)) and
      ((MySQL.Rows[0]['Pasword'].AsString = estEncrypt(UpperCase(edPassword.Text), 1))
      or (MySQL.Rows[0]['Pasword'].AsString = Hashing(UpperCase(edPassword.Text))))
      then
    begin
      ShowMessage('OK');
      ValidLogin := True;
    end;

  end;
  if not ValidLogin then
    ShowMessage('Error');
  ShowMessage('u: '+MySQL.Rows[0]['NmUser'].AsString+', p: '+
    MySQL.Rows[0]['Pasword'].AsString);
end;

procedure TfrmLogin.FormCreate(Sender: TObject);
begin
  MySQL := frmCollection.MySQL;
end;

end.

