/*Testing String.charAt(), just the normal case, and String.length().
  Also adding the resulting char with an int.
*/

public class String_charAt {

  public static void main(String[] args) {
    String s = "abc";
    for(int i=0; i<s.length(); i++) {
      System.out.println("s.charAt("+i+")= " + s.charAt(i));
    }
    char nextOfA = (char)(s.charAt(0) + 1);
    System.out.println("next of a = " + nextOfA);
    System.out.println("Done!");
  }
}
