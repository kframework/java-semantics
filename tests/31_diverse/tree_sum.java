// Building and traversing a tree.

class Node {
  Node(){}

  int Sum() {return -1;}
}

class Container extends Node {
  Node left, right;

  Container(Node left, Node right) {
    this.left = left;
    this.right = right;
  }

  int Sum() {
    return (left.Sum() + right.Sum());
  }

  Node getLeft() {return left;}
  Node getRight() {return right;}
}

class Leaf extends Node {
  int val;

  Leaf(int val) {
    this.val = val;
  }

  int Sum() {
    return val;
  }
}

public class tree_sum {
  public static void main(String[] args) {
    Container o;
    o = new Container(
      new Container(new Leaf(3), new Leaf(4)),
      new Leaf(5)
    );
    System.out.println(o.Sum());
    System.out.println("o.left.Sum = " + o.getLeft().Sum());
    System.out.println("Done!");
  }
}

// 12
// o.left.Sum = 7
// Done!
