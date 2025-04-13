:OBJLIB.bat
%echo off
:rem
:rem  Author: "Kenneth Tomiak"<CBT_Ken@KTomiak.biz>
:rem
:rem  History of Changes
:rem  ----------- ----------------------------------------------------
:rem  02007-07-27 Kenneth E Tomiak
:rem              Original code.
:rem  ----------- ----------------------------------------------------
:rem
cls
set OBJLIB_COMMAND=%0
@echo.
@echo.%OBJLIB_COMMAND%: Attempt to allocate two sequential
@echo.datasets and upload the OBJLIB.SEQ and .JCL file.
@echo.
echo [%FTPCONFIG%]
pause
if [%FTPCONFIG%]==[] goto :no_config
call %FTPCONFIG%
goto :check_basic_attributes
:no_config
set FTPCONFIG=FTPDEFAULT
call %FTPCONFIG%
:check_basic_attributes
if [%USERID%]==[]   goto :need_userid
if [%PASSWORD%]==[] goto :need_password
if [%ZOSHOST%]==[]  goto :need_zoshost_name
:rem
echo.%USERID% >%TMP%\ftp.txt
echo.%PASSWORD% >>%TMP%\ftp.txt
call ftpsetattributes.bat
:rem
echo.quote site recfm=fb blksize=0 lrecl=80 >>%TMP%\ftp.txt 
echo.quote site tracks pri=1 sec=1  >>%TMP%\ftp.txt 
:rem
echo.put OBJLIB.seq '%USERID%.OBJLIB.SEQ' >>%TMP%\ftp.txt
:rem
echo.quote site tracks pri=1 sec=1 >>%TMP%\ftp.txt 
:rem
echo.put OBJLIB.jcl '%USERID%.OBJLIB.JCL' >>%TMP%\ftp.txt
echo.cd '%USERID%.OBJLIB >>%TMP%\ftp.txt 
echo.bell >>%TMP%\ftp.txt 
echo.dir >>%TMP%\ftp.txt 
@echo.
@echo.Watch the FTP session - look at the output.
@echo.If all goes well, you will need to enter 'quit' to end the session.
@echo.If the upload failed then you might fiddle with your
@echo.settings and try the 'put' that failed.
@echo.
@echo.Total bytes to upload: 10078 + crlf
@echo.Total bytes to upload: 9828 - crlf
@echo.
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
@echo.Syntax: %OBJLIB_command%:
@echo.
@echo.But first you must set a configuration file.
@echo.Edit ftpconfig.bat and set variables and save-as
@echo.some filename.bat. I recommend something along the
@echo.line of ftp[HOSTNAME].bat, where [HOSTNAME] matches
@echo.the z/OS system you will be connecting to. If you
@echo.have more than one z/OS system you can can have muliple
@echo.configuration files. Just remember to issue:
@echo.ftpsetconfig ftp[HOSTNAME]
@echo.Otherwise, I try ftpdefault.bat.
@echo.
goto :quick_exit
:all_done
@echo.
@echo.If the upload worked, you may edit the JCL and submit it.
@echo.
:rem
:rem
:rem
:quick_exit
@echo.
@echo.%OBJLIB_COMMAND%: Done.
@echo.
set OBJLIB_COMMAND=
