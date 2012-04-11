/*
1. Assert with true exp with one arg.
2. Assert with true exp with two args. Second arg have a side effect.
  Testing execution of second arg only if first is false.
3. Assert with false with one arg.
4. Assert with false with two args. Second arg of type string.
5. Assert with false with two args. Second arg of type int.
  Testing conversion to string.
*/

class assertionError {
  string message;

  assertionError(string message) {
    this.message = message;
  }

  void print() {
    print("assertionError: ",message,"\n");
  }
}

class main {
  void main(string[] args) {
    assert 1 > 0;
    print("1 > 0 asserted","\n");

    assert 1>0 : "abc";
    print("1 > 0 asserted with arg","\n");

    try {
      assert false;
    } catch (assertionError err) {
      err.print();
    }

    try {
      assert false : "abc";
    } catch (assertionError err) {
      err.print();
    }

    try {
      assert false : -1;
    } catch (assertionError err) {
      err.print();
    }

    print("Done!","\n");
  }
}

// 1 > 0 asserted
// 1 > 0 asserted with arg
// assertionError:
// assertionError: abc
// assertionError: -1
// Done!
