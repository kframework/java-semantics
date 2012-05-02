// Testing try with  both catch and finally clause

public class main {

  void main(string[] args) {
    try {
      try {
        print("no exception first time","\n");
      } catch (int e3) {
        print("caught exception: ",e3,"\n");
      } finally {
        print("finally after no exception","\n");
      }

      throw -1;

      print("No exception second time","\n");
    } catch (int e3) {
      print("caught exception: ",e3,"\n");
    } finally {
      print("finally after exception","\n");
    }
    print("Done!", "\n");
  }
}

// no exception first time
// finally after no exception
// caught exception: -1
// finally after exception
// Done!
