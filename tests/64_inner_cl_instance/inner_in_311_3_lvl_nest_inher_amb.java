/*
Superposition of nesting and inheritance creating ambiguity:
  - Outer:
    - Mid1
    - Mid2 < Outer
      - Inner < Mid1. Inner constructor should be default.
      Which instance of Outer will it choose as enclosing instance for Mid1?
      The outermost Outer or Mid2?
    Instantiate two objects Inner, on two distinct objects Outer.
    - test() of each class will print its immediate outer as well as base class.
    - Outer.test() will print its id.
*/

public class inner_in_311_3_lvl_nest_inher_amb {
  public static void main(String[] args) {
    System.out.println("main: Outer[1]:");
    new Outer("Outer[1]").new Mid2().new Inner().test();
    System.out.println();
    System.out.println("main: Outer[2]:");
    new Outer("Outer[2]").new Mid2().new Inner().test();
    System.out.println();
    System.out.println("Done!");
  }
}

class Outer {

  String id;

  Outer(String id) {
    this.id = id;
  }

  void test(String spaces) {
    System.out.println(spaces + id);
  }

  class Mid1 {

    void test(String spaces) {
      System.out.println(spaces + "Mid1: Outer.this.test():");
      Outer.this.test(spaces + "  ");
    }
  }

  class Mid2 extends Outer {

    Mid2() {
      super(Outer.this.id + ".Mid2");
    }

    void test(String spaces) {
      System.out.println(spaces + "Mid2: super.test():");
      super.test(spaces + "  ");
      System.out.println(spaces + "Mid2: Outer.this.test()");
      Outer.this.test(spaces + "  ");
    }

    class Inner extends Mid1 {

      void test() {
        System.out.println("Inner: super.test():");
        super.test("  ");
        System.out.println("Inner: Mid2.this.test()");
        Mid2.this.test("  ");
      }
    }
  }
}
