/*
- p2.B(), calls super(byte)
*/

package p2;

public class B extends A {

  public B() {
    super((byte)0);
    System.out.println("p2.B::B()");
  }
}
