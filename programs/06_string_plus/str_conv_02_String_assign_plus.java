/*
String += cases:
  - string += string
  - string += int
  - array[string] += string
*/
public class str_conv_02_String_assign_plus {
  public static void main(String[] args) {
    String s = "ab";
    System.out.println((s+="cde"));
    System.out.println((s+=12));
    String[] vs = new String[1];
    vs[0] = s;
    System.out.println((vs[0]+="cde"));
    System.out.println("Done!");
  }
}
