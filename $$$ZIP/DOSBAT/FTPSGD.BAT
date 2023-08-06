:ftpsgd.bat
@echo off
:rem
:rem  Author: "Kenneth Tomiak"<CBT_Ken@KTomiak.biz>
:rem
:rem  History of Changes
:rem  ----------- ----------------------------------------------------
:rem  02007-07-21 Kenneth E Tomiak
:rem              Converted to file760 format.
:rem  02007-07-20 Kenneth E Tomiak
:rem              Original code.
:rem  ----------- ----------------------------------------------------
:rem
cls
set ftpsgd_COMMAND=%0
@echo.
@echo.=================================================================
@echo.   STANDARD GLOBAL DISCLAIMER
@echo.   ==========================
@echo.   The author explicitly disavows any claim whatsoever about
@echo.   the correctness or functionality of this program, and
@echo.   disclaims liability for anything and everything bad that
@echo.   might happen in connection with, before, during, or after
@echo.   using it.  I have tried to make it work right, and I am
@echo.   personally pretty confident that it does, but everybody
@echo.   makes mistakes, so if you use it, you do so at your own
@echo.   risk.
@echo.=================================================================
@echo.
@echo.To bypass the prompt in the future, edit %0 and
@echo.uncomment the goto on line 35.
@echo.Remove the colon (:) in column 1.
@echo.Move line 35 to line 3 to bypass this statement.
@echo.
:goto :I_TAKE_FULL_RESPONSIBILITY
@echo.If you understand the above statement and wish to stop,
@echo.press [CTRL]-[C] and then [Y] to halt processing.
@echo.Otherwise, press [ENTER] to continue.
@echo.
@pause >NUL
:I_TAKE_FULL_RESPONSIBILITY
@echo.
set ftpsgd_COMMAND=
