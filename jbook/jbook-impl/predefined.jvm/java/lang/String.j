.class public java/lang/String
.super java/lang/Object
.implements java/lang/Comparable

.field value Ljava/lang/String;

.method public equals(Ljava/lang/Object;)Z
  .limit stack 2
  .limit locals 2
  aload_0
  aload_1
  invokespecial java/lang/Object/equals(Ljava/lang/Object;)Z
  ireturn
.end method

.method public static native valueOf(I)Ljava/lang/String;
.end method

.method public static native valueOf(Ljava/lang/Object;)Ljava/lang/String;
.end method

.method public native startsWith(Ljava/lang/String;)Z
.end method

.method public <init>()V
    .limit stack 1
    .limit locals 1
    aload_0
    invokespecial java/lang/Object/<init>()V
    return
.end method

.method public <init>(Ljava/lang/String;)V
    .limit stack 2
    .limit locals 2
    aload_0
    invokespecial java/lang/Object/<init>()V
    aload_0
    aload_1
    putfield java/lang/String/value Ljava/lang/String;
    return
.end method

.method public toString()Ljava/lang/String;
    .limit stack 1
    .limit locals 1
    aload_0
    getfield java/lang/String/value Ljava/lang/String;
    areturn
.end method


.method public native length()I
.end method

.method public native concat(Ljava/lang/String;)Ljava/lang/String;
.end method

.method public compareTo(Ljava/lang/Object;)I
.limit stack 1
.limit locals 1
    ldc 0
    ireturn
.end method
