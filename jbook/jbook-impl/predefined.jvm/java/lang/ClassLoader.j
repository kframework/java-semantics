.class public java/lang/ClassLoader
.super java/lang/Object

.method public <init>()V
    .limit stack 1
    .limit locals 0
    aload_0
    invokespecial java/lang/Object/<init>()V
    return
.end method

.method public <cload>(Ljava/lang/String;)Ljava/lang/Class;
    .limit stack 3
    .limit locals 2
    aload_0
    aload_1
    invokevirtual java/lang/ClassLoader/loadClass(Ljava/lang/String;)Ljava/lang/Class;
    areturn
.end method

.method public static native getSystemClassLoader()Ljava/lang/ClassLoader;
.end method

.method public native findLoadedClass(Ljava/lang/String;)Ljava/lang/Class;
.end method

.method public native findSystemClass(Ljava/lang/String;)Ljava/lang/Class;
.end method

.method public native resolveClass(Ljava/lang/Class;)V
.end method

.method public native defineClass(Ljava/lang/String;[BII)Ljava/lang/Class;
.end method

.method public loadClass(Ljava/lang/String;)Ljava/lang/Class;
    .limit stack 2
    .limit locals 1
    aload_0    ; load this
    aload_1    ; load classname
    invokespecial java/lang/ClassLoader/findSystemClass(Ljava/lang/String;)Ljava/lang/Class;
    areturn
.end method
