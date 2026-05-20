@echo off
chcp 65001 >nul
title Inspection Videoshow
color 0B

set "DIR=%LOCALAPPDATA%\AuditionMorand\Videoshow"
set "OUT=%USERPROFILE%\Desktop\videoshow-contenu.txt"

echo Inspection du dossier Videoshow...
echo.

if not exist "%DIR%" (
    echo Le dossier "%DIR%" n'existe pas.
    echo Videoshow est peut-etre installe ailleurs.
    pause
    exit /b 1
)

(
    echo ============================================================
    echo  CONTENU DU DOSSIER VIDEOSHOW
    echo  %DIR%
    echo  Genere le %DATE% a %TIME%
    echo ============================================================
    echo.
    echo --- ARBORESCENCE COMPLETE ---
    echo.
    dir /s /b "%DIR%"
    echo.
    echo ============================================================
    echo --- FICHIERS D'ANIMATION POSSIBLES (video/image) ---
    echo ============================================================
    echo.
    for /r "%DIR%" %%F in (*.mp4 *.webm *.gif *.png *.jpg *.jpeg *.svg *.apng *.json *.lottie) do echo %%F
    echo.
    echo ============================================================
    echo --- FICHIERS WEB (html/js/css) ---
    echo ============================================================
    echo.
    for /r "%DIR%" %%F in (*.html *.htm *.js *.css) do echo %%F
    echo.
    echo ============================================================
    echo --- DOSSIERS DE PREMIER NIVEAU ---
    echo ============================================================
    echo.
    dir /ad /b "%DIR%"
) > "%OUT%"

echo Rapport genere sur le Bureau : videoshow-contenu.txt
echo Ouverture...
start "" notepad "%OUT%"
exit /b 0
