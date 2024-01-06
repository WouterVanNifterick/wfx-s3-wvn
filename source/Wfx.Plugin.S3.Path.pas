unit Wfx.Plugin.S3.Path;

interface

type
  TS3TcPath = record
    BucketName: string;
    TcPathWithoutBucket :string;
    S3Path :string;
    function IsRoot(const aRemoteName:string): Boolean;
    function IsBucket(const aRemoteName:string): Boolean;
    function IsS3Object(const aRemoteName:string): Boolean;
    function GetBucketName(const aRemoteName:string):string;
    function StripAnyBucket(const aRemoteName:string):string;
    function StripKnownBucket(const aRemoteName:string):string;
    function RemoteNameToS3(const aRemoteName:string):string;
    function GetS3FileName(const aRemoteName:string):string;
    function GetPrefix(const aRemoteName:string):string;
    constructor Create(aBucketName:string);
  end;

implementation

uses
  System.SysUtils,
  System.Classes,
  System.AnsiStrings,
  System.IOUtils
;


{ TS3TcPath }

function TS3TcPath.RemoteNameToS3(const aRemoteName: string): string;
begin
  Result := aRemoteName.Replace('\' + BucketName + '\', '');
end;

function TS3TcPath.StripAnyBucket(const aRemoteName: string): string;
begin
  const LBucketName = GetBucketName(aRemoteName);

  Result :=
      aRemoteName
        .TrimLeft(['\'])
        .Replace(LBucketName,'')
        .TrimLeft(['\'])
        .Replace('\','/');

end;

function TS3TcPath.StripKnownBucket(const aRemoteName: string): string;
begin
  Result :=
      aRemoteName
        .TrimLeft(['\'])
        .Replace(BucketName,'')
        .TrimLeft(['\'])
        .Replace('\','/');

end;

function TS3TcPath.IsBucket(const aRemoteName: string): Boolean;
begin
  Result := aRemoteName.StartsWith('\') and aRemoteName.EndsWith('\') and
           (aRemoteName.TrimLeft(['\']).TrimRight(['\']) = aRemoteName.Replace('\',''));
end;

function TS3TcPath.IsRoot(const aRemoteName: string): Boolean;
begin
  Result := aRemoteName = '\';
end;

function TS3TcPath.IsS3Object(const aRemoteName: string): Boolean;
begin
  Result := not IsBucket(aRemoteName)
end;

function TS3TcPath.GetS3FileName(const aRemoteName: string): string;
begin
  Result := TPath.GetFileName(StripKnownBucket(aRemoteName))
end;

constructor TS3TcPath.Create(aBucketName: string);
begin
  BucketName := aBucketName;
end;

function TS3TcPath.GetBucketName(const aRemoteName: string): string;
begin
  var Slugs := aRemoteName.TrimLeft(['\']).Split(['\']);
  if length(Slugs) > 0 then
    Result :=Slugs[0]
  else
    Result := '';
end;

function TS3TcPath.GetPrefix(const aRemoteName: string): string;
begin
  Result := StripAnyBucket(aRemoteName);
  if Result <> '' then
    Result := Result + '/'
end;

end.
