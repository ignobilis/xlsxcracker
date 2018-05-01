unit usqlitedao;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sqldb, sqlite3conn;

type

  { TSQLiteDAO }

  TSQLiteDAO = class
  private
    FConn: TSQLite3Connection;
    FTran: TSQLTransaction;
    procedure Exec(ASQL: String);
  public
    constructor Create(ADatabaseName: String);
    destructor Destroy; override;
    procedure Write(AFilename, ASheetName, AXML: String);
    function ReadXML(AFilename, ASheetName: String): String;
    function Count(AFilename: String): Integer;
  end;

implementation

uses
  db;

{ TSQLiteDAO }

const
  CreateSQL = 'CREATE TABLE data (' +
                'filename text NOT NULL,' +
                'sheetname text NOT NULL,' +
                'xml text NOT NULL,' +
                'PRIMARY KEY (filename, sheetname));';
  WriteSQL = 'REPLACE INTO data (filename, sheetname, xml)' +
                'VALUES (''%s'',''%s'',''%s'');';
  ReadSQL = 'SELECT xml FROM data WHERE filename = ''%s'' AND sheetname = ''%s'';';
  CountSQL = 'SELECT count(*) AS cnt FROM data WHERE filename = ''%s'';';

function DoubleQuotedString(s: String): String;
begin
  Result := StringReplace(s, '''', '''''', [rfReplaceAll]);
end;

procedure TSQLiteDAO.Exec(ASQL: String);
begin
  FConn.Open;
  FTran.Active := True;
  FConn.ExecuteDirect(ASQL);
  FTran.Commit;
end;

constructor TSQLiteDAO.Create(ADatabaseName: String);
begin
  FConn := TSQLite3Connection.Create(Nil);
  FConn.DatabaseName := ADatabaseName;
  FTran := TSQLTransaction.Create(Nil);
  FTran.DataBase := FConn;

  if not FileExists(ADatabaseName) then
     Exec(CreateSQL)
   else
     FConn.Open;
end;

destructor TSQLiteDAO.Destroy;
begin
  FTran.CloseDataSets;
  FTran.Free;

  FConn.Close(False);
  FConn.Free;

  inherited Destroy;
end;

procedure TSQLiteDAO.Write(AFilename, ASheetName, AXML: String);
begin
  AFilename := DoubleQuotedString(AFilename);
  ASheetName := DoubleQuotedString(ASheetName);
  Exec(Format(WriteSQL, [AFilename, ASheetName, AXML]));
end;

function TSQLiteDAO.ReadXML(AFilename, ASheetName: String): String;
var
  q: TSQLQuery;
begin
  Result := '';
  AFilename := DoubleQuotedString(AFilename);
  ASheetName := DoubleQuotedString(ASheetName);
  q := TSQLQuery.Create(Nil);
  try
    q.DataBase := FConn;
    q.SQL.Text := Format(ReadSQL, [AFilename, ASheetName]);
    FTran.Active := True;
    q.Open;
    if not q.Eof then
      Result := q.FieldByName('xml').AsString;
    FTran.Commit;
  finally
    q.Close;
    q.Free;
  end;
end;

function TSQLiteDAO.Count(AFilename: String): Integer;
var
  q: TSQLQuery;
begin
  Result := 0;
  AFilename := DoubleQuotedString(AFilename);
  q := TSQLQuery.Create(Nil);
  try
    q.DataBase := FConn;
    q.SQL.Text := Format(CountSQL, [AFilename]);
    FTran.Active := True;
    q.Open;
    if not q.Eof then
      Result := q.FieldByName('cnt').AsInteger;
    FTran.Commit;
  finally
    q.Close;
    q.Free;
  end;
end;

end.

