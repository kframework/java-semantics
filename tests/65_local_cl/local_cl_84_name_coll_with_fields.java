/*
Test that a local class may have the same name as a variable/field in the same scope.
  Three local classes. One have the same name as a local var, other - as a field, third - as a method.
  Define variables of type all three, instantiate and print them.
  Also print the local var, field and method, accessing them by simple name.
  All local classes have a no-arg traced constructor.
*/

public class local_cl_84_name_coll_with_fields {
  public static void main(String[] args) {
    new O().test();
    System.out.println("Done!");
  }
}

class O {

  String a = "O.a";
  String f() {return "O.f()";}

  void test() {

    String b = "O.test().b";

    class a {
      a() {
        System.out.println("class a constructor");
      }

      public String toString() {
        return "class a: toString()";
      }
    }

    class f {
      f() {
        System.out.println("class f constructor");
      }

      public String toString() {
        return "class f: toString()";
      }
    }

    class b {
      b() {
        System.out.println("class b constructor");
      }

      public String toString() {
        return "class b: toString()";
      }
    }

    a va = new a();
    f vf = new f();
    b vb = new b();
    System.out.println("instance of a: " + va);
    System.out.println("instance of f: " + vf);
    System.out.println("instance of b: " + vb);
    System.out.println("a = " + a);
    System.out.println("f() =  " + f());
    System.out.println("b = " + b);
  }
}
