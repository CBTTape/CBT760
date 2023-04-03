:UPCASE.BAT
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
CALL :UpCase2 %*
SET WORDS=%WORD1%
GOTO:EOF
:rem
:UpCase2
SET WORD1=%*
SET WORD1=%WORD1:a=A%
SET WORD1=%WORD1:b=B%
SET WORD1=%WORD1:c=C%
SET WORD1=%WORD1:d=D%
SET WORD1=%WORD1:e=E%
SET WORD1=%WORD1:f=F%
SET WORD1=%WORD1:g=G%
SET WORD1=%WORD1:h=H%
SET WORD1=%WORD1:i=I%
SET WORD1=%WORD1:j=J%
SET WORD1=%WORD1:k=K%
SET WORD1=%WORD1:l=L%
SET WORD1=%WORD1:m=M%
SET WORD1=%WORD1:n=N%
SET WORD1=%WORD1:o=O%
SET WORD1=%WORD1:p=P%
SET WORD1=%WORD1:q=Q%
SET WORD1=%WORD1:r=R%
SET WORD1=%WORD1:s=S%
SET WORD1=%WORD1:t=T%
SET WORD1=%WORD1:u=U%
SET WORD1=%WORD1:v=V%
SET WORD1=%WORD1:w=W%
SET WORD1=%WORD1:x=X%
SET WORD1=%WORD1:y=Y%
SET WORD1=%WORD1:z=Z%
GOTO:EOF
:rem
:rem
:rem
:Syntax
ECHO.
ECHO %0: Version 3.00 for Windows XP
ECHO Convert to all uppercase
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
