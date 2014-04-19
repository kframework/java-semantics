/*
Classes S, O, O.A < S. Access members of S, O, A from A.
*/

public class inner_in_301_inner_is_derived {
  public static void main(String[] args) {
    new O().new A().test();
    System.out.println("Done!");
  }
}

class S {
    int sv = 1;
    String sf() {return "sf()";}
}

class O {

    int ov = 2;
    String of() {return "of()";}

  class A extends S {
    int av = 20;
    String af() {return "af()";}

    void test() {
      System.out.println("O.A: av   = " + av);
      System.out.println("O.A: af() = " + af());
      System.out.println("O.A: ov   = " + ov);
      System.out.println("O.A: of() = " + of());
      System.out.println("O.A: sv   = " + sv);
      System.out.println("O.A: sf() = " + sf());
    }
  }
}
