/*
<localClassesEnv> is correctly restored when exiting a method call. With outer variables.
  class O, method f(int level). f() structure:
  - class Local(), printing level
  - instantiate Local
  - if level == 1, call f(2) - recursive call.
  - if level == 1, instantiate Local.
  Here we are testing that after returning from the call to f(2), the new instance of Local
  will have access to level 1, not 2 as it was in the innermost call to f().
*/

public class local_cl_916_recursion_l_env_restore {
  public static void main(String[] args) {
    new O().f(1);
    System.out.println("Done!");
  }
}

class O {

  void f(final int level) {

    class Local {
      void test() {
        System.out.println("Local: level = " + level);
      }
    }

    new Local().test();

    if (level == 1) {
      f(2);
      new Local().test();
    }
  }
}
