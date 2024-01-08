unit Wfx.Plugin.S3;

interface

uses
  System.SysUtils,
  System.Classes,
  System.AnsiStrings,
  System.IOUtils,
  System.Generics.Collections,
  System.IniFiles,
  System.TypInfo,
  WinApi.ShFolder,

  WinApi.Windows,
  WinApi.Messages,

  Data.Cloud.CloudAPI,
  Data.Cloud.AmazonAPI,

  Wfx.Plugin.intf,
  Wfx.Plugin.Base,
  Wfx.Plugin.Consts,
  Wfx.Plugin.S3.Path, Vcl.Dialogs;

type
  TPluginMode = ( pmInit, pmPickProfile, pmPickBucket, pmShowFolderContents );
  TS3Plugin = class(TWFXPlugin, IWfxPlugin)
  const
    PLUGIN_NAME = 'S3';
  private
    procedure SetBucketName(const Value: string);
    procedure ConnectToS3;
  protected
    FConnectionInfo: TAmazonConnectionInfo;
    S3             : TAmazonStorageService;
    FBuckets       : TStrings;
    FRegion        : string;
    FBucketName    : string;
    FCurrentPath   : string;
    Path           : TS3TcPath;
    FProfile       : string;
    FPickProfile   : TFileInfo;
    PluginMode     : TPluginMode;
    FProfiles      : TStringList;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure Init; override;
    function GetPluginName: string;override;
    function GetUserPath:string;
    function FindFileInfo(aRemoteName: string; var fi:TFileInfo):boolean;
    function ExecuteFile(aMainWin: THandle; aRemoteName, aVerb: string): Integer; override;
    function FindFirstFile(var aFindData: TWin32FindData; aPath: string): THandle; override;
    function GetFile(aRemoteName: string; aLocalName: string): Integer;override;
    function GetIcon(aRemoteName: string; ExtractFlags: Integer; var TheIcon: HICON): Integer;override;
    function Delete(const aRemoteName: string): Boolean; override;
    function MkDir(aRemoteDir:String):Boolean;override;
    function RenMovFile(aOldName,aNewName:String;aMove,aOverWrite:Boolean; aRemoteInfo:pRemoteInfo):integer;override;
    function PutFile(aLocalName,aRemoteName:String;aCopyFlags:integer):integer;override;
    function RemoveDir(aRemoteName:String):Boolean;override;
    function Disconnect(aDisconnectRoot:String):Boolean;override;
    function GetLocalName(var aRemoteName:String;maxlen:integer):Boolean;override;

    property BucketName:string read FBucketName write SetBucketName;


  end;

implementation

function ISO8601ToDateTime(Value: String):TDateTime;
var
  fs: TFormatSettings;
begin
  fs := TFormatSettings.Create(GetThreadLocale);
  fs.DateSeparator := '-';
  fs.ShortDateFormat := 'yyyy-MM-dd';
  Value := Value.Replace('T', ' ').Replace('Z','').Substring(0,19);
  Result := StrToDateTime(Value, fs);
end;

procedure TS3Plugin.ConnectToS3;
begin
  const awsPath = GetUserPath;
  const credentials = TPath.Combine(TPath.Combine(awsPath,'.aws'),'credentials');

  FProfiles.Free;
  FProfiles := TStringList.Create;
  var AccountName := '';
  var AccountKey := '';

  if TFile.Exists(credentials) then
  begin
    const ini = TIniFile.Create(credentials);
    try
      AccountName  := ini.ReadString(FProfile,'aws_access_key_id',AccountName);
      AccountKey   := ini.ReadString(FProfile,'aws_secret_access_key',AccountKey);
      FRegion      := ini.ReadString(FProfile,'region',FRegion);
      ini.ReadSections(FProfiles);
    finally
      ini.Free;
    end;
  end;

  FConnectionInfo.Free;
  FConnectionInfo             := TAmazonConnectionInfo.Create(nil);
  FConnectionInfo.AccountName := AccountName;
  FConnectionInfo.AccountKey  := AccountKey;
  FConnectionInfo.Region      := FREgion;
  S3.Free;
  S3                               := TAmazonStorageService.Create(FConnectionInfo);

  if (AccountName = '') or
     (AccountKey = '') or
     (FRegion = '') then
    PluginMode := TPluginMode.pmPickProfile
  else
    PluginMode := TPluginMode.pmPickBucket;


