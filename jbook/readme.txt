    Tools info for JBook-java.

Setup:
1. Install cygwin, using default options.
2. Set the windows environment variable:
    CYGWIN=nodosfilewarning

  General:
- Tools should be run on windows. Linux is not supported.
- All tools should be run from this directory.

1. To run a particular file:
    tools\jbook-run.bat <file>
2. To run a particular test dir:
    tools\jbook-test.bat <test dir>
3. To run a test dir over programs preprocessed with java-fan preprocessor:
    tools\jbook-prep-test.bat <test dir>
4. To run all te tests, preprocessed:
    tools\jbook-prep-test.bat ..\programs

A lot of problems were encountered during development. All of them are documented in the scripts
  inside \tools.
