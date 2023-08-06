:ftpsetattributes.bat
@echo off
:rem
:rem  Author: "Kenneth Tomiak"<CBT_Ken@KTomiak.biz>
:rem
:rem  History of Changes
:rem  ----------- ----------------------------------------------------
:rem  02007-07-26 Kenneth E Tomiak
:rem              Support multiple configuration setting bat files.
:rem  02007-07-26 Kenneth E Tomiak
:rem              Combine RECFM, BLKSIZE, and LRECL into one command.
:rem              Fixed pdstype.
:rem              Fixed umask.
:rem  02007-07-21 Kenneth E Tomiak
:rem              Original code.
:rem  ----------- ----------------------------------------------------
:rem
cls
set ftpsetattributes_COMMAND=%0
@echo.
@echo.%ftpsetattributes_COMMAND%: Add quote site commands that
@echo.influence new data set allocations and file transfer processing.
@echo.
:rem
:rem Set which filesystem to talk to, MVS or JES.
:rem
if [%FILETYPE%]==[]       goto :no_filetype
@echo.quote site filetype=%FILETYPE%                     >>%TMP%\ftp.txt
:no_filetype
:rem
:rem HSM attributes
:rem
:hsm_attributes
if [%MGMTCLAS%]==[]       goto :no_mgmtclas
@echo.quote site mgmtclas=%MGMTCLAS%                     >>%TMP%\ftp.txt
:no_mgmtclas
:rem
:rem Device attributes
:rem
:dev_attributes
if [%STORCLAS%]==[]       goto :no_storclas
@echo.quote site storclas=%STORCLAS%                     >>%TMP%\ftp.txt
goto :dcb_attributes
:no_storclas
if [%UNITNAME%]==[]       goto :no_unitname
@echo.quote site unit=%UNITNAME%                         >>%TMP%\ftp.txt
:no_unitname
if [%VOLUME%]==[]         goto :no_volume
@echo.quote site volume=%VOLUME%                         >>%TMP%\ftp.txt
:no_volume
if [%UCOUNT%]==[]         goto :no_ucount
@echo.quote site ucount=%UCOUNT%                         >>%TMP%\ftp.txt
:no_ucount
if [%VCOUNT%]==[]         goto :no_vcount
@echo.quote site vcount=%VCOUNT%                         >>%TMP%\ftp.txt
:no_vcount
:rem
:rem Dataset attributes
:rem
:dcb_attributes
if [%DATACLAS%]==[]       goto :no_dataclas
@echo.quote site dataclas=%DATACLAS%                     >>%TMP%\ftp.txt
goto :unix_permissions
:no_dataclas
if [%SPACETYPE%]==[]      goto :no_spacetype
@echo.quote site %SPACETYPE%                             >>%TMP%\ftp.txt
:no_spacetype
if [%PRIMARY%]==[]        goto :no_primary
@echo.quote site primary=%PRIMARY%                       >>%TMP%\ftp.txt
:no_primary
if [%SECONDARY%]==[]      goto :no_secondary
@echo.quote site secondary=%SECONDARY%                   >>%TMP%\ftp.txt
:no_secondary
if [%PDSTYPE%]==[]        goto :no_pdstype
@echo.quote site pdstype=%PDSTYPE%                       >>%TMP%\ftp.txt
:no_pdstype
if [%DIRECTORY%]==[]      goto :no_directory
@echo.quote site dir=%DIRECTORY%                         >>%TMP%\ftp.txt
:no_directory
if [%DCBDSN%]==[]         goto :no_dcbdsn
@echo.quote site dcb=%DCBDSN%                            >>%TMP%\ftp.txt
:no_dcbdsn
set DCBON=
set QUOTEDCB=
@echo.%QUOTEDCB%
if [%RECFM%]==[]          goto :no_recfm
set QUOTEDCB=%QUOTEDCB% recfm=%RECFM%
set DCBON=ON
:no_recfm
if [%BLKSIZE%]==[]        goto :no_blksize
set QUOTEDCB=%QUOTEDCB% blksize=%BLKSIZE%
set DCBON=ON
:no_blksize
if [%LRECL%]==[]          goto :no_lrecl
set QUOTEDCB=%QUOTEDCB% lrecl=%LRECL%
set DCBON=ON
:no_lrecl
if [%DCBON%]==[]  goto :no_dcb
@echo.quote site %QUOTEDCB% >>%TMP%\ftp.txt
:no_dcb
:rem
:rem UNIX mask for file permissions
:rem
:unix_permissions
if [%UMASK%]==[]          goto :no_umask
@echo.quote site umask %UMASK%                           >>%TMP%\ftp.txt
:no_umask
:rem
:rem File transfer attributes
:rem
:ftp_attributes
if [%RDW%]==[]            goto :no_rdw
@echo.quote site %RDW%                                   >>%TMP%\ftp.txt
:no_rdw
if [%TRAILINGBLANKS%]==[] goto :no_trailingblanks
@echo.quote site %TRAILINGBLANKS%                        >>%TMP%\ftp.txt
:no_trailingblanks
if [%SBDATACONN%]==[]     goto :no_sdbdataconn
@echo.quote site sbdataconn=%SBDATACONN%                 >>%TMP%\ftp.txt
:no_sdbdataconn
:all_done
set ftpsetattributes_COMMAND=
