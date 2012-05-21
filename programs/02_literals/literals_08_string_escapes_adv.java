//Named, octal and unicode escapes, all possible cases, part supported by maude.
public class literals_08_string_escapes_adv {
	public static void main(String[] args) {
    System.out.println("Named escape:");
    System.out.println(""+"_\b_"+"_\t_"+"_\n_"+"_\f_"+"_\r_"+"_\"_"+"_\'_"+"_\\_");
    System.out.println("Octal escape of simple chars:");
    System.out.println(""+"_\141_"+"_\101_"+"_\60_"+"_\40_"+"_\43_");//aA0 #
    System.out.println("Unicode escape of simple chars:");
    System.out.println(""+"_\u0061_"+"_\u0041_"+"_\u0030_"+"_\u0020_"+"_\u0023_");//aA0 #

    System.out.println("Octal escape:");
    System.out.println(""+"_\0_"+"_\7_"+"_\00_"+"_\07_"+"_\37_"+"_\77_"
        +"_\000_"+"_\007_"+"_\077_"+"_\177_");
    System.out.println("Unicode escape:");
    System.out.println(""+"_\u0000_"+"_\u0001_"+"_\uu0007_"+"_\u0010_"+"_\uuu007f_");
		System.out.println("Done!");
	}
}
