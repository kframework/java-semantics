/*
Qualified new instance creation execution order. Call a qualified constructor with
  three arguments. qualifier and all three arguments should be traced.
*/

public class inner_in_62_qual_constr_order {
  public static void main(String[] args) {
    ((O) Tracer.trace(new O(10))).new A((String)Tracer.trace("aa"), (String)Tracer.trace("bb"), (String)Tracer.trace("cc"));
    System.out.println("Done!");
  }
}

class O {

  int v = 1;

  O(int v) {
    this.v = v;
    System.out.println("O.O()");
  }

  public String toString() { return "O[v=" + v + "]";}

  class A {
    String a,b,c;

    A(String a, String b, String c) {
      System.out.println("O.A.A(): a = " + a + ", b = " + b + ", c = " + c);
    }
  }
}

class Tracer {
  static Object trace(Object o) {
    System.out.println("trace: " + o);
    return o;
  }
}
