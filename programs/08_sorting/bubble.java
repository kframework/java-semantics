// This program bubble sorts an array passed as input from the standard
// console (first its length, then its elements).  It reads and prints
// each elements, then it prints the entire array sorted.

public class main {
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

  void main(string[] args) {
    print("Length of array = ");
    int x = read();
    print("Input each of the ",x," elements of the array","\n");
    for (int y = 0; y<x; ++y) {
      print("Element ",y," = ");
      v[y] = read();
    }
    print("Sorting the array using bubble sort ... ");
    bubbleSort(x);
    print("Done!","\n", "Below is the sorted sequence:","\n");
    for (int y = 0; y<x; ++y) {
      print("Element ", y, " = ", v[y],"\n");
    }
    print("Done!","\n");
  }
}
