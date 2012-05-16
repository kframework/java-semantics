// Testing new, constructor, method invocation.

class C {
  int i, j;

  void C(int x) {
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

class main {
  int a, b;
  C o;

  main(String[] args){
    a = b = 5;
    o = new C(a);
    o.print2();
    o.add(++b);
    o.print2();
    System.out.println("Done!");
  }
}

public class constructor {
  public static void main(String[] args) {
    new main(args);
  }
}

// 5 6
// 11 0
// Done!
