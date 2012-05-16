class main {

  main(String[] args) {
    int e;
    try { int x = 2; System.out.print(x+" "); throw ( ++x + x ); }
    catch(int e) { System.out.println(e); }
    System.out.println("Done!");
  }
}

public class exceptions07 {
  public static void main(String[] args) {
    new main(args);
  }
}

// 2 6
// Done!
