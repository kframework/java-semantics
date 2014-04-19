/*
Interface init triggering block environment separation.
  Interface init is triggered in a block with local var x. Interface init initializes the field x.
  Test that the field is assigned to, not the local var.
*/

public class static_i_trig_213_i_env_separation {
  public static void main(String[] args) {
    int x = 1;
    System.out.println("x = " + x);
    System.out.println("I.x = " + I.x);
    System.out.println("Done!");
  }
}

interface I {
  Object x = "abc";
}
