/*
Fields with initializer, some initializer exps refer to fields declared above.
*/

interface I1 {
  int a = 3;
  int b = a + 10;
  int c = I1.a + 100;
}

public class interface_f_72_init_backward_ref {
  public static void main(String[] args) {
    System.out.println("" + I1.a + " " + I1.b + " " + I1.c);
    System.out.println("Done!");
  }
}
