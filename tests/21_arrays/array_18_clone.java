/*
array.clone
  - one dim, array of ints, length = 0, full test
  - two dims, array of ints, [zero][zero], full test
  - int[3], full test
  - int[2][0], full test
  - int[2][2], full test
  - Object[2] - values are string, RuntimeException, full test
  - null.clone(), full test
  - int[][] = {{...}, null} , clone, full test
  By full test we mean test for ==, and full test on all elements
    (possible recursively).
*/

public class array_18_clone {

  public static void main(String[] args) {
    new main();
    System.out.println("Done!");
  }
}

class main {
  main() {
    int[] v1 = new int[0];
    int[] v2 = (int[]) v1.clone();
    cloneTest(v1,v2);

    int[][] m1 = new int[0][0];
    int[][] m2 = (int[][]) m1.clone();
    matrixCloneTest(m1,m2);

    v1 = allocateAndInitArray(4,2);
    cloneTest(v1, (int[])v1.clone());

    m1 = new int[2][0];
    matrixCloneTest(m1, (int[][])m1.clone());

    m1 = new int[2][];
    m1[0] = allocateAndInitArray(10,2);
    m1[1] = allocateAndInitArray(20,2);
    matrixCloneTest(m1, (int[][])m1.clone());

    Object[] vo = new Object[4];
    vo[0] = "str";
    vo[1] = new RuntimeException("re");
    vo[2] = new Object();
    vo[3] = null;
    Object[] vo2 = (Object[])vo.clone();
    System.out.print("Object[] : "+ (vo == vo2) + " : ");
    for(int i=0; i<vo2.length; i++) {
      System.out.print((vo[i] == vo2[i]) + " ");
    }
    System.out.println();

    System.out.println("Null tests:");
    v1 = null;
    try {
      v2 = (int[])v1.clone();
      cloneTest(v1, v2);
    } catch (NullPointerException e) {
      System.out.println(e);
    }

    m1[1] = null;
    try {
      m2 = (int[][])m1.clone();
      matrixCloneTest(m1, m2);
    } catch (NullPointerException e) {
      System.out.println(e);
    }
  }

  void cloneTest(int[] v1, int[] v2) {
    System.out.print((v1 == v2)+" : ");
    if (v1 == null) {
      System.out.println(v1 + "+" + v2);
    } else {
      for(int i=0; i<v1.length; i++) {
        System.out.print((v1[i] == v2[i]) + " ");
      }
      System.out.println();
    }
  }

  void matrixCloneTest(int[][] m1, int[][] m2) {
    System.out.println("Matrix " + (m1 == m2)+" : ");
    if (m1 == null) {
      System.out.println(m1 + "+" + m2);
    } else {
      for(int i=0; i<m1.length; i++) {
        cloneTest(m1[i],m2[i]);
      }
      System.out.println("end matrix.\n");
    }
  }

  int[] allocateAndInitArray(int start, int length) {
    int[] v = new int[length];
    for(int i=0; i<length; i++) {
      v[i] = start + i;
    }
    return v;
  }
}
