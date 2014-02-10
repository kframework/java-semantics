/*
$KOMPILE_CMD -v java --symbolic-rules "symbolic-rule" --backend symbolic

time timeout 300 krun --debug-info --color extended --directory="/home/andrei.arusoaie/work/java-semantics/tools/../semantics" --main-module=JAVA -cMainClass="ListItem(\"test\")" -cModelCheck="false" --output=pretty --parser="kj-parse-aggreg.sh" ../symbolic/test.java -cIN="ListItem(#symInt(e1)) ListItem(#symInt(e2)) ListItem(#symInt(x))" -cPC="true" --search

Expected output: 4 solutions, one of them containing error message.
*/
import java.util.*;

class List {
  int a[] = new int[10];
  int size, capacity;

  List () { size = 0; capacity = 10; }

  void insert (int x) {
    if (size < capacity) {
      a[size] = x;
      ++size;
    }
  }

  void delete(int x) {
    int i = 0;
    while (i < size-1 && a[i] != x) {
        i = i + 1;
    }
    if (a[i] == x) {
      while (i < size - 1) {
          a[i] = a[i+1];
          i = i + 1;
      }
      size = size - 1;
    }
  }

  int getAt(int i) {
    if (i < size) {
        return a[i];
    }
    return -1;
  }

  boolean eqTo(List l) {
    if (size != l.size) {
        return false;
    }
    int i = 0;
    while (i < size - 1 && a[i] == l.getAt(i)) {
        i = i + 1;
    }
    if (a[i] == l.getAt(i)) {
        return true;
    }
    return false;
  }

  List copy() {
    List t = new List();
    int i = 0;
    t.size = size;
    while(i < size) {
        t.a[i] = a[i];
        i = i + 1;
    }
    return t;
  }
}

public class test {
  public static void main(String[] args) {
    int i = 0;
    List l1 = new List();
    Scanner scanner = new Scanner(System.in);
    while (i < 2) {
      l1.insert(scanner.nextInt());
      i = i+1;
    }
    int x = scanner.nextInt();

    List l2 = l1.copy();
    l1.insert(x);
    l1.delete(x);
    if (l2.eqTo(l1) == false) {
        System.out.println("error");
    }
  }
}