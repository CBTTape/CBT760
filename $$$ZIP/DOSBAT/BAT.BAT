:bat.bat
@echo off
:rem
:rem  Author: "Kenneth Tomiak"<CBT_Ken@KTomiak.biz>
:rem
:rem  History of Changes
:rem  ----------- ----------------------------------------------------
:rem  02007-07-26 Kenneth E Tomiak
:rem              Tweaked to bypass message if a parameter was used.
:rem  02007-07-20 Kenneth E Tomiak
:rem              Converted to file760 format.
:rem  02007-04-05 Kenneth E Tomiak
:rem              Original code.
:rem  ----------- ----------------------------------------------------
:rem
cls
set bat_COMMAND=%0
call ftpsgd.bat
@echo.
@echo.%bat_COMMAND%: Attempt to show dot-bat files that could be run.
if [%*]==[] goto :no_dir
goto :yes_dir
:rem
:rem
:rem
:no_dir
@echo.
@echo.%PATH%
@echo.
@echo.The directories shown above are searched when you attempt to
@echo.to run a DOS command or .bat file.
@echo.
@echo.You can invoke %0 and pass one of these directories and only
@echo.the *.bat files will be displayed for you. Remember to add
@echo.an ending backslash if you need one.
@echo.
@echo.Example: %0 \Program Files\KTomiak\
@echo.
@echo.Press [ENTER] now.
pause
@echo.
:yes_dir
set parms=%*
dir "%PARMS%\*.bat" /w /p
@echo.
@echo.%bat_COMMAND%: Done.
@echo.
set bat_COMMAND=
