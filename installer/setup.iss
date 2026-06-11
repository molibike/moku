; MokuERP Windows 安装包脚本
#define MyAppName "MokuERP"
#define MyAppVersion "3.0"
#define MyAppPublisher "Moku"
#define MyAppURL ""
#define MyAppExeName "MokuERP.exe"
#define MyAppStopExeName "MokuERP-stop.exe"

[Setup]
AppId={{A1B2C3D4-E5F6-7890-ABCD-EF1234567890}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName=D:\MokuERP
DisableProgramGroupPage=yes
OutputDir=D:\jshERP\installer\output
OutputBaseFilename=MokuERP-Setup
SetupIconFile=D:\jshERP\installer\moku_logo.ico
UninstallDisplayIcon={app}\moku_logo.ico
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
PrivilegesRequired=admin
PrivilegesRequiredOverridesAllowed=dialog

[Languages]
Name: "chinesesimplified"; MessagesFile: "D:\jshERP\installer\ChineseSimplified.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
; 主程序
Source: "D:\jshERP\installer\launcher\MokuERP.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "D:\jshERP\installer\launcher\MokuERP-stop.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "D:\jshERP\MokuERP-boot\target\MokuERP.jar"; DestDir: "{app}"; Flags: ignoreversion
Source: "D:\jshERP\installer\moku_logo.ico"; DestDir: "{app}"; Flags: ignoreversion

; JDK
Source: "D:\jshERP\tools\jdk8\jdk8u422-b05\*"; DestDir: "{app}\tools\jdk8\jdk8u422-b05"; Flags: ignoreversion recursesubdirs createallsubdirs; Excludes: "*.pdb,src.zip"

; MySQL
Source: "D:\jshERP\tools\mysql\mysql-5.7.44-winx64\*"; DestDir: "{app}\tools\mysql\mysql-5.7.44-winx64"; Flags: ignoreversion recursesubdirs createallsubdirs; Excludes: "*.pdb"

; MySQL Data
Source: "D:\jshERP\tools\mysql\data\*"; DestDir: "{app}\tools\mysql\data"; Flags: ignoreversion recursesubdirs createallsubdirs

; Redis
Source: "D:\jshERP\tools\redis\*"; DestDir: "{app}\tools\redis"; Flags: ignoreversion recursesubdirs createallsubdirs; Excludes: "*.pdb"

[Dirs]
Name: "{app}\upload"
Name: "{app}\tmp\tomcat"
Name: "{app}\logs"

[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; IconFilename: "{app}\moku_logo.ico"
Name: "{autoprograms}\{#MyAppName}\停止 {#MyAppName}"; Filename: "{app}\{#MyAppStopExeName}"; IconFilename: "{app}\moku_logo.ico"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon; IconFilename: "{app}\moku_logo.ico"

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "立即启动 {#MyAppName}"; Flags: nowait postinstall skipifsilent

[UninstallRun]
Filename: "{app}\{#MyAppStopExeName}"; Flags: waituntilterminated

[Code]
function InitializeSetup(): Boolean;
begin
  Result := True;
end;
