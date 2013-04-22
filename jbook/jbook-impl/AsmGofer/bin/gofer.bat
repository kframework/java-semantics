@ECHO OFF
SET ROOT=AsmGofer
SET GOFER=%ROOT%\Preludes\tk.prelude-all-asm
SET TKGOFER=%ROOT%/Tcl/gofer.tcl
SET PATH=%PATH%;AsmGofer\Tk8.0\bin
if "%TCL_LIBRARY%"=="" goto setTcl
goto testTk
:setTcl
SET TCL_LIBRARY=AsmGofer/Tk8.0/lib/tcl8.0
:testTk
if "%TK_LIBRARY%"=="" goto setTk
goto run
:setTk
SET TK_LIBRARY=AsmGofer/Tk8.0/lib/tk8.0
:run
%ROOT%\bin\AsmGof.exe -h1000000 %1 %2 %3 %4 %5 %6 %7 %8 %9
