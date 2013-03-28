public class Operators_non_JBook {
  public static void main(String[] args) {
    int li;
    boolean lb;

		int a = 0, i = 1;

		//Infix operators
		li = 1 | 2;
		li = 1 ^ 2;
		li = 1 & 2;
		li = 1 << 2;
		li = 1 >> 2;
		li = 1 >>> 2;

		//Prefix operators
		++ i;
		-- i;
		li = ~ 1;

		//Assignment operators
		a += i;
		a -= i;
		a *= i;
		a /= i;
    a %= i;
		a &= i;
		a |= i;
		a ^= i;
		a <<= i;
		a >>= i;
		a >>>= i;

    System.out.println("Done!");
  }
}
