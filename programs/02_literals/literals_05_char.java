//main character literals - the part supported by maude
public class literals_05_char {
	public static void main(String[] args) {
		System.out.println("Standart single char literals:");
    System.out.println(""+'a'+'A'+'0'+' '+'#');//aA0 #
    System.out.println("Single chars, same as in named escapes:");
    System.out.println(""+'b'+'t'+'n'+'f'+'r');
    System.out.println("Named escape:");
    System.out.println(""+'\b'+'\t'+'\n'+'\f'+'\r'+'\"'+'\''+'\\');
    System.out.println("Octal escape of simple chars:");
    System.out.println(""+'\141'+'\101'+'\60'+'\40'+'\43');//aA0 #
    System.out.println("Unicode escape of simple chars:");
    System.out.println(""+'\u0061'+'\u0041'+'\u0030'+'\u0020'+'\u0023');//aA0 #
		System.out.println("Done!");
	}
}
