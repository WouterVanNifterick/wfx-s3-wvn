:: build delphi project

@echo off

setlocal

set DELPHI_BIN=C:\Program Files (x86)\Embarcadero\Studio\22.0\bin
set DELPHI_PROJECT=..\source\S3.dproj

call "%DELPHI_BIN%\rsvars.bat"

msbuild "%DELPHI_PROJECT%" /t:Build /p:Config=Release /p:Platform=Win32
copy ..\bin\S3.wfx ..\release\S3.wfx

msbuild "%DELPHI_PROJECT%" /t:Build /p:Config=Release /p:Platform=Win64
set DELPHI_OUTPUT=..\release\S3.wfx64
copy ..\bin\S3.wfx64 ..\release\S3.wfx64
copy ..\res\pluginst.inf ..\release\pluginst.inf

upx -9 "../release/S3.wfx"
upx -9 "../release/S3.wfx64"

set version=0.9

zip -j "../release/TotalCommander-WvN-S3-WFX-%version%.zip" "../release/S3.wfx" "../release/S3.wfx64" "../release/pluginst.inf"

endlocal

