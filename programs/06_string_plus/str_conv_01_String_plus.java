class Ex extends RuntimeException {
  Ex(String message) {
    super(message);
  }
}

public class str_conv_01_String_plus {
  public static void main(String[] args) {
    System.out.println("ab"+"cde");
    System.out.println("ab"+-12);
    System.out.println(-12+"cde");
    System.out.println(""+true);
    System.out.println(""+new RuntimeException("re"));
    System.out.println(""+new AssertionError("ae"));
    System.out.println(""+new Ex("ex"));
    System.out.println(""
        + (byte)100 + " "
        + (short)1000 + " "
        + (int)1000000 + " "
        + (long)9000000000L + " "
        + 'z');
    System.out.println("" + null);
    System.out.println("Done!");
  }
}
