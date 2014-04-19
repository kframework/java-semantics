/*
Multifield with init, also methods. Two groups of fields:
  static int a=...;
  static int b=..., c=...;
  Test their values. Do not implement the interface. We are interested only in preprocessing.
  All field iniitalizers have tracing.
*/

interface I1 {
  int a = Auxx.aInit();

  void f();

  int b = Auxx.bInit(), c = Auxx.cInit();
}

class Auxx {

  static int aInit() {
    System.out.println("Auxx.aInit()");
    return 3;
  }

  static int bInit() {
    System.out.println("Auxx.bInit()");
    return 4;
  }

  static int cInit() {
    System.out.println("Auxx.cInit()");
    return 5;
  }
}

public class interface_f_76_init_multifield {
  public static void main(String[] args) {
    System.out.println("I1.a = " + I1.a);
    System.out.println("Done!");
  }
}
