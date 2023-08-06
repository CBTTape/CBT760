:$$readme.bat
@echo off
:rem
:rem  Author: "Kenneth Tomiak"<CBT_Ken@KTomiak.biz>
:rem
:rem  History of Changes
:rem  ----------- ----------------------------------------------------
:rem  02007-08-02 Kenneth E Tomiak
:rem              Additional sub-directories to be built.
:rem  02007-07-21 Kenneth E Tomiak
:rem              Original code.
:rem  ----------- ----------------------------------------------------
:rem
cls
set $$readme_COMMAND=%0
@echo.
@echo.%$$README_COMMAND%:
@echo.
@echo.Welcome to Ken's Universe.
@echo.
@echo.These files and subdirectories contain a collection of
@echo.PC and z/OS files geared to both the NOVICE and self-proclaimed
@echo.GURUS. I am not a guru, I am more of a generalist.
@echo.According to a FAR SIDE comic strip, there is only one way to
@echo.properly skin a cat. There are many ways to accomplish the
@echo.same tasks presented here. If you have a better way, then I
@echo.am interested in hearing about it. If you just have a different
@echo.way, then I am not so keen on hearing about it. Be prepared to
@echo.justify why your way is better with convincing arguments.
@echo.Otherwise, believe me when I say the color purple is the best.
@echo.
@echo.Ready to go on?
@echo.If not, press [ctrl-c] now. Otherwise, use the space bar to
@echo.page through the text that follows.
pause
type $$README.TXT | MORE
@echo.
@echo.
@echo.Ready to create some sub-directories?
@echo.If not, press [ctrl-c] now.
pause
mkdir "%HOMEPATH%\BACKUPS"
mkdir "%HOMEPATH%\CLIST"
mkdir "%HOMEPATH%\CNTL"
mkdir "%HOMEPATH%\CONFIG"
mkdir "%HOMEPATH%\DATA"
mkdir "%HOMEPATH%\DOSBAT"
mkdir "%HOMEPATH%\DOSDATA"
mkdir "%HOMEPATH%\DOSREXX"
mkdir "%HOMEPATH%\DOSPERL"
mkdir "%HOMEPATH%\EXELIB"
mkdir "%HOMEPATH%\HTML"
mkdir "%HOMEPATH%\IEBUPDTE"
mkdir "%HOMEPATH%\MSGS"
mkdir "%HOMEPATH%\OBJLIB"
mkdir "%HOMEPATH%\PANELS"
mkdir "%HOMEPATH%\PARMLIB"
mkdir "%HOMEPATH%\PROCLIB"
mkdir "%HOMEPATH%\REXX"
mkdir "%HOMEPATH%\SHELL"
mkdir "%HOMEPATH%\SKELS"
mkdir "%HOMEPATH%\SQLLIB"
mkdir "%HOMEPATH%\SRCLIB"
mkdir "%HOMEPATH%\ZOSJCL"
mkdir "%HOMEPATH%\ZOSUTIL"
@echo.
@echo.%$$readme_COMMAND%: Done.
@echo.
set $$readme_COMMAND=
