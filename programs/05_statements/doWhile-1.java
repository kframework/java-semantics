// test of doWhile

public class main {

	void main(string[] args) {
    int i=0, j=0;
		do i++; while (false);
    do j++; while (j < 3);

    print(i," ",j,"\n");
    print("Done!","\n");
	}
}
// 1 3
// Done!
