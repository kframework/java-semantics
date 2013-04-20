/*
String += cases:
  - object += string
  - array[object] += string
*/
public class str_conv_03_Object_assign_plus {
  public static void main(String[] args) {
    Object o = new RuntimeException("re-");
    Object o2 = o;
    System.out.println((""+(o2+="zz")));

    Object[] vo = new Object[1];
    vo[0] = o;
    System.out.println((vo[0]+="cde"));
    System.out.println("Done!");
  }
}
