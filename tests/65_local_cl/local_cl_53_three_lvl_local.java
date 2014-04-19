/*
Three-level local nesting. Local class LA extending I1Factory. Inside it, local class ILB extending I1.
  Access final local vars from ILB.f(), LA.createI1() and O.createILB() by simple name.
*/

public class local_cl_53_three_lvl_local {
  public static void main(String[] args) {
    I1 i1;
    i1 = new O(1).createILB();
    System.out.println(i1.f());
    i1 = new O(2).createILB();
    System.out.println(i1.f());
    System.out.println("Done!");
  }
}

interface I1 {
  String f();
}

interface I1Factory {
  I1 createI1();
}

class O {

  int param;

  O(int param) {
    this.param = param;
  }

  I1 createILB() {

    final String ov = "O.ov"+ "[" + param + "]";

    class LA implements I1Factory {

      public I1 createI1() {

        final String lav = "LA.lav";

        class ILB implements I1 {

          public String f() {
            String ilbv = "ILB.ilbv";

            return "ILB.f()[param=" + param + ", ov="+ov +", lav = "+ lav + ", ilbv = "+ ilbv +"]";
          }
        }

        return new ILB();
      }

    }

    return new LA().createI1();
  }
}
