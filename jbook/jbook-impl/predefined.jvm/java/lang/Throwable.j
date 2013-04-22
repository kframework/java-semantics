;; Java and its Virtual Machine
;; R. Staerk, J. Schmid, E. Boerger


.class public java/lang/Throwable
.super java/lang/Object

.field msg Ljava/lang/String;

.method static <clinit>()V
.limit stack 0
.limit locals 0
   return
   nop
.end method

.method public <init>()V
.limit stack 3
.limit locals 1
   aload 0
   invokespecial java/lang/Object/<init>()V
   aload 0
   ldc ""
   dup_x1
   putfield java/lang/Throwable.msg Ljava/lang/String;
   pop
   return
   nop
.end method

.method public <init>(Ljava/lang/String;)V
.limit stack 3
.limit locals 2
   aload 0
   invokespecial java/lang/Object/<init>()V
   aload 0
   ldc ""
   dup_x1
   putfield java/lang/Throwable.msg Ljava/lang/String;
   pop
   aload 0
   aload 1
   dup_x1
   putfield java/lang/Throwable.msg Ljava/lang/String;
   pop
   return
   nop
.end method

.method public toString()Ljava/lang/String;
.limit stack 2
.limit locals 1
   aload 0
   getfield java/lang/Throwable.msg Ljava/lang/String;
   ldc ""
   invokevirtual java/lang/Object/equals(Ljava/lang/Object;)Z
   ifne LabIf1
   aload 0
   invokespecial java/lang/Object/toString()Ljava/lang/String;
   ldc ": "
   invokevirtual java/lang/String/concat(Ljava/lang/String;)Ljava/lang/String;
   aload 0
   getfield java/lang/Throwable.msg Ljava/lang/String;
   invokevirtual java/lang/String/concat(Ljava/lang/String;)Ljava/lang/String;
   areturn
   goto LabIf2
LabIf1:
   aload 0
   invokespecial java/lang/Object/toString()Ljava/lang/String;
   areturn
LabIf2:
   nop
.end method

.method public printStackTrace()V
.limit locals 1
  return  
.end method

