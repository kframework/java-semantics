public class main {

  void main(String[] args) {
    int e;
    try { int x = 2; System.out.print(x+" "); throw ( ++x + x ); }
    catch(int e) { System.out.println(e); }
    System.out.println("Done!");
  }
}

// 2 6
// Done!
