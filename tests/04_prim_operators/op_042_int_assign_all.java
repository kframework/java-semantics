public class op_042_int_assign_all {
  public static void main(String[] args) {
    new main(args);
  }
}

class main {

	void printAll(String[] vs, int[] v) {
		for (int i = 0; i<v.length; i++) {
      System.out.println(vs[i]+"  =>  "+v[i]);
		}
	}

  int nrOps = 12;

  String[] initVS() {
    String[] vs = new String[nrOps];
    int i=0;

		vs[i++] = "9 = 3   ";
		vs[i++] = "9 +=   3";
		vs[i++] = "9 -=   3";
		vs[i++] = "9 *=   3";
		vs[i++] = "9 /=   3";
		vs[i++] = "9 &=   3";
		vs[i++] = "9 |=   3";
		vs[i++] = "9 ^=   3";
		vs[i++] = "9 %=   3";
		vs[i++] = "9 <<=  3";
		vs[i++] = "9 >>=  3";
		vs[i++] = "9 >>>= 3";

    return vs;
  }

	main(String[] args) {
    int[] v = new int[nrOps];
    String[] vs = initVS();

    for(int i=0; i<nrOps; i++) {
      v[i] = 9;
    }
    int i=0;

		v[i++] = 3;
		v[i++] += 3;
		v[i++] -= 3;
		v[i++] *= 3;
		v[i++] /= 3;
		v[i++] &= 3;
		v[i++] |= 3;
		v[i++] ^= 3;
		v[i++] %= 3;
		v[i++] <<= 3;
		v[i++] >>= 3;
		v[i++] >>>= 3;

    printAll(vs,v);
    System.out.println("Done!");
	}
}

