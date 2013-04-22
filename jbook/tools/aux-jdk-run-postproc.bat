@echo off
REM Runs the given program with the script aux-jdk-run-postproc.sh

REM the fully qualified path to the current directory
SET JBOOK_TOOLS_DIR=%~dp0

%JBOOK_TOOLS_DIR%\bash-run.bat %JBOOK_TOOLS_DIR%\aux-jdk-run-postproc.sh %1
