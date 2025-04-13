:ftpcduc.bat
%echo off
:rem
:rem  Author: "Kenneth Tomiak"<CBT_Ken@KTomiak.biz>
:rem
:rem  History of Changes
:rem  ----------- ----------------------------------------------------
:rem  02007-07-26 Kenneth E Tomiak
:rem              Support multiple configuration setting bat files.
:rem  02007-07-21 Kenneth E Tomiak
:rem              Call ftpsetattributes for allocation defaults.
:rem  02007-07-20 Kenneth E Tomiak
:rem              Converted to file760 format.
:rem  02006-04-11 Kenneth E Tomiak
:rem              Original code.
:rem  ----------- ----------------------------------------------------
:rem
cls
set ftpcduc_COMMAND=%0
@echo.
@echo.%ftpcduc_COMMAND%: Attempt to submit a backup job and then
@echo.download the .SEQOUT. and .XMIT. files it generated.
@echo.
if [%FTPCONFIG%]==[] goto :no_config
call %FTPCONFIG%
goto :check_basic_attributes
:no_config
set FTPCONFIG=HOSTDEFAULT
call %FTPCONFIG%
:check_basic_attributes
if %USERID%.==.   goto :need_userid
if %PASSWORD%.==. goto :need_password
if %ZOSHOST%.==.  goto :need_zoshost_name
if %1.==.         goto :need_remotedirectory
call PARMSUP %1
:rem
:rem login
:rem
@echo.%USERID%                                            >%TMP%\ftp.txt
@echo.%PASSWORD%                                         >>%TMP%\ftp.txt
call ftpsetattributes.bat
:rem
:rem chdir to %WORDS%
:rem
@echo.cd %WORDS%                                         >>%TMP%\ftp.txt
@echo.;                                                  >>%TMP%\ftp.txt
@echo.;  Author: "Kenneth Tomiak" CBT_Ken-at-KTomiak.biz >>%TMP%\ftp.txt
@echo.;                                                  >>%TMP%\ftp.txt
@echo.bell                                               >>%TMP%\ftp.txt
@echo.dir                                                >>%TMP%\ftp.txt
:rem
@echo.
@echo.If what you provided is correct, this will now connect to
@echo.HOST:%ZOSHOST% and log you in as %USERID%.
@echo.Next it will issue a chdir %WORDS% command.
@echo.And a dir subcommand to show datasets at that level.
@echo.After that you are free to issue FTP subcommands.
@echo.
@echo.Use quit to end your session.
@echo.
ftp -s:%TMP%\ftp.txt %ZOSHOST%
del %TMP%\ftp.txt
goto :all_done
:rem
:rem
:rem
:need_remotedirectory
@echo.
@echo.The correct syntax is:
@echo.  %ftpcduc_COMMAND% remote_directory
@echo.
goto :quick_exit
:rem
:rem
:rem
:need_userid
:need_password
:need_zoshost_name
@echo.
@echo. Syntax: %0
@echo.
@echo. But first you must edit ftpconfig.bat and set variables.
@echo.
goto :quick_exit
:all_done
:quick_exit
@echo.
@echo.%ftpcduc_COMMAND%: Done.
@echo.
set ftpcduc_COMMAND=
