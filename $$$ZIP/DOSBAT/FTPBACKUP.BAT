:ftpbackup.bat
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
:rem  02007-01-06 Kenneth E Tomiak
:rem              Original code.
:rem  ----------- ----------------------------------------------------
:rem
cls
set ftpbackup_COMMAND=%0
@echo.
@echo.%ftpbackup_COMMAND%: Attempt to submit a backup job and then
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
if [%1]==[]       goto :need_backupjob
:rem
:rem login
:rem
@echo.%USERID%                                            >%TMP%\ftp.txt
@echo.%PASSWORD%                                         >>%TMP%\ftp.txt
call ftpsetattributes.bat
:rem
:rem connect to JES
:rem
@echo.quote site filetype=JES                            >>%TMP%\ftp.txt
:rem
:rem submit a job, wait for it to finish, then download the output.
:rem
@echo.get %1 ftpbackup.txt                               >>%TMP%\ftp.txt
:rem
:rem disconnect from JES
:rem
@echo.quote site filetype=SEQ                            >>%TMP%\ftp.txt
:rem
:rem toggle prompting to none
:rem
@echo.prompt                                             >>%TMP%\ftp.txt
:rem
:rem change directory to download all &sysuid..SEQOUT datasets.
:rem download them and then delete them.
:rem
@echo.lcd backups                                        >>%TMP%\ftp.txt
@echo.cd seqout                                          >>%TMP%\ftp.txt
@echo.ascii                                              >>%TMP%\ftp.txt
@echo.dir                                                >>%TMP%\ftp.txt
@echo.mget *                                             >>%TMP%\ftp.txt
@echo.mdel *                                             >>%TMP%\ftp.txt
:rem
:rem change directory to download all &sysuid..XMIT datasets.
:rem download them and then delete them.
:rem
@echo.cd ..                                              >>%TMP%\ftp.txt
@echo.cd xmit                                            >>%TMP%\ftp.txt
@echo.bin                                                >>%TMP%\ftp.txt
@echo.dir                                                >>%TMP%\ftp.txt
@echo.mget *                                             >>%TMP%\ftp.txt
@echo.;                                                  >>%TMP%\ftp.txt
@echo.;  Author: "Kenneth Tomiak" CBT_Ken-at-KTomiak.biz >>%TMP%\ftp.txt
@echo.;                                                  >>%TMP%\ftp.txt
@echo.bell                                               >>%TMP%\ftp.txt
@echo.mdel *                                             >>%TMP%\ftp.txt
@echo.quit                                               >>%TMP%\ftp.txt
:rem
@echo.
@echo.If what you provided is correct, this will now connect to
@echo.HOST:%ZOSHOST% and log you in as %USERID%.
@echo.Next it will issue a get %1 to JES,
@echo.wait for the job to complete,
@echo.and then download and delete sysuid..seqout.* and
@echo.sysuid..xmit.* datasets.
@echo.
ftp -s:%TMP%\ftp.txt %ZOSHOST%
del %TMP%\ftp.txt
notepad ftpbackup.txt
del ftpbackup.txt
goto all_done
:rem
:rem
:rem
:need_backupjob
@echo.
@echo.The correct syntax is:
@echo.  %ftpbackup_COMMAND% host_filename
@echo.
@echo.If you omit the host_filename then ZOS$CNTL(FTPBKUP) will be used.
@echo.And if you do not have ZOS$CNTL(FTPBKUP) then this will not work.
@echo.
@echo.Consider editing the FTPBKUP that was provided, upload it using
@echo.ftpputascii80 FTPBKUP ZOS$CNTL(FTPBKUP), and then try again.
@echo.
@echo.About to try now. Press [ctrl-c] to abort.
pause
call %ftpbackup_COMMAND% ZOS$CNTL(FTPBKUP)
goto :all_done
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
@echo.%ftpbackup_COMMAND%: Done.
@echo.
set ftpbackup_COMMAND=
