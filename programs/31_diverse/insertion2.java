// This version of insertion sorting declares the vector in the init function
// and then passes it (actually its reference) where it is needed

class main {

	int[] init(int n) {
		int[] x = new int[n];
		for (int i = 0; i<n; x[i] = n - i + 100, ++i) {}
    return x;
	}

	void printAll(int[] x) {
    String s = "";
		for (int i = 0, xi; i<x.length; ++i) {
      xi = x[i];
      s = s + " " + xi;
		}
    System.out.println(s);
	}

	main(String[] args) {
		int n=10;
    int[] x = init(n);
		System.out.print("The original sequence is");
		printAll(x);
		System.out.print("Sorting the array using insertion sort ... ");
		for (int i = 0; i<n; ++i) {
			int j = i - 1, v = x[i];
			while (j >= 0 && x[j] > v) {
				x[j + 1] = x[j];
				j = j - 1;
			}
			x[j+1] = v;
		}
    System.out.println("Sort completed.");
		System.out.print("The sorted sequence is");
		printAll(x);
    System.out.println("Done!");
	}
}

public class insertion2 {
  public static void main(String[] args) {
    new main(args);
  }
}

