.class public java/lang/System
.super java/lang/Object 

.field public static out Ljava/io/PrintStream;

.method public <init>()V
    .limit stack 1
    .limit locals 1
    aload_0
    invokespecial java/lang/Object/<init>()V
    return
.end method

.method static <clinit>()V
    .limit stack 2
    .limit locals 0
    new java/io/PrintStream
    dup
    invokespecial java/io/PrintStream/<init>()V
    putstatic java/lang/System/out Ljava/io/PrintStream;
    return
.end method
