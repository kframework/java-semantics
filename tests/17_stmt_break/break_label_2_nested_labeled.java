// Test with two labels, one labeled break.
public class break_label_2_nested_labeled {
  public static void main(String[] args) {
    label_1: {
      label_2: {
        System.out.println("Before break");
        if (true) break label_1;
        System.out.print("unreachable");
      }
      System.out.print("unreachable 2");
    }
    System.out.println("Done!");
  }
}
// Before break
// Done!
