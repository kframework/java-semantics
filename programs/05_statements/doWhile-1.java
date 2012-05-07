// test of doWhile

class main {

	void main(String[] args) {
    int i=0, j=0;
		do i++; while (false);
    do j++; while (j < 3);

    System.out.println(i+" "+j);
    System.out.println("Done!");
	}
}
// 1 3
// Done!
