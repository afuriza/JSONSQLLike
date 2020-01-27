unit estoh.sqljson;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FPHTTPClient, fpjson, jsonparser, fgl, Base64;

type

  TJSONSQLConnection = record
    WebServiceURI: string;
    hostname: string;
    username: string;
    password: string;
    database: string;
  end;

  TCustField = class(TObject)
    FieldName: string;
    FieldType: string;
    AsString: string;
    AsInteger: integer;
    AsBoolean: boolean;
    AsFloat: double;
    AsDate: TDate;
    AsTime: TTime;
    AsDateTime: TDateTime;
    AsCurrency: Currency;
  end;

  TCustFields = specialize TFPGMap<string, TCustField>;

  TCustRows = specialize TFPGList<TCustFields>;

  //TCustParam = class(TObject)
  //
  //end;

    //AsString: string;
    //AsInteger: integer;
    //AsBoolean: boolean;
    //AsFloat: double;
    //AsDate: TDate;
    //AsTime: TTime;
    //AsDateTime: TDateTime;
    //AsCurrency: Currency;
  //TCustParams = class(TObject)
  //private
  //  procedure SetDateTime(ADateTime: TDateTime);
  //  function GetDateTime: TDateTime;
  //  procedure SetDate(ADate: TDate);
  //  function GetDate: TDate;
  //  procedure SetInteger(AVal: TDateTime);
  //  function GetInteger: TDateTime;
  //  procedure SetString(ADateTime: TDateTime);
  //  function GetString : TDateTime;
  //public
  //  constructor Create(SQLStr: string);
  //  destructor Destroy; override;
  //
  //end;

  TMySQLJSON = class(TObject)
  private
    CurrentIndex: integer;
  public
    Rows: TCustRows;
    WebServiceURI: string;
    hostname: string;
    username: string;
    password: string;
    database: string;
    SQL: string;
    JSONBody: string;
    //DEBUGSTR: string;
    constructor Create;
    destructor Destroy; override;
    procedure Connect(AConnection: TJSONSQLConnection);
    procedure Connect;
    procedure OpenSQL(SQLStr: string);
    procedure ExecSQL(SQLStr: string);
    procedure Open;
    function FieldByName(AFieldName: string): TCustField;
    function FieldByIndex(AFieldIndex: integer): TCustField;
    procedure FindFirst;
    procedure FindLast;
    procedure FindNext;
    procedure FindPrevious;
    procedure Previous;
    procedure Next;
    procedure Last;
    procedure First;
    Procedure ExecSQL;
    function GetDatabaseList: TStringList;
    function GetTableList(ADatabaseName: string = ''): TStringList;
  end;

implementation

constructor TMySQLJSON.Create;
begin
  inherited Create;
  Rows := TCustRows.Create;
  CurrentIndex := -1;
end;

destructor TMySQLJSON.Destroy;
begin
  FreeAndNil(Rows);
  inherited Destroy;
end;

procedure TMySQLJSON.Connect(AConnection: TJSONSQLConnection);
begin
  WebServiceURI := AConnection.WebServiceURI;
  Hostname := AConnection.hostname;
  Username := AConnection.username;
  Password := AConnection.password;
  Database := AConnection.database;
  Connect;
end;

procedure TMySQLJSON.Connect;
begin
  // dummy connection test
  OpenSQL('show tables');
end;

function TMySQLJSON.GetDatabaseList: TStringList;
var
  i: integer;
begin
  if Assigned(Result) then
    Result := TStringList.Create;
  OpenSQL('show databases');
  for i := 0 to Rows.Count -1 do
  begin
    Result.Add(Rows[i].Data[0].AsString);
  end;
end;

function TMySQLJSON.GetTableList(ADatabaseName: string = ''): TStringList;
var
  i: integer;
  TempDBName: string;
begin
  TempDBName := Database;
  if Assigned(Result) then
    Result := TStringList.Create;
  if ADatabaseName <> '' then
    Database := ADatabaseName;
  OpenSQL('show tables');
  for i := 0 to Rows.Count -1 do
  begin
    Result.Add(Rows[i].Data[0].AsString);
  end;
  Database := TempDBName;
