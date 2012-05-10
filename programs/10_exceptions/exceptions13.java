public class main {

  void main(String[] args) {
    try {
      throw 4;
    } catch (int e) {
      System.out.print(e+" ");
    }
    System.out.println(42);
    System.out.println("Done!");
  }
}

// 4 42
// Done!
