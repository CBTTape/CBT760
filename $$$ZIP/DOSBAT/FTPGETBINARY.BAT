:ftpgetbinary.bat
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
:rem  02006-04-11 Kenneth E Tomiak
:rem              Original code.
:rem  ----------- ----------------------------------------------------
:rem
cls
set ftpgetbinary_COMMAND=%0
@echo.
@echo.%ftpgetbinary_COMMAND%: Login and download a binary file.
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
if %1.==.         goto :need_hostfile
:rem
:rem login
:rem
@echo.%USERID%                                            >%TMP%\ftp.txt
@echo.%PASSWORD%                                         >>%TMP%\ftp.txt
call ftpsetattributes.bat
:rem
:rem Make sure it is BINARY mode and get the file.
:rem
@echo.bin                                                >>%TMP%\ftp.txt
@echo.;                                                  >>%TMP%\ftp.txt
@echo.;  Author: "Kenneth Tomiak" CBT_Ken-at-KTomiak.biz >>%TMP%\ftp.txt
@echo.;                                                  >>%TMP%\ftp.txt
@echo.bell                                               >>%TMP%\ftp.txt
@echo.get %1 %2                                          >>%TMP%\ftp.txt
@echo.quit                                               >>%TMP%\ftp.txt
:rem
@echo.If what you provided is correct, this will now connect to
@echo.HOST:%ZOSHOST% and log you in as %USERID%.
@echo.Next it will get %1
if %2.==. echo.as %1.
if %2.==g echo.as %2.
@echo.
ftp -s:%TMP%\ftp.txt %ZOSHOST%
del %TMP%\ftp.txt
goto :all_done
:rem
:rem
:rem
:need_hostfile
@echo.
@echo.The correct syntax is:
@echo.  %ftpgetbinary_COMMAND% host_filename local_filename
@echo.
@echo.If you omit the local_file_name then the host_filename
@echo.will be used.
@echo.
:rem
:rem
:rem
:need_userid
:need_password
:need_zoshost_name
@echo.
@echo.Syntax: %0
@echo.
@echo.But first you must edit ftpconfig.bat and set variables.
@echo.
goto :quick_exit
:all_done
@echo.
@echo.If the download worked you can start using the file.
@echo.
@echo.Remember, this is a BINARY version of the file. Can you handle it?
@echo.
:quick_exit
@echo.
@echo.%ftpgetbinary_COMMAND%: Done.
@echo.
set ftpgetbinary_COMMAND=
