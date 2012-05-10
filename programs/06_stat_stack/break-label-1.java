// Simple test with labeled break

public class main {
  void main(String[] args) {
    label_1: {
      System.out.println("Before break");
      break label_1;
      System.out.print("unreachable");
    }
    System.out.println("Done!");
  }
}
// Before break
// Done!
