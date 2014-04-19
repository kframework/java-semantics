/*
Fields with initializer, initializer exps refer to fields declared below. Default values exposed.
*/

interface I1 {
  int a = I1.b;
  int b = a + 10;
  int c = b;
}

public class interface_f_73_init_forward_ref {
  public static void main(String[] args) {
    System.out.println("" + I1.a + " " + I1.b + " " + I1.c);
    System.out.println("Done!");
  }
}
