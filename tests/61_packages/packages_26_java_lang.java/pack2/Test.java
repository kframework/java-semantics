package pack2;

public class Test {
  public void test() {
    System.out.println("From pack2.Test:");
    System.out.println("Object: "+new Object().getClass().getName());
    System.out.println("RuntimeException: "+new RuntimeException().getClass().getName());
    System.out.println("java.lang.Object: "+new java.lang.Object().getClass().getName());
    System.out.println("java.lang.RuntimeException: "
      + new java.lang.RuntimeException().getClass().getName());
    System.out.println("pack.Object: "+new pack.Object().getClass().getName());
    System.out.println("pack.RuntimeException: "+new pack.RuntimeException().getClass().getName());
  }
}
