class a {
  int x;
  a() {
    x=7;
  }
  int m0() {
    return x;
  }
}

class b extends a {
  boolean x ;
  b() {
    super();
    x=true;
  }
  int m1() {
    return super.x;
  }
  int m2() {
    a o = this;
    return o.x;            // implicit casting
    // the field x is the one in the type a of o, that is, 7
  }
  int m3() {
    return ((a) this).x;  // explicit casting
    //"cast object to class" casts "object" to "class"
  }
  int m4() {
    return aux1(this);
  }
  int aux1(a o) {   // implicit casting, again
    return o.x;
  }
  boolean m5() {
    return aux2(this);
  }
  boolean aux2(a o) {       // implicit casting, again
    return ((b) o).x;     // but then explicit casting back to b
  }
}

class main {
  main(String[] args) {
    b o = new b();
    if (o.m5()) System.out.println(""+o.m0()+ o.m1()+ o.m2()+ o.m3()+ o.m4());
    else System.out.println("m5 not returning true");
    System.out.println("Done!");
  }
}

public class p14 {
  public static void main(String[] args) {
    new main(args);
  }
}
