/*
Inner interfaces in implements clause, by simple name, inherited.
  Interfaces IA, IA.IInner1, IA.IInner2, class B < IA,
  interfaces B.InnerB < IInner1, IInner2 (by simple name).
  Members:
    - IInner1.x
    - IInner2.y
  Access:
    - x, y from IInnerB.toString()
*/

public class inner_st_811_inherit_in_unq_in_impl {

  public static void main(String[] args) {
    System.out.println(new B.InnerB());

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

class B implements IA {

  static class InnerB implements IInner1, IInner2 {
    public String toString() {
      return "B.InnerB: x = " + x + ", y = " + y;
    }
  }
}
