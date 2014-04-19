/*
1. Assert with true exp with one arg.
2. Assert with true exp with two args. Second arg have a side effect.
  Testing execution of second arg only if first is false.
3. Assert with false with one arg.
4. Assert with false with two args. Second arg of type String.
5. Assert with false with two args. Second arg of type int.
  Testing conversion to String.
*/

class main {
  main(String[] args) {
    assert 1 > 0;
    System.out.println("1 > 0 asserted");

    assert 1 > 0 : "abc";
    System.out.println("1 > 0 asserted with arg");

    try {
      assert false;
    } catch (AssertionError err) {
      System.out.println(err.toString());
    }

    try {
      assert false : null;
    } catch (AssertionError err) {
      System.out.println(err.toString());
    }

    try {
      assert false : "abc";
    } catch (AssertionError err) {
      System.out.println(err.toString());
    }

    try {
      assert false : -1;
    } catch (AssertionError err) {
      System.out.println(err.toString());
    }

    System.out.println("Done!");
  }
}

public class assert_statement{
  public static void main(String[] args) {
    new main(args);
  }
}

// 1 > 0 asserted
// 1 > 0 asserted with arg
// AssertionError
// AssertionError: abc
// AssertionError: -1
// Done!
