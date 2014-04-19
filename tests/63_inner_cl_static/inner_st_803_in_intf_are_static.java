/*
Inner interfaces are always static.
  Types C, C.IInner, Impl < C.IInner.
  IInner is declared without static modifier.
  Members:
    - IInner.f()
    - Impl.f()
  Call Impl.f() from main.
*/

public class inner_st_803_in_intf_are_static {

  public static void main(String[] args) {
    System.out.println(((C.IInner)new Impl()).f());

    System.out.println("Done!");
  }
}

class C {

  interface IInner {
    String f();
  }
}

class Impl implements C.IInner {

  public String f() {
    return "Impl.f()";
  }
}
