class A {
  public static int  i = 2;
  private static int j = 3;
}

public class B extends A {
  public static int i = 4;
  public static void main(String args[]) {
    int k = j;
    System.out.println(k);
  }
}
