// Example 51 from page 39 of Java Precisely edition 1 (The MIT Press 2002)
// Author: Peter Sestoft (sestoft@dina.kvl.dk)


class C1 {
  static void m1(double d) { System.out.println("11d"); }
  void m1(int i) { System.out.println("11i"); }
  void m2(int i) { System.out.println("12i"); }
}

class C2 extends C1 {
  static void m1(double d) { System.out.println("21d"); }
  void m1(int i) { System.out.println("21i"); }
  void m2(double d) { System.out.println("22d"); }
}

class Example51 {
  public static void main(String[] args) {
    int i = 17;
    double d = 17.0;
    C2 c2 = new C2();                           // Type C2, object class C2
    C1 c1 = c2;                                 // Type C1, object class C1
    c1.m1(i); c2.m1(i); c1.m1(d); c2.m1(d);     // Prints 21i 21i 11d 21d
    c1.m2(i);                                   // Prints 12i
    // c2.m2(i) ;                               // ambiguous, thus illegal
  }
}

