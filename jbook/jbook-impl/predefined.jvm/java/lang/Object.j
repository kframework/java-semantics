.class public java/lang/Object

.method public <init>()V
  return
.end method

.method native public equals(Ljava/lang/Object;)Z
.end method

.method native public toString()Ljava/lang/String;
.end method

.method native protected clone()Ljava/lang/Object;
.end method


; fail'("ArithmeticException")
.method static <failArithmeticException>()V
  .limit stack 2
  new java/lang/ArithmeticException
  dup
  invokespecial java/lang/ArithmeticException/<init>()V
  athrow
.end method


; fail'("ClassCastException")
.method static <failClassCastException>()V
  .limit stack 2
  new java/lang/ClassCastException
  dup
  invokespecial java/lang/ClassCastException/<init>()V
  athrow
.end method

; fail'("NullPointerException")
.method static <failNullPointerException>()V
  .limit stack 2
  new java/lang/NullPointerException
  dup
  invokespecial java/lang/NullPointerException/<init>()V
  athrow
.end method

; fail'("NoClassDefFoundError")
.method static <failNoClassDefFoundError>()V
  .limit stack 2
  new java/lang/NoClassDefFoundError
  dup
  invokespecial java/lang/NoClassDefFoundError/<init>()V
  athrow
.end method

; fail'("ClassNotFoundException")
.method static <failClassNotFoundException>()V
  .limit stack 2
  new java/lang/ClassNotFoundException
  dup
  invokespecial java/lang/ClassNotFoundException/<init>()V
  athrow
.end method

; fail'("ClassNotFoundException")
.method static <failClassNotFoundException>(Ljava/lang/String;)V
  .limit stack 3
  .limit locals 1
  new java/lang/ClassNotFoundException
  dup
  aload_0
  invokespecial java/lang/ClassNotFoundException/<init>(Ljava/lang/String;)V
  athrow
.end method

; fail'("ClassFormatError")
.method static <failClassFormatError>()V
  .limit stack 2
  new java/lang/ClassFormatError
  dup
  invokespecial java/lang/ClassFormatError/<init>()V
  athrow
.end method

; fail'("ExceptionInInitializerError")
.method static <failExceptionInInitializerError>()V
  .limit stack 2
  new java/lang/ExceptionInInitializerError
  dup
  invokespecial java/lang/ExceptionInInitializerError/<init>()V
  athrow
.end method

; fail'("NegativeArraySizeException")
.method static <failNegativeArraySizeException>()V
  .limit stack 2
  new java/lang/NegativeArraySizeException
  dup
  invokespecial java/lang/NegativeArraySizeException/<init>()V
  athrow
.end method

; fail'("ArrayIndexOutOfBoundsException")
.method static <failArrayIndexOutOfBoundsException>()V
  .limit stack 2
  new java/lang/ArrayIndexOutOfBoundsException
  dup
  invokespecial java/lang/ArrayIndexOutOfBoundsException/<init>()V
  athrow
.end method

; fail'("ArrayStoreException")
.method static <failArrayStoreException>()V
  .limit stack 2
  new java/lang/ArrayStoreException
  dup
  invokespecial java/lang/ArrayStoreException/<init>()V
  athrow
.end method

; fail'("AbstractMethodError")
.method static <failAbstractMethodError>()V
  .limit stack 2
  new java/lang/AbstractMethodError
  dup
  invokespecial java/lang/AbstractMethodError/<init>()V
  athrow
.end method

; fail'("CloneNotSupportedException")
.method static <failCloneNotSupportedException>()V
  .limit stack 2
  new java/lang/CloneNotSupportedException
  dup
  invokespecial java/lang/CloneNotSupportedException/<init>()V
  athrow
.end method

