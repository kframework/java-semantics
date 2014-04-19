/*
Super in the context of polymorphism.
  A4 < A3 < A2 < A1.
  - f13() - in A1 and A3
  - f14() - in A1 and A4
  - f23() - in A2 and A3
  - f24() - in A2 and A4
  - f12() - in A1, A2
  - f123() - in A1, A2, A3
  - f134() - in A1, A3, A4
  - f1() - in A1.
  - test3() - in A3, calls all methods through super.
  Target object is of type A4.
*/

public class super_m_02_poly {

  public static void main(String[] args) {
    new A4().test3();
    System.out.println("Done!");
  }
}

class A1 {
  String f13() {
    return "A1.f13()";
  }

  String f14() {
    return "A1.f14()";
  }

  String f12() {
    return "A1.f12()";
  }

  String f123() {
    return "A1.f123()";
  }

  String f134() {
    return "A1.f134()";
  }

  String f1() {
    return "A1.f1()";
  }
}

class A2 extends A1 {
  String f23() {
    return "A2.f23()";
  }

  String f24() {
    return "A2.f24()";
  }

  String f12() {
    return "A2.f12()";
  }

  String f123() {
    return "A2.f123()";
  }
}

class A3 extends A2 {
  String f13() {
    return "A3.f13()";
  }

  String f23() {
    return "A3.f23()";
  }

  String f123() {
    return "A3.f123()";
  }

  String f134() {
    return "A3.f134()";
  }

  void test3() {
    System.out.println(super.f13());
    System.out.println(super.f14());
    System.out.println(super.f23());
    System.out.println(super.f24());
    System.out.println(super.f12());
    System.out.println(super.f123());
    System.out.println(super.f134());
    System.out.println(super.f1());
  }
}

class A4 extends A3 {
  String f14() {
    return "A4.f14()";
  }

  String f24() {
    return "A4.f24()";
  }

  String f134() {
    return "A4.f134()";
  }
}
