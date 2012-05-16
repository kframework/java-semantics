//Throw causes thread termination.

class Exception {
  Exception(){}
}

public class throw_2_k_termination {
  public static void main(String[] args) {
    throw new Exception();
    System.out.print("unreachable");
  }
}
// Thread terminated with exception: Exception
