:ftpsetup.bat
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
:rem              Original code.
:rem  ----------- ----------------------------------------------------
:rem
cls
set ftpsetup_COMMAND=%0
@echo.
@echo.%ftpsetup_COMMAND%: Attempt to login and create the
@echo.Universe according to Ken.
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
:rem define dataset attributes
:rem
@echo.dele ISPF$CFG                                      >>%TMP%\ftp.txt
@echo.dele ISPF$CMD                                      >>%TMP%\ftp.txt
@echo.dele ISPF$MSG                                      >>%TMP%\ftp.txt
@echo.dele ISPF$PNL                                      >>%TMP%\ftp.txt
@echo.dele ISPF$REX                                      >>%TMP%\ftp.txt
@echo.dele ZOS$CNTL                                      >>%TMP%\ftp.txt
@echo.dele ZOS$DATA                                      >>%TMP%\ftp.txt
@echo.dele ZOS$PARM                                      >>%TMP%\ftp.txt
@echo.dele ZOS$REXX                                      >>%TMP%\ftp.txt
@echo.dele EXELIB                                        >>%TMP%\ftp.txt
@echo.quote site %VOLUME% unit=SYSALLDA                  >>%TMP%\ftp.txt
@echo.quote site tracks primary=3 secondary=1            >>%TMP%\ftp.txt
@echo.quote site pdstype=pdse                            >>%TMP%\ftp.txt
@echo.quote site recfm=fb blksize=0 lrecl=256            >>%TMP%\ftp.txt
@echo.mkdir ISPF$CFG                                     >>%TMP%\ftp.txt
@echo.quote site tracks primary=15 secondary=1           >>%TMP%\ftp.txt
@echo.quote site recfm=fb blksize=27920 lrecl=80         >>%TMP%\ftp.txt
@echo.mkdir ISPF$CMD                                     >>%TMP%\ftp.txt
@echo.mkdir ISPF$MSG                                     >>%TMP%\ftp.txt
@echo.mkdir ISPF$PNL                                     >>%TMP%\ftp.txt
@echo.quote site tracks primary=45 secondary=15          >>%TMP%\ftp.txt
@echo.quote site recfm=fb blksize=27920 lrecl=80         >>%TMP%\ftp.txt
@echo.mkdir ISPF$REX                                     >>%TMP%\ftp.txt
@echo.mkdir ZOS$CNTL                                     >>%TMP%\ftp.txt
@echo.mkdir ZOS$DATA                                     >>%TMP%\ftp.txt
@echo.mkdir ZOS$PARM                                     >>%TMP%\ftp.txt
@echo.mkdir ZOS$REXX                                     >>%TMP%\ftp.txt
@echo.quote site pdstype=pds  dir=46                     >>%TMP%\ftp.txt
@echo.quote site recfm=u blksize=32760 lrecl=0           >>%TMP%\ftp.txt
@echo.mkdir EXELIB                                       >>%TMP%\ftp.txt
@echo.;                                                  >>%TMP%\ftp.txt
@echo.;  Author: "Kenneth Tomiak" CBT_Ken-at-KTomiak.biz >>%TMP%\ftp.txt
@echo.;                                                  >>%TMP%\ftp.txt
@echo.bell                                               >>%TMP%\ftp.txt
@echo.dir                                                >>%TMP%\ftp.txt
@echo.quit                                               >>%TMP%\ftp.txt
:rem
:rem
:rem
@echo.
@echo.If what you provided is correct, this will now connect to
@echo.HOST:%ZOSHOST% and log you in as %USERID%.
@echo.Next it will issue a torrent of dele subcommands,
@echo.SO YOU BETTER BE SURE YOU WANT TO DO THIS,
@echo.set site attributes, and create several PDSE and PDS
@echo.datasets.
@echo.
@echo.You are then free to populate them as you wish.
@echo.
ftp -s:%TMP%\ftp.txt %ZOSHOST%
del %TMP%\ftp.txt
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
@echo.If the dele and mkdir subcommands worked then you can start
@echo.using these new datasets.
@echo.
:quick_exit
@echo.
@echo.%ftpsetup_COMMAND%: Done.
@echo.
set ftpsetup_COMMAND=
