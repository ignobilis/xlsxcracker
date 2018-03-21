unit fabout;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, fileinfo;

type

  { TfrmAbout }

  TfrmAbout = class(TForm)
    Button1: TButton;
    Image1: TImage;
    Label1: TLabel;
    lblVersion: TLabel;
    Label3: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  frmAbout: TfrmAbout;

implementation

uses
  winpeimagereader, elfreader, machoreader;

{$R *.lfm}

{ TfrmAbout }

procedure TfrmAbout.Button1Click(Sender: TObject);
begin
  Close;
end;

procedure TfrmAbout.FormCreate(Sender: TObject);
var
  fi: TFileVersionInfo;
begin
  try
    fi := TFileVersionInfo.Create(nil);
    fi.ReadFileInfo;
    lblVersion.Caption := Format('Version %s', [fi.VersionStrings.Values['FileVersion']]);
  finally
    fi.Free;
  end
end;

end.

