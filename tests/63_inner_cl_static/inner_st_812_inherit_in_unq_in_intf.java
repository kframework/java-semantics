/*
Accessing inherited inner interfaces by simple name, inside an interface.
  interfaces IA, IA.IInner1, IA.IInner2, IB < IA.
  Members:
    - IInner1.id
    - IInner2.id
  Access:
    - IInner1.id from IB
    - IInner2.id from IB
*/

public class inner_st_812_inherit_in_unq_in_intf {

  public static void main(String[] args) {
    System.out.println(IB.id);

    System.out.println("Done!");
  }
}

interface IA {

  interface IInner1 {
    String id = "IA.IInner1.id";
  }

  interface IInner2 {
    String id = "IA.IInner2.id";
  }
}

interface IB extends IA {
  String id = "IB.id: IInner1.id = " + IInner1.id + ", IInner2.id = " + IInner2.id;
}
