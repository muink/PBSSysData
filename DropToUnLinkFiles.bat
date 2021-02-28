:: PBSSysData
:: Portable System System Data For Windows
:: Author: muink

@echo off
if "%~1" == "" exit

:--init--
rem MachineGUID
for /f "delims=" %%i in ('reg query HKLM\SOFTWARE\Microsoft\Cryptography /v MachineGuid 2^>nul') do (
    for /f "delims=" %%o in ('echo %%i ^| find /i "MachineGuid"') do (
        for /f "tokens=3 delims= " %%p in ("%%o") do (
            set "CURRENTPC=%%p"
        )
    )
)

pushd "%~dp0%CURRENTPC%"
for %%i in (%*) do call:[UnFiles] "%%~i"
goto :eof

:[UnHDLink]
for /f "usebackq delims=" %%c in (`fsutil hardlink list "%~1"`) do (
	if not "%~pnx1" == "%%~c" del /f /q "%~d1%%~c">nul 2>nul
)
goto :eof

:[UnFiles]
echo.%~1|findstr /b /c:"%CD:\=\\%">nul 2>nul || goto :eof
dir /ad /b "%~1">nul 2>nul && (
	for /f "delims=" %%n in ('dir /a-d /b /s "%~1\*" 2^>nul') do call:[UnHDLink] "%%~n"
) || call:[UnHDLink] "%~1"
goto :eof
