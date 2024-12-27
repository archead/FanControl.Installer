; Original software created by Rémi Mercier - Rem0o
; Please see their work at:
; https://github.com/Rem0o
; https://getfancontrol.com
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES:
; https://jrsoftware.org/ishelp/

#define AppName "FanControl"
#define AppVersion "Latest"
#define AppPublisher "Rémi Mercier - Rem0o"
#define AppURL "https://getfancontrol.com/"
#define AppExeName "FanControl.exe"

[Setup]
; NOTE: The value of AppId uniquely identifies this application. Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{B6558A55-98C6-4860-854B-85BF8A1CDAD2}
AppName={#AppName}
AppVersion={#AppVersion}
AppVerName={#AppName} {#AppVersion}
UninstallDisplayName={#AppName}
UninstallDisplayIcon={app}\{#AppExeName}
AppPublisher={#AppPublisher}
AppPublisherURL={#AppURL}
AppSupportURL={#AppURL}
AppUpdatesURL={#AppURL}
DefaultDirName={autopf}\{#AppName}

DisableProgramGroupPage=yes
LicenseFile=..\assets\FanControl.Releases\LICENSE
; Uncomment the following line to run in non administrative install mode (install for current user only.)
;PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog
OutputDir=..\bin
OutputBaseFilename=FanControl.Installer
Compression=none
SolidCompression=yes
WizardStyle=modern

; Only allow the installer to run on x64-compatible systems,
; and enable 64-bit install mode.
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"


[Types]
Name: "default"; Description: "Default (.NET 8.0)" 
Name: "custom"; Description: "Custom (Choose .NET 4.8 or 8.0)"; Flags: iscustom


[Components]
Name: "FanControl"; Description: Latest version of Fan Control; Flags: fixed;  Types: custom default;
Name: "FanControl\net48"; Description: Install latest version of Fan Control with .NET 4.8 (Legacy); Flags: exclusive; Types: custom;
Name: "FanControl\net80"; Description: Install latest version of Fan Control with .NET 8.0; Flags: exclusive; Types: custom default;

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked;

[Files]
; NOTE: Don't use "Flags: ignoreversion" on any shared system files
Source: "{tmp}\extracted_files\{#AppExeName}"; DestDir: "{app}"; Flags: external ignoreversion
Source: "{tmp}\extracted_files\*"; DestDir: "{app}"; Flags: external ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\{#AppName}"; Filename: "{app}\{#AppExeName}"
Name: "{autodesktop}\{#AppName}"; Filename: "{app}\{#AppExeName}"; Tasks: desktopicon

[Code]
var

  ModePage: TInputOptionWizardPage;

  DownloadPage: TDownloadWizardPage;
  FileName: String;
  TempDir: String;
  FilePath: String;
  ResultCode: Integer;
  
  Version: Integer;

const

  JSONFileName = 'version.json'; // Name of your JSON file
  ShowDescritions = false;
  
    
function OnDownloadProgress(const Url, FileName: String; const Progress, ProgressMax: Int64): Boolean;
begin
  if Progress = ProgressMax then
    Log(Format('Successfully downloaded file to {tmp}: %s', [FileName]));
  Result := True;
end;

// A very basic json "parser" to find keys and their values
// Not super robust since it just needs to retreive the version of the program
function GetVersionNumber: Integer;
var
  JsonContent: AnsiString;
  NumberPos: Integer;
  NumberEndPos: Integer;
  VersionNumber: string;
begin
  // Load the content of the JSON file
  if LoadStringFromFile(ExpandConstant('{tmp}\') + JSONFileName, JsonContent) then
  begin
    // Find the position of the "Number" field
    NumberPos := Pos('"Number":', JsonContent);
    if NumberPos > 0 then
    begin
      // Find the position of the number after "Number:" (move past the '"Number":' part)
      NumberPos := NumberPos + 9; // Move past '"Number":'
      // Now search for the end of the number (either a comma or closing brace)
      NumberEndPos := Pos(',', Copy(JsonContent, NumberPos, MaxInt)); // Find the comma after the number
      if NumberEndPos = 0 then
        NumberEndPos := Pos('}', Copy(JsonContent, NumberPos, MaxInt)); // If no comma, find the closing brace
      // Extract the number value
      VersionNumber := Copy(JsonContent, NumberPos, NumberEndPos - 1); // Subtract 1 to remove the comma or brace
      // Convert it to an integer and return it
      Result := StrToInt(Trim(VersionNumber));
    end
    else
    begin
      // "Number" not found in JSON
      Result := -1;
    end;
  end
  else
  begin
    // File could not be loaded
    Result := -1;
  end;
end;

function InitializeSetup: Boolean;
begin
  try
    DownloadTemporaryFile('https://raw.githubusercontent.com/Rem0o/FanControl.Releases/refs/heads/master/version.json', JSONFileName, '', @OnDownloadProgress);
    // Get the version number from the JSON file
    Version := GetVersionNumber;
    Log('Detected version: ' + IntToStr(Version));
    Result := True;
  except
    Log(GetExceptionMessage);
    Result := False;
  end;
end;

procedure InitializeWizard();
begin

  DownloadPage := CreateDownloadPage(SetupMessage(msgWizardPreparing), SetupMessage(msgPreparingDesc), @OnDownloadProgress);
  DownloadPage.ShowBaseNameInsteadOfUrl := True;
  
  // https://stackoverflow.com/a/58714173
  ModePage :=
    CreateInputOptionPage(
      wpWelcome, 'Installation mode', 'Select installation mode', 'Basic: Quick installation with default parameters' #13#10 'Advanced: Fully customizable installation', True, False);
  ModePage.Add('Basic mode (Recommended)');
  ModePage.Add('Advanced mode');
  ModePage.Values[0] := True; { Select Basic mode by default }
end;

function ShouldSkipPage(PageID: Integer): Boolean;
begin
  { If "Basic" mode is selected, skip Directory and Components pages }
  Result := 
    ModePage.Values[0] and
    ((PageID = wpSelectDir) or (PageID = wpSelectComponents));
end;

function NextButtonClick(CurPageID: Integer): Boolean;
begin
  if CurPageID = wpReady then begin
  
    DownloadPage.Clear;
    // Use AddEx to specify a username and password
    if WizardIsComponentSelected('FanControl\net48') then 
      DownloadPage.Add('https://github.com/Rem0o/FanControl.Releases/releases/latest/download/FanControl_' + IntToStr(Version) + '_net_4_8.zip', '{#AppVersion}.zip', '');
    if WizardIsComponentSelected('FanControl\net80') then 
      DownloadPage.Add('https://github.com/Rem0o/FanControl.Releases/releases/latest/download/FanControl_' + IntToStr(Version) + '_net_8_0.zip', '{#AppVersion}.zip', '');
    DownloadPage.Show;
    try
      try
        begin
          DownloadPage.Download; // This downloads the files to {tmp}
          
          FileName := '{#AppVersion}.zip';
          
          TempDir := ExpandConstant('{tmp}\extracted_files');
          
          FilePath := ExpandConstant('{tmp}\') + FileName;
          
          CreateDir(TempDir);
          
          // uses the system unarchiver to extract the release zip
          Exec(ExpandConstant('{sys}\tar.exe'), '-xf ' + FilePath + ' -C ' + TempDir, ExpandConstant('{tmp}'), SW_HIDE, ewWaitUntilTerminated, ResultCode);
          Result := True;
        end;
      except
        if DownloadPage.AbortedByUser then
          Log('Aborted by user.')
        else
          SuppressibleMsgBox(AddPeriod(GetExceptionMessage), mbCriticalError, MB_OK, IDOK);
        Result := False;
      end;
    finally
      DownloadPage.Hide;
    end;
  end else
    Result := True;
end;

function InitializeUninstall(): Boolean;

  //var ErrorCode: Integer;
begin // ensure that FanControl is not running in case the user did not close it > inno doesn't have an easy way to check this without a Mutex
  // Display a message box
  case MsgBox('Please fully close FanControl.'#13#10'Uninstallation process will fail if not fully closed!', mbError, MB_OKCANCEL) of 
    IDOK: { user clicked OK };
    IDCANCEL: { user clicked CANCEL };
  end;
  // No longer used keeping as reference
  //ShellExec('open','taskkill.exe','/f /im {#AppExeName}','',SW_HIDE,ewNoWait,ErrorCode); Flags: wa
  //ShellExec('open','tskill.exe',' {#AppName}','',SW_HIDE,ewNoWait,ErrorCode);
  result := True;
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
begin
  if CurUninstallStep = usPostUninstall then
  begin
    if MsgBox('Do you want to remove user generated files?'#13#10'i.e. Config, Plugins, Logs', mbConfirmation, MB_YESNO or MB_DEFBUTTON2) = IDYES then
    begin
        DelTree(ExpandConstant('{app}'), True, True, True);
    end;
  end;
end;

[Run]
Filename: "{app}\{#AppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(AppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent

[UninstallRun]
; In case start on boot is enabled, remove with the rest of the uninstall
Filename: "schtasks"; Parameters: "/Delete /TN ""FanControl"" /F"; Flags: shellexec runhidden waituntilterminated; RunOnceId: "DelSchTask"

; No longer used > keeping as reference
;Filename: "{cmd}"; Parameters: "/C ""taskkill /im {#AppExeName} /t"; Flags: shellexec runhidden waituntilterminated; RunOnceId: "KillAppGraceful";

