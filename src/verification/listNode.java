// Copyright (c) 2014 K Team. All Rights Reserved.
public class listNode {
  int val;
  listNode next;

    listNode (int val)
    {
        this.val = val;
        this.next = null;
    }

    public static void main(String[] args) {
        listNode node1 = new listNode (1);
        listNode node2 = new listNode (2);
        listNode node3 = new listNode (3);
        node1.next = node2;
        insertion_sort(node1);
//        bubble_sort(node1);
//        reverse(node1);
//        append(node1, node3);
    }
    
static listNode append(listNode x, listNode y)
/*@ rule <k> $ => return ?x; ...</k>
         <heap>... list(x)(A), list(y)(B) => list(?x)(A @ B) ...</heap> */
{
  listNode p;
  if (x == null)
    return y;

  p = x;
  /*@ inv <heap>... lseg(x, p)(?A1), list(p)(?A2) ...</heap>
          /\ A = ?A1 @ ?A2 /\ ~(p = 0) */
  while (p.next != null) {
    p = p.next;
  }
  p.next = y;

  return x;
}

static listNode reverse(listNode x)
/*@ rule <k> $ => return ?p; ...</k>
         <heap>... list(x)(A) => list(?p)(rev(A)) ...</heap> */
{
  listNode p;

  p = null;
  //@ inv <heap>... list(p)(?B), list(x)(?C) ...</heap> /\ A = rev(?B) @ ?C
  while(x != null) {
    listNode y;

    y = x.next;
    x.next = p;
    p = x;
    x = y;
  }

  return p;
}
    static listNode bubble_sort(listNode x)
/*@ rule <k> $ => return ?x; ...</k>
         <heap>... list(x)(A) => list(?x)(?A) ...</heap>
    if isSorted(?A) /\ seq2mset(A) = seq2mset(?A) */
    {
        boolean change;

        if (x == null || x.next == null)
            return x;

        change = true ;
  /*@ inv <heap>... list(x)(?A) ...</heap>
          /\ ~(x = 0) /\ seq2mset(A) = seq2mset(?A)
          /\ (isSorted(?A) \/ ~(change = 0)) */
        while (change) {
            listNode y;

            change = false;
            y = x;
    /*@ inv <heap>... lseg(x, y)(?B), y |. [?v, ?n], list(?n)(?C) ...</heap>
            /\ ~(x = 0) /\ seq2mset(A) = seq2mset(?B @ [?v] @ ?C)
            /\ (isSorted(?B @ [?v]) \/ ~(change = 0)) */
            while (y.next != null) {
                if (y.val > y.next.val) {
                    int temp;

                    change = true;
                    temp = y.val;
                    y.val = y.next.val;
                    y.next.val = temp;
                }
                y = y.next;
            }
        }

        return x;
    }


    static listNode insertion_sort(listNode x)
/*@ rule <k> $ => return ?x; ...</k>
         <heap>... list(x)(A) => list(?x)(?A) ...</heap>
    if isSorted(?A) /\ seq2mset(A) = seq2mset(?A) */
    {
        listNode y;

        y = null;
  /*@ inv <heap>... list(y)(?B), list(x)(?C) ...</heap>
          /\ isSorted(?B) /\ seq2mset(A) = seq2mset(?B) U seq2mset(?C) */
        while (x != null) {
            listNode n;

            n = x;
            x = x.next;
            n.next = null;
            if (y != null) {
                if (y.val < n.val) {
                    listNode z;

                    z = y;
        /*@ inv <heap>... lseg(y,z)(?B), z |. [?v,?n],
                          list(?n)(?C), n |. [nval,0] ...</heap>
                /\ D = ?B @ [?v] @ ?C /\ ?v < nval */
                    while (z.next != null && z.next.val < n.val) {
                        z = z.next;
                    }

                    n.next = z.next;
                    z.next = n;
                }
                else {
                    n.next = y;
                    y = n;
                }
            }
            else {
                y = n;
            }
        }

        return y;
    }



    static listNode merge_sort(listNode x)
/*@ rule <k> $ => return ?x; ...</k>
         <heap>... list(x)(A) => list(?x)(?A) ...</heap>
    if isSorted(?A) /\ seq2mset(A) = seq2mset(?A) */
    {
        listNode p;
        listNode y;
        listNode z;

        if (x == null || x.next == null)
            return x;

        y = null;
        z = null;
  /*@ inv <heap>... list(x)(?A), list(y)(?B), list(z)(?C) ...</heap>
          /\ seq2mset(A) = seq2mset(?A) U seq2mset(?B) U seq2mset(?C)
          /\ (len(?B) = len(?C) \/ len(?B) = len(?C) + 1 /\ x = 0) */
        while (x != null) {
            listNode t;

            t = x;
            x = x.next;
            t.next = y;
            y = t;

            if (x != null) {
                t = x;
                x = x.next;
                t.next = z;
                z = t;
            }
        }

        y = merge_sort(y);
        z = merge_sort(z);

        if (y.val < z.val) {
            x = y;
            p = y;
            y = y.next;
        }
        else {
            x = z;
            p = z;
            z = z.next;
        }
  /*@ inv <heap>...lseg(x,p)(?A1),p|.[?v,?n],list(y)(?B),list(z)(?C) ...</heap>
          /\ seq2mset(A) = seq2mset(?A1 @ [?v]) U seq2mset(?B) U seq2mset(?C)
          /\ leq(seq2mset(?A1 @ [?v]), seq2mset(?B))
          /\ leq(seq2mset(?A1 @ [?v]), seq2mset(?C))
          /\ isSorted(?A1 @ [?v]) /\ isSorted(?B) /\ isSorted(?C) */
        while (y != null && z != null) {
            if (y.val < z.val) {
                p.next = y;
                y = y.next;
            }
            else {
                p.next = z;
                z = z.next;
            }

            p = p.next;
        }

        if (y != null)
            p.next = y;
        else
            p.next = z;

        return x;
    }


    static listNode quicksort(listNode x)
/*@ rule <k> $ => return ?x; ...</k>
         <heap>... list(x)(A) => list(?x)(?A) ...</heap>
    if isSorted(?A) /\ seq2mset(A) = seq2mset(?A) */
    {
        listNode p;
        listNode y;
        listNode z;

        if (x == null || x.next == null)
            return x;

        p = x;
        x = x.next;
        p.next = null;
        y = null;
        z = null;
  /*@ inv <heap>... p|.[v,0], list(x)(?A), list(y)(?B), list(z)(?C) ...</heap>
          /\ seq2mset(A) = {v} U seq2mset(?A) U seq2mset(?B) U seq2mset(?C)
          /\ leq(seq2mset(?B), {v}) /\ leq({v}, seq2mset(?C)) */
        while(x != null) {
            listNode t;

            t = x;
            x = x.next;
            if (t.val < p.val) {
                t.next = y;
                y = t;
            }
            else {
                t.next = z;
                z = t;
            }
        }

        y = quicksort(y);
        z = quicksort(z);
        x = append(y, append(p, z));

        return x;
    }

}

