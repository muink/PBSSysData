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
set "CURRENTDEVICE=%~d0"
set "LASTDEVICE=%~d0"
set "LASTDEVFILE=%~dp0%CURRENTPC%\.drv"
for /f "delims=" %%i in ('type "%LASTDEVFILE%" 2^>nul') do set "LASTDEVICE=%%~i"

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
:LinkDirs
call:[LinkDirs] "%~dp0%CURRENTPC%\%LINKSDR%" "%~dp0%CURRENTPC%\%LINKSDR%\%LINKSFL%"
echo.%~d0>"%~dp0%CURRENTPC%\.drv"


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

:[LinkHDDir]
if "%~2" == "" goto :eof
setlocal enabledelayedexpansion
set srcpath=
set dstpath=
for /f "delims=" %%i in ("%~2") do set "dstpath=%%~i"
set "srcpath=%~1%dstpath:~2%"
rem echo.%srcpath% --^> %dstpath%
if exist "%srcpath%\" (
	if exist "%dstpath%" (
		dir /al "%dstpath%\.." 2>nul|findstr /r /c:"<JUNCTION>  *%~n2 " >nul && (
			for /f "tokens=2 delims=[]" %%l in ('dir /al "%dstpath%\.." 2^>nul^|findstr /r /c:"<JUNCTION>  *%~n2 "') do (
				if not "%%~l" == "%srcpath%" (
					if "%%~l" == "%LASTDEVICE%%srcpath:~2%" (
						rd /q "%dstpath%" >nul 2>nul
						mklink /j "%dstpath%" "%srcpath%"
					) else echo."%dstpath%" is linked to another location, Unable to create dirlink...>>"%ERRORLOG%" && set /a ERRORCOUNT+=1
				)
			)
		) || echo.Dst:"%dstpath%" is exist, Unable to create dirlink...>>"%ERRORLOG%" && set /a ERRORCOUNT+=1
	) else (
		if not exist "%dstpath%\.." md "%dstpath%\.." 2>nul
		mklink /j "%dstpath%" "%srcpath%"
	)
) else (
	echo.Src: "%srcpath%\" is not exist, Unable to create dirlink...>>"%ERRORLOG%"
	set /a ERRORCOUNT+=1
)
for /f "delims=" %%i in ("%ERRORCOUNT%") do endlocal & set /a "ERRORCOUNT=%%~i"
goto :eof
:[LinkDirs]
for /f "delims=" %%i in ('type "%~dp0%CURRENTPC%\%LINKSDR%\%LINKSFL%" ^| findstr /b /v "#"') do (
	call:[LinkHDDir] "%~dp0%CURRENTPC%\%LINKSDR%" "%%~i"
)
goto :eof

:ERROR
echo.
echo.You need put this project to system drive...
echo.
pause
exit
