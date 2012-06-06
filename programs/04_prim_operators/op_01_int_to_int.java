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
		vs[i++] = "9 | 3        ";
		vs[i++] = "9 ^ 3        ";
		vs[i++] = "9 & 3        ";
		vs[i++] = "9 | -4       ";
		vs[i++] = "9 ^ -4       ";
		vs[i++] = "9 & -4       ";
		vs[i++] = "-10 | 3      ";
		vs[i++] = "-10 ^ 3      ";
		vs[i++] = "-10 & 3      ";
		vs[i++] = "9 << 3       ";
		vs[i++] = "9 >> 3       ";
		vs[i++] = "9 >>> 3      ";
		vs[i++] = "9 + 3        ";
		vs[i++] = "9 - 3        ";
		vs[i++] = "9 * 3        ";
		vs[i++] = "9 / 3        ";
		vs[i++] = "9 % 3        ";

		//Prefix operators
		vs[i++] = "++9          ";
		vs[i++] = "--9          ";
		vs[i++] = "~ 9          ";
		vs[i++] = "+ 9          ";
		vs[i++] = "- 9          ";

		//Postfix operators
		vs[i++] = "9++          ";
		vs[i++] = "9--          ";

    //Ternary operator
    vs[i++] = "9 > 3 ? 9 : 3";

    nrOps = i;
    return vs;
  }

	main(String[] args) {
    int[] v = new int[nrOps];
    String[] vs = initVS();

    for(int i=0; i<nrOps; i++) {
      v[i] = 9;
    }

    int i=0;
		//Infix operators
		v[i++] = 9 | 3;
		v[i++] = 9 ^ 3;
		v[i++] = 9 & 3;
		v[i++] = 9 | -4;
		v[i++] = 9 ^ -4;
		v[i++] = 9 & -4;
		v[i++] = -10 | 3;
		v[i++] = -10 ^ 3;
		v[i++] = -10 & 3;
		v[i++] = 9 << 3;
		v[i++] = 9 >> 3;
		v[i++] = 9 >>> 3;
		v[i++] = 9 + 3;
		v[i++] = 9 - 3;
		v[i++] = 9 * 3;
		v[i++] = 9 / 3;
		v[i++] = 9 % 3;

		//Prefix operators
		++v[i++];
		--v[i++];
		v[i++] = ~ 9;
		v[i++] = + 9;
		v[i++] = - 9;

		//Postfix operators
		v[i] = v[i++]++;
		v[i] = v[i++]--;

    //Ternary operator
    v[i++] = 9 > 3 ? 9 : 3;

    printAll(vs,v);
    System.out.println("Done!");
	}
}

public class op_01_int_to_int {
  public static void main(String[] args) {
    new main(args);
  }
}
