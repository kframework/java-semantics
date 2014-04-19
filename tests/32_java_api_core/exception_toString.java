public class exception_toString {
  public static void main(String[] args) {
    System.out.println(new RuntimeException("abc").toString());
    System.out.println(new RuntimeException("").toString());
    System.out.println(new RuntimeException((String)null).toString());
    System.out.println("Done!");
  }
}

