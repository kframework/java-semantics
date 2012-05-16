class main {
  int f(int x) {
    if (x <= 1) return 1; else return(x * (f(x - 1)));
  }
  main(String[] args) {
    System.out.println(f(f(4)));
    System.out.println("Done!");
  }
}

public class p12 {
  public static void main(String[] args) {
    new main(args);
  }
}
