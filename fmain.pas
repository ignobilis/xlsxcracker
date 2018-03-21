unit fmain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  StdCtrls, Menus, uxlsx;

type

  { TfrmMain }

  TfrmMain = class(TForm)
    Button1: TButton;
    Button2: TButton;
    btnProtect: TButton;
    edtFilename: TEdit;
    GroupBox1: TGroupBox;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    mnu: TMainMenu;
    mmo: TMemo;
    od: TOpenDialog;
    sb: TStatusBar;
    procedure btnProtectClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure MenuItem3Click(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  frmMain: TfrmMain;
  xlsxCracker: TxlsxCracker;

implementation

uses
  fabout;

{$R *.lfm}

{ TfrmMain }

procedure TfrmMain.Button1Click(Sender: TObject);
begin
  if (od.Execute) then
  begin
    edtFilename.Text := od.FileName;
    xlsxCracker.Filepath := od.FileName;
    btnProtect.Enabled := xlsxCracker.CanProtect;
  end;
end;

procedure TfrmMain.btnProtectClick(Sender: TObject);
begin
  if FileExists(edtFilename.Text) then
    xlsxCracker.Protect
  else
    MessageDlg('Error', 'Invalid filename or file error.', mtError, [mbOk], 0);
end;

procedure TfrmMain.Button2Click(Sender: TObject);
begin
  if FileExists(edtFilename.Text) then
    xlsxCracker.Crack
  else
    MessageDlg('Error', 'Invalid filename or file error.', mtError, [mbOk], 0);
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  xlsxCracker := TxlsxCracker.Create(mmo);
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  xlsxCracker.Free;
end;

procedure TfrmMain.MenuItem2Click(Sender: TObject);
begin
  Close;
end;

procedure TfrmMain.MenuItem3Click(Sender: TObject);
begin
  frmAbout.ShowModal;
end;

end.

