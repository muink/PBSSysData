:: PBSSysData
:: Portable System System Data For Windows
:: Author: muink

@echo off
%~1 mshta vbscript:createobject("shell.application").shellexecute("%~f0","::","","runas",1)(window.close)&exit

:Init
cd /d %~dp0
if not "%~d0" == "%SystemDrive%" goto ERROR
call .\MakeInit.cmd "%~dp0"
set "CURRENTDEVICE=%SystemDrive%"
set "CURRENTROOT=%SystemRoot%"

set "ERRORLOG=%~dp0%CURRENTPC%\Error.log"
null>"%ERRORLOG%" 2>nul
set /a ERRORCOUNT=0

:LinkFiles
call:[LinkFiles] "*.ttf *.ttc *.otf *.otc" "%~dp0%CURRENTPC%\Fonts" "%CURRENTROOT%\Fonts"
call:[LinkFiles] "*.icc *.icm" "%~dp0%CURRENTPC%\ICC" "%CURRENTROOT%\System32\spool\drivers\color"

:MapFiles
call:[MapFiles] "*" "%~dp0%CURRENTPC%\Program Files" "%CURRENTDEVICE%\Program Files"
call:[MapFiles] "*" "%~dp0%CURRENTPC%\Program Files (x86)" "%CURRENTDEVICE%\Program Files (x86)"
call:[MapFiles] "*" "%~dp0%CURRENTPC%\ProgramData" "%CURRENTDEVICE%\ProgramData"
call:[MapFiles] "*" "%~dp0%CURRENTPC%\Windows" "%CURRENTDEVICE%\Windows"
call:[MapFiles] "*" "%~dp0%CURRENTPC%\Users" "%CURRENTDEVICE%\Users"


if %ERRORCOUNT% gtr 0 (
	echo.%ERRORCOUNT% errors have occurred and the error log will be opened for you...
	ping -n 5 127.0.0.1 >nul
	notepad "%ERRORLOG%"
)
goto :eof




:[MakeHDLink]
for /f "usebackq delims=" %%c in (`fsutil hardlink list "%~1"`) do if "%~pn2\%~nx1" == "%%~c" goto :eof
::#continue
mklink /h "%~2\%~nx1" "%~1" 2>nul || if exist "%~2\%~nx1" (
	echo."%~2\%~nx1" is exist, Unable to create hardlink...>>"%ERRORLOG%"
	set /a ERRORCOUNT+=1
)
goto :eof
:[LinkFiles]
setlocal enabledelayedexpansion
set "ftype=%~1"
set "srcpa=%~2"
set "dstpa=%~3"
echo.%dstpa%|findstr /e \ 2>nul && set "dstpa=%dstpa:~0,-1%"
pushd "%srcpa%"
for /f "delims=" %%i in ('dir /s /a-d-h /b %ftype% 2^>nul') do call:[MakeHDLink] "%%~i" "%dstpa%"
popd
for /f "delims=" %%i in ("%ERRORCOUNT%") do endlocal & set /a "ERRORCOUNT=%%~i"
goto :eof

:[MapHDLink]
setlocal enabledelayedexpansion
set "sandwich=%~1"
set "sandwich=!sandwich:%CD%=!"
set "sandwich=!sandwich:%~nx1=!"
for /f "usebackq delims=" %%c in (`fsutil hardlink list "%~1"`) do ( if "%~pn2%sandwich%%~nx1" == "%%~c" endlocal & goto :eof )
::#continue
md "%~pn2%sandwich%" 2>nul
mklink /h "%~2%sandwich%%~nx1" "%~1" 2>nul || if exist "%~2%sandwich%%~nx1" (
	echo."%~2%sandwich%%~nx1" is exist, Unable to create hardlink...>>"%ERRORLOG%"
	set /a ERRORCOUNT+=1
)
for /f "delims=" %%i in ("%ERRORCOUNT%") do endlocal & set /a "ERRORCOUNT=%%~i"
goto :eof
:[MapFiles]
setlocal enabledelayedexpansion
set "ftype=%~1"
set "srcpa=%~2"
set "dstpa=%~3"
echo.%dstpa%|findstr /e \ 2>nul && set "dstpa=%dstpa:~0,-1%"
pushd "%srcpa%"
for /f "delims=" %%i in ('dir /s /a-d-h /b %ftype% 2^>nul') do call:[MapHDLink] "%%~i" "%dstpa%"
popd
for /f "delims=" %%i in ("%ERRORCOUNT%") do endlocal & set /a "ERRORCOUNT=%%~i"
goto :eof

:ERROR
echo.
echo.You need put this project to system drive...
echo.
pause
exit
