public class main {

	public static void main(string[] args) {
		int n,s,i;
		print("n=");
		n=read();
		s=0;
		i=1;
		while(i<=n) {
			s = s + i;
			i = i + 1;
		}
		print("sum 1..", n, "=", s, "\n");
	}
}
