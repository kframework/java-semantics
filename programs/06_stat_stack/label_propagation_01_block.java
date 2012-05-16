// break label -> simple doWhile -> matched labeled block.

public class label_propagation_01_block {

  public static void main(String[] args) {
    label_1: {
      do {
        System.out.println("Inside doWhile");
        break label_1;
        System.out.print("unreachable 1");
      } while(true);
      System.out.print("unreachable 2");
    }
    System.out.println("Done!");
  }
}

// Inside doWhile
// Done!
