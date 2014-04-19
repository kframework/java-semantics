/*
Inner interface implements an outer interface.
  interfaces I1, I1.IInner < I1, C < I1.IInner
    - I1.f()
    - I1.IInner.g()
  Call both on (I1.IInner)C from main.
*/

public class inner_st_805_in_intf_impl_out_intf {

  public static void main(String[] args) {
    I1.IInner in = new C();
    System.out.println(in.f() + " " + in.g());

    System.out.println("Done!");
  }
}

interface I1 {

  String f();

  static interface IInner extends I1 {
    String g();
  }
}

class C implements I1.IInner {
  public String f() {
    return "C.f()";
  }

  public String g() {
    return "C.g()";
  }
}
