@echo off
chcp 65001 >nul
title Portable LLM
cd /d "%~dp0"

set "ARCH=x64"
if "%PROCESSOR_ARCHITECTURE%"=="ARM64" set "ARCH=arm64"
if "%PROCESSOR_IDENTIFIER:~0,7%"=="ARM64" set "ARCH=arm64"

if "%ARCH%"=="arm64" (
    reg query "HKLM\SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\arm64" /v Installed >nul 2>&1 || (
        start /wait "" "redist\vc_redist.arm64.exe" /install /quiet /norestart
    )
) else (
    reg query "HKLM\SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\x64" /v Installed >nul 2>&1 || (
        start /wait "" "redist\vc_redist.x64.exe" /install /quiet /norestart
    )
)

set "LLAMA=bin\win-%ARCH%\llama.exe"
if not exist "%LLAMA%" (
    echo ERROR: %LLAMA% not found
    pause
    exit /b 1
)

set "MODEL="
for %%f in ("models\*.gguf") do set "MODEL=%%f" & goto found_model
echo ERROR: No .gguf model found in models\ folder.
pause
exit /b 1
:found_model

:menu
cls
echo  _    _     _     _      _      __  __
echo ^| ^|  ^| ^|   ^| ^|   ^| ^|    ^| ^|    ^|  ^\^/  ^|
echo ^| ^|  ^| ^|___^| ^|__ ^| ^|    ^| ^|    ^| ^\  ^/ ^|
echo ^| ^|  ^| ^/ __^| '_ ^\^| ^|    ^| ^|    ^| ^|^\^/^| ^|
echo ^| ^|__^| ^\__ ^\ ^|_) ^| ^|____^| ^|____^| ^|  ^| ^|
echo  ^\____^/^|___^/_.__/^|______^|______^|_^|  ^|_^|
echo         UsbLLM - Plug and Play
echo ========================================
echo Architecture : %ARCH%
echo Model        : %MODEL%
echo.
echo  1. Terminal Chat  (interactive CLI)
echo  2. Exit
echo.
set /p "choice=Select [1-2]: "

if "%choice%"=="1" goto chat
if "%choice%"=="2" exit /b
goto menu

:chat
echo.
"%LLAMA%" cli -m "%MODEL%" --conversation --ctx-size 4096 --temp 0.7 --threads %NUMBER_OF_PROCESSORS% --mlock
echo.
pause
goto menu