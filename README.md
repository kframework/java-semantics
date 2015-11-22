## For User: Installation, Compile, Run and Test

In order to use Java Semantics you need the following prerequisites:

- Linux.
- Java 8 or later (K Framework installation might require more updated Java version).
- K Framework (See <http://kframework.org>). The bin directory should be added to PATH. 

Installation process:

```
$ cd ~
$ git clone --depth=1 https://github.com/kframework/java-semantics.git
$ chmod +x java-semantics/tools/*
$ export PATH=$PATH:~/java-semantics/tools
```

Before executing programs, you need to compile java-semantics first:

```
$ cd java-semantics/src
$ kjkompile.sh
```

Now you can execute programs bundled with the semantics:

```
$ kjrun.sh ../tests/01_smoke_tests/helloWorld.java
```

Now you can test the execution of multiple programs at once using bundled tool kjtest.

```
$ kjtest.sh --t1 ../tests/01_smoke_tests/
```

This tool executes each program in the given directory with both Java Semantics and JDK and compares the results.
  Testing result is summarized in test-results.xml.

## For Developer: Kompile and Krun
Instead of using kjkompile.sh and krun.sh, developers want to interact with kompile and krun directly.

Kompile:

```
$ cd java-semantics/src
$ kompile -v --debug -d exec exec/java-exec.k 
$ kompile -v --debug -d prep prep/java-prep.k
```

Krun:
To debug prep semantics:
```
$ krun --directory "/home/java-semantics/src/prep" --parser "kj-parse-aggreg.sh" --symbolic-execution ../tests/01_smoke_tests/helloWorld.java
```

To debug exec semantics (once you have correct pkast file):
```
$ krun --directory "/home/java-semantics/src/exec" -cMainClass="ListItem(\"helloWorld\")" -cDissolveAllExceptOut="true" --parser "cat" --symbolic-execution helloWorld.java.pkast
```

## Other docs
Directory docs contains two technical reports: the complete documented semantics of module METHOD_INVOKE and
  the documentation of the main rule for new instance creation with all the prerequisites.

## POPL 15' : K-Java: A Complete Semantics of Java
http://fsl.cs.illinois.edu/index.php/K-Java:_A_Complete_Semantics_of_Java
