@echo off
type %1
echo interpreter trace > inttrace.txt
set /p consoleInput=
echo console input:
echo %consoleInput%
IF %consoleInput%==error echo %consoleInput%>&2
PING 1.1.1.1 -n 1 -w 60000 >NUL
