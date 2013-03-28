public class Operators_JBook {
  public static void main(String[] args) {
    int li;
    boolean lb;

		int a = 0, i = 1;

		//Infix operators
		lb = true || false;
		//lb = true && false;
		//li = 1 | 2;
		//li = 1 ^ 2;
		//li = 1 & 2;
		lb = 1 == 2;
		lb = 1 != 2;
		lb = 1 < 2;
		lb = 1 > 2;
		lb = 1 <= 2;
		lb = 1 >= 2;
		//li = 1 << 2;
		//li = 1 >> 2;
		//li = 1 >>> 2;
		li = 1 + 2;
		li = 1 - 2;
		li = 1 * 2;
		li = 1 / 2;
		li = 1 % 2;

		//Prefix operators
		//++ i;
		//-- i;
		lb = ! true;
		//li = ~ 1;
		li = + 1;
		li = - 1;

		//Postfix operators
		i ++;
		i --;

    //Ternary operator
    li = 4 > 2 ? 4 : 2;

		//Assignment operators
		a = i;
		//a += i;
		//a -= i;
		//a *= i;
		//a /= i;
    //a %= i;
		//a &= i;
		//a |= i;
		//a ^= i;
		//a <<= i;
		//a >>= i;
		//a >>>= i;

    System.out.println("Done!");
  }
}
