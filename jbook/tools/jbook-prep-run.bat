@echo off
REM Use this script only from inside test-runner. Uses preprocessing results produced by test-generator.
REM Based on the given program, runs the already available preprocessed program in the dir .prep of the local directory.
REM That program is run with jbook-java.
REM After that a cygwin script is used for postprocessing.
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

SET JAVA_FILE=%1

REM Retrieve simple name from the java file path
for %%F in (%JAVA_FILE%) do SET JAVA_SIMPLE_NAME=%%~nxF

REM java file absolute path
REM SET JAVA_FILE_ABS=%~f1

REM absolute path to the preprocessed java file (from the generator step)
SET PREP_LAVA_FILE_ABS=%START_DIR%/.prep/%JAVA_SIMPLE_NAME%

REM replace \ with / in the java file
SET PREP_LAVA_FILE_ABS=%PREP_LAVA_FILE_ABS:\=/%

echo :p files/java.p > in-temp.txt
echo mainF "%PREP_LAVA_FILE_ABS%" >> in-temp.txt
echo :q >> in-temp.txt

REM go to AsmGofer.exe dir
cd %JBOOK_IMPL_DIR%

AsmGofer.exe < %START_DIR%\in-temp.txt > %START_DIR%\jbr-temp.txt

cd %START_DIR%

REM filter the output
%JBOOK_TOOLS_DIR%\bash-run.bat %JBOOK_TOOLS_DIR%\jbook-postproc.sh jbr-temp.txt
