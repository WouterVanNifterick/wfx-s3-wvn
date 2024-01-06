unit Wfx.Plugin.ExportProcs;

interface

uses
  System.SysUtils,
  Vcl.Dialogs,
  System.Classes,
  WinApi.Windows,
  WinApi.ShellApi,
  System.AnsiStrings,
  Wfx.Plugin.Consts;

procedure DLLEntryPoint(dwReason: DWORD);
function FsInitW(aPluginNr: Integer; aProgressProcW: TProgressProcW; aLogProcW: TLogProcW; aRequestProcW: TRequestProcW): Integer; stdcall;

function FsExecuteFileW(MainWin: THandle; RemoteName, Verb: PWideChar): Integer; stdcall;
function FsFindFirstW(aPath: PWideChar; aFindData: PWin32FindDataW): Integer; stdcall;
function FsFindNextW(aHandle: THandle; var FindDataW: TWin32FindDataW): bool; stdcall;
function FsFindClose(Hdl: THandle): Integer; stdcall;
function FsDeleteFileW(aRemoteName: PWideChar): bool; stdcall;
function FsGetFileW(RemoteName, LocalName: PWideChar; CopyFlags: Integer; RemoteInfo: pRemoteInfo): Integer; stdcall;
procedure FsGetDefRootName(DefRootName: PAnsiChar; MaxLen: Integer); stdcall;
procedure FsStatusInfoW(RemoteDir: PWideChar; InfoStartEnd, InfoOperation: Integer); stdcall;
function FsExtractCustomIconW(RemoteName: PWideChar; ExtractFlags: Integer; var TheIcon: HIcon): Integer; stdcall;

procedure FsSetCryptCallbackW(CryptProcW:TCryptProcW;CryptoNr,Flags:integer); stdcall;
function FsMkDirW(RemoteDir:pwidechar):bool; stdcall;
function FsRenMovFileW(OldName,NewName:pwidechar;Move,OverWrite:bool; RemoteInfo:pRemoteInfo):integer; stdcall;
function FsPutFileW(LocalName,RemoteName:pwidechar;CopyFlags:integer):integer; stdcall;
function FsRemoveDirW(RemoteName:pwidechar):bool; stdcall;
procedure FsConnectW(RemoteName:pwidechar); stdcall;
function FsDisconnectW(DisconnectRoot:pwidechar):bool; stdcall;
function FsSetAttrW(RemoteName:pwidechar;NewAttr:integer):bool; stdcall;
function FsSetTimeW(RemoteName:pwidechar;CreationTime,LastAccessTime,  LastWriteTime:PFileTime):bool; stdcall;
procedure FsSetDefaultParams(dps:pFsDefaultParamStruct); stdcall;
function FsGetPreviewBitmapW(RemoteName:pwidechar;width,height:integer; var ReturnedBitmap:hbitmap):integer; stdcall;
function FsLinksToLocalFiles:bool; stdcall;
function FsGetLocalNameW(RemoteName:pwidechar;maxlen:integer):bool; stdcall;

implementation

uses
  Wfx.Plugin.Intf;

var
  Plugin: IWfxPlugin;

procedure DLLEntryPoint(dwReason: DWORD);
begin
  case dwReason of
    DLL_PROCESS_ATTACH:
      Plugin := globalPluginFactory;
    DLL_PROCESS_DETACH:
      Plugin := nil;
  end;
end;

function FsInitW(aPluginNr: Integer; aProgressProcW: TProgressProcW; aLogProcW: TLogProcW; aRequestProcW: TRequestProcW): Integer; stdcall;
begin
  Plugin.PluginNumber    := aPluginNr;
  Plugin.EnterText       := aRequestProcW;
  Plugin.ProgressBarProc := aProgressProcW;
  Plugin.LogProc         := aLogProcW;
  Plugin.Init;
  Result := INIT_OK
end;

function FsExecuteFileW(MainWin: THandle; RemoteName, Verb: PWideChar): Integer; stdcall;
begin
  Result := Plugin.ExecuteFile(MainWin, RemoteName, Verb);
end;

function FsFindFirstW(aPath: PWideChar; aFindData: PWin32FindDataW): Integer; stdcall;
begin
  Result := Plugin.FindFirstFile(aFindData^, aPath);
  if Plugin.FileCount = 0 then
  begin
    SetLastError(ERROR_NO_MORE_FILES);
    aFindData.dwFileAttributes := 0;
    Result := -1;
  end;
