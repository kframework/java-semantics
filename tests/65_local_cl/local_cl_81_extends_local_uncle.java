/*
Class O. Local classes A, Local, in the same block. Inside Local - local class DeepLocal derived from A.
  Instantiate one DeepLocal. Fields inside classes:
  O: a,b
  Local: a,c
  A: a,d
  DeepLocal: a,e
  Print all 8 fields from DeepLocal, using qualified this/super where needed.
*/

public class local_cl_81_extends_local_uncle {
  public static void main(String[] args) {
    new O().test();
    System.out.println("Done!");
  }
}

class O {

  String a = "O.a";
  String b = "O.b";

  void test() {
    class A {
      String a = "A.a";
      String c = "A.c";
    }

    class Local {
      String a = "Local.a";
      String d = "Local.d";

      void test() {
        class DeepLocal extends A {
          String a = "DeepLocal.a";
          String e = "DeepLocal.e";

          void test() {
            System.out.println("Inside DeepLocal:");
            System.out.println("a=" + a);
            System.out.println("b=" + b);
            System.out.println("c=" + c);
            System.out.println("d=" + d);
            System.out.println("e=" + e);
            System.out.println("this.a=" + this.a);
            System.out.println("super.a=" + super.a);
            System.out.println("Local.this.a=" + Local.this.a);
            System.out.println("O.this.a=" + O.this.a);
          }
        }

        new DeepLocal().test();
      }
    }

    new Local().test();
  }
}
