:: PBSSysData
:: Portable System System Data For Windows
:: Author: muink

@echo off
if "%~1" == "" exit

set "nodedir=%~1"
pushd %nodedir%
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

set "LINKSDR=Dir"
set "LINKSFL=Links.ini"

set "SUBKY=Program Files=69;Program Files (x86)=69;ProgramData=69;Windows=69;Users=imageres.dll:169"
set "KEY=%LINKSDR%=imageres.dll:176;Fonts=38;ICC=colorui.dll:0;%SUBKY%"


:--icon--
if not exist desktop.ini call:[WTini] "%cd%" "" "69"

:--DirLink--
md "ETC" 2>nul || goto :--pcname--
pushd "ETC"
call:[WTini] "%CD%" "" 72
mklink /j "%CD%\Desktop" "%SystemDrive%\Users\Public\Desktop" 2>nul
mklink /j "%CD%\Syscfg" "%SystemDrive%\Windows\System32\config" 2>nul
mklink /j "%CD%\Defauser" "%SystemDrive%\Users\Default" 2>nul
popd

:--pcname--
md "%CURRENTPC%" 2>nul || (
	call:[WTini] "%CD%" "" 15 "%USERDOMAIN%"
	goto :--template--
)
pushd "%CURRENTPC%"
call:[WTini] "%CD%" "" 15 "%USERDOMAIN%"
setlocal enabledelayedexpansion
:--pcname--#loop
for /f "tokens=1* delims=;" %%i in ("!KEY!") do (
	for /f "tokens=1,2 delims==" %%k in ("%%i") do call:[MKKEY] "%CD%" "%%~k" "%%~l"
	set "KEY=%%j"
	goto :--pcname--#loop
)
pushd "%LINKSDR%"
if not exist %LINKSFL% (
	(echo.# One target path per line
	echo.#"%%ProgramFiles%%\Wireshark\profiles"
	echo.#"%%ProgramFiles(x86)%%\MSI Afterburner\Profiles"
	echo.#"%%AllUsersProfile%%\Microsoft\Windows\Start Menu"
	echo.#"%%SystemRoot%%\Resources\Themes"
	echo.#"%%SystemDrive%%\Users\%%UserName%%"
	)>%LINKSFL%
)
:--pcname--#dirloop
for /f "tokens=1* delims=;" %%i in ("!SUBKY!") do (
	for /f "tokens=1,2 delims==" %%k in ("%%i") do call:[MKKEY] "%CD%" "%%~k" "%%~l"
	set "SUBKY=%%j"
	goto :--pcname--#dirloop
)
endlocal
popd
popd

:--template--

if exist "%~dp0One-off_Run.cmd" (
	call "%~dp0One-off_Run.cmd" "%nodedir%" 2>nul
	del /f /q "%~dp0One-off_Run.cmd" >nul 2>nul
)

popd & goto :eof


:[WTini]
setlocal enabledelayedexpansion
set "icolib=%~2"
set "localname=%~4"
if "%icolib%" == "" set "icolib=SHELL32.dll"
if "%icolib%" == "imageres.dll" if "%~3" == "169" set "localname=@%%SystemRoot%%\system32\shell32.dll,-21813"
set "pa=%~1"
del /f /q /a "%pa%\desktop.ini" 2>nul
(echo.[.ShellClassInfo]
echo.IconResource=%%SystemRoot%%\system32\%icolib%,%~3
if not "%localname%" == "" echo.LocalizedResourceName=%localname%)>"%pa%\desktop.ini"
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
