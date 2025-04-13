:parsmivp.bat
@echo off
:rem
:rem  Author: "Kenneth Tomiak"<CBT_Ken@KTomiak.biz>
:rem
:rem  History of Changes
:rem  ----------- ----------------------------------------------------
:rem  02007-07-20 Kenneth E Tomiak
:rem              Original code.
:rem  ----------- ----------------------------------------------------
:rem
cls
set parmsivp_COMMAND=%0
@echo.
@echo.%parmsivp_COMMAND%: Show how parmslow and parms up work.
@echo.
@echo.You passed:
@echo.%*
@echo.I added:
@echo.PLUS SOME of my TEXT iN Mixed-Case.
@echo.
@echo.%0: Now converting parms to lower case.
@echo.
call PARMSLOW %* PLUS SOME of my TEXT iN Mixed-Case.
echo %WORDS%
@echo.
@echo.%0: Now converting parms to upper case.
@echo.
call PARMSUP %WORDS%
echo %WORDS%
@echo.
@echo.%parmsivp_COMMAND%: Done.
@echo.
set parmsivp_COMMAND=
