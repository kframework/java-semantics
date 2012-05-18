//Throw causes thread termination.

public class throw_2_k_termination {
  public static void main(String[] args) {
    if(true) throw new RuntimeException("");
    System.out.print("unreachable");
  }
}
// Thread terminated with exception: RuntimeException
