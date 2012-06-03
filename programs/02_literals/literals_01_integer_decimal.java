//decimal integer literals
public class literals_01_integer_decimal {
	public static void main(String[] args) {
    System.out.println("Decimal int literals:");
		System.out.println(0 + " " + 12 + " " + -13);
    System.out.print("Int overflow, 2002001001 + 2002001001 = ");
    System.out.println(2002001001 + 2002001001);
    System.out.println("int extremes: "+ -2147483648 + " " + 2147483647);
    System.out.println("Decimal long literals:");
		System.out.println(0L + " " + 12L + " " + 12345678900l + " " + 12345678900L);
    System.out.print("Long not overflow, 2002001001L + 2002001001L = ");
    System.out.println(2002001001L + 2002001001L);
    System.out.println("long extremes: "+ -9223372036854775808L
        + " " + 9223372036854775807L);
		System.out.println("Done!");
	}
}

