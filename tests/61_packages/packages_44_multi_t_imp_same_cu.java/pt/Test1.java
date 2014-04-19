package pt;

import pa2.*;

public class Test1 {
  public A createA() {
    return new A();
  }

  public Object test2CreateA() {
    return new Test2().createA();
  }
}

class Test2 {
  public A createA() {
    return new A();
  }
}
