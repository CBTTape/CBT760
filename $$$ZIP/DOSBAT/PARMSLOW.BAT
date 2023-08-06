:PARMSLOW.BAT
@ECHO OFF
:rem
:rem  Author: "Rob van der Woude"
:rem http://www.robvanderwoude.com
:rem
:rem  History of Changes
:rem  ----------- ----------------------------------------------------
:rem  02007-07-20 Kenneth E Tomiak
:rem              Added syntax?
:rem  ----------- ----------------------------------------------------
:rem
IF [%1]==[] GOTO Syntax
:rem
:rem
:rem
CALL :LoCase2 %*
SET WORDS=%WORD1%
GOTO:EOF
:rem
:rem
:rem
:LoCase2
SET WORD1=%*
SET WORD1=%WORD1:A=a%
SET WORD1=%WORD1:B=b%
SET WORD1=%WORD1:C=c%
SET WORD1=%WORD1:D=d%
SET WORD1=%WORD1:E=e%
SET WORD1=%WORD1:F=f%
SET WORD1=%WORD1:G=g%
SET WORD1=%WORD1:H=h%
SET WORD1=%WORD1:I=i%
SET WORD1=%WORD1:J=j%
SET WORD1=%WORD1:K=k%
SET WORD1=%WORD1:L=l%
SET WORD1=%WORD1:M=m%
SET WORD1=%WORD1:N=n%
SET WORD1=%WORD1:O=o%
SET WORD1=%WORD1:P=p%
SET WORD1=%WORD1:Q=q%
SET WORD1=%WORD1:R=r%
SET WORD1=%WORD1:S=s%
SET WORD1=%WORD1:T=t%
SET WORD1=%WORD1:U=u%
SET WORD1=%WORD1:V=v%
SET WORD1=%WORD1:W=w%
SET WORD1=%WORD1:X=x%
SET WORD1=%WORD1:Y=y%
SET WORD1=%WORD1:Z=z%
GOTO:EOF
:rem
:rem
:rem
:Syntax
ECHO.
ECHO %0: Version 2.00 for Windows Xp
ECHO Convert to all lowercase
ECHO.
ECHO Usage:  %0  [some text]
ECHO.Then you use %WORDS% anyway you want.
ECHO.
ECHO Written by Rob van der Woude
ECHO http://www.robvanderwoude.com
ECHO.
ECHO.Modified by Kenneth E Tomiak
ECHO.
:End
:EOF
