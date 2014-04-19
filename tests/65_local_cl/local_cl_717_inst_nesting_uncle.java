/*
Class O. Local classes A, Local, in the same block. Inside Local - local class DeepLocal.
  Instantiate A from DeepLocal, unqualified. According to $15.9.2 this is the only possibility,
  we cannot call the constructor for A qualified.
*/

public class local_cl_717_inst_nesting_uncle {
  public static void main(String[] args) {
    new O(10).test();
    System.out.println("Done!");
  }
}

class O {

  int param;

  O(int param) {
    this.param = param;
  }

  public String toString() {return "O: param=" + param;}

  void test() {
    class A {
      public String toString() {return "O.A: " + O.this.toString();}
    }

    class Local {
      public String toString() {return "O.Local: " + O.this.toString();}

      void test() {
        class DeepLocal {
          public String toString() {return "O.Local.DeepLocal: " + O.this.toString();}

          void testInstA() {
            System.out.println("DeepLocal.testInstA(): ");
            System.out.println(this);
            A a = new A();
            System.out.println("new A():");
            System.out.println(a);
            //Illegal construct, $15.9.2. The enclosing instance of a newly instantiated local lcass may only
            //be one of the enclosing instances of this.
            //a = new O(200).new A();
          }
        }

        new DeepLocal().testInstA();
      }
    }

    new Local().test();
  }
}
