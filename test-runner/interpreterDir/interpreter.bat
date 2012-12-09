@echo off
type %1
echo interpreter trace > inttrace.txt
set /p consoleInput=
echo console input:
echo %consoleInput%
IF %consoleInput%==error echo %consoleInput%>&2
