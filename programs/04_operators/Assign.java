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

		vs[i++] = "4 = 2   ";
		vs[i++] = "4 +=   2";
		vs[i++] = "4 -=   2";
		vs[i++] = "4 *=   2";
		vs[i++] = "4 /=   2";
		vs[i++] = "4 &=   2";
		vs[i++] = "4 |=   2";
		vs[i++] = "4 ^=   2";
		vs[i++] = "4 %=   2";
		vs[i++] = "4 <<=  2";
		vs[i++] = "4 >>=  2";
		vs[i++] = "4 >>>= 2";

    return vs;
  }

	static void main(String[] args) {
    int[] v = new int[nrOps];
    String[] vs = initVS();

    for(int i=0; i<nrOps; i++) {
      v[i] = 4;
    }
    int i=0;

		v[i++] = 2;
		v[i++] += 2;
		v[i++] -= 2;
		v[i++] *= 2;
		v[i++] /= 2;
		v[i++] &= 2;
		v[i++] |= 2;
		v[i++] ^= 2;
		v[i++] %= 2;
		v[i++] <<= 2;
		v[i++] >>= 2;
		v[i++] >>>= 2;

    printAll(vs,v);
    System.out.println("Done!");
	}
}
