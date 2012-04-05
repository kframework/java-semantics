// This program should execute correctly

public class main {
	int[] x;

	void init(int n) {
		x = new int[n];
		for (int i = 0; i<n; x[i] = n - i + 100, i++) {}
	}

	void printAll(int n) {
    string s = "";
		for (int i = 0, xi; i<n; i++) {
      xi = x[i];
      s = s + " " + xi;
		}
    print(s);
	}

	void main(string[] args) {
		int n=30;
		init(n);
		print("The original sequence is");
		printAll(n);
		print("\n", "Sorting the array using insertion sort ... ");
		for (int i = 0; i<n; i++) {
			int j = i - 1, v = x[i];
			while (j >= 0 && x[j] > v) {
				x[j + 1] = x[j];
				j = j - 1;
			}
			x[j+1] = v;
		}
		print("Done!", "\n", "The sorted sequence is");
		printAll(n);
		print("\n");
	}
}
