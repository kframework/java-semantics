/*
Access inner class from outer one, three level hierarchy.
  Classes A, A.B, A.B.C.
  Members:
  - A.id
  - B.id
  - C.id
  - A.test - calls A.id, B.id
  - B.test - calls A.id, B.id, C.id
  - C.test - calls A.id, B.id, C.id
  All classes are referred by simple name inside A,B,C.
  Calls inside main are made indirectly, to avoid qualified class references.
*/

public class inner_st_107_simple_names_3_lvl {

  public static void main(String[] args) {
    System.out.println(A.testA());
    System.out.println(A.testB());
    System.out.println(A.testC());
    System.out.println("Done!");
  }
}

class A {

  static String id = "A";

  static String testA() {
    return "A: " + A.id + " " + B.id;
  }

  static String testB() {
    return B.testB();
  }

  static String testC() {
    return B.testC();
  }

  public static class B {

    static String id = "A.B";

    static String testB() {
      return "B: " + A.id + " " + B.id + " " + C.id;
    }

    static String testC() {
      return C.testC();
    }

    public static class C {

      static String id = "A.B.C";

      static String testC() {
        return "C: " + A.id + " " + B.id + " " + C.id;
      }
    }
  }
}
