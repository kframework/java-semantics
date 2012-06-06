class main {

	void printAll(String[] vs, int[] v) {
		for (int i = 0; i<nrOps; i++) {
      System.out.println(vs[i]+" = "+v[i]);
		}
	}

  int nrOps = 30;

  String[] initVS() {
    String[] vs = new String[nrOps];
    int i=0;

		//Infix operators
		vs[i++] = " 2147483647 + 2147483647      ";
		vs[i++] = "-2147483647 - 2147483647      ";
		vs[i++] = " 2147483647 * 2147483647      ";
    vs[i++] = "- (-2147483648)               ";
    vs[i++] = "++2147483647                  ";
    vs[i++] = "2147483647++                  ";
    vs[i++] = "-- (-2147483648)              ";
    vs[i++] = "(-2147483648)--               ";
    vs[i++] = "~(-2147483648)                ";
    vs[i++] = "2147483647 | (-2147483648)    ";
    vs[i++] = "2147483647 ^ (-2147483648)    ";
    vs[i++] = "3 << 31                       ";

    nrOps = i;

    return vs;
  }

	main(String[] args) {
    int[] v = new int[nrOps];
    String[] vs = initVS();

    int i=0;
		//Infix operators
		v[i++] =  2147483647 + 2147483647;
		v[i++] = -2147483647 - 2147483647;
		v[i++] =  2147483647 * 2147483647;
    v[i++] = - (-2147483648);
    v[i] = 2147483647;
    ++v[i++];
    v[i] = 2147483647;
    v[i++]++;
    v[i] = -2147483648;
    --v[i++];
    v[i] = -2147483648;
    v[i++]--;
    v[i++] = ~(-2147483648);
    v[i++] = 2147483647 | (-2147483648);
    v[i++] = 2147483647 ^ (-2147483648);
    v[i++] = 3 << 31;

    printAll(vs,v);
    System.out.println("Done!");
	}
}

public class op_05_int_to_int_overflow {
  public static void main(String[] args) {
    new main(args);
  }
}
