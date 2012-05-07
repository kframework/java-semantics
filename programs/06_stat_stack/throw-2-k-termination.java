//Throw causes thread termination.

class Exception {
  Exception(){}
}

class main {
  void main(String[] args) {
    throw new Exception();
    System.out.print("unreachable");
  }
}
// Thread terminated with exception: Exception
