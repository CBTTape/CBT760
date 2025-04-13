:batchcaptfs.bat
@echo off
:rem
:rem  Author: "Kenneth Tomiak"<CBT_Ken@KTomiak.biz>
:rem
:rem  History of Changes
:rem  ----------- ----------------------------------------------------
:rem  02007-07-31 Kenneth E Tomiak
:rem              Original code.
:rem  ----------- ----------------------------------------------------
:rem
cls
set batchcaptfs_COMMAND=%0
call ftpsgd.bat
@echo.
@echo.%batchcaptfs_COMMAND%: Attempt to copy all CA ptf files into
@echo.
@echo.
if not exist *.ptf goto :no_suchfile
copy *.ptf cumfile /b
@echo.
@echo.%bat_COMMAND%: Done.
@echo.
goto :yes_dir
:rem
:rem
:rem
:no_suchfile
@echo.
@echo.%batchcaptfs_command% expects you downloaded some files from
@echo.CA and used .ptf for the file extension.
@echo.
@echo.
@echo.Press [ENTER] now.
pause
@echo.
:yes_dir
set batchcaptfs_COMMAND=
