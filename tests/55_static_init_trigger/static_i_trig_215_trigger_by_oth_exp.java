/*
Interface init triggered by 5 different expressions.
  Test < A < I0{a}, I1{b}, I2{c}, I3{d}, I4{e}, I5{f}.
  Triggering expressions:
  - b,
  - this.c,
  - super.d,
  - ((I4)this).e
  - (new Test()).f
  All expressions in instance context. All initializers are traced. I0 init is not triggered.
*/

public class static_i_trig_215_trigger_by_oth_exp {
  public static void main(String[] args) {
    new Test().test();
    System.out.println("Done!");
  }
}

interface I0 {
  String a = T.trace("I0.a");
}

interface I1 {
  String b = T.trace("I1.b");
}

interface I2 {
  String c = T.trace("I2.c");
}

interface I3 {
  String d = T.trace("I3.d");
}

interface I4 {
  String e = T.trace("I4.e");
}

interface I5 {
  String f = T.trace("I5.f");
}

class A implements I3 {}

class Test extends A implements I0, I1, I2, I3, I4, I5 {
  static {
    T.trace("A.(static init)");
  }

  void test() {
    System.out.println("b              = " + b);
    System.out.println("this.c         = " + this.c);
    System.out.println("super.d        = " + super.d);
    System.out.println("((I4)this).e   = " + ((I4)this).e);
    System.out.println("(new Test()).f = " + (new Test()).f);
  }
}

class T {
  static String trace(String s) {
    System.out.println("trace(" + s + ")");
    return s;
  }
}
