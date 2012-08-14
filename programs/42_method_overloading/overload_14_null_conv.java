/*
14. Distinct arguments number, conversion from null.
  - f(Object), f(Object, Object)
  Call types: (null), (null, String)
  Call all arguments requiring conversion.
*/

public class overload_14_null_conv {

  public static void main(String[] args) {
    new main();
    System.out.println("Done!");
  }
}

class main {
  main() {
    f(null);
    f(null, "def");
  }

  void f(Object a) {
    System.out.println(a);
  }

  void f(Object a, Object b) {
    System.out.println(a+" "+b);
  }
}
