public class main {

  void main(String[] args) {
    try {
      1;
      try {
        2;
      } catch(int a) {
        System.out.print(2);     // should not print this
      }
      throw 1;
    } catch(int b) {
      System.out.println(1);  // should print this
    }
    System.out.println("Done!");
  }
}

// 1
// Done!
