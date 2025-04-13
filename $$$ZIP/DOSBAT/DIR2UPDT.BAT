:dir2updt.bat
@echo off
:rem
:rem  Author: "Kenneth Tomiak"<CBT_Ken@KTomiak.biz>
:rem
:rem  History of Changes
:rem  ----------- ----------------------------------------------------
:rem  02007-07-20 Kenneth E Tomiak
:rem              Converted to file760 format.
:rem  02007-07-15 Kenneth E Tomiak
:rem              Original code.
:rem  ----------- ----------------------------------------------------
:rem
cls
set MY_COMMAND=%0
@echo.
@echo.%MY_COMMAND%: Append members into one dataset with ./ ADD
@echo.control cards for IEBUPDTE.
@echo.
set parms=%*
if %PARMS%.==. goto :default_everything
goto :what_was_asked_for
:rem
:rem
:rem
:default_everything
set PARMS=*.*
@echo.
@echo.Defaulting to all files in current directory.
@echo.
:what_was_asked_for
@echo.
@echo.%MY_COMMAND%: Appending %PARMS% into IEBUPDTE.PDS.
@echo.
if exist IEBUPDTE.PDS del IEBUPDTE.PDS
for %%t in (%PARMS%) do call mbr2updt %%t
@echo../ ENDUP >>IEBUPDTE.PDS
@echo.
@echo.If you had any binary files or files with an extension, plan
@echo.on editing IEBUPDTE.PDS before you can use it.
@echo.
@echo.%MY_COMMAND%: Done.
@echo.
set MY_COMMAND=
