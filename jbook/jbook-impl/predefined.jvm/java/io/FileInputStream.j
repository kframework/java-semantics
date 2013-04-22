.class public java/io/FileInputStream
.super java/io/InputStream

.field private filename Ljava/lang/String;

.method public <init>(Ljava/lang/String;)V
    .limit stack 2
    .limit locals 2
    aload_0
    invokespecial java/io/InputStream/<init>()V
    aload_0
    aload_1
    putfield java/io/FileInputStream.filename Ljava/lang/String;
    return
.end method

.method public available()I
   .limit locals 1
   .limit stack 1
   ldc 0
   ireturn
.end method

.method public read([B)I
   .limit stack 4
   .limit locals 2
   aload_0
   aload_1
   invokespecial java/io/FileInputStream/readFile([B)Z
   ifeq notFound
   ldc 1
   ireturn
notFound:
   new java/io/IOException
   dup
   invokespecial java/io/IOException/<init>()V
   athrow
.end method

.method private native readFile([B)Z
.end method
