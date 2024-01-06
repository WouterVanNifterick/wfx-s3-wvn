unit Wfx.Plugin.Base;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  Wfx.Plugin.Intf,
  Wfx.Plugin.Consts,
  WinApi.Windows;

type

  TWFXPlugin = class abstract(TInterfacedObject, IWfxPlugin)
  protected
    FEnterText      : TRequestProcW;
    FPluginNumber   : Integer;
    FProgressBarProc: TProgressProcW;
    FLogProc        : TLogProcW;
    PathExe         : string;
    FFileListIndex  : Integer;
    FFileList       : TList<TFileInfo>;
    AbortCopy       : Boolean;
    FCurrentFile    : TFileInfo;
    DefaultParams   : TFsDefaultParamStruct;
    constructor Create; virtual;
    destructor Destroy; override;

    procedure LogDebug(const msg:string);
  public
    procedure RefreshTc(aMainWin:THandle);
    function GetPluginName: string; virtual; abstract;
    function ExecuteFile(aMainWin: THandle; aRemoteName, Verb: string): Integer; virtual; abstract;
    function FindFirstFile(var aFindData: TWin32FindData; Path: string): THandle; virtual; abstract;
    function FindNextFile(aHandle: THandle; var FindDataW: TWin32FindData): bool; virtual;
    function GetFile(aRemoteName: string; aLocalName: string): Integer; virtual; abstract;
    function Delete(const aRemoteName: string): Boolean; virtual; abstract;
    procedure Init; virtual;

    function GetDLLPathName: string;
    procedure TCShowMessage(const aTitle, aText: string);
    function Input(const aTitle, Question: string; var aText: string; aInputType: Integer = RT_Other): Boolean;
    procedure BuildFindData(var aFindData: TWin32FindDataW; const aFileInfo: TFileInfo); virtual;

  public
    private procedure SetFileListIndex(const aValue: Integer);
    private function  GetFileListIndex: Integer;
    public  property     FileListIndex: Integer read GetFileListIndex write SetFileListIndex;

    private function  GetPluginNumber: Integer;
    private procedure SetPluginNumber(aValue: Integer);
    public  property     PluginNumber: Integer read GetPluginNumber write SetPluginNumber;

    private procedure SetEnterText(const aValue: TRequestProcW);
    private function  GetEnterText: TRequestProcW;
    public  property     EnterText: TRequestProcW read  GetEnterText write SetEnterText;

    private procedure SetProgressBarProc(const aValue: TProgressProcW);
    private function  GetProgressBarProc: TProgressProcW;
    public  property     ProgressBarProc: TProgressProcW read GetProgressBarProc write SetProgressBarProc;

    private function  GetLogProc: TLogProcW;
    private procedure SetLogProc(const aValue: TLogProcW);
    public  property     LogProc: TLogProcW read GetLogProc write SetLogProc;


    private function  GetFileCount: Integer;
    public  property  FileCount: Integer read GetFileCount;

    private function  GetCurrentFile: TFileInfo;
    private procedure SetCurrentFile(const aValue: TFileInfo);

    property CurrentFile: TFileInfo read GetCurrentFile write SetCurrentFile;

    public function GetIcon(RemoteName: string; ExtractFlags: Integer; var TheIcon: HICON): Integer;virtual;

    procedure Connect(aRemoteName: string); virtual;
    function Disconnect(aDisconnectRoot:String):Boolean; virtual;

    procedure SetCryptCallback(CryptProcW:TCryptProcW;CryptoNr,Flags:integer); virtual;
    function MkDir(RemoteDir:String):Boolean; virtual;
    function RenMovFile(OldName,NewName:String;Move,OverWrite:Boolean; RemoteInfo:pRemoteInfo):integer; virtual;
    function PutFile(LocalName,RemoteName:String;CopyFlags:integer):integer; virtual;
    function RemoveDir(RemoteName:String):Boolean; virtual;
    function SetAttr(RemoteName:String;NewAttr:integer):Boolean; virtual;
    function SetTime(RemoteName:String;CreationTime,LastAccessTime,  LastWriteTime:PFileTime):Boolean; virtual;
    procedure SetDefaultParams(dps:pFsDefaultParamStruct); virtual;
    function GetPreviewBitmap(RemoteName:String;width,height:integer; var ReturnedBitmap:hbitmap):integer; virtual;
    function LinksToLocalFiles:Boolean; virtual;
    function GetLocalName(var RemoteName:String;maxlen:integer):Boolean; virtual;
  end;

