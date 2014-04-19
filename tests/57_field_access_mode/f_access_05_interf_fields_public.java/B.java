/*
Interface fields are public.
  B < (A{protected v}, I{v})
*/
package a;

interface I {
  String v = "I.v";
}

class A {
  protected static String v = "A.v";
}

public class B extends A implements I {}
