/*Import p.pc.A from pt.(Test1,Test2)*/

package pt;

import p.pc.A;

public class Test1 {
  public A createA() {
    return new A();
  }

  public Object createTest2A() {
    return new Test2().createA();
  }
}

class Test2 {
  public A createA() {
    return new A();
  }
}
