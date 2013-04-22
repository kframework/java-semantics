@echo off
REM Runs the given program with jbook-java.
REM uses cygwin scripts only for postprocessing.
REM thus is termination-compatible via taskkill /t.

REM We cannot call jbook-raw-run.bat, because after its return everything else is not executed.
REM Weird problem.

REM If AsmGofer.exe is started by a cygwin-bash script, it will not be killed by taskkill,
REM e.g. by test-runner.jar. This is why Asmgofer.exe should be started from a bat-only environment.
REM Only after it returns, we can postprocess the results using bash scripts.

REM required to be able to SET variables inside if
setlocal EnableDelayedExpansion

REM Check that there are one or two arguments
if [%1]==[] (
    echo Usage: jbook-run.bat ^<java_file^>
    echo You entered:
    echo %0
    goto :eof
)
if not [%2]==[] (
    echo Usage: jbook-run.bat ^<java_file^>
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

echo :p files/java.p > in-temp.txt
echo mainF "%JAVA_FILE_ABS%" >> in-temp.txt
echo :q >> in-temp.txt

REM go to AsmGofer.exe dir
cd %JBOOK_IMPL_DIR%

AsmGofer.exe < %START_DIR%\in-temp.txt > %START_DIR%\jbr-temp.txt

cd %START_DIR%

REM filter the output
%JBOOK_TOOLS_DIR%\bash-run.bat %JBOOK_TOOLS_DIR%\jbook-postproc.sh jbr-temp.txt
