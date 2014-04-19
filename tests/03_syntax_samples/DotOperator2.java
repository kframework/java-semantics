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

    Object lo;
    int li;

    new C().init();
    field = a = this;
    C local = this;

    li = this.a.b;
    li = this.a.g(3);
    li = this.f(2).b;
    li = this.f(2).g(3);

    li = super.a.b;
    li = super.a.g(3);
    li = super.f(2).b;
    li = super.f(2).g(3);

    li = field.a.b;
    li = field.a.g(3);
    li = field.f(2).b;
    li = field.f(2).g(3);

    li = local.a.b;
    li = local.a.g(3);
    li = local.f(2).b;
    li = local.f(2).g(3);

    li = f(1).a.b;
    li = f(1).a.g(3);
    li = f(1).f(2).b;
    li = f(1).f(2).g(3);

    System.out.println("Done!");
  }
}

public class DotOperator2 {
  public static void main(String[] args) {
    new main(args);
  }
}
