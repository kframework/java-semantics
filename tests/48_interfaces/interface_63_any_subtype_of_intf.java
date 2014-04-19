/*
Interfaces and others subtype of interface.
  Class A < IA, IC < IB < IA.
  Class Tester, method f() with the following argument types:
    - Object, IA, IA[], IA[][], IC[], long, boolean.
    - call arguments: all primitive types, Object, Object[], IA, IA[], IA[][], IA[][][],
      IB, IB[], IB[][], IB[][][], IC, IC[], IC[][], A, A[][], A[][][], String, String[],
      RuntimeException, int[], IOther, IOther[][].
*/

public class interface_63_any_subtype_of_intf {
  public static void main(String[] args) {
    Tester t = new Tester();
    System.out.println("f(byte):             " + t.f((byte)0));
    System.out.println("f(short):            " + t.f((short)0));
    System.out.println("f(int):              " + t.f((int)0));
    System.out.println("f(long):             " + t.f((long)0));
    System.out.println("f(char):             " + t.f((char)0));
    System.out.println("f(boolean):          " + t.f((boolean)false));
    System.out.println("f(Object):           " + t.f((Object)null));
    System.out.println("f(Object[]):         " + t.f((Object[])null));
    System.out.println("f(IA):               " + t.f((IA)null));
    System.out.println("f(IA[]):             " + t.f((IA[])null));
    System.out.println("f(IA[][]):           " + t.f((IA[][])null));
    System.out.println("f(IA[][][]):         " + t.f((IA[][][])null));
    System.out.println("f(IB):               " + t.f((IB)null));
    System.out.println("f(IB[]):             " + t.f((IB[])null));
    System.out.println("f(IB[][]):           " + t.f((IB[][])null));
    System.out.println("f(IB[][][]):         " + t.f((IB[][][])null));
    System.out.println("f(IC):               " + t.f((IC)null));
    System.out.println("f(IC[]):             " + t.f((IC[])null));
    System.out.println("f(IC[][]):           " + t.f((IC[][])null));
    System.out.println("f(A):                " + t.f((A)null));
    System.out.println("f(A[][]):            " + t.f((A[][])null));
    System.out.println("f(A[][][]):          " + t.f((A[][][])null));
    System.out.println("f(String):           " + t.f((String)null));
    System.out.println("f(String[]):         " + t.f((String[])null));
    System.out.println("f(RuntimeException): " + t.f((RuntimeException)null));
    System.out.println("f(int[]):            " + t.f((int[])null));
    System.out.println("f(IOther):           " + t.f((IOther)null));
    System.out.println("f(IOther[][]):       " + t.f((IOther[][])null));

    System.out.println("Done!");
  }
}

interface IA {}
interface IB extends IA {}
interface IC extends IB {}
class A implements IA {}
interface IOther {}

class Tester {
  String f(Object a)       {return "f(Object)";}
  String f(IA a)           {return "f(IA)";}
  String f(IA[] a)         {return "f(IA[])";}
  String f(IA[][] a)       {return "f(IA[][])";}
  String f(IC[] a)         {return "f(IC[])";}
  String f(long a)         {return "f(long)";}
  String f(boolean a)      {return "f(boolean)";}
}

