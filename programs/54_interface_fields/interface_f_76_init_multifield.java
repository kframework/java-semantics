/*
Multifield with init, also methods. Two groups of fields:
  static int a=...;
  static int b=..., c=...;
  Test their values. Do not implement the interface. We are interested only in preprocessing.
  All field iniitalizers have tracing.
*/

interface I1 {
  int a = Aux.aInit();

  void f();

  int b = Aux.bInit(), c = Aux.cInit();
}

class Aux {

  static int aInit() {
    System.out.println("Aux.aInit()");
    return 3;
  }

  static int bInit() {
    System.out.println("Aux.bInit()");
    return 4;
  }

  static int cInit() {
    System.out.println("Aux.cInit()");
    return 5;
  }
}

public class interface_f_76_init_multifield {
  public static void main(String[] args) {
    System.out.println("I1.a = " + I1.a);
    System.out.println("Done!");
  }
}
