/*
Local vars of one method don't influence name resolution inside local classes of another method.
  Class O.
  Two fields: a,b.
  Two methods: test1 - local var a, test2 - local var b.
  Each have a local class: Local1, Local2. Local classes access both a and b.
*/

public class local_cl_913_multi_meth_locals {
  public static void main(String[] args) {
    O o = new O();
    o.test1();
    System.out.println();
    o.test2();
    System.out.println("Done!");
  }
}

class O {

  int a = 1, b = 10;

  void test1() {

    final int a = 2;

    class Local1 {

      public String toString() {return "O.test1().Local1: a="+a + " ,b="+b;}
    }

    System.out.println("O.test1(): a="+a + " ,b="+b);

    System.out.println(new Local1());
  }

  void test2() {

    final int b = 20;

    class Local2 {

      public String toString() {return "O.test2().Local2: a="+a + " ,b="+b;}
    }

    System.out.println("O.test2(): a="+a + " ,b="+b);

    System.out.println(new Local2());
  }
}
