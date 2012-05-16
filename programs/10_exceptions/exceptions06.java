class main {

  int x;

  int f(int y) {
    int t = 1;
    try {
      System.out.print(t+" ");
      System.out.print(8+" ");
    } catch(int p) {
      System.out.print(p+10);  // not reachable
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

public class exceptions06 {
  public static void main(String[] args) {
    new main(args);
  }
}

// 1 8 120
// Done!
