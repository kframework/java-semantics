/*
Array instanceof complex cases:
  Object Object instanceof int[]
  Object int[] instanceof Object
  Object Object[] instanceof int[]
  Object int[] instanceof Object[]
  Object int[] instanceof int[][]
  Object int[][] instanceof int[]
  Object int[][] instanceof Object[]
  Object Object[] instanceof int[][]
  Object String instanceof int[]
  Object int[] instanceof String
  Object RE instanceof int[]
  Object int[] instanceof RE
  Object RE[] instanceof int[]
  Object int[] instanceof RE[]
*/

public class array_21_instanceof_complex {

  public static void main(String[] args) {
    System.out.println(((Object)new Object()) instanceof int[]);
    System.out.println(((Object)new int[0]) instanceof Object);
    System.out.println(((Object)new Object[0]) instanceof int[]);
    System.out.println(((Object)new int[0]) instanceof Object[]);
    System.out.println(((Object)new int[0]) instanceof int[][]);
    System.out.println(((Object)new int[0][]) instanceof int[]);
    System.out.println(((Object)new int[0][]) instanceof Object[]);
    System.out.println(((Object)new Object[0]) instanceof int[][]);
    System.out.println(((Object)"abc") instanceof int[]);
    System.out.println(((Object)new int[0]) instanceof String);
    System.out.println(((Object)new RuntimeException("")) instanceof int[]);
    System.out.println(((Object)new int[0]) instanceof RuntimeException);
    System.out.println(((Object)new RuntimeException[0]) instanceof int[]);
    System.out.println(((Object)new int[0]) instanceof RuntimeException[]);

    System.out.println("Done!");
  }
}
