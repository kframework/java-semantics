public class testError {

  public static void main(String[] args) {
    int i = 10;
    int j = 15;
    switch(i) {
    //Here java semantics will work, but JDK will give compile-time error
      case j: System.out.println("case j!");
    }
    System.out.println("Hello World!");
    System.out.println("Done!");
  }
}
