unit uConnection;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  uCollectionTable;

type

  { TfrmConnection }

  TfrmConnection = class(TForm)
    btnEnter: TButton;
    Label1: TLabel;
    edWebService: TLabeledEdit;
    edHostname: TLabeledEdit;
    edUsername: TLabeledEdit;
    edPassword: TLabeledEdit;
    procedure btnEnterClick(Sender: TObject);
  private

  public

  end;

var
  frmConnection: TfrmConnection;

implementation

{$R *.lfm}

{ TfrmConnection }

procedure TfrmConnection.btnEnterClick(Sender: TObject);
begin
  frmCollection.MySQL.hostname := edHostname.Text;
  frmCollection.MySQL.WebServiceURI := edWebservice.Text;
  frmCollection.MySQL.username := edUsername.Text;
  frmCollection.MySQL.password := edPassword.Text;
  frmCollection.MySQL.Connect;
  frmCollection.show;
  Hide;
end;

end.

