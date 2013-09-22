// Example 52 from page 39 of Java Precisely edition 1 (The MIT Press 2002)
// Author: Peter Sestoft (sestoft@dina.kvl.dk)


class D1 { 
  D1() { m2(); }
  void m1() { System.out.println("D1.m1 "); }
  void m2() { System.out.print("D1.m2 "); m1(); }
}
  
class D2 extends D1 { 
  int f;
  D2() { f = 7; }
  void m1() { System.out.println("D2.m1:" + f); }
}
  
class Example52 {
  public static void main(String[] args) {
    System.out.println("Executing: D1 d1 = new D1()");
    D1 d1 = new D1();           // Prints D1.m2 D1.m1
    System.out.println("Executing: D1 d2 = new D2()");
    D1 d2 = new D2();           // Prints D1.m2 D2.m1:0
    System.out.println("Executing: d1.m2()");
    d1.m2();                    // Prints D1.m2 D1.m1
    System.out.println("Executing: d2.m2()");
    d2.m2();                    // Prints D1.m2 D2.m1:7
} }


