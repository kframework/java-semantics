/*
Two simple packages pack1 and pack2. Two classes with the same simple name, one in each package.
  Refer both through fully-qualified names.
*/

public class packages_13_class_name_amb {
  public static void main(String[] args) {
    System.out.println(new pack1.A() + " " + new pack2.A());
    System.out.println("Done!");
  }
}
