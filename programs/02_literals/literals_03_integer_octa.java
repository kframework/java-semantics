//Octal integer literals
public class literals_03_integer_octa {
	public static void main(String[] args) {
    System.out.println("Octa int literals:");
		System.out.println(00 + " " + 077 +  " " + 037777777777);
    System.out.print("Octa int overflow, 017777777777 + 017777777777 = ");
		System.out.println(017777777777 + 017777777777);
    System.out.println("int extremes: "+ 020000000000 + " " + 017777777777);
    System.out.println("Octa long literals:");
		System.out.println(00L + " " + 037777777777l
        + " " + 01777777777777777777777L);
    System.out.print("Octa long not overflow, 017777777777L + 017777777777L = ");
		System.out.println(017777777777L + 017777777777L);
    System.out.println("long extremes: "+ 01000000000000000000000L
        + " " + 0777777777777777777777L);
		System.out.println("Done!");
	}
}

