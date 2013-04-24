import java.util.*;

class main {

  Scanner scanner = new Scanner(System.in);

  int[] init(int n) {
    int[] x = new int[n];
    System.out.print("Type "+n+" numbers: ");
    for (int i = 0; i<n; ++i)
      x[i] = scanner.nextInt();
    System.out.println("Finished reading the "+n+" numbers");
    return x;
  }

  void printArray(int[] x, int n) {
    System.out.println();
    for (int i = 0; i<n; ++i)
      System.out.print(x[i]+" ");
    System.out.println();
  }

  void reverse(int[] x, int n) {
    for (int i = 0; i< n/2; ++i) {
      int t = x[i];
      x[i] = x[n - i - 1];
      x[n - i - 1] = t;
    }
  }

  void insertionSort(int[] x, int n) {
		for (int i = 0; i<n; ++i) {
			int j = i - 1, v = x[i];
			while (j >= 0 && x[j] > v) {
				x[j + 1] = x[j];
				j = j - 1;
			}
			x[j+1] = v;
		}
  }

  void bubbleSort(int[] v, int n) {
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

  void siftDown(int[] v, int root, int bottom) {
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

  void heapSort(int[] v, int size) {
    int temp, i = (size/2) - 1;
    while (i >= 0) {
      siftDown(v, i, size - 1);
      i = i - 1;
    }
    i = size - 1;
    while (i >= 1 ) {
      temp = v[0];
      v[0] = v[i];
      v[i] = temp;
      siftDown(v, 0, i - 1);
      i = i - 1;
    }
  }

  main(String[] args) {
    System.out.print("Size of the array to sort = ");
    int n = scanner.nextInt();
    int[] x = init(n);
    System.out.print("The original unsorted array is:");
    printArray(x,n);
    System.out.print("Reversing the array ... ");
    reverse(x,n);
    System.out.print("Done!"+"\n"+"The reversed array is:");
    printArray(x,n);
    System.out.print("Sorting the array using insertion sort ... ");
    insertionSort(x,n);
    System.out.print("Done!"+"\n"+"The resulting array is:");
    printArray(x,n);
    System.out.print("Reversing the array ... ");
    reverse(x,n);
    System.out.print("Done!"+"\n"+"Sorting the array using bubble sort ... ");
    bubbleSort(x,n);
    System.out.print("Done!"+"\n"+"The resulting array is:");
    printArray(x,n);
    System.out.print("Reversing the array ... ");
    reverse(x,n);
    System.out.print("Done!"+"\n"+"Sorting the array using heap sort ... ");
    heapSort(x,n);
    System.out.print("Done!"+"\n"+"The resulting array is:");
    printArray(x,n);
    System.out.println("Done!");
  }
}

public class all_sorting {
  public static void main(String[] args) {
    new main(args);
  }
}

