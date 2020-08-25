:: PBSSysData
:: Portable System System Data For Windows
:: Author: muink

@echo off
if "%~1" == "" exit

pushd %~1 2>nul
:--init--
set "USERDOMAIN=%UserDomain%"
rem MachineGUID
for /f "delims=" %%i in ('reg query HKLM\SOFTWARE\Microsoft\Cryptography /v MachineGuid 2^>nul') do (
    for /f "delims=" %%o in ('echo %%i ^| find /i "MachineGuid"') do (
        for /f "tokens=3 delims= " %%p in ("%%o") do (
            set "CURRENTPC=%%p"
        )
    )
)
rem dmi info
rem wmic csproduct get UUIDs

set "KEY=Fonts=38;ICC=colorui.dll:0;Program Files=69;Program Files (x86)=69;ProgramData=69;Windows=69;Users=imageres.dll:169"


:--DirLink--
md "ETC" 2>nul || goto :--pcname--
pushd "ETC"
call:[WTini] "%CD%" "" 72
mklink /j "%CD%\Desktop" "%SystemDrive%\Users\Public\Desktop" 2>nul
mklink /j "%CD%\Syscfg" "%SystemDrive%\Windows\System32\config" 2>nul
mklink /j "%CD%\Defauser" "%SystemDrive%\Users\Default" 2>nul
popd

:--pcname--
md "%CURRENTPC%" 2>nul || goto :--template--
pushd "%CURRENTPC%"
call:[WTini] "%CD%" "" 15 "%USERDOMAIN%"
setlocal enabledelayedexpansion
:--pcname--#loop
for /f "tokens=1* delims=;" %%i in ("!KEY!") do (
	for /f "tokens=1,2 delims==" %%k in ("%%i") do call:[MKKEY] "%CD%" "%%~k" "%%~l"
	set "KEY=%%j"
	goto :--pcname--#loop
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
if not "%~4" == "" echo.LocalizedResourceName=%~4)>"%pa%\desktop.ini"
echo.IconResource=%%SystemRoot%%\system32\%icolib%,%~3
attrib +r "%pa%"
attrib +s +h "%pa%\desktop.ini"
endlocal
goto :eof

:[MKKEY]
setlocal enabledelayedexpansion
set "pa=%~1\%~2"
set "key=%~2"
set "value=%~3"
set "value2=%value::=" "%"
if "%value%" == "%value2%" set value2=" "%value%
md "%pa%" 2>nul
call:[WTini] "%pa%" "%value2%"
endlocal
goto :eof
