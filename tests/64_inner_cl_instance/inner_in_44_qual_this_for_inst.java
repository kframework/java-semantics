/*
Various qualifiers to instantiate inner classes.
  Classes O3 < O2 < O1, O3.C < A. Of them, classes O3, O1, C, A all have the inner class Inner.
  Instantiate Inner from C, using qualifiers:
  - <no qualifier>
  - this
  - O3.this
  We cannot use super or O3.super as qualifier, because super is not a Primary expression, and cannot be used
  as qualifiers for new instance creation.
*/

public class inner_in_44_qual_this_for_inst {
  public static void main(String[] args) {
    new O3().new C().test();
    System.out.println("Done!");
  }
}

class O1 {
  class Inner {
    public String toString() {return "O1.Inner";}
  }
}

class O2 extends O1 {}

class A {
  class Inner {
    public String toString() {return "A.Inner";}
  }
}

class O3 extends O2 {

  class Inner {
    public String toString() {return "O3.Inner";}
  }

  class C extends A {

    class Inner {
      public String toString() {return "O3.C.Inner";}
    }

    void test() {
      System.out.println("O3.C: new Inner()           = " + new Inner());
      System.out.println("O3.C: this.new Inner()      = " + this.new Inner());
      System.out.println("O3.C: O3.this.new Inner()   = " + O3.this.new Inner());
    }
  }
}