end;

function TMySQLJSON.FieldByName(AFieldName: string): TCustField;
begin
  if CurrentIndex < 0 then
    raise Exception.Create('Cannot find data')
  else
    Result := Rows[CurrentIndex].KeyData[AFieldName];
end;

function TMySQLJSON.FieldByIndex(AFieldIndex: integer): TCustField;
begin
  if CurrentIndex < 0 then
    raise Exception.Create('Cannot find data')
  else
    Result := Rows[CurrentIndex].Data[AFieldIndex];
end;

procedure TMySQLJSON.FindFirst;
begin
  if CurrentIndex < 0 then
    raise Exception.Create('Cannot find data')
  else
  begin
    CurrentIndex := 0;
  end;
end;

procedure TMySQLJSON.FindLast;
begin
  if CurrentIndex < 0 then
    raise Exception.Create('Cannot find data')
  else
  begin
    CurrentIndex := Rows.Count -1;
  end;
end;

procedure TMySQLJSON.FindNext;
begin
  if CurrentIndex < 0 then
    raise Exception.Create('Cannot find data')
  else
  begin
    if (CurrentIndex + 1) <= Rows.Count -1 then
      CurrentIndex += 1;
  end;
end;

procedure TMySQLJSON.FindPrevious;
begin
  if CurrentIndex < 0 then
    raise Exception.Create('Cannot find data')
  else
  begin
    if (CurrentIndex - 1) >= 0 then
      CurrentIndex -= 1;
  end;
end;

procedure TMySQLJSON.Previous;
begin
  FindPrevious;
end;

procedure TMySQLJSON.Next;
begin
  FindNext;
end;

procedure TMySQLJSON.Last;
begin
  FindLast;
end;

procedure TMySQLJSON.First;
begin
  FindFirst;
end;

procedure TMySQLJSON.Open;
begin
  OpenSQL(SQL);
end;

procedure TMySQLJSON.ExecSQL;
begin
  ExecSQL(SQL);
end;

function DumpExceptionCallStack(E: Exception): string;
var
  I: Integer;
  Frames: PPointer;
  Report: string;
begin
  Report := 'EXCEPTION ERROR ' + LineEnding +
    'Stacktrace' + LineEnding;
  if E <> nil then begin
    Report := Report + 'Exception class: ' + E.ClassName + LineEnding +
    'Message: ' + E.Message + LineEnding;
  end;
  Report := Report + BackTraceStrFunc(ExceptAddr);
  Frames := ExceptFrames;
  for I := 0 to ExceptFrameCount - 1 do
    Report := Report + LineEnding + BackTraceStrFunc(Frames[I]);
  Result := Report + LineEnding +
    'Stacktrace';
  //WriteLn(Report);
end;

procedure TMySQLJSON.OpenSQL(SQLStr: string);
var
  HTTP: TFPHTTPClient;
  FormData: TStrings;
  JSONResponse: TJSONData;
  TryInvalidJSON: Boolean;
  JSONRows: TJSONArray;
  Fields: TCustFields;
  Field: TCustField;
  i, j: integer;
  fm: TFormatSettings;
