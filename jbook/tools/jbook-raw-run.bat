@echo off
REM Runs the given file with jbook-java without any pre/postprocessing
REM Can be run from any dir

REM required to be able to SET variables inside if
setlocal EnableDelayedExpansion

REM Check that there are one or two arguments
if [%1]==[] (
    echo Usage: jbook-raw-run.bat ^<java_file^>
    echo You entered:
    echo %0
    goto :eof
)
if not [%2]==[] (
    echo Usage: jbook-raw-run.bat ^<java_file^>
    echo You entered:
    echo %0 %1 %2 ...
    goto :eof
)

SET START_DIR=%cd%
SET JBOOK_TOOLS_DIR=%~dp0
SET JBOOK_IMPL_DIR=%JBOOK_TOOLS_DIR%\..\jbook-impl

REM java file absolute path
SET JAVA_FILE_ABS=%~f1

REM replace \ with / in java file
SET JAVA_FILE_ABS=%JAVA_FILE_ABS:\=/%

REM go to AsmGofer.exe dir
cd %JBOOK_IMPL_DIR%

echo :p files/java.p > temp.txt
echo mainF "%JAVA_FILE_ABS%" >> temp.txt
echo :q >> temp.txt

AsmGofer.exe < temp.txt

del temp.txt
cd %START_DIR%
