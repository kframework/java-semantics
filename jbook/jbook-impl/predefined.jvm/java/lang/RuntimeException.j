;>> RuntimeException.class <<
;
; Output created by D-Java (May 20 1997)
; mailto:umsilve1@cc.umanitoba.ca
; Copyright (c) 1996-1997 Shawn Silverman
;

;Classfile version:
;    Major: 45
;    Minor: 3

.source Throwable1.java
.class  public java/lang/RuntimeException
; ACC_SUPER bit is set
.super  java/lang/Exception

.field static inRuntimeException I

; >> METHOD 1 <<
.method public <init>(Ljava/lang/String;)V
    .limit stack 2
    .limit locals 2
.line 10
    aload_0
    aload_1
    invokespecial java/lang/Exception/<init>(Ljava/lang/String;)V
    return
.end method

; >> METHOD 1 <<
.method public <init>()V
    .limit stack 1
    .limit locals 1
.line 10
    aload_0
    invokespecial java/lang/Exception/<init>()V
    return
.end method

; >> METHOD 2 <<
.method static <clinit>()V
    .limit stack 1
    .limit locals 0
.line 11
.line 10
    return
.end method
