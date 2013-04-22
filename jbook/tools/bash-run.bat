@echo off
REM Takes two arguments.
REM   The first argument is a bash script.
REM   the second one - an argument to that script (optional).
REM Converts both the script and the argument to windows absolute paths
REM   the given script in bash with the given argument.
REM You can also give the bash script without argument.

REM required to be able to SET variables inside if
setlocal EnableDelayedExpansion

REM Check that there are one or two arguments
if [%1]==[] (
    echo Usage: bash-run.bat bash_script [bash_script_argument]
    echo You entered:
    echo %0
    goto :eof
)
if not [%3]==[] (
    echo Usage: bash-run.bat bash_script [bash_script_argument]
    echo You entered:
    echo %0 %1 %2 %3 ...
    goto :eof
)

REM Tells bash to start in the current directory
SET CHERE_INVOKING=1

REM fully qualified path of the bash script.
SET SCRIPT_ABS=%~f1

if [%2]==[] (
    bash --login !SCRIPT_ABS!
) else (
    REM fully qualified path of the bash script argument.
    SET ARG_ABS=%~f2

    bash --login !SCRIPT_ABS! !ARG_ABS!
)
