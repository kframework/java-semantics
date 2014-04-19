/*
Basic testing of new, constructor, method invocation.
  Constructor uses arguments to initialize fields.
*/

class C {
  int i, j;

  C(int x) {
    i = x;
    j = ++x;
  }

  void add(int d) {
    i = i+d;
    j = j-d;
  }

  void print2() {
    System.out.println(i+ " "+ j);
  }
}

public class constr_50_basic {
  public static void main(String[] args) {
    int a, b;
    C o;
    a = b = 5;
    o = new C(a);
    o.print2();
    o.add(++b);
    o.print2();
    System.out.println("Done!");
  }
}

// 5 6
// 11 0
// Done!
