:add2path.bat
@echo off
:rem
:rem  Author: "Kenneth Tomiak"<CBT_Ken@KTomiak.biz>
:rem
:rem  History of Changes
:rem  ----------- ----------------------------------------------------
:rem  02007-07-26 Kenneth E Tomiak
:rem              Original code.
:rem  ----------- ----------------------------------------------------
:rem
cls
set bat_COMMAND=%0
@echo.
@echo.%bat_COMMAND%: Attempt to add my personal location to the path.
@echo.
@echo.OLD:
@echo.%PATH%
@echo.
set path=%USERPROFILE%\DOSBAT;%PATH%
@echo.
@echo.NEW:
@echo.%PATH%
@echo.
