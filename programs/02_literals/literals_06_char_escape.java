//Escape sequences for chars - named, octal and unicode.
//Only chars in the range of ascii codes 0-127.
//Those beyond 127 are not supported by maude.
public class literals_06_char_escape {
	public static void main(String[] args) {
    System.out.println("Named escape:");
    System.out.println(""+'\b'+'\t'+'\n'+'\f'+'\r'+'\"'+'\''+'\\');
    System.out.println("Octal escape of simple chars:");
    System.out.println(""+'\141'+'\101'+'\60'+'\40'+'\43');//aA0 #
    System.out.println("Unicode escape of simple chars:");
    System.out.println(""+'\u0061'+'\u0041'+'\u0030'+'\u0020'+'\u0023');//aA0 #

    System.out.println("Octal escape:");
    System.out.println(""+'\0'+'\7'+'\00'+'\07'+'\37'+'\77'
        +'\000'+'\007'+'\077'+'\177');
    System.out.println("Octal escape 0, 127, again: " + '\0' + '\177');
    System.out.println("Unicode escape:");
    System.out.println(""+'\u0000'+'\u0001'+'\uu0007'+'\u0010'+'\uuu007f');
		System.out.println("Done!");
	}
}
