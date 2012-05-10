//Hexadecimal integer literals
public class main {
	static void main(String[] args) {
    System.out.println("Hexa int literals:");
		System.out.println(0x0 + " " + 0x5f + " " + 0X5F + " " + 0xFFFFFFF0);
    System.out.print("Hexa int overflow, 0x70000000 + 0x70000000 = ");
		System.out.println(0x70000000 + 0x70000000);
    System.out.println("Hexa long literals:");
		System.out.println(0x0L + " " + 0x123456789abL + " " + 0x123456789ABl
        + " " + 0xFFFFFFF0L + " " + 0xFFFFFFFF00000000L);
    System.out.print("Hexa long not overflow, 0x70000000L + 0x70000000L = ");
		System.out.println(0x70000000L + 0x70000000L);
		System.out.println("Done!");
	}
}

