class C {
  void C(){}

  int b;
  int g(int i){return i;}

}

class main extends C {
  int b;
  int g(int i){return i;}

  C a = new C();
  C f(int i) {return a;}

  void main(string[] args) {
    //situatii posibile:

    //'This()
    this;

    //'ExprName(b)
    b;

    //'Invoke('Method('MethodName(g)),,_)
    g(2);

    //'Field('This(),,b)
    this.b;

    //'Invoke('Method('This(),,_,,g),,_)
    this.g(2);

    //'SuperField(b)
    super.b;

    //'Invoke('SuperMethod(_,,g),,_)
    super.g(2);

    //'ExprName('AmbName(a),,b)
    a.b;

    //'Invoke('Method('MethodName('AmbName(a),,g)),,_)
    a.g(2);

    //'Field('Invoke('Method('MethodName(f)),,_),,b)
    f(1).b;

    //'Invoke(
    //  'Method(
    //    'Invoke('Method('MethodName(f)),,_),,
    //    _,,
    //    g
    //  ),,
    //  _
    //)
    f(1).g(2);

    print("Finished!", "\n");
  }
}
