public class bst {
int value;
bst left;
bst right;

  public static void main(String[] args) {
  bst node1 = new bst ();
bst node2 = new bst ();
bst node3 = new bst ();
node1.left = node2;
node1.right = node3;
}

static int find(int v, bst t)
{
  if (t == null)
    return false;
  else if (v == t.value)
    return true;
  else if (v < t.value)
    return find(v, t.left);
  else
    return find(v, t.right);
}

}
