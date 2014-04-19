// This program heap sorts an array passed as input from the standard
// console (first its length, then its elements).  It reads and prints
// each elements, then it prints the entire array sorted

import java.util.*;

class main {
  Scanner scanner = new Scanner(System.in);
  int[] v = new int[30];

  void siftDown(int root, int bottom) {
    boolean done = false;
    int maxChild, temp;

    while (root*2 <= bottom && !done) {
      if (root*2 == bottom)
        maxChild = root*2;
      else if (v[root*2] > v[root*2 + 1])
        maxChild = root*2;
      else
        maxChild = root*2 + 1;
      if (v[root] < v[maxChild]) {
        temp = v[root];
        v[root] = v[maxChild];
        v[maxChild] = temp;
        root = maxChild;
      }
      else
        done = true;
    }
  }

  void heapSort(int size) {
    int temp, i = (size/2) - 1;
    while (i >= 0) {
      siftDown(i, size - 1);
      i = i - 1;
    }
    i = size - 1;
    while (i >= 1 ) {
      temp = v[0];
      v[0] = v[i];
      v[i] = temp;
      siftDown(0, i - 1);
      i = i - 1;
    }
  }

  main(String[] args) {
    System.out.print("Length of array = ");
    int x = scanner.nextInt();
    System.out.println("Input each of the "+x+" elements of the array");
    for (int y = 0; y<x; ++y) {
      System.out.print("Element "+y+" = ");
      v[y] = scanner.nextInt();
    }
    System.out.print("Sorting the array using heap sort ... ");
    heapSort(x);
    System.out.println("Done!");
    System.out.println("Below is the sorted sequence:");
    for (int y = 0; y<x; ++y) {
      System.out.println("Element "+ y+ " = "+ v[y]);
    }
    System.out.println("Done!");
  }
}

public class heap {
  public static void main(String[] args) {
    new main(args);
  }
}

