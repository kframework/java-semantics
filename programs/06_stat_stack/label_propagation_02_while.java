// break label -> simple doWhile -> matched labeled while.

public class label_propagation_02_while {

  public static void main(String[] args) {
    label_1:
    while(true) {
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
