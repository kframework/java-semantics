/*
<localClassesEnv> is correctly restored when exiting a block. With outer variables.
  Local classed DeepLocal followed by Local. Inside Local.test() - another DeepLocal.
  Instantiate DeepLocal in three places, all inside Local.test():
  - Before the second DeepLocal, in the same block.
  - After the second DeepLocal, in the same block,
  - After the second DeepLocal, after its block, and outside the second DeepLocal scope.
  variables:
  - int a, before the first DeepLocal.
  - int a, before the second DeepLocal.
  Both classes DeepLocal print a.
*/

public class local_cl_915_cl_name_shadow_block {
  public static void main(String[] args) {
    new O().test();
    System.out.println("Done!");
  }
}

class O {

  void test() {

    final int a = 1;

    class DeepLocal {
      public String toString() {return "O.DeepLocal: a = " + a;}
    }

    class Local {

      void test() {
        {
          final int a = 2;

          System.out.println("Before inner DeepLocal declaration:");
          System.out.println(new DeepLocal() + "\n");

          class DeepLocal {
            public String toString() {return "O.Local.DeepLocal: a = " + a;}
          }

          System.out.println("After inner DeepLocal declaration:");
          System.out.println(new DeepLocal() + "\n");
        }

        System.out.println("After inner DeepLocal scope:");
        System.out.println(new DeepLocal() + "\n");
      }
    }

    new Local().test();
  }
}
