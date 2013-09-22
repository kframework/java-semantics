/*Testing String.charAt(), just the normal case*/

public class String_charAt {

  public static void main(String[] args) {
    String s = "abc";
    for(int i=0; i<s.length(); i++) {
      System.out.println("s.charAt("+i+")= " + s.charAt(i));
    }
    System.out.println("Done!");
  }
}
