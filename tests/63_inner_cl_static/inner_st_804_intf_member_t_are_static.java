/*
Member types of an interface are static.
  Types I1, I1.Inner. Inner is declared without static modifier.
  Members:
    Inner.f()
  Instantiate Inner and call f() from main.
*/

public class inner_st_804_intf_member_t_are_static {

  public static void main(String[] args) {
    System.out.println(new I1.Inner().f());

    System.out.println("Done!");
  }
}

interface I1 {

  class Inner {
    String f() {
      return "I1.Inner.f()";
    }
  }
}

