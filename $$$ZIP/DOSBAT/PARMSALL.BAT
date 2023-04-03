:parmsall.bat
@echo off
:rem
:rem  Author: "Kenneth Tomiak"<CBT_Ken@KTomiak.biz>
:rem
:rem  History of Changes
:rem  ----------- ----------------------------------------------------
:rem  02007-07-20 Kenneth E Tomiak
:rem              Converted to file760 format.
:rem  02006-10-04 Kenneth E Tomiak
:rem              Original code.
:rem  ----------- ----------------------------------------------------
:rem
cls
set parmsall_COMMAND=%0
@echo.
@echo.%parmsall_COMMAND%: Append all parms into one variable, using a
@echo. loop versus using percent-asterisk.
@echo.
if [%1]==[] goto :no_parms_passed
:rem
:rem Grab all parms
:rem
set all=%*
@echo.percent-asterisk=%ALL%
@echo.
:rem
:rem Loop through to pick up after %1.
:rem
shift
@echo:Shift over the first word.
@echo.
set parms=%1
shift
:loop
if %1.==. goto :parm_done
set parms=%PARMS% %1
shift
goto :loop
:parm_done
@echo.Loop=%PARMS%
@echo.
@echo.percent-asterisk=%*
@echo.
@echo.%parmsall_COMMAND%: Done.
@echo.
goto :all_done
:no_parms_passed
if [%1]==[] call %parmsall_COMMAND% Hey, how about passing some parms?
:all_done
set parmsall_command=
