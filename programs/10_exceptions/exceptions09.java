class main {

  int i, j;
  String s;

  main(String[] args) {
    i = 0;
    while (++i <= 3) {
      System.out.print(i+" ");
    }
    try {
      if (true) throw new RuntimeException(s="a");
      i = 10;
      System.out.print(i);   // should not print this
    } catch(RuntimeException j) {
      i = 20;
      System.out.print(i+" ");   // should print this
    }
    i = 15;
    System.out.println(i);
    System.out.println("Done!");
  }
}

public class exceptions09 {
  public static void main(String[] args) {
    new main(args);
  }
}

// 1 2 3 20 15
// Done!
