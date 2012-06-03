class main {

	void printAll(String[] vs, int[] v) {
		for (int i = 0; i<nrOps; i++) {
      System.out.println(vs[i]+" = "+v[i]);
		}
	}

  int nrOps = 19;

  String[] initVS() {
    String[] vs = new String[nrOps];
    int i=0;

		//Infix operators
		vs[i++] = "4 | 2        ";
		vs[i++] = "4 ^ 2        ";
		vs[i++] = "4 & 2        ";
		vs[i++] = "4 << 2       ";
		vs[i++] = "4 >> 2       ";
		vs[i++] = "4 >>> 2      ";
		vs[i++] = "4 + 2        ";
		vs[i++] = "4 - 2        ";
		vs[i++] = "4 * 2        ";
		vs[i++] = "4 / 2        ";
		vs[i++] = "4 % 2        ";

		//Prefix operators
		vs[i++] = "++4          ";
		vs[i++] = "--4          ";
		vs[i++] = "~ 4          ";
		vs[i++] = "+ 4          ";
		vs[i++] = "- 4          ";

		//Postfix operators
		vs[i++] = "4++          ";
		vs[i++] = "4--          ";

    //Ternary operator
    vs[i++] = "4 > 2 ? 4 : 2";

    return vs;
  }

	main(String[] args) {
    int[] v = new int[nrOps];
    String[] vs = initVS();

    for(int i=0; i<nrOps; i++) {
      v[i] = 4;
    }

    int i=0;
		//Infix operators
		v[i++] = 4 | 2;
		v[i++] = 4 ^ 2;
		v[i++] = 4 & 2;
		v[i++] = 4 << 2;
		v[i++] = 4 >> 2;
		v[i++] = 4 >>> 2;
		v[i++] = 4 + 2;
		v[i++] = 4 - 2;
		v[i++] = 4 * 2;
		v[i++] = 4 / 2;
		v[i++] = 4 % 2;

		//Prefix operators
		++v[i++];
		--v[i++];
		v[i++] = ~ 4;
		v[i++] = + 4;
		v[i++] = - 4;

		//Postfix operators
		v[i] = v[i++]++;
		v[i] = v[i++]--;

    //Ternary operator
    v[i++] = 4 > 2 ? 4 : 2;

    printAll(vs,v);
    System.out.println("Done!");
	}
}

public class op_01_int_to_int {
  public static void main(String[] args) {
    new main(args);
  }
}
