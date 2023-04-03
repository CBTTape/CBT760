:ftpivp.bat
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
:rem  02007-07-16 Kenneth E Tomiak
:rem              Original code.
:rem  ----------- ----------------------------------------------------
:rem
cls
set ftpivp_COMMAND=%0
@echo.
@echo.%ftpivp_COMMAND%: Demonstrate FTP with z/OS capabilities.
@echo.
if [%FTPCONFIG%]==[] goto :no_config
call %FTPCONFIG%
goto :check_basic_attributes
:no_config
set FTPCONFIG=HOSTDEFAULT
call %FTPCONFIG%
:check_basic_attributes
if %USERID%.==.          goto :need_userid
if %PASSWORD%.==.        goto :need_password
if %ZOSHOST%.==.         goto :need_zoshost_name
if %1.==.                goto :need_pdsname
if not exist IEBBKUP.JCL goto :need_bkupjcl
if not exist IEBREST.JCL goto :need_restjcl
:rem
:rem login
:rem
@echo.%USERID%                                            >%TMP%\ftp.txt
@echo.%PASSWORD%                                         >>%TMP%\ftp.txt
call ftpsetattributes.bat
:rem
:rem Build a pds, upload the job, submit it, get the output.
:rem
@echo.quote site RECFM=FB                                >>%TMP%\ftp.txt
@echo.quote site BLKSIZE=3200 LRECL=80                   >>%TMP%\ftp.txt
@echo.quote site DIR=5                                   >>%TMP%\ftp.txt
@echo.mkdir %1                                           >>%TMP%\ftp.txt
@echo.cd %1                                              >>%TMP%\ftp.txt
@echo.dir                                                >>%TMP%\ftp.txt
@echo.put IEBBKUP.JCL IEBBKUP                            >>%TMP%\ftp.txt
@echo.put IEBREST.JCL IEBREST                            >>%TMP%\ftp.txt
@echo.quote site filetype=jes                            >>%TMP%\ftp.txt
@echo.get IEBBKUP jobbkup.txt                            >>%TMP%\ftp.txt
@echo.quote site filetype=seq                            >>%TMP%\ftp.txt
:rem
:rem Drop back to HLQ and get the IEBCOPY backup dataset.
:rem
@echo.cd '%UCUSERID%'                                    >>%TMP%\ftp.txt
@echo.bin                                                >>%TMP%\ftp.txt
@echo.quote stru r                                       >>%TMP%\ftp.txt
@echo.;                                                  >>%TMP%\ftp.txt
@echo.;  Author: "Kenneth Tomiak" CBT_Ken-at-KTomiak.biz >>%TMP%\ftp.txt
@echo.;                                                  >>%TMP%\ftp.txt
@echo.get PDSCNTL.BACKUP                                 >>%TMP%\ftp.txt
@echo.quote site recfm=vs blksize=32740 lrecl=32736      >>%TMP%\ftp.txt
@echo.put PDSCNTL.BACKUP RESTORE.PDSCNTL                 >>%TMP%\ftp.txt
@echo.quote site filetype=jes                            >>%TMP%\ftp.txt
@echo.cd %1                                              >>%TMP%\ftp.txt
@echo.bell                                               >>%TMP%\ftp.txt
@echo.get IEBREST jobrest.txt                            >>%TMP%\ftp.txt
@echo.quote site filetype=seq                            >>%TMP%\ftp.txt
@echo.quit                                               >>%TMP%\ftp.txt
:rem
@echo.
@echo.If what you provided is correct, this will now connect to
@echo.HOST:%ZOSHOST% and log you in as %USERID%.
@echo.Next it will create a PDS as you requested,
@echo.upload IEBBKUP.JCL as member IEBBKUP,
@echo.submit IEBBKUP and wait for it to complete,
@echo.download the output (remember it is still on the spool),
@echo.delete the temporary PDS, and download PDSCNTL.BACKUP.
@echo.
ftp -s:%TMP%\ftp.txt %ZOSHOST%
del %TMP%\ftp.txt
goto all_done
:need_bkupjcl
@echo.
@echo.%ftpivp_COMMAND% was delivered with IEBBKUP.JCL. This needs to
@echo.be in the same directory where you are running this from.
@echo.I insist, so fix the JOBCARD and %ftpivp_COMMAND% will try again.
@echo.
@echo.Press [ENTER] now.
pause
call parmsup.bat %USERID%
set UCUSERID=%WORDS%
@echo.//%UCUSERID%A JOB (FTP,IVP),'KENNETH E TOMIAK',       >IEBBKUP.JCL
@echo.//             CLASS=A,                              >>IEBBKUP.JCL
@echo.//             MSGCLASS=X,MSGLEVEL=(1,1),            >>IEBBKUP.JCL
@echo.//             REGION=6M,TIME=1440,                  >>IEBBKUP.JCL
@echo.//             NOTIFY=%UCUSERID%                     >>IEBBKUP.JCL
@echo.//*                                                  >>IEBBKUP.JCL
@echo.//* =================================================>>IEBBKUP.JCL
@echo.//* First cleanup for reruns.                        >>IEBBKUP.JCL
@echo.//* =================================================>>IEBBKUP.JCL
@echo.//DELETE  EXEC PGM=IDCAMS                            >>IEBBKUP.JCL
@echo.//SYSPRINT DD  SYSOUT=*                              >>IEBBKUP.JCL
@echo.//SYSIN    DD  *                                     >>IEBBKUP.JCL
@echo.         DELETE %UCUSERID%.PDSCNTL.BACKUP            >>IEBBKUP.JCL
@echo.         DELETE %UCUSERID%.IEBTEST                   >>IEBBKUP.JCL
@echo.         SET MAXCC = 0                               >>IEBBKUP.JCL
@echo./*                                                   >>IEBBKUP.JCL
@echo.//*                                                  >>IEBBKUP.JCL
@echo.//* =================================================>>IEBBKUP.JCL
@echo.//* Next, create the unloaded dataset.               >>IEBBKUP.JCL
@echo.//* =================================================>>IEBBKUP.JCL
@echo.//BACKUP  EXEC PGM=IEBCOPY                           >>IEBBKUP.JCL
@echo.//SYSPRINT DD  SYSOUT=*                              >>IEBBKUP.JCL
@echo.//SYSUT1   DD  DISP=(SHR),DSN=%UCUSERID%.%1          >>IEBBKUP.JCL
@echo.//SYSUT2   DD  DISP=(NEW,CATLG,DELETE),              >>IEBBKUP.JCL
@echo.//             DSN=%UCUSERID%.PDSCNTL.BACKUP,        >>IEBBKUP.JCL
@echo.//             UNIT=SYSALLDA,                        >>IEBBKUP.JCL
if [%VOLUME%]==[] goto :no_volser
@echo.//             VOL=SER=%VOLUME%,                     >>IEBBKUP.JCL
:no_volser
@echo.//             SPACE=(TRK,(20,100),RLSE)             >>IEBBKUP.JCL
@echo.//* = Default  DCB=                                  >>IEBBKUP.JCL
@echo.//*                DSORG=PS                          >>IEBBKUP.JCL
@echo.//*                RECFM=VB                          >>IEBBKUP.JCL
@echo.//*                BLKSIZE=32740                     >>IEBBKUP.JCL
@echo.//*                LRECL=32736                       >>IEBBKUP.JCL
@echo.//SYSIN    DD  *                                     >>IEBBKUP.JCL
@echo.CPYLABEL COPY INDD=SYSUT1,OUTDD=SYSUT2               >>IEBBKUP.JCL
@echo./*                                                   >>IEBBKUP.JCL
@echo.//*                                                  >>IEBBKUP.JCL
@echo.//                                                   >>IEBBKUP.JCL
notepad IEBBKUP.JCL
%ftpivp_COMMAND% %*
goto :quick_exit
:rem
:need_restjcl
@echo.
@echo.%ftpivp_COMMAND% was delivered with IEBREST.JCL. This is built
@echo.to help prove you can transport a native IEBCOPY unload
@echo.dataset to the PC and back again.
@echo.
@echo.Press [ENTER] now.
pause
@echo.
@echo.Building a restore job, too.
@echo.
call parmsup.bat %USERID%
set UCUSERID=%WORDS%
@echo.//%UCUSERID%A JOB (FTP,IVP),'KENNETH E TOMIAK',       >IEBREST.JCL
@echo.//             CLASS=A,                              >>IEBREST.JCL
@echo.//             MSGCLASS=X,MSGLEVEL=(1,1),            >>IEBREST.JCL
@echo.//             REGION=6M,TIME=1440,                  >>IEBREST.JCL
@echo.//             NOTIFY=%UCUSERID%                     >>IEBREST.JCL
@echo.//*                                                  >>IEBREST.JCL
@echo.//* =================================================>>IEBREST.JCL
@echo.//* Later you can restore the dataset with this.     >>IEBREST.JCL
@echo.//* =================================================>>IEBREST.JCL
@echo.//RESTORE EXEC PGM=IEBCOPY                           >>IEBREST.JCL
@echo.//SYSPRINT DD  SYSOUT=*                              >>IEBREST.JCL
@echo.//SYSUT1   DD  DISP=SHR,                             >>IEBREST.JCL
@echo.//*            DSN=%UCUSERID%.PDSCNTL.BACKUP         >>IEBREST.JCL
@echo.//             DSN=%UCUSERID%.RESTORE.PDSCNTL        >>IEBREST.JCL
@echo.//SYSUT2   DD  DISP=(NEW,CATLG,DELETE),              >>IEBREST.JCL
@echo.//             DSN=%UCUSERID%.IEBTEST,               >>IEBREST.JCL
@echo.//             UNIT=SYSALLDA,                        >>IEBREST.JCL
if [%VOLUME%]==[] goto :no_volser2
@echo.//             VOL=SER=%VOLUME%,                     >>IEBREST.JCL
:no_volser2
@echo.//             SPACE=(TRK,(20,100),RLSE),            >>IEBREST.JCL
@echo.//             DSNTYPE=LIBRARY,                      >>IEBREST.JCL
@echo.//             DSORG=PO,                             >>IEBREST.JCL
@echo.//             RECFM=FB,                             >>IEBREST.JCL
@echo.//             BLKSIZE=0,                            >>IEBREST.JCL
@echo.//             LRECL=80                              >>IEBREST.JCL
@echo.//*   DCB=(DSORG=PO,RECFM=FB,BLKSIZE=0,LRECL=80)     >>IEBREST.JCL
@echo.//SYSIN    DD  *                                     >>IEBREST.JCL
@echo.CPYLABEL COPY INDD=SYSUT1,OUTDD=SYSUT2               >>IEBREST.JCL
@echo./*                                                   >>IEBREST.JCL
@echo.//*                                                  >>IEBREST.JCL
notepad IEBREST.JCL
%ftpivp_COMMAND% %*
goto :quick_exit
:rem
:rem
:rem
:need_PDSname
call parmsup.bat %USERID%
set UCUSERID=%WORDS%
set pdsname=FTPIVP.CNTL
%ftpivp_COMMAND% %PDSNAME%
:all_done
@echo.
@echo.If the IVP worked, you now have the output from an IEBCOPY on
@echo.on your PC. Good luck with that!
@echo.
@echo.If you root around in FILE760 you will learn how to transport
@echo.this type of file from z/OS to your PC and then back to z/OS.
@echo.And if you take the time to install Open Object REXX, FREE
@echo.if you look at www.rexxla.org, there is some REXX code you
@echo.can use to KETCOPY the PDS members into individual files.
@echo.
:quick_exit
@echo.
@echo.%ftpivp_COMMAND%: Done.
@echo.
set ftpivp_COMMAND=
