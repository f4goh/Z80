@echo off
chcp 1252 >nul
REM ??? Script d'assemblage automatique pour blink.asm avec TASM

SET PROJECT_DIR=%~dp0
SET TASM_DIR=%PROJECT_DIR%..\..\tasm32
SET SOURCE=blink.asm
SET BASENAME=blink

REM ?? Suppression des anciens fichiers générés
IF EXIST "%PROJECT_DIR%%BASENAME%.hex" DEL "%PROJECT_DIR%%BASENAME%.hex"
IF EXIST "%PROJECT_DIR%%BASENAME%.bin" DEL "%PROJECT_DIR%%BASENAME%.bin"
IF EXIST "%PROJECT_DIR%%BASENAME%.lst" DEL "%PROJECT_DIR%%BASENAME%.lst"
IF EXIST "%PROJECT_DIR%%BASENAME%.obj" DEL "%PROJECT_DIR%%BASENAME%.obj"

REM ?? Assemblage depuis le dossier TASM
pushd %TASM_DIR%

REM ?? Génération du fichier HEX
tasm.exe -s -h -c -g0 -80 "%PROJECT_DIR%%SOURCE%" "%PROJECT_DIR%%BASENAME%.hex"

REM ?? Génération du fichier BIN
tasm.exe -s -h -c -g3 -80 "%PROJECT_DIR%%SOURCE%" "%PROJECT_DIR%%BASENAME%.bin"

popd

echo ? Fichiers generes avec succes :
echo    - %BASENAME%.hex
echo    - %BASENAME%.bin
pause
