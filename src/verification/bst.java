public class bst {
int value;
bst left;
bst right;

  public static void main(String[] args) {
  bst node1 = new bst (0);
bst node2 = new bst (0);
bst node3 = new bst (0);
node1.left = node2;
node1.right = node3;
}

static boolean find(int v, bst t)
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

    

     bst (int value)
    {
        this.value = value;
        this.left = null;
        this.right = null;
    }


    static bst insert(int v, bst t)
    {
        if (t == null)
            return new bst(v);

        if (v < t.value)
            t.left = insert(v, t.left);
        else if (v > t.value)
            t.right = insert(v, t.right);

        return t;
    }


    static int find_min(bst t)
    {
        if (t.left == null)
            return t.value;
        else
            return find_min(t.left);
    }

    static bst delete(int v, bst t)
    {
        int min;

        if (t == null)
            return t;

        if (v == t.value) {
            if (t.left == null) {
                                return t.right;
            }
            else if (t.right == null) {

                return t.left;
            }
            else {
                min = find_min(t.right);
                t.right = delete(min, t.right);
                t.value = min;
            }
        }
        else if (v < t.value)
            t.left = delete(v, t.left);
        else
            t.right = delete(v, t.right);

        return t;
    }
}