implementation

{ TWFXPlugin }

uses WinApi.Messages;

function DateTimeToFileTime(MyDateTime: TDateTime): TFileTime;
var
  MyFileAge      : Integer;
  MyLocalFileTime: _FILETIME;
begin
  MyFileAge := DateTimeToFileDate(MyDateTime);
  DosDateTimeToFileTime(LongRec(MyFileAge).Hi, LongRec(MyFileAge).Lo, MyLocalFileTime);
  LocalFileTimeToFileTime(MyLocalFileTime, Result);
end;



constructor TWFXPlugin.Create;
begin
  PathExe := ExtractFilePath(GetDLLPathName);
  FFileList := TList<TFileInfo>.Create;
end;

procedure TWFXPlugin.Connect(aRemoteName: string);
begin
  LogDebug('Connect ' + aRemoteName);
end;

destructor TWFXPlugin.Destroy;
begin
  Self.FFileList.Free;
  inherited;
end;

function TWFXPlugin.Disconnect(aDisconnectRoot: String): Boolean;
begin
  LogDebug('Disconnect ' + aDisconnectRoot);
  Result := True;
end;

function TWFXPlugin.FindNextFile(aHandle: THandle; var FindDataW: TWin32FindData): bool;
begin
  if aHandle = 0 then
    Exit(false);

  FileListIndex := FileListIndex + 1;
  Result := FileCount > FileListIndex;
  if Result then
    BuildFindData(FindDataW, CurrentFile);
end;

function TWFXPlugin.GetCurrentFile: TFileInfo;
begin
  if FileListIndex < 0 then Exit(TFileInfo.Create);
  if FileListIndex >= FFileList.Count then Exit(TFileInfo.Create);

  Result := FFileList[FileListIndex];
end;

function TWFXPlugin.GetDLLPathName: string;
begin
  Result := GetModuleName(HInstance);
end;

function TWFXPlugin.GetEnterText: TRequestProcW;
begin
  Result := FEnterText
end;

function TWFXPlugin.GetFileCount: Integer;
begin
  if FFileList = nil then
    Exit(0);

  Result := FFileList.Count;
end;

function TWFXPlugin.GetFileListIndex: Integer;
begin
  Result := FFileListIndex;
end;

function TWFXPlugin.GetIcon(RemoteName: string; ExtractFlags: Integer; var TheIcon: HICON): Integer;
begin
  Result := 0;
end;

function TWFXPlugin.GetLocalName(var RemoteName: String; maxlen: integer): Boolean;
begin
  Result := True;
end;

function TWFXPlugin.GetLogProc: TLogProcW;
begin
  Result := FLogProc;
end;

function TWFXPlugin.GetPluginNumber: Integer;
begin
  Result := FPluginNumber;
end;

function TWFXPlugin.GetPreviewBitmap(RemoteName: String; width, height: integer; var ReturnedBitmap: hbitmap): integer;
begin
  Result := 0;
end;

function TWFXPlugin.GetProgressBarProc: TProgressProcW;
begin
  Result := FProgressBarProc;
end;

procedure TWFXPlugin.TCShowMessage(const aTitle, aText: string);
const max_msg_size = 256;
var a: array [0 .. max_msg_size] of char;
begin
  EnterText(FPluginNumber, RT_MsgOK, PChar(aTitle), PChar(aText), @a, max_msg_size);
end;



procedure TWFXPlugin.Init;
begin

end;

