unit uxlsx;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, StdCtrls, usqlitedao;

type

  TProcessType = (ptCrack, ptProtect);

  { TxlsxCracker }

  TxlsxCracker = class
  private
    FCanProtect: Boolean;
    FRunPath: String;
    FFilepath: String;
    FFileDir: String;
    FTempFileDir: String;
    FFilename: String;
    FCrackedFilename: String;
    FProtectedFilename: String;
    FMmo: TMemo;
    FDAO: TSQLiteDAO;
    FXML: String;
    procedure SetFilepath(AValue: String);
    procedure Log(s: String);
    procedure ClearLog;
    procedure Process(AProcessType: TProcessType);
    procedure CopyToTemp;
    procedure Unzip;
    procedure ProcessXMLFiles(AProcessType: TProcessType);
    procedure ProcessXMLFile(AProcessType: TProcessType; AFilename: String);
    procedure RewriteXMLFile(AProcessType: TProcessType; AFilename: String;
      ALine: Integer; ASubString: String);
    procedure Zip(AProcessType: TProcessType);
    procedure CopyZipFile(AProcessType: TProcessType);
  public
    property Filepath: String read FFilepath write SetFilepath;
    property CanProtect: Boolean read FCanProtect;
    constructor Create(mmo: TMemo);
    destructor Destroy; override;
    procedure Crack;
    procedure Protect;
  end;

implementation

uses
  FileUtil, Zipper, Forms;

const
  TempFileDir = 'C:\Temp';
  TagSheetProtection = '<sheetProtection';
  TagClose = '/>';
  TagSheetData = '</sheetData>';

{ TxlsxCracker }

procedure TxlsxCracker.SetFilepath(AValue: String);
var
  ext: String;
  cnt: Integer;
begin
  cnt := 0;
  if (FFilepath <> AValue) then
  begin
    if (FileExists(AValue)) then
    begin
      ClearLog;
      FFilepath := AValue;
      FFileDir := ExtractFileDir(FFilepath);
      FFilename := ExtractFilename(FFilepath);
      ext := ExtractFileExt(FFilename);
      FCrackedFilename := StringReplace(FFilename, ext, '', []) + '_Cracked' + ext;
      FProtectedFilename := StringReplace(FFilename, ext, '', []) + '_Protected' + ext;
      FTempFileDir := TempFileDir + '\' + FFileName + '_';
      cnt := FDAO.Count(FFilename);
      FCanProtect := cnt > 0;
    end
    else
      raise Exception.Create('File does not exist.');
  end;
end;

procedure TxlsxCracker.Log(s: String);
begin
  if (FMmo <> Nil) then
    FMmo.Lines.Add(s);;
end;

procedure TxlsxCracker.ClearLog;
begin
  if (FMmo <> Nil) then
    FMmo.Clear;
end;

procedure TxlsxCracker.Process(AProcessType: TProcessType);
begin
  if (Trim(FFilepath) <> '') then
  begin
    CopyToTemp;
    Unzip;
    ProcessXMLFiles(AProcessType);
    Zip(AProcessType);
    CopyZipFile(AProcessType);
  end
  else
    raise Exception.Create('No file selected.');
end;

