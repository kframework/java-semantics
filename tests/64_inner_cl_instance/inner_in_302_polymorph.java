/*
Classes S, O, O.A < S, I1, I2. Cast the object of type A to S, I1, I2, access the respective members.
  S, I1, I2 should have each a method overwritten in O.A.
*/

public class inner_in_302_polymorph {
  public static void main(String[] args) {
    O.A a = new O().new A();
    System.out.println(((S)a).sf());
    System.out.println(((I1)a).i1f());
    System.out.println(((I2)a).i2f());
    System.out.println("Done!");
  }
}

class S {
  int sv = 1;
  String sf() {return "S.sf()";}
}

interface I1 {
  String i1f();
}

interface I2 {
  String i2f();
}

class O {

  int ov = 2;
  String of() {return "of()";}

  class A extends S implements I1, I2 {
    int av = 20;
    String sf() {return "A.sf()";}
    public String i1f() {return "A.i1f()";}
    public String i2f() {return "A.i2f()";}
  }
}
