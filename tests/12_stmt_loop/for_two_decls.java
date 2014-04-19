// For with index var declaration inside for.

public class for_two_decls {
  public static void main(String[] args) {
    for(int i=0, j=0; i<5; i++, j = i % 2) {
      System.out.println(i + " " + j);
    }
    System.out.println("Done!");
  }
}
