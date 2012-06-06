//semantics for this test is covered under chapter $5.
public class imp_conv_03_primitive_var_init {
  public static void main(String[] args) {
    byte bt = 100;
    short sh = 1000;
    int i = 1000000;
    long l = 9000000000L;
    char ch1 = 50000;
    char ch2 = 'z';
    char ch3 = 100;
    System.out.println("" + bt + " " + sh + " " + i + " " + l + " "
        + (int)ch1 + " " + ch2 + " " + ch3);
    System.out.println("Done!");
  }
}
