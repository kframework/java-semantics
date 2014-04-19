/*
Simple inner class. Classes A, A.B. Instantiate and toString() both from main().
*/

public class inner_st_101_simple {

  public static void main(String[] args) {
    System.out.println(new A());
    System.out.println(new A.B());
    System.out.println("Done!");
  }
}

class A {

  public String toString() {
    return "A";
  }

  public static class B {
    public String toString() {
      return "A.B";
    }
  }
}
