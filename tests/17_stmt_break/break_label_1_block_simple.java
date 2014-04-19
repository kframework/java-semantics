// Simple test with labeled break

public class break_label_1_block_simple {
  public static void main(String[] args) {
    label_1: {
      System.out.println("Before break");
      if (true) break label_1;
      System.out.print("unreachable");
    }
    System.out.println("Done!");
  }
}
// Before break
// Done!
