unit Wfx.Plugin.intf;

interface

uses
  Wfx.Plugin.Consts,
  WinApi.Windows;

type
  PFileInfo = ^TFileInfo;
  TFileType = (ftFile,ftDir,ftAction);
  TFileInfoProc = reference to procedure(aMainWin: THandle; aRemoteName, aVerb: string; sender:PFileInfo);
  TFileInfo = record
    FileName: string;
    Directory: string;
    Date: TDateTime;
    Size: Int64;
    ReadOnly: Boolean;
    IsVirtual: Boolean;
    OnExecute: TFileInfoProc;
    FileType:TFileType;
    class function Create:TFileInfo;static;
  end;

  IWfxPlugin = interface
    ['{659F13FB-D7DF-4416-A1A4-526A78208865}']
    function GetDLLPathName: string;
    function GetPluginName: string;
    function ExecuteFile(MainWin: THandle; RemoteName, Verb: string): Integer;
    function FindFirstFile(var FindData: TWin32FindDataW; Path: string): THandle;
    function FindNextFile(aHandle: THandle; var FindDataW: TWin32FindDataW): bool;
    function Delete(const RemoteName: string): Boolean;
    procedure TCShowMessage(const Title, Text: string);
    function Input(const Title, Question: string; var Text: string; InputType: Integer = RT_Other): Boolean;

    function GetFileListIndex: Integer;
    procedure SetFileListIndex(const Value: Integer);
    property FileListIndex: Integer read GetFileListIndex write SetFileListIndex;

    procedure SetPluginNumber(AValue: Integer);
    function GetPluginNumber: Integer;
    property PluginNumber: Integer        read GetPluginNumber    write SetPluginNumber;

    function GetProgressBarProc: TProgressProcW;
    procedure SetProgressBarProc(const Value: TProgressProcW);
    property ProgressBarProc : TProgressProcW read GetProgressBarProc write SetProgressBarProc;

    function GetLogProc: TLogProcW;
    procedure SetLogProc(const Value: TLogProcW);
    property LogProc         : TLogProcW      read GetLogProc write SetLogProc        ;

    function GetEnterText: TRequestProcW;
    procedure SetEnterText(const Value: TRequestProcW);
    property EnterText: TRequestProcW read GetEnterText write SetEnterText;

    function GetFileCount: integer;
    property FileCount:integer read GetFileCount;

    function GetCurrentFile:TFileInfo;
    property CurrentFile:TFileInfo read GetCurrentFile;

    procedure Init;

    function GetFile(aRemoteName,aLocalName:string):integer;

    function GetIcon(RemoteName: string; ExtractFlags: Integer; var TheIcon: HIcon):Integer;


    procedure SetCryptCallback(CryptProcW:TCryptProcW;CryptoNr,Flags:integer);
    function MkDir(RemoteDir:String):Boolean;
    function RenMovFile(OldName,NewName:String;Move,OverWrite:Boolean; RemoteInfo:pRemoteInfo):integer;
    function PutFile(LocalName,RemoteName:String;CopyFlags:integer):integer;
    function RemoveDir(RemoteName:String):Boolean;
    procedure Connect(aRemoteName: string);
    function Disconnect(DisconnectRoot:String):Boolean;
    function SetAttr(RemoteName:String;NewAttr:integer):Boolean;
    function SetTime(RemoteName:String;CreationTime,LastAccessTime,  LastWriteTime:PFileTime):Boolean;
    procedure SetDefaultParams(dps:pFsDefaultParamStruct);
    function GetPreviewBitmap(RemoteName:String;width,height:integer; var ReturnedBitmap:hbitmap):integer;
    function LinksToLocalFiles:Boolean;
    function GetLocalName(var RemoteName:String;maxlen:integer):Boolean;
  end;

type
 TPluginFactory = reference to function:IWfxPlugin;

var globalPluginFactory :TPluginFactory ;

implementation

uses System.SysUtils;

{ TFileInfo }

class function TFileInfo.Create: TFileInfo;
begin
  Result.FileName := '';
  Result.Date := now;
  Result.Size := 0;
  Result.FileType := TFileType.ftFile;
  Result.ReadOnly := False;
  Result.IsVirtual := True;
  Result.OnExecute :=
    procedure(aMainWin: THandle; aRemoteName, aVerb: string; sender:PFileInfo)
    begin

    end;

end;

end.
