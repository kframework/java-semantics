// break label -> simple doWhile -> matched labeled for.

public class label_propagation_03_for {

  public static void main(String[] args) {
    boolean cond = true;//needed to avoid unreachable statement compile error.
    label_1:
    for(;;) {
      do {
        System.out.println("Inside doWhile");
        if(true) break label_1;
        System.out.print("unreachable 1");
      } while(cond);
      System.out.print("unreachable 2");
    }
    System.out.println("Done!");
  }
}

// Inside doWhile
// Done!
