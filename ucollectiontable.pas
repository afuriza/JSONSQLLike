unit uCollectionTable;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls,
  ExtCtrls, Menus, estoh.sqljson, SynEdit, SynHighlighterSQL;

type

  { TfrmCollection }

  TfrmCollection = class(TForm)
    btnExecSQL: TButton;
    btnOpenSQL: TButton;
    btnMenu: TButton;
    cbDBList: TComboBox;
    cbTableList: TComboBox;
    Label1: TLabel;
    Label2: TLabel;
    ListView1: TListView;
    miLoginTest: TMenuItem;
    Panel1: TPanel;
    Panel2: TPanel;
    mnList: TPopupMenu;
    seRunQuery: TSynEdit;
    Splitter1: TSplitter;
    SynSQLSyn1: TSynSQLSyn;
    procedure btnExecSQLClick(Sender: TObject);
    procedure btnOpenSQLClick(Sender: TObject);
    procedure cbDBListSelect(Sender: TObject);
    procedure cbTableListChange(Sender: TObject);
    procedure cbTableListSelect(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure BukaData(Val: string);
    procedure btnMenuClick(Sender: TObject);
    procedure miLoginTestClick(Sender: TObject);
  private

  public
    MySQL: TMySQLJSON;
  end;

var
  frmCollection: TfrmCollection;

implementation
uses
  uLoginTest;

{$R *.lfm}

{ TfrmCollection }

procedure TfrmCollection.FormCreate(Sender: TObject);
begin
  MySQL := TMySQLJSON.Create;
end;

procedure TfrmCollection.cbDBListSelect(Sender: TObject);
begin
  cbTableList.Items := MySQL.GetTableList(cbDBList.Text);
  MySQL.database := cbDBList.Text;
end;

procedure TfrmCollection.cbTableListChange(Sender: TObject);
begin

end;

procedure TfrmCollection.btnOpenSQLClick(Sender: TObject);
begin
  BukaData(seRunQuery.Text);
end;

procedure TfrmCollection.btnExecSQLClick(Sender: TObject);
begin
  MySQL.ExecSQL(seRunQuery.Text);
end;

procedure TfrmCollection.BukaData(Val: string);
var
  i, j: integer;
  vNewColumn: TListColumn;
  vNewItem: TListItem;
begin
  MySQL.OpenSQL(val);
  ListView1.Clear;
  ListView1.Columns.Clear;
  if MySQL.Rows.count > 0 then
  begin
    for i := 0 to MySQL.Rows[0].Count -1 do
    begin
      vNewColumn := ListView1.Columns.Add;
      vNewColumn.Caption := MySQL.Rows[0].Data[i].FieldName;
      vNewColumn.Width := 20 + Trunc(6.4 * MySQL.Rows[0].Data[i].FieldName.Length);
    end;
  end;
  for i := 0 to MySQL.Rows.Count -1 do
  begin
    vNewItem := ListView1.Items.Add;
    for j := 0 to MySQL.Rows[i].count -1 do
    begin
      if j = 0 then
        vNewItem.Caption := MySQL.Rows[i].Data[0].AsString
      else
        vNewItem.SubItems.Add(MySQL.Rows[i].Data[j].AsString);
    end;
  end;
  Application.ProcessMessages;
end;

procedure TfrmCollection.btnMenuClick(Sender: TObject);
begin

  with btnMenu.ClientToScreen(point(0, btnMenu.Height)) do
    mnList.Popup(X, Y);
end;

procedure TfrmCollection.miLoginTestClick(Sender: TObject);
begin
  frmLogin.show;
end;

procedure TfrmCollection.cbTableListSelect(Sender: TObject);
begin
  BukaData('select * from '+cbTableList.Text+' limit 1000');
end;

procedure TfrmCollection.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  Application.Terminate;
end;

procedure TfrmCollection.FormShow(Sender: TObject);
begin
  cbDBlist.Items := MySQL.GetDatabaseList;
end;

end.

