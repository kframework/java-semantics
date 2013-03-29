//Exception var hiding local vars with the same name

class main {

  int b = 10;

  main() {
    try {
      int b = 1;
      try {
        b = 2;
      } catch(RuntimeException a) {
        System.out.print(2);     // should not print this
      }
      System.out.println(b);
      throw new RuntimeException();
    } catch(RuntimeException b) {
      System.out.println(b.toString());  // should print this
    }
    System.out.println(b);
    System.out.println("Done!");
  }
}

public class throw_15_catch_env_restore {
  public static void main(String[] args) {
    new main();
  }
}

