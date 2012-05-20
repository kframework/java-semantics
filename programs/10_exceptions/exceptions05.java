class main {

  int x;

  int f(int y) {
    int t = 1;
    try{
      System.out.print(t+" ");
      if (true) throw new RuntimeException("a");
      System.out.print(8);      // not reachable
    } catch(RuntimeException p) {
      System.out.print(p.toString() + "10 ");
    }
    for (int i = 1; i<=y; ++i)
      t = t*i;
    return t;
  }

  main(String[] args) {
    x = 5;
    System.out.println(f(x));
    System.out.println("Done!");
  }
}

public class exceptions05 {
  public static void main(String[] args) {
    new main(args);
  }
}

// 1 15 120
// Done!
