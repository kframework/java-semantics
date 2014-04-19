/*
Type import on demand simple. Class Main, p1.A, p1.B import p1.* from Main. Test simple names A, B.
*/

import p1.*;

public class packages_41_multi_t_imp_simple {
  public static void main(String[] args) {
    System.out.println(new A());
    System.out.println(new B());
    System.out.println("Done!");
  }
}
