:$$readme.bat
@echo off
:rem
:rem  Author: "Kenneth Tomiak"<CBT_Ken@KTomiak.biz>
:rem
:rem  History of Changes
:rem  ----------- ----------------------------------------------------
:rem  02007-07-20 Kenneth E Tomiak
:rem              Converted to file760 format.
:rem  02007-07-20 Kenneth E Tomiak
:rem              Original code.
:rem  ----------- ----------------------------------------------------
:rem
call ftpsgd.bat
cls
set $$readme_COMMAND=%0
@echo.
@echo.This directory contains a collection of DOS command scripts,
@echo.commonly referred to as BAT files. These are examples of how
@echo.to script the Windows/XP FTP command line client. These are
@echo.what I refer to as 'Blind eye' scripts. When they work, they
@echo.work fine. If any hiccup happens, well, commands may stop
@echo.working and predictable results will occur. I predict doom.
@echo.
@echo.These scripts are all flexible in the host they connect to,
@echo.but were designed soley to connect to a z/OS host and work
@echo.with MVS datasets. That means, NOT the z/OS UNIX files.
@echo.You may find they work just fine. I did not test them with
@echo.z/OS UNIX files.
@echo.
@echo.Ready to go on?
pause
type $$README.DIR | MORE
@echo.
@echo.%$$readme_COMMAND%: Done.
@echo.
set $$readme_COMMAND=
