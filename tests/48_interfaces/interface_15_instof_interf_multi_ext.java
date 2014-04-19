/*
IC < (IA, IB). C < IC, B < IB, A < IA Test instanceof
  among (IA)A, (IB)B, (IC)C on one side and (IA, IB, IC) on other.
*/

public class interface_15_instof_interf_multi_ext {
  public static void main(String[] args) {
    IA a = new A();
    IB b = new B();
    IC c = new C();
    System.out.println("A instanceof IA "+ (a instanceof IA));
    System.out.println("A instanceof IB "+ (a instanceof IB));
    System.out.println("A instanceof IC "+ (a instanceof IC));
    System.out.println("B instanceof IA "+ (b instanceof IA));
    System.out.println("B instanceof IB "+ (b instanceof IB));
    System.out.println("B instanceof IC "+ (b instanceof IC));
    System.out.println("C instanceof IA "+ (c instanceof IA));
    System.out.println("C instanceof IB "+ (c instanceof IB));
    System.out.println("C instanceof IC "+ (c instanceof IC));

    System.out.println("Done!");
  }
}

interface IA {}
interface IB {}
interface IC extends IA, IB {}

class A implements IA {}
class B implements IB {}
class C implements IC {}
