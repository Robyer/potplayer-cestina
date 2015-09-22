[Setup]
AppVersion=2.5
VersionInfoVersion=2.5

AppName=PotPlayer CZ
AppId=PotPlayerCZ
DefaultDirName={code:GetDirName}
DefaultGroupName=Daum\PotPlayer
UninstallDisplayIcon={app}\uninstall.exe
Compression=lzma2
SolidCompression=yes
DirExistsWarning=no
UninstallFilesDir={app}\CZ
OutputBaseFilename=potplayer_czech
OutputDir=.
ArchitecturesInstallIn64BitMode=x64 ia64
AppPublisher=Robert Pösel (Robyer)
AppPublisherURL=http://www.robyer.cz/cestiny/pot-player
InfoBeforeFile=èti mì.txt

[Languages]
Name: "czech"; MessagesFile: "compiler:Languages\Czech.isl"

[Files]
Source: "Czech.dsf"; DestDir: "{app}\Skins"
Source: "Czech_old.dsf"; DestDir: "{app}\Skins"
Source: "Language\Czech.ini"; DestDir: "{app}\Language"
Source: "èti mì.txt"; DestDir: "{app}\CZ"; Flags: isreadme

[Run]
Filename: {code:GetFileName}; Description: Spustit PotPlayer; Flags: postinstall shellexec skipifsilent

[Code]
/////////////////////////////////////////////////////////////////////
function GetUninstallString(): String;
var
  sUnInstPath: String;
  sUnInstallString: String;
begin
  sUnInstPath := ExpandConstant('Software\Microsoft\Windows\CurrentVersion\Uninstall\PotPlayerCZ_is1');
  sUnInstallString := '';
  if not RegQueryStringValue(HKLM, sUnInstPath, 'UninstallString', sUnInstallString) then
    RegQueryStringValue(HKCU, sUnInstPath, 'UninstallString', sUnInstallString);
  Result := sUnInstallString;
end;


/////////////////////////////////////////////////////////////////////
function IsUpgrade(): Boolean;
begin
  Result := (GetUninstallString() <> '');
end;


/////////////////////////////////////////////////////////////////////
function UnInstallOldVersion(): Integer;
var
  sUnInstallString: String;
  iResultCode: Integer;
begin
// Return Values:
// 1 - uninstall string is empty
// 2 - error executing the UnInstallString
// 3 - successfully executed the UnInstallString

  // default return value
  Result := 0;

  // get the uninstall string of the old app
  sUnInstallString := GetUninstallString();
  if sUnInstallString <> '' then begin
    sUnInstallString := RemoveQuotes(sUnInstallString);
    if Exec(sUnInstallString, '/SILENT /NORESTART /SUPPRESSMSGBOXES','', SW_HIDE, ewWaitUntilTerminated, iResultCode) then
      Result := 3
    else
      Result := 2;
  end else
    Result := 1;
end;

/////////////////////////////////////////////////////////////////////
procedure CurStepChanged(CurStep: TSetupStep);
begin
  if (CurStep=ssInstall) then
  begin
    if (IsUpgrade()) then
    begin
      UnInstallOldVersion();
    end;
  end;
end;

/////////////////////////////////////////////////////////////////////
function NextButtonClick(PageId: Integer): Boolean;
begin
  Result := True;
  if (PageId = wpSelectDir) then
  begin
    if (not FileExists(ExpandConstant('{app}\PotPlayerMini64.exe')) and not FileExists(ExpandConstant('{app}\PotPlayerMini.exe'))) then begin
      MsgBox('Prosím zvolte složku, ve které máte nainstalovaný PotPlayer. Její umístìní se mùže lišit v závislosti na nainstalované verzi (32-bit nebo 64-bit).', mbError, MB_OK);
      Result := False;
      exit;
    end;
  end;
end;

/////////////////////////////////////////////////////////////////////
function GetDirName(Value: string): string;
var
  InstallPath: string;
begin
  // initialize default path, which will be returned when the following registry
  // key queries fail due to missing keys or for some different reason
  Result := ExpandConstant('{pf}\Daum\PotPlayer');
  // query the registry values; if this succeeds, return the obtained value
  if RegQueryStringValue(HKCU, 'Software\Daum\PotPlayer', 'ProgramFolder', InstallPath) then
    Result := InstallPath
  else if RegQueryStringValue(HKLM, 'Software\Daum\PotPlayer', 'ProgramFolder', InstallPath) then
    Result := InstallPath;
end;

function GetFileName(Value: string): string;
var
  InstallPath: string;
begin
  if FileExists(ExpandConstant('{app}\PotPlayerMini64.exe')) then
    Result := ExpandConstant('{app}\PotPlayerMini64.exe')
  else
    Result := ExpandConstant('{app}\PotPlayerMini.exe');
end;