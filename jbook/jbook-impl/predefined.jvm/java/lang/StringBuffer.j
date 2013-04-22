.class public java/lang/StringBuffer
.super java/lang/Object 

.field value Ljava/lang/String;

.method public <init>(Ljava/lang/String;)V
    .limit stack 2
    .limit locals 2
    aload_0
    invokespecial java/lang/Object/<init>()V
    aload_0
    aload_1
    putfield java/lang/StringBuffer/value Ljava/lang/String;
    return
.end method

.method public <init>()V
    .limit stack 2
    .limit locals 1
    aload_0
    invokespecial java/lang/Object/<init>()V
    aload_0
    ldc ""
    putfield java/lang/StringBuffer/value Ljava/lang/String;
    return
.end method


.method native static nappend(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;
.end method

.method public append(I)Ljava/lang/StringBuffer;
    .limit stack 2
    .limit locals 2
    aload_0
    iload_1
    invokestatic java/lang/String/valueOf(I)Ljava/lang/String;
    invokespecial java/lang/StringBuffer/append(Ljava/lang/String;)Ljava/lang/StringBuffer;
    areturn
.end method

.method public append(Ljava/lang/String;)Ljava/lang/StringBuffer;
    .limit stack 3
    .limit locals 2
    aload_0
    dup
    getfield java/lang/StringBuffer/value Ljava/lang/String;
    aload_1
    invokestatic java/lang/StringBuffer/nappend(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;
    putfield java/lang/StringBuffer/value Ljava/lang/String;
    aload_0
    areturn
.end method

.method public append(Ljava/lang/Object;)Ljava/lang/StringBuffer;
    .limit stack 3
    .limit locals 2
    aload_0
    dup
    getfield java/lang/StringBuffer/value Ljava/lang/String;
    aload_1
    invokevirtual java/lang/Object/toString()Ljava/lang/String;
    invokestatic java/lang/StringBuffer/nappend(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;
    putfield java/lang/StringBuffer/value Ljava/lang/String;
    aload_0
    areturn
.end method

.method public toString()Ljava/lang/String;
    .limit stack 1
    .limit locals 1
    aload_0
    getfield java/lang/StringBuffer/value Ljava/lang/String;
    areturn
.end method

.method static <clinit>()V
    .limit stack 0
    .limit locals 0
    return
.end method
