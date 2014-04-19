/*
Interface subtype of other.
  Class A < IA.
  Class Tester, method f() with the following argument types:
    - all primitive types, String, Object, int[], Object[], Object[][], A, A[].
    - call arguments: IA, IA[], IA[][], IA[][][].
*/

public class interface_62_intf_subtype_of_other {
  public static void main(String[] args) {
    Tester t = new Tester();
    System.out.println("f(IA):       " + t.f((IA)null));
    System.out.println("f(IA[]):     " + t.f((IA[])null));
    System.out.println("f(IA[][]):   " + t.f((IA[][])null));
    System.out.println("f(IA[][][]): " + t.f((IA[][][])null));

    System.out.println("Done!");
  }
}

interface IA {}
class A implements IA {}

class Tester {
  String f(byte a)       {return "f(byte)";}
  String f(short a)      {return "f(short)";}
  String f(int a)        {return "f(int)";}
  String f(long a)       {return "f(long)";}
  String f(char a)       {return "f(char)";}
  String f(boolean a)    {return "f(boolean)";}
  String f(String a)     {return "f(String)";}
  String f(Object a)     {return "f(Object)";}
  String f(int[] a)      {return "f(int[])";}
  String f(Object[] a)   {return "f(Object[])";}
  String f(Object[][] a) {return "f(Object[][])";}
  String f(A a)          {return "f(A)";}
  String f(A[] a)        {return "f(A[])";}
}

