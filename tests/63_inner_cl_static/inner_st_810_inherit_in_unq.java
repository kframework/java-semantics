/*
Accessing inherited inner interfaces by simple name.
  Interfaces IA, IA.IInner1, IA.IInner2, class B < IA.
  Members:
    - IInner1.id
    - IInner2.id
  Access:
    - IInner1.id from B
    - IInner2.id from B
*/

public class inner_st_810_inherit_in_unq {

  public static void main(String[] args) {
    System.out.println(new B());

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

class B implements IA {
  public String toString() {
    return "B: IInner1.id = " + IInner1.id + ", IInner2.id = " + IInner2.id;
  }
}
