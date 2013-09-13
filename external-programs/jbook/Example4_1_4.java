interface I {
   int m(int i);
}

class B {
   public int m(int i) {
    return i * i;
   }
}

public class Example4_1_4 extends B implements I {
  public static void main(String args[]) {
    Example4_1_4 a = new Example4_1_4();
    System.out.println(a.m(2));
  }
}
