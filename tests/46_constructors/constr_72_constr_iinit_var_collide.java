/*
Testing the distinction between IInit and freshEnv(IInit) in the rule [invokeConstructor].
  Constructor with argument a="Constr.a", instance initializer with local var a = "IInit.a".
  Print a in the constructor.
*/

class A {

  {
    String a = "IInit.a";
    System.out.println("A.IInit(" + a + ")");
  }

  A(String a) {
    System.out.println("A.A(" + a + ")");
  }
}

public class constr_72_constr_iinit_var_collide {
  public static void main(String[] args) {
    new A("Constr.a");
    System.out.println("Done!");
  }
}
