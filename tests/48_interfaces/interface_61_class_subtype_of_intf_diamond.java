/*
Overloading with interfaces as method arguments.
  IC < (IA, IB) < IMax. A < IA ; B < (IB, IMax); C < (IB, IC).
  Tester: have an f(IA), f(IB), f(IC), f(IMax). Call it with arguments
  of static type A, B, C, IA, IB, IC, IMax.
*/

public class interface_61_class_subtype_of_intf_diamond {
  public static void main(String[] args) {
    Tester t = new Tester();
    System.out.println("f(IA):   " + t.f((IA)null));
    System.out.println("f(IB):   " + t.f((IB)null));
    System.out.println("f(IC):   " + t.f((IC)null));
    System.out.println("f(IMax): " + t.f((IMax)null));
    System.out.println("f(A):    " + t.f( (A)null));
    System.out.println("f(B):    " + t.f( (B)null));
    System.out.println("f(C):    " + t.f( (C)null));

    System.out.println("Done!");
  }
}

interface IMax {}
interface IA extends IMax {}
interface IB extends IMax {}
interface IC extends IA, IB {}

class A implements IA {}
class B implements IB, IMax {}
class C implements IB, IC {}

class Tester {
  String f(IA x) {
    return "f(IA)";
  }

  String f(IB x) {
    return "f(IB)";
  }

  String f(IC x) {
    return "f(IC)";
  }

  String f(IMax x) {
    return "f(IMax)";
  }
}

