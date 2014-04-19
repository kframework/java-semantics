/*
Three-level local nesting. Local class LA extending I1Factory. Inside it, local class ILB extending I1.
  Inside O.createILB(): local vars a,b,c. Inside LA.createI1(): local vars a,b. Inside ILB.f()
  - local var a. Print a,b,c from ILB.f().
*/

public class local_cl_54_three_lvl_local_hiding {
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

    final String a = "O.a"+ "[" + param + "]";
    final String b = "O.b"+ "[" + param + "]";
    final String c = "O.c"+ "[" + param + "]";

    class LA implements I1Factory {

      public I1 createI1() {

        final String a = "LA.a";
        final String b = "LA.b";

        class ILB implements I1 {

          public String f() {
            final String a = "ILB.a";

            return "ILB.f()[a="+a +", b = "+ b + ", c = "+ c +"]";
          }
        }

        return new ILB();
      }

    }

    return new LA().createI1();
  }
}
