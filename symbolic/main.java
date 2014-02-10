/*
$KOMPILE_CMD -v java --symbolic-rules "symbolic-rule" --backend symbolic

time timeout 300 krun --debug-info --color extended --directory="/home/andrei.arusoaie/work/java-semantics/tools/../semantics" --main-module=JAVA -cMainClass="ListItem(\"test\")" -cModelCheck="false" --output=pretty --parser="kj-parse-aggreg.sh" ../symbolic/main.java -cIN="ListItem(#symInt(e1)) ListItem(#symInt(e2)) ListItem(#symInt(x))" -cPC="true" --search

Expected output (unreached at the moment): 11 solutions, none of them containing error message.
*/
import java.util.*;

class LList {
  int a[] = new int[10];
  int size, capacity;

  LList () { size = 0; capacity = 10; }

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

  boolean eqTo(LList l) {
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

  LList copy() {
    LList t = new LList();
    int i = 0;
    t.size = size;
    while(i < size) {
        t.a[i] = a[i];
        i = i + 1;
    }
    return t;
  }
}

class OrderedList extends LList {

    OrderedList() {
        super();
    }

    void insert(int x) {
        if (size < capacity) {
            int i = 0;
            while(i < size && a[i] <= x) { i = i + 1; }
            ++size;
            int k = size - 1;
            while(k > i) { a[k] = a[k-1]; k = k - 1; }
            a[i] = x;
        }
    }

    OrderedList copy() {
        OrderedList t = new OrderedList();
        int i = 0;
        t.size = size;
        while(i < size) { t.a[i] = a[i]; i = i + 1; }
        return t;
    }
}

public class main {
  public static void main(String[] args) {
    int i = 0;
    LList l1 = new OrderedList();
    Scanner scanner = new Scanner(System.in);
    while (i < 2) {
      l1.insert(scanner.nextInt());
      i = i+1;
    }
    int x = scanner.nextInt();

    LList l2 = l1.copy();
    l1.insert(x);
    l1.delete(x);
    if (l2.eqTo(l1) == false) {
        System.out.println("error");
    }
  }
}