public class rbt {
    int value;
    int color;// RED=0, BLACK=1
    rbt left;
    rbt right;

    rbt (int value)
    {
        this.value = value;
        this.color = 0;
        this.left = null;
        this.right = null;
    }
    
    // Basics

    static rbt make_node(int v)
    {
        rbt node = new rbt (v);
        return node;
    }

    static int color(rbt t)
    {
        return t ? t.color : 1; // BLACK
    }

    static int find_min(rbt t)
    {
        if (t.left === null)
            return t.value;
        else
            return find_min(t.left);
    }

    static rbt left_rotate(x)
    {
        rbt y = x.right;
        x.right = y.left;
        y.left = x;
        return y;
    }

    static rbt right_rotate(x)
    {
        rbt y = x.left;
        x.left = y.right;
        y.right = x;
        return y;
    }

// Find

    static boolean find(int v, rbt t)
    {
        if (t === null)
            return false;
        else if (v === t.value)
            return true;
        else if (v < t.value)
            return find(v, t.left);
        else
            return find(v, t.right);
    }


// Insert

    static rbt insert_aux(int value, rbt tree)
    {
        if (tree == null) {
            return make_node(value);
        }
        if (value < tree.value) {
            tree.left = insert_aux(value, tree.left);
            if (color(tree.left) != 1 /* RED */) {
                if (color(tree.right) != 1 /* RED */) { // case 3
                    if (color(tree.left.left) != 1 /* RED */ || color(tree.left.right) != 1 /* RED */) {
                        tree.left.color = 1 /* BLACK */;
                        tree.right.color = 1 /* BLACK */;
                        tree.color = 0 /* RED */;
                    }
                }
                else {
                    if (color(tree.left.right) != 1 /* RED */) { // case 4
                        tree.left = left_rotate(tree.left);
                    }
                    if (color(tree.left.left) != 1 /* RED */) { // case 5; case 4 falls through
                        tree = right_rotate(tree);
                        tree.color = 1 /* BLACK */;
                        tree.right.color = 0 /* RED */;
                    }
                }
            }
        }
        else if (value > tree.value) {
            tree.right = insert_aux(value, tree.right);
            if (color(tree.right) != 1 /* RED */) {
                if (color(tree.left) != 1 /* RED */) {
                    if (color(tree.right.right) != 1 /* RED */ || color(tree.right.left) != 1 /* RED */) { // case 3
                        tree.right.color = 1 /* BLACK */;
                        tree.left.color = 1 /* BLACK */;
                        tree.color = 0 /* RED */;
                    }
                }
                else {
                    if (color(tree.right.left) != 1 /* RED */) { // case 4
                        tree.right = right_rotate(tree.right);
                    }
                    if (color(tree.right.right) != 1 /* RED */) { // case 5; case 4 falls through
                        tree = left_rotate(tree);
                        tree.color = 1 /* BLACK */;
                        tree.left.color = 0 /* RED */;
                    }
                }
            }
        }
        return tree;
    }

    static rbt insert(int value, rbt tree)
    {
        tree = insert_aux(value, tree);
        if (color(tree) != 1 /* RED */) {
            tree.color = 1 /* BLACK */;
        }
        return tree;
    }


// Remove

