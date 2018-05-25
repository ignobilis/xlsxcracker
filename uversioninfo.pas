unit uVersionInfo;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

function ResourceVersionInfo: String;

implementation

uses
  resource, versiontypes, versionresource;

function ResourceVersionInfo: String;

(* Unlike most of AboutText (below), this takes significant activity at run-    *)
(* time to extract version/release/build numbers from resource information      *)
(* appended to the binary.                                                      *)

var
  Stream: TResourceStream;
  vr: TVersionResource;
  fi: TVersionFixedInfo;

begin
  Result := '';
  try
    (* This raises an exception if version info has not been incorporated into the  *)
    (* binary (Lazarus Project -> Project Options -> Version Info -> Version        *)
    (* numbering).                                                                  *)

    Stream := TResourceStream.CreateFromID(HINSTANCE, 1, PChar(RT_VERSION));
    try
      vr := TVersionResource.Create;
      try
        vr.SetCustomRawDataStream(Stream);
        fi:= vr.FixedInfo;
        Result := IntToStr(fi.FileVersion[0]) + '.' + IntToStr(fi.FileVersion[1]) +
                  '.' + IntToStr(fi.FileVersion[2]) + '.' + IntToStr(fi.FileVersion[3]);
        vr.SetCustomRawDataStream(nil)
      finally
        vr.Free
      end
    finally
      Stream.Free
    end
  except
  end
end; { resourceVersionInfo }

end.


