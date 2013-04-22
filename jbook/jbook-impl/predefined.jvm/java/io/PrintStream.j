.class public java/io/PrintStream
.super java/lang/Object

.field public static out Ljava/io/PrintStream;

.method public <init>()V
    .limit stack 1
    .limit locals 1
    aload_0
    invokespecial java/lang/Object/<init>()V
    return
.end method

.method public native print(I)V
.end method

.method public native print(Z)V
.end method

.method public native print(C)V
.end method

.method public native print(J)V
.end method

.method public native print(D)V
.end method

.method public native print(F)V
.end method

.method public native print(Ljava/lang/String;)V
.end method

.method public native println()V
.end method

.method public print(Ljava/lang/Object;)V
   .limit stack 2
   .limit locals 2
   aload_0
   aload_1
   ifnonnull printObject
   ldc "null"
   invokespecial java/io/PrintStream/print(Ljava/lang/String;)V
   return   
printObject:
   aload_1
   invokevirtual java/lang/Object/toString()Ljava/lang/String;
   invokespecial java/io/PrintStream/print(Ljava/lang/String;)V
   return
.end method

.method public println(I)V
   .limit stack 2
   .limit locals 2
   aload_0
   iload_1
   invokevirtual java/io/PrintStream/print(I)V
   aload_0
   invokespecial java/io/PrintStream/println()V
   return
.end method

.method public println(Z)V
   .limit stack 2
   .limit locals 2
   aload_0
   iload_1
   invokevirtual java/io/PrintStream/print(Z)V
   aload_0
   invokespecial java/io/PrintStream/println()V
   return
.end method

.method public println(C)V
   .limit stack 2
   .limit locals 2
   aload_0
   iload_1
   invokevirtual java/io/PrintStream/print(C)V
   aload_0
   invokespecial java/io/PrintStream/println()V
   return
.end method

.method public println(F)V
   .limit stack 2
   .limit locals 2
   aload_0
   fload_1
   invokevirtual java/io/PrintStream/print(F)V
   aload_0
   invokespecial java/io/PrintStream/println()V
   return
.end method

.method public println(D)V
   .limit stack 3
   .limit locals 3
   aload_0
   dload_1
   invokevirtual java/io/PrintStream/print(D)V
   aload_0
   invokespecial java/io/PrintStream/println()V
   return
.end method

.method public println(J)V
   .limit stack 3
   .limit locals 3
   aload_0
   lload_1
   invokevirtual java/io/PrintStream/print(J)V
   aload_0
   invokespecial java/io/PrintStream/println()V
   return
.end method

.method public println(Ljava/lang/String;)V
   .limit stack 2
   .limit locals 2
   aload_0
   aload_1
   invokespecial java/io/PrintStream/print(Ljava/lang/String;)V
   aload_0
   invokespecial java/io/PrintStream/println()V
   return
.end method

.method public println(Ljava/lang/Object;)V
   .limit stack 2
   .limit locals 2
   aload_0
   aload_1
   invokespecial java/io/PrintStream/print(Ljava/lang/Object;)V
   aload_0
   invokespecial java/io/PrintStream/println()V
   return
.end method

