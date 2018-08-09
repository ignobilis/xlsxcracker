RequestExecutionLevel admin

# define installer name
OutFile "xlsxCrackerSetup.exe"
 
# set program files as install directory
InstallDir $PROGRAMFILES32\xlsxcracker

Name xlsxCracker

Page license
Page instfiles
UninstPage uninstConfirm
UninstPage instfiles

Icon xlsxcracker.ico

LicenseData license.txt
 
# default section start
Section

SetShellVarContext all

# define output path
SetOutPath $INSTDIR
 
# specify file to go in output path
File xlsxcracker.exe
File sqlite3.dll
 
# define uninstaller name
WriteUninstaller $INSTDIR\uninstaller.exe

WriteRegStr HKLM "SOFTWARE\ignobilis\xlsxcracker" datafolder "$DOCUMENTS\xlsxcracker"

CreateDirectory $DOCUMENTS\xlsxcracker

CreateShortCut "$SMPROGRAMS\xlsxCracker.lnk" "$INSTDIR\xlsxcracker.exe"
CreateShortCut "$DESKTOP\xlsxCracker.lnk" "$INSTDIR\xlsxcracker.exe"
 
#-------
# default section end
SectionEnd
 
# create a section to define what the uninstaller does.
# the section will always be named "Uninstall"
Section "Uninstall"
 
# Always delete uninstaller first
Delete $INSTDIR\uninstaller.exe

SetShellVarContext all
 
# now delete installed files
Delete $INSTDIR\xlsxcracker.exe
Delete $INSTDIR\sqlite3.dll

RMDir $INSTDIR

Delete $DOCUMENTS\xlsxcracker\xlsx.dat

RMDir $DOCUMENTS\xlsxcracker

Delete $SMPROGRAMS\xlsxCracker.lnk
Delete $DESKTOP\xlsxCracker.lnk
 
DeleteRegKey HKLM "SOFTWARE\ignobilis\xlsxcracker"
 
SectionEnd
