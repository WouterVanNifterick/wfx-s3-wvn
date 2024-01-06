library S3;

{$DEFINE NOFORMS}
{$R 'S3.res' '..\res\S3.rc'}

uses
  FastMM4,
  System.SysUtils,
  Vcl.Dialogs,
  System.Classes,
  WinApi.Windows,
  WinApi.ShellApi,
  System.AnsiStrings,
  Wfx.Plugin.S3 in 'Wfx.Plugin.S3.pas',
  Wfx.Plugin.S3.Path in 'Wfx.Plugin.S3.Path.pas',
  Wfx.Plugin.Base in 'Wfx.Plugin.Base.pas',
  Wfx.Plugin.intf in 'Wfx.Plugin.intf.pas',
  Wfx.Plugin.Consts in 'Wfx.Plugin.Consts.pas',
  Wfx.Plugin.ExportProcs in 'Wfx.Plugin.ExportProcs.pas';

{$E wfx}
{$IFDEF WIN64}
{$E w64}
{$IFNDEF VER230}
{$E wfx64}
{$ENDIF}
{$ENDIF}


exports
  FsInitW,
  FsFindFirstW,
  FsFindNextW,
  FsFindClose,
  FsGetDefRootName,
  FsExecuteFileW,
  FsGetFileW,
  FsStatusInfoW,
  FsExtractCustomIconW,
  FsDeleteFileW,
  FsSetCryptCallbackW,
  FsMkDirW,
  FsRenMovFileW,
  FsPutFileW,
  FsRemoveDirW,
  FsDisconnectW,
  FsSetAttrW,
  FsSetTimeW,
  FsSetDefaultParams,
  FsGetPreviewBitmapW,
  FsLinksToLocalFiles,
  FsGetLocalNameW;

begin
  DllProc := @DLLEntryPoint;
  DLLEntryPoint(DLL_PROCESS_ATTACH);
end.
