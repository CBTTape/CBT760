:ftpputascii80.bat
@echo off
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
:rem  02007-02-12 Kenneth E Tomiak
:rem              Original code.
:rem  ----------- ----------------------------------------------------
:rem
cls
set ftpputascii80_COMMAND=%0
@echo.
@echo.%ftpputascii80_COMMAND%: Attempt to upload file in ASCII mode.
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
if %1.==.         goto :need_localfile
if not exist %1   goto :no_suchfile
:rem
:rem login
:rem
@echo.%USERID%                                            >%TMP%\ftp.txt
@echo.%PASSWORD%                                         >>%TMP%\ftp.txt
call ftpsetattributes.bat
:rem
:rem Make sure it is ASCII mode and upload file.
:rem
@echo.ascii                                              >>%TMP%\ftp.txt
@echo.quote site recfm=fb blksize=27920 lrecl=80         >>%TMP%\ftp.txt
@echo.;                                                  >>%TMP%\ftp.txt
@echo.;  Author: "Kenneth Tomiak" CBT_Ken-at-KTomiak.biz >>%TMP%\ftp.txt
@echo.;                                                  >>%TMP%\ftp.txt
@echo.bell                                               >>%TMP%\ftp.txt
@echo.put %1 %2                                          >>%TMP%\ftp.txt
@echo.quit                                               >>%TMP%\ftp.txt
:rem
@echo.
@echo.If what you provided is correct, this will now connect to
@echo.HOST:%ZOSHOST% and log you in as %USERID%.
@echo.Next it will upload %1 in ASCII mode.
@echo.
ftp -s:%TMP%\ftp.txt %ZOSHOST%
del %TMP%\ftp.txt
goto :all_done
:rem
:rem
:rem
:need_localfile
@echo.
@echo.The correct syntax is:
@echo.  %ftpputascii80_COMMAND% local_file host_file
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
@echo.If the upload worked you can start using the file.
@echo.
:quick_exit
@echo.
@echo.%ftpputascii80_COMMAND%: Done.
@echo.
set ftpputascii80_COMMAND=
