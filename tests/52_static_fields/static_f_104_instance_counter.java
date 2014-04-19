/*
Static field as instance counter.
  Class have one static and one instance field. Create three instances.
  Check that static field is the same, instance field is different.
*/

public class static_f_104_instance_counter {
  public static void main(String[] args) {
    A.nextId = 0;
    System.out.println(A.nextId);
    A a1 = new A();
    System.out.println(A.nextId);
    A a2 = new A();
    System.out.println(A.nextId);
    A a3 = new A();
    System.out.println(A.nextId);

    System.out.println(a1+" "+a2+" "+a3);
    System.out.println("Done!");
  }
}

class A {
  static int nextId;
  int id;

  A() {
    id = nextId;
    nextId++;
  }

  public String toString() {
    return "(id="+id+" nextId="+nextId+")";
  }
}
