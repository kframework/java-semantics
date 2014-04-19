/*
Package java.lang have the classes Object and RuntimeException. Add a package pack
  with classes Object and RuntimeException. Test both classes unqualified,
  qualified with "java.lang", and qualified
  with "pack." from Main (default package), and from a class Test inside another package pack2.
*/

public class packages_26_java_lang {
  public static void main(String[] args) {
    new Test().test();
    System.out.println();
    new pack2.Test().test();
    System.out.println("Done!");
  }
}

class Test {
  void test() {
    System.out.println("From Main:");
    System.out.println("Object: "+new Object().getClass().getName());
    System.out.println("RuntimeException: "+new RuntimeException().getClass().getName());
    System.out.println("java.lang.Object: "+new java.lang.Object().getClass().getName());
    System.out.println("java.lang.RuntimeException: "
      + new java.lang.RuntimeException().getClass().getName());
    System.out.println("pack.Object: "+new pack.Object().getClass().getName());
    System.out.println("pack.RuntimeException: "+new pack.RuntimeException().getClass().getName());
  }
}
