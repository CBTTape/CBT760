:oorexx.bat
@echo off
:rem
:rem  Author: "Kenneth Tomiak"<CBT_Ken@KTomiak.biz>
:rem
:rem  History of Changes
:rem  ----------- ----------------------------------------------------
:rem  02007-07-21 Kenneth E Tomiak
:rem              Converted to file760 format.
:rem              Improved parameter collection routine.
:rem  02007-06-09 Kenneth E Tomiak
:rem              Original code.
:rem  ----------- ----------------------------------------------------
:rem
cls
set oorexx_COMMAND=%0
@echo.
@echo.%oorexx_COMMAND%: Invoke Open Object REXX from my location
@echo.and execute REXX code from my location passing your parameters.
@echo.
:rem
:rem Set variables to store location of rexx code
:rem
if %1.==. goto :no_program
set pgm=%1
set CODEHOME=D:\home\ktomiak\rexx
:echo %CODEHOME%.
if exist %CODEHOME%\%PGM% goto :bundle_parameters
set pgm=%PGM%.rex
if exist %CODEHOME%\%PGM% goto :bundle_parameters
set pgm=%PGM%.rexx
if exist %CODEHOME%\%PGM% goto :bundle_parameters
:rem
:rem Forgot to specify a program
:rem
:no_program
dir %CODEHOME%\*.rex /w /one /p
if %1.==. goto :show_syntax
@echo.
@echo.Program %PGM% was not found. Pick one and try again.
@echo.
goto :exitit
:rem
:rem Bundle remaining parms into one variable
:rem
:bundle_parameters
set parms=
if [%2]==[] goto :run_rexx_program
:rem
:rem Loop through to pick up after %1.
:rem
shift
set parms=%1
shift
:loop
if %1.==. goto :parm_done
set parms=%PARMS% %1
shift
goto :loop
:parm_done
:rem
:rem
:rem
:run_rexx_program
set REXXHOME=C:\Progra~1\ooRexx\
set oldpath=%PATH%
set path=%REXXHOME%;%OLDPATH%
@echo.
@echo. Executing %PGM% with parms=%PARMS%.
@echo.
%REXXHOME%REXX %CODEHOME%\%PGM% %PARMS%
set path=%OLDPATH%
goto :exitit
:rem
:rem
:rem
:show_syntax
@echo.
@echo.Syntax:
@echo. %oorexx_COMMAND%: some_rexx_filename other parameters
@echo.
:rem
:rem
:rem
:exitit
set REXXHOME=
set CODEHOME=
set parms=
set pgm=
set oorexx_COMMAND=
