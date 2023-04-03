:II13288.bat
@echo off
:rem
:rem  Author: "Kenneth Tomiak"<CBT_Ken@KTomiak.biz>
:rem
:rem  History of Changes
:rem  ----------- ----------------------------------------------------
:rem  02007-07-20 Kenneth E Tomiak
:rem              Converted to file760 format.
:rem  02007-07-17 Kenneth E Tomiak
:rem              Original code.
:rem  ----------- ----------------------------------------------------
:rem
cls
call ftpconfig.bat
md mvstools
@echo.
@echo.%0: Starting.
@echo.
@echo.DFSMS 1.3 - OA01610
@echo.IBM APAR II13288
@echo.http://www-1.ibm.com/support/docview.wss?uid=swg21186980
@echo.There is an adhoc tool available that can be run to determine
@echo.the change (if any) to index cisize. This is available from
@echo.the software server (ftp.software.ibm.com) in the s390/mvs/tools
@echo.directory as INDXCISZ.JCL.TRSD. This will need to be
@echo.downloaded in binary format and untersed using TRSMAIN.
@echo.Please note that this tool is provided as is.
@echo.
if %USERID%.==.   goto :need_userid
if %PASSWORD%.==. goto :need_password
if %ZOSHOST%.==.  goto :need_zoshost_name
if %EMAIL%.==.    goto :need_emailaddress
:rem
:rem login
:rem
@echo anonymous                                           >%TMP%\ftp.txt
@echo %EMAIL%                                            >>%TMP%\ftp.txt
@echo cd s390/mvs/tools                                  >>%TMP%\ftp.txt
@echo prompt                                             >>%TMP%\ftp.txt
@echo bin                                                >>%TMP%\ftp.txt
@echo ls                                                 >>%TMP%\ftp.txt
@echo lcd mvstools                                       >>%TMP%\ftp.txt
@echo mget *.*                                           >>%TMP%\ftp.txt
@echo cd packlib                                         >>%TMP%\ftp.txt
@echo get trsmain.bin TRSMAIN.XMI                        >>%TMP%\ftp.txt
@echo quit                                               >>%TMP%\ftp.txt
@echo.
@echo.Login to ftp.software.ibm.com and grab the tools.
@echo.
ftp -s:%TMP%\ftp.txt ftp.software.ibm.com
cd mvstools
@echo.
@echo.Rename the files to what they should have been called.
@echo.
ren catlook.bin catlook.xmi
ren DFDSSCT.CVTOC20.PDS.XFRSEQ CVTOC20H.CMS
ren DFDSSCT.CVTOC20H.HTML CVTOC20H.HTML
ren dflist.bin DFLIST.XMI
ren IMBDSHIP.JCL.TRSD IMBDSHIP.TERSED
ren INDXCISZ.JCL.TRSD INDXCISZ.TERSED
ren VVDSFIX.VER13.TRSD VVDSFIX.TERSED
ren XISOLATE.V112.PDS.XFRSEQ XISOLATE.XMI
ren y2k.cmd y2k.os2
cd ..
@echo %USERID%                                            >%TMP%\ftp.txt
@echo %PASSWORD%                                         >>%TMP%\ftp.txt
@echo bin                                                >>%TMP%\ftp.txt
@echo lcd mvstools                                       >>%TMP%\ftp.txt
@echo quote site tracks primary=10 secondary=10          >>%TMP%\ftp.txt
@echo quote site recfm=fb blksize=10240 lrecl=1024       >>%TMP%\ftp.txt
@echo quote site %VOLUME%                                >>%TMP%\ftp.txt
@echo put INDXCISZ.TERSED                                >>%TMP%\ftp.txt
@echo quote site recfm=fb blksize=27920 lrecl=80         >>%TMP%\ftp.txt
@echo put TRSMAIN.XMI                                    >>%TMP%\ftp.txt
@echo quit                                               >>%TMP%\ftp.txt
:rem
@echo.
@echo.Login to %ZOSHOST% and upload a file.
@echo.
ftp -s:%TMP%\ftp.txt %ZOSHOST%
del %TMP%\ftp.txt
@echo.
@echo.If everything worked, your system now has a TRSMAIN.XMI file
@echo.that you must receive. Then you can run TRSMAIN to unterse
@echo.INDXCISZ.TERSED. Fix the JCL in the untersed dataset and
@echo.you will link INDXCISZ and be ready to run it.
@echo.
@echo.What could be easier? II13288 in the ZOS$CNTL pds!
@echo.
@echo.The [ENTER} key is best used as the any key.
pause
goto :all_done
:rem
:rem
:rem
:need_userid
:need_password
:need_zoshost_name
:need_emailaddress
@echo.
@echo. Syntax: %0
@echo.
@echo. But first you must edit ftpconfig.bat and set variables.
@echo.
goto :all_done
:rem
:rem
:rem
:all_done
@echo.
@echo.%0: Done.
@echo.
