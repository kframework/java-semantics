class Ex extends RuntimeException {
  Ex(String message) {
    super(message);
  }
}

public class op_21_String_plus {
  public static void main(String[] args) {
    System.out.println("ab"+"cde");
    System.out.println("ab"+-12);
    System.out.println(-12+"cde");
    System.out.println(""+true);
    System.out.println(""+new RuntimeException("re"));
    System.out.println(""+new AssertionError("ae"));
    System.out.println(""+new Ex("ex"));
  }
}
