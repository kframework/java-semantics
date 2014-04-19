/*
Inner class declaration access modes.
  Class A. Class A inner classes:
    - private A.Pri
    - package A.Pack
    - protected A.Prot
    - public A.Pub
    - public A.InnerTest
  Tests. Print a static field from the follwing classes.
    - from main:
      - A.Pack
      - A.Prot
      - A.Pub
    - from A:
      - A.Pri
      - A.Pack
      - A.Prot
      - A.Pub
    - from A.InnerTest:
      - A.Pri
      - A.Pack
      - A.Prot
      - A.Pub
*/

public class inner_st_401_inner_dec_acc_modes {

  public static void main(String[] args) {
    test();
    A.test();
    A.InnerTest.test();
    System.out.println("Done!");
  }

  static void test() {
    System.out.println(A.Pack.id + " " + A.Prot.id + " " + A.Pub.id);
  }
}

class A {

  static void test() {
    System.out.println(A.Pri.id + " " + A.Pack.id + " " + A.Prot.id + " " + A.Pub.id);
  }

  private static class Pri {
    static String id = "A.Pri";
  }

  static class Pack {
    static String id = "A.Pack";
  }

  protected static class Prot {
    static String id = "A.Prot";
  }

  public static class Pub {
    static String id = "A.Pub";
  }

  public static class InnerTest {
    static void test() {
      System.out.println(A.Pri.id + " " + A.Pack.id + " " + A.Prot.id + " " + A.Pub.id);
    }
  }
}

