//Use a field of type reference. Pass a reference as a method argument.

class A {
  int val;

  A(int v) {
    val = v;
  }

  int get() { return val; }
}

class B {
  A o;

  B(A o) {
    this.o = o;
  }

  int do1() {
    int val = 9;
    return (o.get());
  }
}

public class fields_102_of_type_ref {
  public static void main(String[] args) {
    A a = new A(1);
    B b = new B(a);  // passes an object
    System.out.println(b.do1());
    System.out.println("Done!");
  }
}
