public class main {

  int x;

  void main(String[] args) {
    x = 5;
    try {
      throw 3;
      System.out.print(x);       // should not print this
    } catch(int y) {
      System.out.println(y);  // should print this
    }
    System.out.println("Done!");
  }
}

// 3
// Done!
