/*
Main method return type.
  Three classes, all with a public static <Type> main(String[] args).
  <Type> is:
    - Object
    - void
    - String
  Test that the second case is chosen.
*/

public class main_03_return_type {
  public static void main(String[] args) {
    System.out.println("void main(String[])");
    System.out.println("Done!");
  }

  public static void main(int[] args) {
    System.out.println("<main class>.main(int[])");
  }
}
