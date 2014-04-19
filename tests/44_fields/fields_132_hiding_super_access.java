/*
B < A. B.x, A.x.
Access a hidden field through super qualifier, cast to base class,
  or named reference to base class.
*/

class A {

  int x;

  A() {
    x=7;
  }

  int m0() {
    return x;
  }
}

class B extends A {

  boolean x ;

  B() {
    x=true;
  }

  int m1() {
    return super.x;
  }

  int m2() {
    A o = this;
    return o.x;            // implicit casting
    // the field x is the one in the type a of o, that is, 7
  }

  int m3() {
    return ((A) this).x;  // explicit casting
    //"cast object to class" casts "object" to "class"
  }

  int m4() {
    return aux1(this);
  }

  int aux1(A o) {   // implicit casting, again
    return o.x;
  }

  boolean m5() {
    return aux2(this);
  }

  boolean aux2(A o) {     // implicit casting, again
    return ((B) o).x;     // but then explicit casting back to b
  }
}

public class fields_132_hiding_super_access {
  public static void main(String[] args) {
    B o = new B();
    if (o.m5()) {
      System.out.println(""+o.m0()+ o.m1()+ o.m2()+ o.m3()+ o.m4());
    } else
      System.out.println("m5 not returning true");
    System.out.println("Done!");
  }
}
