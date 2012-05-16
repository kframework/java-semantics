class main {
  main(String[] args) {
    int x = 1;
    try { int x = 5; throw x; int y = x/0;}   // division by zero unreachable
    catch(int y) {y = y + 2; System.out.print(y+" ");}   // new y here, the one declared by catch
    System.out.println(x);
    System.out.println("Done!");
  }
}

public class exceptions04 {
  public static void main(String[] args) {
    new main(args);
  }
}

// 7 1
// Done!
