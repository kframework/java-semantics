//Exception var hiding local vars with the same name

class main {

  int b = 10;

  main() {
    int i = 0;
    while (i < 2) {
      System.out.println("i = " + i);
      i++;
      try {
        int b = 2;
        System.out.println("try: b = " + b);
        continue;
      } finally {
        System.out.println("finally: b = " + b);
      }
    }
  }
}

public class continue_11_block_env_restore {
  public static void main(String[] args) {
    new main();
    System.out.println("Done!");
  }
}
