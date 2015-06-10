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
        reverse(node1);
        append(node1, node3);
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

}