procedure TxlsxCracker.CopyToTemp;
begin
  if (DirectoryExists(FTempFileDir)) then
    DeleteDirectory(FTempFileDir, False);
  ForceDirectories(FTempFileDir);
  CopyFile(FFilepath, FTempFileDir + '\' + FFilename);
  Log('Temporary file created');
end;

procedure TxlsxCracker.Unzip;
var
  z: TUnZipper;
begin
  Log('Start unzipping');
  z := TUnZipper.Create;
  try
    z.Filename := FTempFileDir + '\' + FFilename;
    z.OutputPath := FTempFileDir + '\_';
    z.Examine;
    z.UnZipAllFiles;
    Log('Unzipping complete');
  finally
    z.Free;
  end;
end;

procedure TxlsxCracker.Zip(AProcessType: TProcessType);
var
  z: TZipper;
  filelist: TStringList;
  i: Integer;
begin
  Log('Start zipping');
  z := TZipper.Create;
  if (AProcessType = ptCrack) then
    z.Filename := FTempFileDir + '\_\' + FCrackedFilename
  else
    z.Filename := FTempFileDir + '\_\' + FProtectedFilename;
  filelist := TStringList.Create;
  try
    FindAllFiles(filelist, FTempFileDir + '\_');
    for i := 0 to filelist.Count - 1 do
      z.Entries.AddFileEntry(filelist[i], StringReplace(filelist[i], FTempFileDir + '\_\', '', []));
    z.ZipAllFiles;
    Log('Zipping complete');
  finally
    filelist.Free;
    z.Free;
  end;
end;

procedure TxlsxCracker.CopyZipFile(AProcessType: TProcessType);
begin
  Log('Copying file');
  if (AProcessType = ptCrack) then
    CopyFile(FTempFileDir + '\_\' + FCrackedFilename, FFileDir + '\' + FCrackedFilename)
  else
    CopyFile(FTempFileDir + '\_\' + FProtectedFilename, FFileDir + '\' + FProtectedFilename);
  Log('Deleting temporary files');
  DeleteDirectory(FTempFileDir, False);
  if (AProcessType = ptCrack) then
    Log('Cracking complete')
  else
    Log('Protecting complete');
end;

procedure TxlsxCracker.ProcessXMLFiles(AProcessType: TProcessType);
var
  sr: TSearchRec;
  fn: String;
begin
  Log('Start processing');
  if FindFirst(FTempFileDir + '\_\xl\worksheets\*.xml', faAnyFile, sr) = 0 then
  repeat
    fn := FTempFileDir + '\_\xl\worksheets\' + sr.Name;
    ProcessXMLFile(AProcessType, fn);
  until FindNext(sr) <> 0;
  FindClose(sr);
  Log('Done processing');
end;

procedure TxlsxCracker.ProcessXMLFile(AProcessType: TProcessType; AFilename: String);
var
  filename: String;
  f: TextFile;
  s: String;
  ln: Integer;
  idx, len: Integer;
  subs: String;
begin
  subs := '';
  filename := ExtractFilename(AFilename);
  Log('Processing ' + filename);
  if (AProcessType = ptProtect) then
    subs := FDAO.ReadXML(FFilename, filename);
  if ((AProcessType = ptCrack) or ((AProcessType = ptProtect) and (subs <> ''))) then
  begin
    AssignFile(f, AFilename);
    Reset(f);
    ln := 0;
    idx := 0;
    len := 0;
    while ((idx = 0) and (not Eof(f))) do
    begin
      Inc(ln);
      Readln(f, s);
      if (AProcessType = ptCrack) then
        idx := Pos(TagSheetProtection, s)
      else
        idx := Pos(TagSheetData, s)
    end;
    CloseFile(f);
    if (idx > 0) then
    begin
      if (AProcessType = ptCrack) then
      begin
        len := Pos(TagClose, Copy(s, idx, Length(s))) + (Length(TagClose) - 1);
        subs := Copy(s, idx, len);
        FDAO.Write(FCrackedFilename, filename, subs);
      end;
      RewriteXMLFile(AProcessType, AFilename, ln, subs);
    end;
  end;
  Log('Done processing ' + filename);
end;

procedure TxlsxCracker.RewriteXMLFile(AProcessType: TProcessType;
  AFilename: String; ALine: Integer; ASubString: String);
var
  tempfn: String;
  inp, outp: TextFile;
  s: String;
  ln: Integer;
begin
  tempfn := AFilename + '_';
  if not RenameFile(AFilename, tempfn) then
  begin
    Log('Renaming failed');
    Log(AFilename);
    Log(tempfn);
  end
  else
  begin
    AssignFile(inp, tempfn);
    AssignFile(outp, AFilename);
    Reset(inp);
    Rewrite(outp);
    ln := 0;
    while not Eof(inp) do
    begin
      Inc(ln);
      Readln(inp, s);
      if (ln = ALine) then
      begin
        if (AProcessType = ptCrack) then
          s := StringReplace(s, ASubString, '', [])
        else
          s := StringReplace(s, TagSheetData, TagSheetData + ASubString, []);
      end;
      Writeln(outp, s);
    end;
    CloseFile(inp);
    CloseFile(outp);
    DeleteFile(tempfn);
  end;
end;

constructor TxlsxCracker.Create(mmo: TMemo);
begin
  FMmo := mmo;
  FRunPath := ExtractFileDir(Application.ExeName);
  FDAO := TSQLiteDAO.Create(FRunPath + '\xlsx.dat');
  FXML := '';
end;

destructor TxlsxCracker.Destroy;
begin
  FDAO.Free;

  inherited Destroy;
end;

procedure TxlsxCracker.Crack;
begin
  Process(ptCrack);
end;

procedure TxlsxCracker.Protect;
begin
  Process(ptProtect);
end;

end.