begin
  fm.ShortDateFormat := 'yyyy-mm-dd';
  fm.DateSeparator := '-';
  JSONBody := '';
  TryInvalidJSON := False;
  //DebugStr := 'Start: ';
  HTTP := TFPHTTPClient.Create(nil);
  FormData := TStringList.Create;
  try
    FormData.Values['hostname'] := Hostname;
    FormData.Values['uname'] := Username;
    FormData.Values['passwd'] := Password;
    if Database <> '' then
      FormData.Values['DatabaseName'] := Database
    else
      FormData.Values['DatabaseName'] := 'information_schema';
    FormData.Values['sqlstr'] := SQLStr;
    //DebugStr := 'Try: '+WebServiceURI+'/opensql';
    JSONBody := HTTP.FormPost(WebServiceURI+'/opensql', FormData);
    try
      JSONResponse := GetJSON(JSONBody);
    except
      TryInvalidJSON := True;
    end;
    //DebugStr := 'Open: '+HTTP.FormPost(WebServiceURI+'/opensql', FormData);
    if TryInvalidJSON then
    begin
      raise Exception.Create('mysqljson: INVALID_JSON_BODY');
    end
    else if JSONResponse.FindPath('result').AsString <> 'OK' then
    begin
      raise Exception.Create('mysqljson: '+JSONResponse.FindPath('msg').AsString);
    end
    else
    begin
      Rows.Clear;
      JSONRows := TJSONArray(JSONResponse.FindPath('rows'));

      for i := 0  to JSONRows.Count -1 do
      begin
        Fields := TCustFields.Create;
        for j := 0 to JSONRows.Items[i].Count -1 do
        begin
          //DebugStr := i.ToString + ', ' + j.ToString;
          Field := TCustField.Create;
          Field.FieldName := JSONRows.Items[i].Items[j].FindPath('name').AsString;
          Field.FieldType := JSONRows.Items[i].Items[j].FindPath('type').AsString;
          case JSONRows.Items[i].Items[j].FindPath('type').AsString of
            'string':
              begin
                if JSONRows.Items[i].Items[j].FindPath('value').AsString <> '' then
                  Field.AsString := DecodeStringBase64(JSONRows.Items[i].Items[j].FindPath('value').AsString);
              end;
            'integer':
              begin
                Field.AsInteger := JSONRows.Items[i].Items[j].FindPath('value').AsInteger;
                if JSONRows.Items[i].Items[j].FindPath('value').AsString <> '' then
                  Field.AsString := JSONRows.Items[i].Items[j].FindPath('value').AsString;
              end;
            'boolean':
              begin
                Field.AsBoolean := JSONRows.Items[i].Items[j].FindPath('value').AsBoolean;
                if JSONRows.Items[i].Items[j].FindPath('value').AsString <> '' then
                  Field.AsString := JSONRows.Items[i].Items[j].FindPath('value').AsString;
              end;
            'float':
              begin
                Field.AsFloat := JSONRows.Items[i].Items[j].FindPath('value').AsFloat;
                if JSONRows.Items[i].Items[j].FindPath('value').AsString <> '' then
                  Field.AsString := JSONRows.Items[i].Items[j].FindPath('value').AsString;
                Field.AsDateTime := JSONRows.Items[i].Items[j].FindPath('value').AsFloat;
                Field.AsDate := JSONRows.Items[i].Items[j].FindPath('value').AsFloat;
                Field.AsTime := JSONRows.Items[i].Items[j].FindPath('value').AsFloat;
                Field.AsInteger := JSONRows.Items[i].Items[j].FindPath('value').AsInteger;
              end;
            'currency':
              begin
                Field.AsCurrency := JSONRows.Items[i].Items[j].FindPath('value').AsFloat;
                if JSONRows.Items[i].Items[j].FindPath('value').AsString <> '' then
                  Field.AsString := JSONRows.Items[i].Items[j].FindPath('value').AsString;
                if JSONRows.Items[i].Items[j].FindPath('value').AsString <> '' then
                  Field.AsString := DateToStr(JSONRows.Items[i].Items[j].FindPath('value').AsFloat,
                    fm);
                if JSONRows.Items[i].Items[j].FindPath('value').AsString <> '' then
                  Field.AsString := TimeToStr(JSONRows.Items[i].Items[j].FindPath('value').AsFloat,
                    fm);
                if JSONRows.Items[i].Items[j].FindPath('value').AsString <> '' then
                  Field.AsString := DateTimeToStr(JSONRows.Items[i].Items[j].FindPath('value').AsFloat,
                    fm);
                Field.AsDateTime := JSONRows.Items[i].Items[j].FindPath('value').AsFloat;
                Field.AsDate := JSONRows.Items[i].Items[j].FindPath('value').AsFloat;
                Field.AsTime := JSONRows.Items[i].Items[j].FindPath('value').AsFloat;
                Field.AsInteger := JSONRows.Items[i].Items[j].FindPath('value').AsInteger;
              end;
            'date':
              begin
                Field.AsDate := JSONRows.Items[i].Items[j].FindPath('value').AsFloat;
                if JSONRows.Items[i].Items[j].FindPath('value').AsString <> '' then
                  Field.AsString := DateToStr(JSONRows.Items[i].Items[j].FindPath('value').AsFloat,
                    fm);
                if JSONRows.Items[i].Items[j].FindPath('value').AsString <> '' then
                  Field.AsString := TimeToStr(JSONRows.Items[i].Items[j].FindPath('value').AsFloat,
                    fm);
                if JSONRows.Items[i].Items[j].FindPath('value').AsString <> '' then
                  Field.AsString := DateTimeToStr(JSONRows.Items[i].Items[j].FindPath('value').AsFloat,
                    fm);
              end;
            'time':
              begin
                Field.AsTime := JSONRows.Items[i].Items[j].FindPath('value').AsFloat;
                if JSONRows.Items[i].Items[j].FindPath('value').AsString <> '' then
                  Field.AsString := DateToStr(JSONRows.Items[i].Items[j].FindPath('value').AsFloat,
                    fm);
                if JSONRows.Items[i].Items[j].FindPath('value').AsString <> '' then
                  Field.AsString := TimeToStr(JSONRows.Items[i].Items[j].FindPath('value').AsFloat,
                    fm);
                if JSONRows.Items[i].Items[j].FindPath('value').AsString <> '' then
                  Field.AsString := DateTimeToStr(JSONRows.Items[i].Items[j].FindPath('value').AsFloat,
                    fm);
              end;
            'datetime':
              begin
                Field.AsDateTime := JSONRows.Items[i].Items[j].FindPath('value').AsFloat;
                if JSONRows.Items[i].Items[j].FindPath('value').AsString <> '' then
                  Field.AsString := DateToStr(JSONRows.Items[i].Items[j].FindPath('value').AsFloat,
                    fm);
                if JSONRows.Items[i].Items[j].FindPath('value').AsString <> '' then
                  Field.AsString := TimeToStr(JSONRows.Items[i].Items[j].FindPath('value').AsFloat,
                    fm);
                if JSONRows.Items[i].Items[j].FindPath('value').AsString <> '' then
                  Field.AsString := DateTimeToStr(JSONRows.Items[i].Items[j].FindPath('value').AsFloat,
                    fm);
              end;
            'unknown':
              begin
                if JSONRows.Items[i].Items[j].FindPath('value').AsString <> '' then
                  Field.AsString := DecodeStringBase64(JSONRows.Items[i].Items[j].FindPath('value').AsString);
              end;
          end;
          Fields.Add(Field.FieldName, Field);
        end;
        Rows.Add(Fields);
      end;
    end;
    CurrentIndex := 0;
  finally
    HTTP.Free;

  end;