end;

constructor TS3Plugin.Create;
begin
  inherited;
  PluginMode := TPluginMode.pmInit;
  Path := TS3TcPath.Create('');
  FProfiles := TStringList.Create;
  FBuckets := TStringList.Create;

end;

function TS3Plugin.Delete(const aRemoteName: string): Boolean;
  var res:TCloudResponseInfo;
  var s3ObjectName: string;

begin
  res := TCloudResponseInfo.Create;
  try
    if Path.IsBucket(aRemoteName) then
    begin
      Result := S3.DeleteBucket(Path.GetBucketName(aRemoteName), res, FRegion );
    end
    else
    begin
      s3ObjectName := Path.StripKnownBucket(aRemoteName);
      Result := S3.DeleteObject( BucketName, s3ObjectName, res, FRegion );
    end;
  finally
    LogDebug(res.StatusMessage);
    res.Free;
  end;
end;

destructor TS3Plugin.Destroy;
begin
  FBuckets.Free;
  S3.Free;
  FConnectionInfo.Free;
  inherited;
end;

function TS3Plugin.Disconnect(aDisconnectRoot: String): Boolean;
begin
  inherited;
  Result := false;
end;

function TS3Plugin.ExecuteFile(aMainWin: THandle; aRemoteName, aVerb: string): Integer;
begin
  try
    var f:TFileinfo;
    if not self.FindFileInfo(aRemoteName, f) then
      Exit(FS_EXEC_ERROR);

    if f.FileType = TFileType.ftAction then
    begin
      if Assigned(f.OnExecute) then
        f.OnExecute(aMainWin, aRemoteName, aVerb, @f);
    end;
    Result := FS_EXEC_OK;
  except
    on E: Exception do
    begin
      Result := FS_EXEC_ERROR;
      TCShowMessage('', E.Message);
    end;
  end;
end;

