class C {
  int b;
  int g(int i){return i;}

  C a;
  C f(int i) {return this;}

  void init() {
    a = this;
  }
}

class main extends C {
  int b;
  int g(int i){return i;}

  C f(int i) {return a;}

  C field;
  C a;

  main(String[] args) {
    super.init();

    new C().init();
    field = a = this;
    C local = this;

    this.b = 1;
    super.b = 2;
    field.b=3;
    local.b=4;
    f(1).b=5;

    this.a.b = 1;
    this.f(1).b = 1;
    super.a.b = 2;
    super.f(1).b = 2;
    field.a.b=3;
    field.f(1).b=3;
    local.a.b=4;
    local.f(1).b=4;
    f(1).a.b=5;
    f(1).f(1).b=5;

    System.out.println("Done!");
  }
}

public class DotOperator3 {
  public static void main(String[] args) {
    new main(args);
  }
}
