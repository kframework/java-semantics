/*
Null subtype of interface.
  IB < IA
  - T0: f(IA),   f(IB),   f(Object)
  - T1: f(IA[]), f(IB[]), f(Object)
  - call target: A,B,C
  - call argument: null.
*/

public class interface_64_null_subtype_of_intf {
  public static void main(String[] args) {
    System.out.println("T0.f(null):       " + new T0().f(null));
    System.out.println("T1.f(null):       " + new T1().f(null));

    System.out.println("Done!");
  }
}

interface IA {}
interface IB extends IA {}

class T0 {
  String f(IA a)           {return "f(IA)";}
  String f(IB a)           {return "f(IB)";}
  String f(Object a)       {return "f(Object)";}
}

class T1 {
  String f(IA[] a)         {return "f(IA[])";}
  String f(IB[] a)         {return "f(IB[])";}
  String f(Object a)       {return "f(Object)";}
}

