//Hexadecimal integer literals
public class literals_02_integer_hexa {
	public static void main(String[] args) {
    System.out.println("Hexa int literals:");
		System.out.println(0x0 + " " + 0x5f + " " + 0X5F + " " + 0xFFFFFFF0);
    System.out.print("Hexa int overflow, 0x70000000 + 0x70000000 = ");
		System.out.println(0x70000000 + 0x70000000);
    System.out.println("int extremes: "+ 0x80000000 + " " + 0x7fffffff);
    System.out.println("Hexa long literals:");
		System.out.println(0x0L + " " + 0x123456789abL + " " + 0x123456789ABl
        + " " + 0xFFFFFFF0L + " " + 0xFFFFFFFF00000000L);
    System.out.print("Hexa long not overflow, 0x70000000L + 0x70000000L = ");
		System.out.println(0x70000000L + 0x70000000L);
    System.out.println("long extremes: "+ 0x8000000000000000L
        + " " + 0x7fffffffffffffffL);
		System.out.println("Done!");
	}
}

