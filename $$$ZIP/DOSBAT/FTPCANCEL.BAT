:ftpcancel.bat
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
:rem  02000-01-20 Kenneth E Tomiak
:rem              Original code.
:rem  ----------- ----------------------------------------------------
:rem
cls
set ftpcancel_COMMAND=%0
@echo.
@echo.%ftpcancel_COMMAND%: Attempt to submit a CANCEL U= command for
@echo.when your TSO session can not be reconnected.
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
if %1.==.         goto :default_command
if not exist %1   goto :need_canceljob
set CANCEL=%1
goto :bypass_building_jobs
:rem
:rem Create a cancel command using JES2 format.
:rem
:default_command
set CANCEL=CANCEL.$VS
@echo./*$VS,'C U=%USERID%'                                   >CANCEL.$VS
@echo.//%USERID%A JOB (ACCT),                                >CANCEL.JCL
@echo.//             CLASS=A,                               >>CANCEL.JCL
@echo.//             MSGCLASS=X                             >>CANCEL.JCL
@echo.//*                                                   >>CANCEL.JCL
@echo.//      COMMAND 'C U=%USERID%'                        >>CANCEL.JCL
@echo.//*                                                   >>CANCEL.JCL
@echo.//STEP001 EXEC PGM=IEFBR14                            >>CANCEL.JCL
@echo.//*                                                   >>CANCEL.JCL
@echo.//                                                    >>CANCEL.JCL
:bypass_building_jobs
:rem
:rem login
:rem
@echo.%USERID%                                            >%TMP%\ftp.txt
@echo.%PASSWORD%                                         >>%TMP%\ftp.txt
:rem
:rem connect to JES
:rem
@echo.quote site filetype=JES                            >>%TMP%\ftp.txt
@echo.;                                                  >>%TMP%\ftp.txt
@echo.;  Author: "Kenneth Tomiak" CBT_Ken-at-KTomiak.biz >>%TMP%\ftp.txt
@echo.;                                                  >>%TMP%\ftp.txt
@echo.bell                                               >>%TMP%\ftp.txt
:rem
:rem Submit %CANCEL%
:rem
@echo.put %CANCEL%                                       >>%TMP%\ftp.txt
@echo.quit                                               >>%TMP%\ftp.txt
:rem
@echo.
@echo.If what you provided is correct, this will now connect to
@echo.HOST:%ZOSHOST% and log you in as %USERID%.
@echo.Next it will issue a put %CANCEL% to JES.
@echo.
ftp -s:%TMP%\ftp.txt %ZOSHOST%
del %TMP%\ftp.txt
goto all_done
:rem
:rem
:rem
:need_canceljob
@echo.
@echo.The correct syntax is:
@echo.  %ftpcancel_COMMAND% local_filename
@echo.
@echo.%1 does not exist.
@echo.
@echo.If you omit the local_filename then CANCEL.$VS
@echo.will be used to store a $VS command. This bat file also
@echo.builds CANCEL.JCL as another method to submit a command.
@echo.Not everybody is authorized to submit commands and
@echo.not all installations allow commands via job submission.
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
@echo.
@echo.If the cancel worked you can toggle over to your tn3270 session
@echo.and login to TSO.
@echo.
:quick_exit
@echo.
@echo.%ftpcancel_COMMAND%: Done.
@echo.
set ftpcancel_COMMAND=
set CANCEL=
