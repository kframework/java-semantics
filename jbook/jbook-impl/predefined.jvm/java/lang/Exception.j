;; Java and its Virtual Machine
;; R. Staerk, J. Schmid, E. Boerger


.class public java/lang/Exception
.super java/lang/Throwable

.method static <clinit>()V
.limit stack 0
.limit locals 0
   return
   nop
.end method

.method public <init>()V
.limit stack 1
.limit locals 1
   aload 0
   invokespecial java/lang/Throwable/<init>()V
   return
   nop
.end method

.method public <init>(Ljava/lang/String;)V
.limit stack 2
.limit locals 2
   aload 0
   aload 1
   invokespecial java/lang/Throwable/<init>(Ljava/lang/String;)V
   return
   nop
.end method

