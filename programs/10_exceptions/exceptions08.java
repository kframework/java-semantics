class main {

  main(String[] args) {
    int e;
    try {
      try {
        try {
          try {
            int x = 1; System.out.print(x+" "); throw ++x;
          } catch(int e) {
            System.out.print(e+" ");
            throw ++e;
          }
        } catch(int e) {
          System.out.print(e+" ");
          throw ++e;
        }
      } catch(int e) {
        System.out.print(e+" ");
        throw ++e;
      }
    } catch(int e) {
      System.out.println(e);
    }
    System.out.println("Done!");
  }
}

public class exceptions08 {
  public static void main(String[] args) {
    new main(args);
  }
}

// 1 2 3 4 5
// Done!
