:ftpscript.bat
@echo off
:rem
:rem  Author: "Kenneth Tomiak"<CBT_Ken@KTomiak.biz>
:rem
:rem  History of Changes
:rem  ----------- ----------------------------------------------------
:rem  02007-07-26 Kenneth E Tomiak
:rem              Support multiple configuration setting bat files.
:rem  02007-07-21 Kenneth E Tomiak
:rem              Converted to file760 format.
:rem  02007-07-15 Kenneth E Tomiak
:rem              Original code.
:rem  ----------- ----------------------------------------------------
:rem
cls
set ftpscript_COMMAND=%0
@echo.
@echo.%ftpscript_COMMAND%: Invoke FTP using pre-built script.
@echo.
if %1.==.         goto :need_localfile
if not exist %1   goto :no_suchfile
:rem
@echo.
@echo.If what you provided is correct, this will now run
@echo.your pre-built script.
@echo.
call ftp -s:%1
goto :all_done
:rem
:rem
:rem
:need_localfile
@echo.
@echo.The correct syntax is:
@echo.  %ftpscript_COMMAND% local_script_file_name
@echo.
goto :quick_exit
:rem
:rem
:rem
:nosuchfile
@echo.
@echo.%1 does not exist, choose another file.
@echo.
goto :quick_exit
:rem
:rem
:rem
:all_done
@echo.
@echo.If the script worked you can perform your next activity.
@echo.
:quick_exit
@echo.
@echo.%ftpscript_COMMAND%: Done.
@echo.
set ftpscript_COMMAND=
