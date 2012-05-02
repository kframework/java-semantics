//Throw causes thread termination.

class Exception {
  Exception(){}
}

public class main {
  void main(string[] args) {
    throw new Exception();
    print("unreachable");
  }
}
// Thread terminated with exception: Exception
