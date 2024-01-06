unit Wfx.Plugin.Consts;

interface

uses
  Winapi.Windows;

const
  INIT_OK = 0;

{ ids for FsGetFile }
const
  FS_FILE_OK                  = 0;
  FS_FILE_EXISTS              = 1;
  FS_FILE_NOTFOUND            = 2;
  FS_FILE_READERROR           = 3;
  FS_FILE_WRITEERROR          = 4;
  FS_FILE_USERABORT           = 5;
  FS_FILE_NOTSUPPORTED        = 6;
  FS_FILE_EXISTSRESUMEALLOWED = 7;

const
  FS_EXEC_OK       = 0;
  FS_EXEC_ERROR    = 1;
  FS_EXEC_YOURSELF = -1;
  FS_EXEC_SYMLINK  = -2;

const
  FS_COPYFLAGS_OVERWRITE            = 1;
  FS_COPYFLAGS_RESUME               = 2;
  FS_COPYFLAGS_MOVE                 = 4;
  FS_COPYFLAGS_EXISTS_SAMECASE      = 8;
  FS_COPYFLAGS_EXISTS_DIFFERENTCASE = 16;

  { flags for tRequestProc }
const
  RT_Other            = 0;
  RT_UserName         = 1;
  RT_Password         = 2;
  RT_Account          = 3;
  RT_UserNameFirewall = 4;
  RT_PasswordFirewall = 5;
  RT_TargetDir        = 6;
  RT_URL              = 7;

  RT_MsgOK            = 8;
  RT_MsgYesNo         = 9;
  RT_MsgOKCancel      = 10;

  { flags for tLogProc }
type
  TMsgType =
  record
    const
      connect           = 1;
      disconnect        = 2;
      details           = 3;
      transfercomplete  = 4;
      connectcomplete   = 5;
      importanterror    = 6;
      operationcomplete = 7;
  end;

  { flags for FsStatusInfo }
const
  FS_STATUS_START = 0;
  FS_STATUS_END   = 1;

const
  FS_STATUS_OP_LIST          = 1;
  FS_STATUS_OP_GET_SINGLE    = 2;
  FS_STATUS_OP_GET_MULTI     = 3;
  FS_STATUS_OP_PUT_SINGLE    = 4;
  FS_STATUS_OP_PUT_MULTI     = 5;
  FS_STATUS_OP_RENMOV_SINGLE = 6;
  FS_STATUS_OP_RENMOV_MULTI  = 7;
  FS_STATUS_OP_DELETE        = 8;
  FS_STATUS_OP_ATTRIB        = 9;
  FS_STATUS_OP_MKDIR         = 10;
  FS_STATUS_OP_EXEC          = 11;
  FS_STATUS_OP_CALCSIZE      = 12;
  FS_STATUS_OP_SEARCH        = 13;
  FS_STATUS_OP_SEARCH_TEXT   = 14;

  { Flags for FsExtractCustomIcon }
const
  FS_ICONFLAG_SMALL         = 1;
  FS_ICONFLAG_BACKGROUND    = 2;

  FS_ICON_USEDEFAULT        = 0;
  FS_ICON_EXTRACTED         = 1;
  FS_ICON_EXTRACTED_DESTROY = 2;
  FS_ICON_DELAYED           = 3;

type
  TRemoteInfo =
    record
      SizeLow       : Integer;
      SizeHigh      : Integer;
      LastWriteTime : TFileTime;
      Attr          : Integer;
    end;

  pRemoteInfo = ^TRemoteInfo;

type
  TFsDefaultParamStruct =
    record
      Size                      : Integer;
      PluginInterfaceVersionLow : Integer;
      PluginInterfaceVersionHi  : Integer;
      DefaultIniName            : array [0 .. MAX_PATH - 1] of AnsiChar;
    end;

  pFsDefaultParamStruct = ^TFsDefaultParamStruct;

  { callback functions }
type
  TProgressProc  = function (PluginNr: Integer; SourceName, TargetName: PAnsiChar; PercentDone: Integer) : Integer; stdcall;
  TProgressProcW = function (PluginNr: Integer; SourceName, TargetName: PWideChar; PercentDone: Integer): Integer; stdcall;
  TLogProc       = procedure(PluginNr: Integer; MsgType    : Integer; LogString  : PAnsiChar); stdcall;
  TLogProcW      = procedure(PluginNr: Integer; MsgType    : Integer; LogString  : PWideChar); stdcall;
  TRequestProc   = function (PluginNr: Integer; RequestType: Integer; CustomTitle, CustomText, ReturnedText: PAnsiChar; maxlen: Integer): bool; stdcall;
  TRequestProcW  = function (PluginNr: Integer; RequestType: Integer; CustomTitle, CustomText, ReturnedText: PWideChar; maxlen: Integer): bool; stdcall;

  PCryptProc     = ^TCryptProc;
  TCryptProc     = function (PluginNr, CryptoNumber:integer; mode:integer; ConnectionName, Password:PAnsiChar; maxlen:integer):integer; stdcall;
  PCryptProcW    = ^TCryptProcW;
  TCryptProcW    = function (PluginNr, CryptoNumber:integer; mode:integer; ConnectionName, Password:PWideChar; maxlen:integer):integer; stdcall;

implementation

end.
