//Exception var hiding local vars with the same name

class main {

  int b = 10;

  main() {
    try {
      int b = 2;
      System.out.println("try: b = " + b);
      return;
    } finally {
      System.out.println("finally: b = " + b);
    }
  }
}

public class return_20_block_env_restore {
  public static void main(String[] args) {
    new main();
    System.out.println("Done!");
  }
}

