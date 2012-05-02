// Building and traversing a tree.

class Node {
  void Node(){}

  int Sum() {}
}

class Container extends Node {
  Node left, right;

  void Container(Node left, Node right) {
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

  void Leaf(int val) {
    this.val = val;
  }

  int Sum() {
    return val;
  }
}

class main {
  void main(string[] args) {
    Container o;
    o = new Container(
      new Container(new Leaf(3), new Leaf(4)),
      new Leaf(5)
    );
    print(o.Sum(), "\n");
    print("o.left.Sum = " + o.getLeft().Sum() + "\n");
    print("Done!","\n");
  }
}

// 12
// o.left.Sum = 7
// Done!
