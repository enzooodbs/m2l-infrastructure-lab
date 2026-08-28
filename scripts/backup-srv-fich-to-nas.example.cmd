@echo off
setlocal

REM Exemple public : adapter les chemins et identifiants à votre environnement.
set "SOURCE=C:\Partages"
set "DEST=\\NAS_IP\nas-data\backup-srv-fich"
set "LOG=C:\Scripts\backup-srv-fich-to-nas.log"

robocopy "%SOURCE%" "%DEST%" /MIR /Z /R:2 /W:5 /COPY:DAT /DCOPY:DAT /LOG+:"%LOG%"
set "RC=%ERRORLEVEL%"

REM Robocopy considère 0 à 7 comme des résultats non fatals.
if %RC% LEQ 7 exit /b 0
exit /b %RC%
