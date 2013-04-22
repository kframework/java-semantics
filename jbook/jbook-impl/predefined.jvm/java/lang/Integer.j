.class public java/lang/Integer
.super java/lang/Number
.implements java/lang/Comparable

.field private i I

.method public <init>()V
.limit stack 1
.limit locals 1
	aload_0
	invokespecial java/lang/Number/<init>()V
	return
.end method

.method public <init>(I)V
.limit stack 2
.limit locals 2
        aload_0
        invokespecial java/lang/Number/<init>()V
        aload_0
        iload_1
        putfield java/lang/Integer/i I
        return
.end method

.method public toString()Ljava/lang/String;
.limit stack 1
.limit locals 1
   aload_0
   getfield java/lang/Integer/i I
   invokestatic java/lang/String/valueOf(I)Ljava/lang/String;
   areturn
.end method


.method public compareTo(Ljava/lang/Object;)I
.limit stack 1
.limit locals 1
    ldc 0
    ireturn
.end method
