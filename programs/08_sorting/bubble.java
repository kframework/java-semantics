// This program bubble sorts an array passed as input from the standard
// console (first its length, then its elements).  It reads and prints
// each elements, then it prints the entire array sorted.

class main {
  int[] v = new int[30];

  void bubbleSort(int n) {
    int t;
    boolean sorted = false;
    while(!sorted) {
      sorted = true;
      for (int y = 0; y < n - 1; ++y) {
        if (v[y] > v[y+1]) {
          t = v[y];
          v[y] = v[y+1];
          v[y+1] = t;
          sorted = false;
        }
      }
    }
  }

  int read() {
    return Integer.parseInt(System.console().readLine());
  }

  void main(String[] args) {
    System.out.print("Length of array = ");
    int x = read();
    System.out.println("Input each of the "+x+" elements of the array");
    for (int y = 0; y<x; ++y) {
      System.out.print("Element "+y+" = ");
      v[y] = read();
    }
    System.out.print("Sorting the array using bubble sort ... ");
    bubbleSort(x);
    System.out.println("Done!"+"\n"+ "Below is the sorted sequence:");
    for (int y = 0; y<x; ++y) {
      System.out.println("Element "+ y+ " = "+ v[y]);
    }
    System.out.println("Done!");
  }
}
