:ftpsetconfig.bat
@echo off
:rem
:rem  Author: "Kenneth Tomiak"<CBT_Ken@KTomiak.biz>
:rem
:rem  History of Changes
:rem  ----------- ----------------------------------------------------
:rem  02007-07-27 Kenneth E Tomiak
:rem              Prevent naming this filename.
:rem  02007-07-26 Kenneth E Tomiak
:rem              Support multiple configuration setting bat files.
:rem              Original code.
:rem  ----------- ----------------------------------------------------
:rem
set ftpsetconfig_COMMAND=%0
if [%1]==[]   goto :no_config
if [%0]==[%1] goto :not_myself
if [%0.bat]==[%1] goto :not_myself
if [%0]==[%1.bat] goto :not_myself
set ftpconfig=%1
call %FTPCONFIG%
if [%USERID%]==[]   goto :show_some_hints
goto :check_basic_attributes
:show_some_hints
@echo.
@echo.If you get:
@echo.'%1' is not recognized as an internal or external command,
@echo.operable program or batch file.
@echo.The error means the file does not exist or is not in your path.
@echo.Did you save %1 in another directory?
goto :check_basic_attributes
:not_myself
@echo.
@echo.Silly person, that would make me loop. Choose another filename.
@echo.
:no_config
set FTPCONFIG=HOSTDEFAULT
@echo.
@echo.Setting to use the default [HOSTDEFAULT.bat] file.
@echo.
pause
call %FTPCONFIG%
:check_basic_attributes
if [%USERID%]==[]   goto :need_userid
if [%PASSWORD%]==[] goto :need_password
if [%ZOSHOST%]==[]  goto :need_zoshost_name
@echo ZOSHOST=%ZOSHOST%, is that what you wanted?
goto :all_done
:rem
:rem
:rem
:need_userid
:need_password
:need_zoshost_name
@echo.
@echo. Syntax: %ftpsetconfig [hostconfigfile.bat]
@echo.
@echo. Why not copy HOSTDEFAULT.bat to %1 with a .bat extension.
@echo. Next you must edit %1 and set the variables.
@echo. Then try %ftpsetconfig_COMMAND% %1
@echo.
goto :quick_exit
:all_done
:quick_exit
@echo.
@echo.%ftpsetconfig_COMMAND%: Done.
@echo.
@echo.%ftpconfig%: now in effect.
@echo.
set ftpsetconfig_COMMAND=
