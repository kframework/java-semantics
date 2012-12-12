package ro.uaic.java.test;

class TheClass {}
class TheClass2 {}

public class Test {
  public void theTest() {
    System.out.println(new RuntimeException((String) null).getClass().getName());
    System.out.println(new Object().getClass().getName());
    TheClass theClass = new TheClass();
    Object objectTC = theClass;
    System.out.println(theClass.getClass().getName());
    System.out.println(objectTC.getClass().getName());
    System.out.println(new TheClass2().getClass().getName());
  }
}

