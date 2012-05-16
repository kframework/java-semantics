class main {
  main(String[] args) {
    int x = 1;
    try { x = x + 1; throw x; x = x/0;}     // division by zero unreachable
    catch(int y) {x = y+1;}
    System.out.println(x);
    System.out.println("Done!");
  }
}

public class exceptions03 {
  public static void main(String[] args) {
    new main(args);
  }
}

// 3
// Done!
