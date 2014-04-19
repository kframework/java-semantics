/*
Two instances of the same Local, declared inside a for may see different values
  for the same vars. If they instantiate another local class from the same for,
  they will also see different <localClassesEnv>.
  Test:
  - for i = 1..2, a = i, class Local1, class Local2, instantiate Local2 and save it.
  - From outside for, use the two instances of Local2 to instantiate and display
    two instances of Local1.
  - instances of Local1 print different values for a.
*/

public class local_cl_917_local_decl_env_in_for {
  public static void main(String[] args) {
    new O().test();
    System.out.println("Done!");
  }
}

interface I1 {
  void test();
}

class O {

  void test() {

    I1[] vi = new I1[2];

    for(int i=0; i<2; i++) {
      final int a = i;

      class Local1 {
        void test() {
          System.out.println("Local1: a = " + a);
        }
      }

      class Local2 implements I1 {
        public void test() {
          System.out.println("Local2: a = " + a);
          System.out.println("Instantiating Local1 from Local2:");
          new Local1().test();
          System.out.println();
        }
      }

      vi[i] = new Local2();

    }

    for(int i=0; i<2; i++) {
      vi[i].test();
    }
  }
}
