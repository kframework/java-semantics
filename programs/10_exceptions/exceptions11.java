public class main {

  int i, j;

  void main(String[] args) {
    i = 0;
    while (++i <= 3) {
      System.out.print(i+" ");
    }
    try {
      throw j=1;
      i = 10;
      System.out.print(i);   // should not print this
    } catch(int j) {
      i = 20;
      System.out.print(i+" ");   // should print this
    }
    i = 15;
    System.out.println(i);
    System.out.println("Done!");
  }
}

// 1 2 3 20 15
// Done!