end;

procedure TMySQLJSON.ExecSQL(SQLStr: string);
var
  HTTP: TFPHTTPClient;
  FormData: TStrings;
  JSONResponse: TJSONData;
  TryInvalidJSON: Boolean;
begin
  JSONBody := '';
  TryInvalidJSON := False;
  HTTP := TFPHTTPClient.Create(nil);
  FormData := TStringList.Create;
  try
    FormData.Values['hostname'] := Hostname;
    FormData.Values['uname'] := Username;
    FormData.Values['passwd'] := Password;
    FormData.Values['DatabaseName'] := Database;
    FormData.Values['sqlstr'] := SQLStr;
    JSONBody := HTTP.FormPost(WebServiceURI+'/execsql', FormData);
    try
      JSONResponse := GetJSON(JSONBody);
    except
      TryInvalidJSON := True;
    end;
    //DebugStr := 'Open: '+HTTP.FormPost(WebServiceURI+'/opensql', FormData);
    if TryInvalidJSON then
    begin
      raise Exception.Create('mysqljson: INVALID_JSON_BODY');
    end
    else if JSONResponse.FindPath('result').AsString <> 'OK' then
    begin
      raise Exception.Create('mysqljson: '+JSONResponse.FindPath('msg').AsString);
    end;
  finally
    HTTP.Free;
    CurrentIndex := -1;
  end;
end;

end.

