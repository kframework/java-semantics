## Installation

In order to use Java Semantics you need the following prerequisites:

- A computer with at least 1GB of memory
- Linux, OSX or Windows + Cygwin. Installation instructions below are written for Linux.
- Java 7 or later, added to PATH.
- K Framework (See <http://kframework.org>). The directory k-framework/dist/bin should be added to $PATH.

Installation process:

```
$ cd ~
$ git clone --depth=1 https://github.com/kframework/java-semantics.git
$ chmod +x java-semantics/tools/*
$ export PATH=$PATH:~/java-semantics/tools
$ cd java-semantics/semantics
$ kjkompile.sh
```

Now you can execute programs bundled with the semantics:

```
$ kjrun.sh ../tests/01_smoke_tests/helloWorld.java
```

Now you can test the execution of multiple programs at once using bundled tool kjtest.
(Make sure you run some program with kjrun.sh first, it needs to perform some initializations.)

```
$ kjtest.sh --t1 ../tests/01_smoke_tests/
```

This tool executes each program in the given directory with both Java Semantics and JDK and compares the results. Testing result is summarized in test-results.xml.

## Other docs
Directory docs contains two technical reports: the complete documented semantics of module METHOD_INVOKE and the documentation of the main rule for new instance creation with all prerequisites.

URL:
https://github.com/kframework/java-semantics
