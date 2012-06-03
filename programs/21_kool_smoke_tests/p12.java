class main {
  int factorial(int x) {
    if (x <= 1)
      return 1;
    else
      return(x * (factorial(x - 1)));
  }

  main(String[] args) {
    System.out.println(factorial(factorial(4)));
    System.out.println("Done!");
  }
}

public class p12 {
  public static void main(String[] args) {
    new main(args);
  }
}