end;

function FsFindNextW(aHandle: THandle; var FindDataW: TWin32FindDataW): bool; stdcall;
begin
  if Plugin.FileCount = 0 then
    Exit(False);

  Result := Plugin.FindNextFile(aHandle, FindDataW);
end;

function FsFindClose(Hdl: THandle): Integer; stdcall;
begin
  Result := 0;
end;

function FsDeleteFileW(aRemoteName: PWideChar): bool; stdcall;
begin
  Result := Plugin.Delete(aRemoteName);
end;

function FsGetFileW(RemoteName, LocalName: PWideChar; CopyFlags: Integer; RemoteInfo: pRemoteInfo): Integer; stdcall;
begin
  Result := Plugin.GetFile(RemoteName, LocalName)
end;

procedure FsGetDefRootName(DefRootName: PAnsiChar; MaxLen: Integer); stdcall;
begin
  System.AnsiStrings.StrLCopy(DefRootName, PAnsiChar(AnsiString(Plugin.GetPluginName)), MaxLen - 1);
end;

procedure FsStatusInfoW(RemoteDir: PWideChar; InfoStartEnd, InfoOperation: Integer); stdcall;
begin
   if (InfoStartEnd <> FS_STATUS_END) and
      (InfoOperation = FS_STATUS_OP_GET_MULTI) then
   begin

   end;
end;

function FsExtractCustomIconW(RemoteName: PWideChar; ExtractFlags: Integer; var TheIcon: HIcon): Integer; stdcall;
begin
  Result := Plugin.GetIcon(RemoteName, ExtractFlags, TheIcon);
end;


procedure FsSetCryptCallbackW(CryptProcW:TCryptProcW;CryptoNr,Flags:integer); stdcall;
begin
  Plugin.SetCryptCallback(CryptProcW, CryptoNr, Flags)
end;

function FsMkDirW(RemoteDir:pwidechar):bool; stdcall;
begin
  Result := Plugin.MkDir(RemoteDir);
end;

function FsRenMovFileW(OldName,NewName:pwidechar;Move,OverWrite:bool; RemoteInfo:pRemoteInfo):integer; stdcall;
begin
  Result := Plugin.RenMovFile(OldName, newName, Move, Overwrite, remoteInfo);
end;

function FsPutFileW(LocalName,RemoteName:pwidechar;CopyFlags:integer):integer; stdcall;
begin
  Result := Plugin.PutFile(LocalName, RemoteName, CopyFlags);
end;

function FsRemoveDirW(RemoteName:pwidechar):bool; stdcall;
begin
  Result := Plugin.RemoveDir(RemoteName)
end;

procedure FsConnectW(RemoteName:pwidechar); stdcall;
begin
  Plugin.Connect(RemoteName);
end;

function FsDisconnectW(DisconnectRoot:pwidechar):bool; stdcall;
begin
  Result := Plugin.Disconnect(DisconnectRoot)
end;

function FsSetAttrW(RemoteName:pwidechar;NewAttr:integer):bool; stdcall;
begin
  Result := Plugin.SetAttr(RemoteName, NewAttr)
end;

function FsSetTimeW(RemoteName:pwidechar;CreationTime,LastAccessTime,  LastWriteTime:PFileTime):bool; stdcall;
begin
  Result := Plugin.SetTime(RemoteName, CreationTime, LastAccessTime, LastWriteTime)
end;

procedure FsSetDefaultParams(dps:pFsDefaultParamStruct); stdcall;
begin
  Plugin.SetDefaultParams(dps)
end;

function FsGetPreviewBitmapW(RemoteName:pwidechar;width,height:integer; var ReturnedBitmap:hbitmap):integer; stdcall;
begin
  Result := Plugin.GetPreviewBitmap(RemoteName, width, height, ReturnedBitmap)
end;

function FsLinksToLocalFiles:bool; stdcall;
begin
  Result := Plugin.LinksToLocalFiles
end;

function FsGetLocalNameW(RemoteName:pwidechar;maxlen:integer):bool; stdcall;
var
  rem, loc:string;
begin
  loc := RemoteName;
  Result := Plugin.GetLocalName(loc, maxlen)
end;



end.
