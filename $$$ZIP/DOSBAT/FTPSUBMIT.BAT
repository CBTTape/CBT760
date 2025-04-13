:ftpsubmit.bat
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
set ftpsubmit_COMMAND=%0
@echo.
@echo.%ftpsubmit_COMMAND%: Attempt to submit a backup job and then
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
if %1.==.         goto :need_job
:rem
:rem login
:rem
@echo.%USERID%                                            >%TMP%\ftp.txt
@echo.%PASSWORD%                                         >>%TMP%\ftp.txt
:rem
:rem connect to JES
:rem
@echo.quote site filetype=jes                            >>%TMP%\ftp.txt
@echo.;                                                  >>%TMP%\ftp.txt
@echo.;  Author: "Kenneth Tomiak" CBT_Ken-at-KTomiak.biz >>%TMP%\ftp.txt
@echo.;                                                  >>%TMP%\ftp.txt
@echo.bell                                               >>%TMP%\ftp.txt
@echo.get %1 jobout.txt                                  >>%TMP%\ftp.txt
@echo.quit                                               >>%TMP%\ftp.txt
:rem
@echo.
@echo.If what you provided is correct, this will now connect to
@echo.HOST:%ZOSHOST% and log you in as %USERID%.
@echo.Next it will issue a get %1 to JES,
@echo.wait for the job to complete,
@echo.and then download the output to jobout.txt.
@echo.
ftp -s:%TMP%\ftp.txt %ZOSHOST%
del %TMP%\ftp.txt
notepad jobout.txt
@echo.
@echo.Remember, the output is still on the JES SPOOL.
@echo.
goto :all_done
:rem
:rem
:rem
:need_job
@echo.
@echo.The correct syntax is:
@echo.  %ftpsubmit_COMMAND% host_filename
@echo.
@echo.If you omit the host_filename then there is nothing to submit.
@echo.If there is nothing to submit then you ran the wrong dot-bat file.
@echo.
@echo.Run bat.bat to find the dot-bat file you meant to run.
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
@echo.If the backup and download worked, you can start using the
@echo.files just downloaded.
@echo.
:rem
:rem
:rem
:quick_exit
@echo.
@echo.%ftpsubmit_COMMAND%: Done.
@echo.
set ftpsubmit_COMMAND=
