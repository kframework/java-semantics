/*Import pa.* and pc.* from pt.Test. Test
  simple names A,B,C in pt.Test.*/

package pt;

import pa.*;
import pc.*;

public class Test {
  public A createA() {
    return new A();
  }

  public B createB() {
    return new B();
  }

  public C createC() {
    return new C();
  }
}

