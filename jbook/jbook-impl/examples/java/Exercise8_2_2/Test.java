class E extends Exception { }

class F extends E { }

class G extends Exception { }

class Test {
  static void test(E e) {
    try { throw e; }
    catch (F x) { }
    catch (E x) { }
    catch (G x) { }
    catch (Error x) { }
    catch (RuntimeException x) { }
    catch (Exception x) { }
  }

  static void main(String[] argv) { }
}
