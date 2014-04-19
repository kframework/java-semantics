/*
25. Multiple arguments, multiple argument number types:
  - f(long), f(int, long), f(long, int)
  - call types: int, long, (int, long), (long, int)
*/

public class overload_25_multi_arg {

  public static void main(String[] args) {
    new main();
    System.out.println("Done!");
  }
}

class A {}
class B extends A {}

class main {
  main() {
    f(0);
    f(0L);
    f(0,0L);
    f(0L,0);
  }

  void f(long a) {
    System.out.println("f(long)");
  }

  void f(int a, long b) {
    System.out.println("f(int, long)");
  }

  void f(long a, int b) {
    System.out.println("f(long, int)");
  }
}
