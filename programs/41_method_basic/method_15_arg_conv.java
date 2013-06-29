/*
Argument conversion.
  Method with four arguments, arguments 2 and 3 needs conversion.
  formal types: int, int, Object, String
  actual method call types:
    - int, short, RuntimeException, String
    - int, int, null, null
*/

public class method_15_arg_conv {

  public static void main(String[] args) {
    new test();
    System.out.println("Done!");
  }
}

class test {
  test() {
    f(12, (short)100000, new RuntimeException("re"), "sss");
    f(12, 13, null, null);
  }

  void f(int a, int b, Object o, String s) {
    System.out.println(a + " " + b + " " + o + " " + s);
  }
}
