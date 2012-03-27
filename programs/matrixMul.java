//Multiplication of two matrixes. In this program the general form of array creation expression is tested.

public class main {

  int[][] matrixMul(int[][] m1, int[][] m2, int n, int m, int p) {
    int[][] rez = new int[n][p];
    int s;
    for(int i=0; i<n; ++i) {
      for(int k=0; k<p; ++k) {
        s=0;
        for(int j=0; j<m; ++j) {
          s = s + m1[i][j]*m2[j][k];
        }
        rez[i][k] = s;
      }
    }
    return rez;
  }

  void matrixPrint(int[][] m1, int n, int m) {
    for(int i=0; i<n; ++i) {
      for(int j=0; j<m; ++j) {
        print(m1[i][j]," ");
      }
      print("\n");
    }
  }

  void main(string[] args) {
    int n=2, m=3, p=2;
    int[][] m1,m2;
    m1 = new int[n][m];
    for(int i=0; i<n; ++i) {
      for(int j=0; j<m; ++j) {
        m1[i][j] = i+j;
      }
    }
    print("M1=","\n");
    matrixPrint(m1,n,m);
    m2 = new int[m][p];
    for(int i=0; i<m; ++i) {
      for(int j=0; j<p; ++j) {
        m2[i][j] = 1;
      }
    }
    print("M2=","\n");
    matrixPrint(m2,m,p);
    int[][] rez = matrixMul(m1, m2, n, m, p);
    print("M1 * M2 = ","\n");
    matrixPrint(rez,n,p);
  }
}
