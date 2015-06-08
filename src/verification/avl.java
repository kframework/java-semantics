public class avl {
int value;
int height;
avl left;
avl right;

    avl (int value)
    {
        this.value = value;
        this.height = 1;
        this.left = null;
        this.right = null;
    }


    public static void main(String[] args) {
avl node1 = new avl (0);
avl node2 = new avl (0);
avl node3 = new avl (0);
node1.left = node2;
node1.right = node3;
}

    static int find_min(avl t)
    {
        if (t.left == null)
            return t.value;
        else
            return find_min(t.left);
    }

    static int max(int a, int b)
    {
        return a > b ? a : b;
    }

    static int height(avl t)
    {
        return t == null ? 0: t.height;
    }

    static void update_height(avl t)
    {
        t.height = max(height(t.left), height(t.right)) + 1;
    }

    static avl left_rotate(avl x)
    {
        avl y;

        y = x.right;
        x.right = y.left;
        y.left = x;

        update_height(x);
        update_height(y);

        return y;
    }

    static avl right_rotate(avl x)
    {
        avl y;

        y = x.left;
        x.left = y.right;
        y.right = x;

        update_height(x);
        update_height(y);

        return y;
    }

    static avl balance(avl t)
    {
        if (height(t.left) - height(t.right) > 1) {
            if (height(t.left.left) < height(t.left.right))
                t.left = left_rotate(t.left);
            t = right_rotate(t);
        }
        else if (height(t.left) - height(t.right) < -1) {
            if (height(t.right.left) > height(t.right.right))
                t.right = right_rotate(t.right);
            t = left_rotate(t);
        }

        return t;
    }


static boolean find(int v, avl t)
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


    static avl insert(int v, avl t)
    {
        if (t == null)
            return new avl(v);

        if (v < t.value)
            t.left = insert(v, t.left);
        else if (v > t.value)
            t.right = insert(v, t.right);
        else
            return t;

        update_height(t);
        t = balance(t);

        return t;
    }

    static avl delete(int v, avl t)
    {
        int min;

        if (t == null)
            return null;

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

        update_height(t);
        t = balance(t);

        return t;
    }
}
