class C {
  C(){}

  int b;
  int g(int i){return i;}

}

class main extends C {
  int b;
  int g(int i){return i;}

  C a = new C();
  C f(int i) {return a;}

  main(String[] args) {
    Object lo;
    int li;
    //situatii posibile:

    //'This()
    lo = this;

    //'ExprName(b)
    li = b;

    //'Invoke('Method('MethodName(g)),,_)
    li = g(2);

    //'Field('This(),,b)
    li = this.b;

    //'Invoke('Method('This(),,_,,g),,_)
    li = this.g(2);

    //'SuperField(b)
    li = super.b;

    //'Invoke('SuperMethod(_,,g),,_)
    li = super.g(2);

    //'ExprName('AmbName(a),,b)
    li = a.b;

    //'Invoke('Method('MethodName('AmbName(a),,g)),,_)
    li = a.g(2);

    //'Field('Invoke('Method('MethodName(f)),,_),,b)
    li = f(1).b;

    //'Invoke(
    //  'Method(
    //    'Invoke('Method('MethodName(f)),,_),,
    //    _,,
    //    g
    //  ),,
    //  _
    //)
    li = f(1).g(2);

    System.out.println("Done!");
  }
}

public class DotOperator1 {
  public static void main(String[] args) {
    new main(args);
  }
}
