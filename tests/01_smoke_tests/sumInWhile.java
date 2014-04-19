public class sumInWhile {

	public static void main(String[] args) {
		int n,s,i;
    n=4;
		s=0;
		i=1;
		while(i<=n) {
			s = s + i;
			i = i + 1;
		}
		System.out.println("sum 1.." + n + "=" + s);
    System.out.println("Done!");
	}
}

// sum 1..4=10
// Done!
