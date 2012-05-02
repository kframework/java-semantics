public class Main {

  int[] init(int n) {
    int[] x = new int[n];
    print("Type ",n," numbers: ");
    for (int i = 0; i<n; ++i)
      x[i] = read();
    print("Finished reading the ",n," numbers","\n");
    return x;
  }

  void printArray(int[] x, int n) {
    print("\n");
    for (int i = 0; i<n; ++i)
      print(x[i]," ");
    print("\n");
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

  void main(string[] args) {
    print("Size of the array to sort = ");
    int n = read();
    int[] x = init(n);
    print("The original unsorted array is:");
    printArray(x,n);
    print("Reversing the array ... ");
    reverse(x,n);
    print("Done!"+"\n"+"The reversed array is:");
    printArray(x,n);
    print("Sorting the array using insertion sort ... ");
    insertionSort(x,n);
    print("Done!"+"\n"+"The resulting array is:");
    printArray(x,n);
    print("Reversing the array ... ");
    reverse(x,n);
    print("Done!"+"\n"+"Sorting the array using bubble sort ... ");
    bubbleSort(x,n);
    print("Done!"+"\n"+"The resulting array is:");
    printArray(x,n);
    print("Reversing the array ... ");
    reverse(x,n);
    print("Done!"+"\n"+"Sorting the array using heap sort ... ");
    heapSort(x,n);
    print("Done!"+"\n"+"The resulting array is:");
    printArray(x,n);
  }
}
