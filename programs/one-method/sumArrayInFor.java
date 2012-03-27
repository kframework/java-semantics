public class main {

	public static void main(string[] args) {
		int n=4;
		int s,i;

		int[] v = new int[n + 1];
		for(i=0; i<=n; ++i) {
			v[i] = i;
		}

		s=0;
		for(i=0; i<=n; ++i) {
			s = s + v[i];
		}
		print("sum 1..", n, "=", s, "\n");
	}
}
