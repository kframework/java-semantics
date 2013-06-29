/*
Overriding. Test that an unqualified call to an overridden method
  calls the method from the actual object type.
*/

class c1 {
  int m1() { return 1; }
  int m2() { return 100; }
  int m3() { return m2(); }
}

class c2 extends c1 {
  int m2() { return 2; }
}

public class method_32_overriding_2 {
  public static void main(String[] args) {
    c1 o1 = new c1();
    c2 o2 = new c2();
    System.out.println(""+o1.m1()+ o1.m2()+ o1.m3()+ o2.m1()+ o2.m2()+ o2.m3());
    System.out.println("Done!");
  }
}
