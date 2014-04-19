/*
Inner interfaces in implements clause, by simple name, inherited, inside an outer interface.
  Interfaces IA, IA.IInner1, IA.IInner2, IB < IA, IB.IInnerB < IInner1, IInner2 (by simple name).

  Members:
    - IInner1.x
    - IInner2.y
  Access:
    - x, y from IInnerB.toString()
*/

public class inner_st_813_inherit_in_unq_in_intf_ext {

  public static void main(String[] args) {
    System.out.println(IB.IInnerB.id);

    System.out.println("Done!");
  }
}

interface IA {

  interface IInner1 {
    String x = "IA.IInner1.x";
  }

  interface IInner2 {
    String y = "IA.IInner2.y";
  }
}

interface IB extends IA {

  interface IInnerB extends IInner1, IInner2 {
    String id = "IB.IInnerB.id: x = " + x + ", y = " + y;
  }
}