    static rbt left_remove_fixup(ref ctx, rbt tree)
    {
        if (color(tree.right) != 1 /* RED */) { // case 2
            tree = left_rotate(tree);
            tree.color = 1 /* BLACK */;
            tree.left.color = 0 /* RED */;
            tree.left = left_remove_fixup(ctx, tree.left);
            ctx.fixed = 1;
        }
        else {
            if (color(tree.right.left) == 1 /* BLACK */ &&
                    color(tree.right.right) == 1 /* BLACK */) { // case 3 & 4
                if (color(tree) == 1 /* BLACK */) { // case 3
                    ctx.fixed = 0; // {left,right}_remove_fixup will be called again later
                } else { // case 4
                    ctx.fixed = 1;
                }
                tree.right.color = 0 /* RED */;
                tree.color = 1 /* BLACK */;
            }
            else {
                if (color(tree.right.right) == 1 /* BLACK */) { // case 5
                    tree.right = right_rotate(tree.right);
                    tree.right.color = 1 /* BLACK */;
                    tree.right.right.color = 0 /* RED */;
                }
                // case 6; case 5 falls through
                tree = left_rotate(tree);
                tree.color = color(tree.left);
                tree.left.color = 1 /* BLACK */;
                tree.right.color = 1 /* BLACK */;
                ctx.fixed = 1;
            }
        }
        return tree;
    }

    static rbt right_remove_fixup(ref ctx, rbt tree)
    {
        if (color(tree.left) != 1 /* RED */) {
            tree = right_rotate(tree);
            tree.color = 1 /* BLACK */;
            tree.right.color = 0 /* RED */;
            tree.right = right_remove_fixup(ctx, tree.right);
            ctx.fixed = 1;
        }
        else {
            if (color(tree.left.right) == 1 /* BLACK */ &&
                    color(tree.left.left) == 1 /* BLACK */) {
                if (color(tree) == 1 /* BLACK */) { // case 3
                    ctx.fixed = 0; // {left,right}_remove_fixup will be called again later
                } else { // case 4
                    ctx.fixed = 1;
                }
                tree.left.color = 0 /* RED */;
                tree.color = 1 /* BLACK */;
            }
            else {
                if (color(tree.left.left) == 1 /* BLACK */) {
                    tree.left = left_rotate(tree.left);
                    tree.left.color = 1 /* BLACK */;
                    tree.left.left.color = 0 /* RED */;
                }
                tree = right_rotate(tree);
                tree.color = color(tree.right);
                tree.right.color = 1 /* BLACK */;
                tree.left.color = 1 /* BLACK */;
                ctx.fixed = 1;
            }
        }
        return tree;
    }

    static rbt remove_aux(ref ctx, int value, rbt tree)
    {
        if (tree == null) {
            ctx.fixed = 1;
            return null;
        }
        if (value == tree.value) {
            if (tree.left == null) {
                if (color(tree.right) != 1 /* RED */) {
                    tree.right.color = 1 /* BLACK */;
                    ctx.fixed = 1;
                }
                else {
                    if (color(tree) == 1 /* BLACK */) {
                        ctx.fixed = 0; // {left,right}_remove_fixup will be called again later
                    } else { // case 4
                        ctx.fixed = 1;
                    }
                }
                return tree.right;
            }
            else if (tree.right == null) {
                if (color(tree.left) != 1 /* RED */) {
                    tree.left.color = 1 /* BLACK */;
                    ctx.fixed = 1;
                }
                else {
                    if (color(tree) == 1 /* BLACK */) {
                        ctx.fixed = 0; // {left,right}_remove_fixup will be called again later
                    } else { // case 4
                        ctx.fixed = 1;
                    }
                }
                return tree.left;
            }
            else {
                tree.value = find_min(tree.right);
                tree.right = remove_aux(ctx, tree.value, tree.right);
                if (ctx.fixed != 1) {
                    tree = right_remove_fixup(ctx, tree);
                }
            }
        }
        else if (value < tree.value) {
            tree.left = remove_aux(ctx, value, tree.left);
            if (ctx.fixed != 1) {
                tree = left_remove_fixup(ctx, tree);
            }
        }
        else {
            tree.right = remove_aux(ctx, value, tree.right);
            if (ctx.fixed != 1) {
                tree = right_remove_fixup(ctx, tree);
            }
        }
        return tree;
    }

    static rbt remove(int value, rbt tree)
    {
        ref ctx = new ref();
        ctx.fixed = 0;
        tree = remove_aux(ctx, value, tree);
        return tree;
    }
}

class ref {int fixed;}
