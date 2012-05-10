class C {
  int b;
  int g(int i){return i;}
  C a;
  C f(int i) {return this;}

  void C(){
    a = this;
  }
}

public class main extends C {
  int b;
  int g(int i){return i;}

  C f(int i) {return a;}

  C field;
  C a;

  //todo this one get stucked
  //main x = this;

  void main(String[] args) {
    C();
    field = a = this;
    C local = this;

    this.a.b;
    this.a.g(3);
    this.f(2).b;
    this.f(2).g(3);

    super.a.b;
    super.a.g(3);
    super.f(2).b;
    super.f(2).g(3);

    field.a.b;
    field.a.g(3);
    field.f(2).b;
    field.f(2).g(3);

    local.a.b;
    local.a.g(3);
    local.f(2).b;
    local.f(2).g(3);

    f(1).a.b;
    f(1).a.g(3);
    f(1).f(2).b;
    f(1).f(2).g(3);

    System.out.println("Done!");
  }
}
