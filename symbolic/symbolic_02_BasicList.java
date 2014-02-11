/*
kompile -v java --symbolic-rules "symbolic-rule" --backend symbolic

time timeout 300 krun --debug-info --color extended --directory="." --main-module=JAVA \
  -cMainClass="ListItem(\"symbolic_02_BasicList\")" -cModelCheck="false" --output=pretty --parser="kj-parse-aggreg.sh" \
  ../symbolic/symbolic_02_BasicList.java \
  -cIN="ListItem(#symInt(e1)) ListItem(#symInt(e2)) ListItem(#symInt(x))" -cPC="true" --search

Expected output: 4 solutions, one of them containing error message.
*/
import java.util.*;

class BasicList {
  int a[] = new int[10];
  int size, capacity;

  BasicList() { size = 0; capacity = 10; }

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

  boolean eqTo(BasicList l) {
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

  BasicList copy() {
    BasicList t = new BasicList();
    int i = 0;
    t.size = size;
    while(i < size) {
        t.a[i] = a[i];
        i = i + 1;
    }
    return t;
  }
}

public class symbolic_02_BasicList {
  public static void main(String[] args) {
    int i = 0;
    BasicList l1 = new BasicList();
    Scanner scanner = new Scanner(System.in);
    while (i < 2) {
      l1.insert(scanner.nextInt());
      i = i+1;
    }
    int x = scanner.nextInt();

    BasicList l2 = l1.copy();
    l1.insert(x);
    l1.delete(x);
    if (l2.eqTo(l1) == false) {
      System.out.println("error");
    } else {
      System.out.println("ok");
    }
    System.out.println("Done!");
  }
}