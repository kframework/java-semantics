//Multiplication of two matrixes. In this program the general form of array creation expression is tested.

class main {

  int[][] matrixMul(int[][] m1, int[][] m2) {
    int[][] rez = new int[m1.length][m2[0].length];
    int s;
    for(int i=0; i<m1.length; ++i) {
      for(int k=0; k<m2[0].length; ++k) {
        s=0;
        for(int j=0; j<m2.length; ++j) {
          s = s + m1[i][j]*m2[j][k];
        }
        rez[i][k] = s;
      }
    }
    return rez;
  }

  void matrixPrint(int[][] m1) {
    for(int i=0; i<m1.length; ++i) {
      for(int j=0; j<m1[i].length; ++j) {
        System.out.print(m1[i][j] + " ");
      }
      System.out.println();
    }
  }

  main(String[] args) {
    int n=2, m=3, p=2;
    int[][] m1,m2;
    m1 = new int[n][m];
    for(int i=0; i<n; ++i) {
      for(int j=0; j<m; ++j) {
        m1[i][j] = i+j;
      }
    }
    System.out.println("M1=");
    matrixPrint(m1);
    m2 = new int[m][p];
    for(int i=0; i<m; ++i) {
      for(int j=0; j<p; ++j) {
        m2[i][j] = 1;
      }
    }
    System.out.println("M2=");
    matrixPrint(m2);
    int[][] rez = matrixMul(m1, m2);
    System.out.println("M1 * M2 = ");
    matrixPrint(rez);
    System.out.println("Done!");
  }
}

public class matrixMul {
  public static void main(String[] args) {
    new main(args);
  }
}

