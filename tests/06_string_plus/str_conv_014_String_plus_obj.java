class Ex extends RuntimeException {
  Ex(String message) {
    super(message);
  }
}

public class str_conv_014_String_plus_obj {
  public static void main(String[] args) {
    System.out.println((""+new RuntimeException("re")));
    System.out.println((""+new AssertionError("ae")));
    System.out.println((""+new Ex("ex")));
    System.out.println("Done!");
  }
}