function TS3Plugin.FindFileInfo(aRemoteName: string; var fi:TFileInfo):boolean;
begin
  const a = aRemoteName.Split(['\']);

  var l := '';
  if length(a)>0 then
    l := a[high(a)]
  else
    l := aRemoteName;

  for var f in FFileList do
  begin
    if f.FileName = l then
    begin
      fi := f;
      Exit(True);
    end;
  end;
  Result := False;
end;

function TS3Plugin.FindFirstFile(var aFindData: TWin32FindData; aPath: string): THandle;
begin
  FCurrentPath := aPath;

  FFileList.Clear;

  if pluginMode=TPluginMode.pmShowFolderContents then
    if Path.IsRoot(FCurrentPath) then
      PluginMode := TPluginMode.pmPickBucket;

  case pluginMode of
    pmInit:
      FFileList.Add(FPickProfile);

    pmPickProfile:
      begin
        for var p in FProfiles do
        begin
          var f := TFileInfo.Create;
          f.FileName := p;
          f.IsVirtual := True;
          f.OnExecute :=
            procedure(aMainWin: THandle; aRemoteName, aVerb: string; sender:PFileInfo)
            begin
              const a = aRemoteName.Split(['\']);

              var l := '';
              if length(a)>0 then
                l := a[high(a)]
              else
                l := aRemoteName;

              PluginMode := TPluginMode.pmPickBucket;

              FProfile := l;
              ConnectToS3;
              RefreshTc(aMainWin);
            end;
          f.FileType := TFileType.ftAction;

          FFileList.Add(f);
        end;
      end;
    pmPickBucket:
      begin
        FFileList.Add(FPickProfile);
        FBuckets := S3.ListBuckets;
        LogDebug('Retrieved bucket list');
        for var bucketName in FBuckets do
        begin
          var FileInfo:= TFileInfo.Create;
          var item := bucketName.Split(['=']);
          if length(item) = 2 then
          begin
            FileInfo.FileName := item[0];
            FileInfo.Date := ISO8601ToDateTime(item[1]);
          end
          else
          begin
            FileInfo.FileName := bucketName;
            FileInfo.Date := 0;
          end;

          FileInfo.Directory := '';
          FileInfo.ReadOnly := True;
          FileInfo.Size := 0;
          FileInfo.FileType := TFileType.ftDir;
          FileInfo.OnExecute :=
            procedure(aMainWin: THandle; aRemoteName, aVerb: string; sender:PFileInfo)
            begin
              PluginMode := TPluginMode.pmShowFolderContents;
            end;
          FFileList.Add(FileInfo);
        end;
        FFileListIndex := 0;
        PluginMode := TPluginMode.pmShowFolderContents;
      end;
    pmShowFolderContents:
      begin
        const LBucketName = Path.GetBucketName(FCurrentPath);
        const LDirectory = Path.GetPrefix(FCurrentPath);
        var res := TCloudResponseInfo.Create;
        var params := TStringList.Create;
        params.AddPair('prefix', LDirectory );

        var LBucketResult := S3.GetBucket(LBucketName, params, res, FRegion);

        if LBucketResult <> nil then
        begin
          BucketName := LBucketResult.Name;
          for var o in LBucketResult.Objects do
          begin
            if o.Name = LDirectory then
              Continue;

            var FileInfo:= TFileInfo.Create;
            var Name := o.Name.TrimRight(['/']).Replace('/','\');

            FileInfo.Directory := LBucketResult.RequestPrefix;
            FileInfo.Date := ISO8601ToDateTime(o.LastModified);
            FileInfo.Size := o.Size;
            if o.Name.EndsWith('/') then
              FileInfo.FileType := TFileType.ftDir
            else
              FileInfo.FileType := TFileType.ftFile;

            FileInfo.ReadOnly := false;
            const prefix = ExtractFilePath(Name).Replace('\','/');
            if prefix <> LBucketResult.RequestPrefix then
              Continue;

            FileInfo.FileName  := Name.Substring(length(Prefix),MaxInt);

            FFileList.Add(fileInfo);
          end;
        end
        else
          TCShowMessage('Error', res.StatusMessage );

        res.Free;
      end;


  end;


  if FFileList.Count > 0 then
  begin
    FFileListIndex := 0;
    BuildFindData(aFindData, FFileList[0]);
  end
  else
  begin
    FFileListIndex := -1;
  end;
  Result := 1;

end;

procedure TS3Plugin.Init;
begin
  inherited;

  FProfile := 'default';
  FRegion := 'eu-west-1';
  FPickProfile.FileName := '[PICK AWS PROFILE]';

  FPickProfile.FileType := TFileType.ftAction;
  FPickProfile.ReadOnly := True;
  FPickProfile.Size := 0;
  FPickProfile.OnExecute :=
    procedure(aMainWin: THandle; aRemoteName, aVerb: string; sender:PFileInfo)
    begin
      PluginMode := TPluginMode.pmPickProfile;
      RefreshTc(aMainWin);
    end;

  PluginMode := TPluginMode.pmPickProfile;

  ConnectToS3;

  FBuckets.Free;
  FBuckets := TStringList.Create;
end;

function TS3Plugin.MkDir(aRemoteDir: String): Boolean;
var res:TCloudResponseInfo;
begin
  inherited;
  aRemoteDir := aRemoteDir.TrimLeft(['\']);
  var Slugs := aRemoteDir.Split(['\']);
  if length(Slugs) = 1 then
  begin
    // we're at the root, so let's create a bucket
    res := TCloudResponseInfo.Create;
    Result := S3.CreateBucket(aRemoteDir, TAmazonACLType.amzbaPrivate, FRegion, res);
  end
  else
  begin
    // we're in a bucket, so let's create a folder
    res := TCloudResponseInfo.Create;
    var s3Name := Path.StripKnownBucket(aRemoteDir) + '/';
    S3.UploadObject(BucketName, s3Name, [], false, nil, nil, TAmazonACLType.amzbaNotSpecified, res, FRegion );

  end;
  Exit(True);
end;

function TS3Plugin.PutFile(aLocalName, aRemoteName: String; aCopyFlags: integer): integer;
var res:TCloudResponseInfo;
begin
  if BucketName = '' then
  begin
    TCShowMessage('Cannot upload file', 'Select a bucket first');
    Exit(FS_FILE_OK);
  end;

  try
    res := TCloudResponseInfo.Create;
    var s3Name := Path.StripKnownBucket(aRemoteName);
    S3.UploadObject(BucketName, s3Name, TFile.ReadAllBytes(aLocalName), false, nil, nil, TAmazonACLType.amzbaNotSpecified, res, FRegion );
    Result := FS_FILE_OK;
  except
    Result := FS_FILE_WRITEERROR;
  end;
end;



function TS3Plugin.GetPluginName: string;
begin
  Result := PLUGIN_NAME;
end;

function TS3Plugin.RemoveDir(aRemoteName: String): Boolean;
begin
  Result := Delete(aRemoteName);
end;

function TS3Plugin.RenMovFile(aOldName, aNewName: String; aMove, aOverWrite: Boolean; aRemoteInfo: pRemoteInfo): integer;
begin
  try
    // Shitty, S3 does not support renaming of objects directly.
    // Amazon suggests creating a new object, and deleting the old
    var params := TAmazonGetObjectOptionals.Create;

    var oldName := Path.StripAnyBucket(aOldName);
    var oldBucket := Path.GetBucketName(aOldName);
    var newName := Path.StripAnyBucket(aNewName);
    var newBucket := Path.GetBucketName(aNewName);

    S3.CopyObject(newBucket, newName, oldBucket, oldName, nil, nil, FRegion);
    if oldBucket = newBucket then
      S3.DeleteObject(oldBucket, oldName, nil, FRegion) ;
    Result := FS_FILE_OK;
  except
    Result := 1;
  end;
end;

procedure TS3Plugin.SetBucketName(const Value: string);
begin
  FBucketName := Value;
  Path.BucketName := Value;
end;

function TS3Plugin.GetUserPath: string;
var
  LStr: array[0 .. MAX_PATH] of Char;
begin
  const CSIDL_PROFILE = $28;
  SetLastError(ERROR_SUCCESS);
  if SHGetFolderPath(0, CSIDL_PROFILE, 0, 0, @LStr) = S_OK then
    Result := LStr;
end;

function TS3Plugin.GetFile(aRemoteName, aLocalName: string): Integer;
begin
  try
    if (FCurrentPath = '\') then
    begin
      Result := FS_FILE_NOTSUPPORTED;
      exit;
    end
    else
    begin
      if not AbortCopy then
      begin
        var s := TFileStream.Create(aLocalName, fmCreate);
        var s3Item := Path.StripKnownBucket(aRemoteName);
        try
          var params := TAmazonGetObjectOptionals.Create;

          if S3.GetObject( BucketName, s3Item, params, s, nil, FRegion ) then
          begin
            Result := FS_FILE_OK
          end
          else
            Result := FS_FILE_READERROR;
        finally
          s.Free;
        end;
      end
    end;
    Result := FS_FILE_OK;
  except
    on E: Exception do
    begin
      Result := FS_FILE_READERROR;
      TCShowMessage('', E.Message);
    end;
  end;
end;

function TS3Plugin.GetIcon(aRemoteName: string; ExtractFlags: Integer; var TheIcon: HICON): Integer;
begin
  Result := FS_ICON_USEDEFAULT;
  if aRemoteName.EndsWith('\..\') then
    Exit;

   if Path.IsRoot(aRemoteName) then
  begin
    TheIcon := LoadIcon(HInstance, 'BUCKET');
    Result  := FS_ICON_EXTRACTED;
    Exit;
  end;

  var fi:= TFileInfo.Create;
  if FindFileInfo(aRemoteName, fi) then
  if fi.FileType = TFileType.ftAction then

  begin
    TheIcon := LoadIcon(HInstance, 'CONFIG');
    Result  := FS_ICON_EXTRACTED;
    Exit;
  end;

  if Path.IsBucket(aRemoteName) then
  begin
    TheIcon := LoadIcon(HInstance, 'BUCKET');
    Result  := FS_ICON_EXTRACTED;
    Exit;
  end;

end;

function TS3Plugin.GetLocalName(var aRemoteName: String; maxlen: integer): Boolean;
begin
  Result := True;
end;




initialization
  globalPluginFactory :=
    function:IWfxPlugin
    begin
      Result := TS3Plugin.Create;
    end;

end.
