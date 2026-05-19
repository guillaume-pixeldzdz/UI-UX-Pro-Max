@echo off
setlocal enabledelayedexpansion
title Lancer Videoshow
color 0A

echo ===============================================
echo   Lancement automatique de Videoshow
echo ===============================================
echo.

set "INSTALL_DIR=%LOCALAPPDATA%\AuditionMorand"
set "PORT=8123"

REM ---------------------------------------------------------------
REM 1. Si le serveur repond deja, on saute directement a l'ouverture
REM ---------------------------------------------------------------
echo [1/4] Verification si le serveur tourne deja sur le port %PORT%...
powershell -NoProfile -Command "try { (New-Object Net.Sockets.TcpClient('localhost', %PORT%)).Close(); exit 0 } catch { exit 1 }"
if %errorlevel% equ 0 (
    echo       Deja en cours d'execution. On va directement ouvrir la regie.
    goto OPEN_CHROME
)
echo       Pas de serveur detecte. On va le lancer.
echo.

REM ---------------------------------------------------------------
REM 2. Verifier que le dossier d'installation existe
REM ---------------------------------------------------------------
echo [2/4] Recherche du dossier d'installation...
if not exist "%INSTALL_DIR%" (
    echo       ERREUR : Le dossier "%INSTALL_DIR%" n'existe pas.
    echo       Videoshow n'est peut-etre pas installe, ou ailleurs.
    echo.
    pause
    exit /b 1
)
echo       Trouve : %INSTALL_DIR%
echo.

REM ---------------------------------------------------------------
REM 3. Chercher et lancer le serveur
REM    On essaie d'abord des noms probables, puis tout .exe trouve.
REM ---------------------------------------------------------------
echo [3/4] Recherche du serveur Videoshow...

set "SERVER_EXE="

REM Noms probables a tester en priorite
for %%N in (
    "Videoshow\videoshow-server.exe"
    "Videoshow\server.exe"
    "Videoshow\videoshow.exe"
    "Videoshow\app.exe"
    "Videoshow\AuditionMorand.exe"
    "AuditionMorand.exe"
    "server.exe"
    "videoshow.exe"
) do (
    if exist "%INSTALL_DIR%\%%~N" (
        set "SERVER_EXE=%INSTALL_DIR%\%%~N"
        goto FOUND
    )
)

REM Si rien trouve, on prend le premier .exe non-chrome trouve recursivement
for /r "%INSTALL_DIR%" %%F in (*.exe) do (
    echo %%~nF | findstr /i /v "chrome" >nul && (
        if not defined SERVER_EXE set "SERVER_EXE=%%F"
    )
)

:FOUND
if not defined SERVER_EXE (
    echo       ERREUR : Aucun executable trouve dans %INSTALL_DIR%.
    echo       Ouverture du dossier pour inspection manuelle.
    explorer "%INSTALL_DIR%"
    echo.
    pause
    exit /b 1
)

echo       Lancement : !SERVER_EXE!
start "" "!SERVER_EXE!"

REM ---------------------------------------------------------------
REM 4. Attendre que le port reponde (jusqu'a 15 secondes)
REM ---------------------------------------------------------------
echo.
echo [4/4] Attente du demarrage du serveur (15 sec max)...
set /a tries=0
:WAIT_LOOP
set /a tries+=1
powershell -NoProfile -Command "try { (New-Object Net.Sockets.TcpClient('localhost', %PORT%)).Close(); exit 0 } catch { exit 1 }"
if %errorlevel% equ 0 goto OPEN_CHROME
if %tries% geq 15 (
    echo       Le serveur ne repond toujours pas apres 15 secondes.
    echo       Verifiez manuellement le dossier : %INSTALL_DIR%
    explorer "%INSTALL_DIR%"
    pause
    exit /b 1
)
timeout /t 1 /nobreak >nul
goto WAIT_LOOP

REM ---------------------------------------------------------------
REM Ouvrir la regie dans Chrome
REM ---------------------------------------------------------------
:OPEN_CHROME
echo.
echo Ouverture de la regie Videoshow...
set "CHROME=%ProgramFiles%\Google\Chrome\Application\chrome.exe"
if not exist "%CHROME%" set "CHROME=%ProgramFiles(x86)%\Google\Chrome\Application\chrome.exe"
if not exist "%CHROME%" (
    echo Chrome introuvable, ouverture avec le navigateur par defaut.
    start "" "http://localhost:%PORT%/?mode=controle"
) else (
    start "" "%CHROME%" --user-data-dir="%LOCALAPPDATA%\AuditionMorand\ChromeProfile" --no-first-run --no-default-browser-check --disable-features=Translate --autoplay-policy=no-user-gesture-required --app=http://localhost:%PORT%/?mode=controle --window-size=1440,900 --window-position=0,0
)

echo.
echo Termine. Si la regie ne s'ouvre pas correctement, relancez ce script.
timeout /t 3 >nul
exit /b 0
