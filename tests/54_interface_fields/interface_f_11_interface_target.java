/*
Access to an interface field. Through the defining interface.
    Possible expressions: Interface qualifier, interface ref qualifier.
*/

public class interface_f_11_interface_target {
  public static void main(String[] args) {
    System.out.println(I1.v + " " + ((I1) new A()).v);
    System.out.println("Done!");
  }
}

interface I1 {
  int v = 12;
}

class A implements I1 {
}
