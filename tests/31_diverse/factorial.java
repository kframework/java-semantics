import java.util.*;

class main {
  int factorial(int y) {
    if (y == 1) {
      return 1;
    } else {
      return y*factorial(y-1);
    }
  }

  main(String[] args) {
    System.out.print("Input a natural numer: ");
    int n = new Scanner(System.in).nextInt();
    System.out.println("Factorial of "+n+" is: "+factorial(n));
    System.out.println("Done!");
  }
}

public class factorial {
  public static void main(String[] args) {
    new main(args);
  }
}

