// Program testing Collatz' conjecture up to a user-provided number.

// Experiment: change the return type of the collatz function below to "int".
// Then the typed static SIMPLE will type-check it, but the typed
// dynamic SIMPLE will get stuck.  The former is allowed to work because
// we want to allow flexibility to implementations to provide return
// default values to functions (like C does), but at the same time we
// do not want to enforce any particular such value, which is why the
// latter gets stuck.

import java.util.*;

class main {
  void collatz(int n) {
    int s=0;
    System.out.print("Testing Collatz' conjecture for n = " + n + " ... ");
    while (n > 1) {
      s = s+1;
      if (n == (n/2)*2)
        n = n/2;
      else
        n = 3*n+1;
    }
    System.out.println("Done! It took "+s+" steps.");
  }

  main(String[] args) {
    System.out.print("Testing Collatz' conjecture up to what number? ");
    int m = new Scanner(System.in).nextInt();
    for (int i = 1; i<=m; ++i)
      collatz(i);
    System.out.println("It appears to hold.");
    System.out.println("Done!");
  }
}

public class collatz {
  public static void main(String[] args) {
    new main(args);
  }
}



