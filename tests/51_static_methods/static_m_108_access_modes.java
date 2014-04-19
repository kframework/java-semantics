/*
Static methods access modes - test just public vs private access mode
  in one compilation unit.
*/

public class static_m_108_access_modes {
  public static void main(String[] args) {
    A.privateTest();

    System.out.println("Public static test int:");
    A a = new A();
    System.out.print("A.sf((int) 0):     ");
    A.sf((int) 0);
    System.out.print("a.sf((int) 0):     ");
    a.sf((int)0);

    System.out.println("Done!");
  }
}

class A {

  static void privateTest() {
    System.out.println("Private static test int:");
    A a = new A();
    System.out.print("sf((int) 0):       ");
    sf((int) 0);
    System.out.print("A.sf((int) 0):     ");
    A.sf((int) 0);
    System.out.print("a.sf((int) 0):     ");
    a.sf((int)0);

    System.out.println("Private static test long:");
    System.out.print("sf((long) 0):      ");
    sf((long) 0);
    System.out.print("A.sf((long) 0):    ");
    A.sf((long) 0);
    System.out.print("a.sf((long) 0):    ");
    a.sf((long)0);

    a.privateInstanceTest();
  }

  void privateInstanceTest() {
    System.out.println("Private instance test int:");
    A a = new A();
    System.out.print("sf((int) 0):      ");
    sf((int) 0);
    System.out.print("this.sf((int) 0): ");
    this.sf((int) 0);

    System.out.println("Private instance test long:");
    System.out.print("sf((long) 0):     ");
    sf((long) 0);
    System.out.print("this.sf((long) 0):");
    this.sf((long) 0);
  }

  private static void sf(int a) {
    System.out.println("A.sf(int)");
  }

  public static void sf(long a) {
    System.out.println("A.sf(long)");
  }
}
