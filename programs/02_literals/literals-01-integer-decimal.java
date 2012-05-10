//decimal integer literals
public class main {
	static void main(String[] args) {
    System.out.println("Decimal int literals:");
		System.out.println(0 + " " + 12 + " " + -13 + " " + -2147483648);
    System.out.print("Int overflow, 2002001001 + 2002001001 = ");
    System.out.println(2002001001 + 2002001001);
    System.out.println("Decimal long literals:");
		System.out.println(0L + " " + 12L + " " + 12345678900l + " " + 12345678900L
        + " " + -9223372036854775808L);
    System.out.print("Long not overflow, 2002001001L + 2002001001L = ");
    System.out.println(2002001001L + 2002001001L);
		System.out.println("Done!");
	}
}

