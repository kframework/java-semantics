interface I {
   int m(int i);
}

class B {
   public int m(int i) {
    return i * i;
   }
}

public class A extends B implements I {
  static void main(String args[]) {
    A a = new A();
    System.out.println(a.m(2));
  }
}
