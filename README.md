## Installation

In order to use Java Semantics you need the following prerequisites:

- A computer with at least 1GB of memory
- Linux or OSX
- Java 7 or later, added to PATH.
- K Framework (See <http://kframework.org>). The directory k-framework/dist/bin should be added to $PATH.

Installation process:

```
$ cd ~
$ git clone --depth=1 https://github.com/kframework/java-semantics.git
$ chmod +x java-semantics/tools/*
$ export PATH=$PATH:~/java-semantics/tools
$ cd java-semantics/semantics
$ kompile java
```

Now you can execute programs bundled with the semantics:

```
$ kjrun.sh ../programs/01_smoke_tests/helloWorld.java
```

Now you can test the execution of multiple programs at once using bundled tool kjtest.
(Make sure you run a program with kjrun.sh first, it needs to perform some initializations.)

```
$ kjtest.sh --t1 ../programs/01_smoke_tests/
```

This tool executes each program in the given directory with both Java Semantics and JDK and compares the results. Testing result is summarized in test-results.xml.
