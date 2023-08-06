:ftpdownload.bat
%echo off
:rem
:rem  Author: "Kenneth Tomiak"<CBT_Ken@KTomiak.biz>
:rem
:rem  History of Changes
:rem  ----------- ----------------------------------------------------
:rem  02007-07-26 Kenneth E Tomiak
:rem              Support multiple configuration setting bat files.
:rem  02007-07-26 Kenneth E Tomiak
:rem              Original code.
:rem  ----------- ----------------------------------------------------
:rem
cls
set ftpdownload_COMMAND=%0
@echo.
@echo.%ftpdownload_COMMAND%: Attempt download all .SEQOUT. and .XMIT.
@echo.files generated from a backup process.
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
:rem
:rem login
:rem
@echo.%USERID%                                            >%TMP%\ftp.txt
@echo.%PASSWORD%                                         >>%TMP%\ftp.txt
call ftpsetattributes.bat
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
@echo.Next it will download and delete sysuid..seqout.* and
@echo.sysuid..xmit.* datasets.
@echo.
ftp -s:%TMP%\ftp.txt %ZOSHOST%
del %TMP%\ftp.txt
goto all_done
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
@echo.If the download and download worked, you can start using the
@echo.files just downloaded.
@echo.
:rem
:rem
:rem
:quick_exit
@echo.
@echo.%ftpdownload_COMMAND%: Done.
@echo.
set ftpdownload_COMMAND=
