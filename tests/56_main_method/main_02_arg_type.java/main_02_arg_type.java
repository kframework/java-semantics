/*
Choosing the main class.
  A program with three public classes - one with the name before the main class, main class,
  and the third one after the main class. Classes one and three also have public static
  methods main, with one argument, but the type is int, respectively Object[].
  The main class have another method main with type int[]. Test that the main class is correctly
  choosen.
*/

public class main_02_arg_type {
  public static void main(String[] args) {
    System.out.println("<main class>.main(String[])");
    System.out.println("Done!");
  }

  public static void main(int[] args) {
    System.out.println("<main class>.main(int[])");
  }
}