procedure TWFXPlugin.BuildFindData(var aFindData: TWin32FindDataW; const aFileInfo: TFileInfo);
begin
  aFindData := Default (TWin32FindDataW);
  StrCopy(aFindData.cFileName, PChar(aFileInfo.FileName));
  aFindData.nFileSizeLow     := aFileInfo.Size;
  aFindData.ftCreationTime   := DateTimeToFileTime(aFileInfo.Date);
  aFindData.ftLastWriteTime  := DateTimeToFileTime(aFileInfo.Date);
  aFindData.ftLastAccessTime := DateTimeToFileTime(aFileInfo.Date);

  if aFileInfo.ReadOnly then
    aFindData.dwFileAttributes := aFindData.dwFileAttributes + FILE_ATTRIBUTE_READONLY;

  if aFileInfo.IsVirtual then
    aFindData.dwFileAttributes := aFindData.dwFileAttributes + FILE_ATTRIBUTE_VIRTUAL ;

  if aFileInfo.FileType = TFileType.ftDir then
    aFindData.dwFileAttributes := aFindData.dwFileAttributes + FILE_ATTRIBUTE_DIRECTORY;

end;

function TWFXPlugin.Input(const aTitle, Question: string; var aText: string; aInputType: Integer = RT_Other): Boolean;
var
  a: array [0 .. 255] of char;
begin
  StrCopy(@a, PChar(aText));
  Result := EnterText(FPluginNumber, aInputType, PChar(aTitle), PChar(Question), @a, 256);
  aText := a;
end;

function TWFXPlugin.LinksToLocalFiles: Boolean;
begin
  Result := False;
end;

procedure TWFXPlugin.LogDebug(const msg: string);
begin
  if not IsDebuggerPresent then
    Exit;

  OutputDebugString( PwideChar(PWideString(WideString(msg))));
end;

function TWFXPlugin.MkDir(RemoteDir: String): Boolean;
begin
  Result := False;
end;

function TWFXPlugin.PutFile(LocalName, RemoteName: String; CopyFlags: integer): integer;
begin
  Result := FS_FILE_OK;
end;

procedure TWFXPlugin.RefreshTc(aMainWin:THandle);
begin
  const cm_RereadSource = 540;
  PostMessage(aMainWin, WM_USER+51, cm_RereadSource, 0);

end;

function TWFXPlugin.RemoveDir(RemoteName: String): Boolean;
begin
  Result := False;
end;

function TWFXPlugin.RenMovFile(OldName, NewName: String; Move, OverWrite: Boolean; RemoteInfo: pRemoteInfo): integer;
begin
  Result := FS_FILE_OK;
end;

function TWFXPlugin.SetAttr(RemoteName: String; NewAttr: integer): Boolean;
begin
  Result := False;
end;

procedure TWFXPlugin.SetCryptCallback(CryptProcW: TCryptProcW; CryptoNr, Flags: integer);
begin

end;

procedure TWFXPlugin.SetCurrentFile(const aValue: TFileInfo);
begin
  FCurrentFile := aValue;
end;

procedure TWFXPlugin.SetDefaultParams(dps: pFsDefaultParamStruct);
begin
  DefaultParams := dps^;
end;

procedure TWFXPlugin.SetEnterText(const aValue: TRequestProcW);
begin
  FEnterText := aValue;
end;

procedure TWFXPlugin.SetFileListIndex(const aValue: Integer);
begin
  FFileListIndex := aValue;
end;

procedure TWFXPlugin.SetLogProc(const aValue: TLogProcW);
begin
  FLogProc := aValue
end;

procedure TWFXPlugin.SetPluginNumber(aValue: Integer);
begin
  FPluginNumber := aValue;
end;

procedure TWFXPlugin.SetProgressBarProc(const aValue: TProgressProcW);
begin
  FProgressBarProc := aValue;
end;


function TWFXPlugin.SetTime(RemoteName: String; CreationTime, LastAccessTime, LastWriteTime: PFileTime): Boolean;
begin
  Result := False;
end;

end.
