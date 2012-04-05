// This version of insertion sorting declares the vector in the init function
// and then passes it (actually its reference) where it is needed

public class main {

	int[] init(int n) {
		int[] x = new int[n];
		for (int i = 0; i<n; x[i] = n - i + 100, ++i) {}
    return x;
	}

	void printAll(int[] x) {
    string s = "";
		for (int i = 0, xi; i<x.length; ++i) {
      xi = x[i];
      s = s + " " + xi;
		}
    print(s);
	}

	void main(string[] args) {
		int n=30;
    int[] x = init(n);
		print("The original sequence is");
		printAll(x);
		print("\n", "Sorting the array using insertion sort ... ");
		for (int i = 0; i<n; ++i) {
			int j = i - 1, v = x[i];
			while (j >= 0 && x[j] > v) {
				x[j + 1] = x[j];
				j = j - 1;
			}
			x[j+1] = v;
		}
		print("Done!", "\n", "The sorted sequence is");
		printAll(x);
		print("\n");
	}
}
