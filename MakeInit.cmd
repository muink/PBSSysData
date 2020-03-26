:: PBSSysData
:: Portable System System Data For Windows
:: Author: muink

@echo off
if "%~1" == "" exit

pushd %~1 2>nul
:--init--
set "CURRENTPC=%UserDomain%"

set "KEY=Fonts=38;ICC=colorui.dll:0"


:--pcname--
md "%CURRENTPC%" 2>nul || goto :--AllDesktop--
pushd "%CURRENTPC%"
	call:[WTini] "%CD%" "" 15
popd

:--AllDesktop--
mklink /j "%CURRENTPC%\Desktop" "%SystemDrive%\Users\Public\Desktop" 2>nul || goto :--ProgramData--

:--ProgramData--
md "%CURRENTPC%\ProgramData" 2>nul || goto :--ETC--
pushd "%CURRENTPC%\ProgramData"
	call:[WTini] "%CD%" "" 69
popd

:--ETC--
md "%CURRENTPC%\ETC" 2>nul || goto :--template--
pushd "%CURRENTPC%\ETC"
call:[WTini] "%CD%" "" 72
setlocal enabledelayedexpansion
:--ETC--#loop
for /f "tokens=1* delims=;" %%i in ("!KEY!") do (
	for /f "tokens=1,2 delims==" %%k in ("%%i") do call:[MKKEY] "%CD%" %%k %%l
	set "KEY=%%j"
	goto :--ETC--#loop
)
endlocal
popd

:--template--

if exist "%~dp0One-off_Run.cmd" (
	call "%~dp0One-off_Run.cmd" "%~1" 2>nul
	del /f /q "%~dp0One-off_Run.cmd" >nul 2>nul
)

popd & goto :eof


:[WTini]
setlocal enabledelayedexpansion
set "icolib=%~2"
if "%icolib%" == "" set "icolib=SHELL32.dll"
set "pa=%~1"
(echo.[.ShellClassInfo]
echo.IconResource=%SystemRoot%\system32\%icolib%,%~3)>"%pa%\desktop.ini"
attrib +r "%pa%"
attrib +s +h "%pa%\desktop.ini"
endlocal
goto :eof

:[MKKEY]
setlocal enabledelayedexpansion
set "pa=%~1\%2"
set "key=%2"
set "value=%3"
set "value2=%value::=" "%"
if "%value%" == "%value2%" set value2=" "%value%
md "%pa%" 2>nul
call:[WTini] "%pa%" "%value2%"
endlocal
goto :eof
