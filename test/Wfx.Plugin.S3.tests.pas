unit Wfx.Plugin.S3.tests;

interface

uses

  Wfx.Plugin.Intf,
  Wfx.Plugin.S3,
  DUnitX.TestFramework;

type
  [TestFixture]
  S3PluginFixture = class
    SUT : TS3Plugin;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    [Test]
    procedure PluginNameNotEmpty;

    [Test]
    procedure InitDoesNotRaise;
  end;

implementation

procedure S3PluginFixture.Setup;
begin
  SUT := TS3Plugin.Create;
end;

procedure S3PluginFixture.TearDown;
begin
  SUT.Free;
end;

procedure S3PluginFixture.PluginNameNotEmpty;
begin
  Assert.IsNotEmpty(SUT.GetPluginName);
end;

procedure S3PluginFixture.InitDoesNotRaise();
begin
  Assert.WillNotRaiseAny( SUT.Init );
end;

initialization
  TDUnitX.RegisterTestFixture(S3PluginFixture);

end.
