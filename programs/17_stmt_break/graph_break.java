/* JLS $14.15. Test of break statement with labels.
  In the following example, a mathematical  graph is represented by an array of
arrays. A graph consists of a set of nodes and a set of edges; each edge is an arrow
that points from some node to some other node, or from a node to itself. In this
example it is assumed that there are no redundant edges; that is, for any two nodes
P  and Q , where  Q  may be the same as  P, there is at most one edge from  P  to  Q .
Nodes are represented by integers,  and there is an edge from node i to node
edges[ i ][ j ]  for every  i  and j  for which the array reference  edges[ i ][ j ]
does not throw an IndexOutOfBoundsException.
  The task of the method  loseEdges, given integers  i and j , is to construct a
new graph by copying a given graph but omitting the edge from node  i  to node  j ,
if any, and the edge from node  j  to node  i , if any.
  Note the use of two statement labels,  edgelist  and  search , and the use of  break
statements. This allows the code that co pies a list, omitting on e edge, to be shared
between two separate tests, th e test for an edge from node i  to node  j , and the test
for an edge from node j  to node  i .
*/
class Graph {

  int edges[][];

  Graph(int[][] edges) {
    this.edges = edges;
  }

  Graph loseEdges(int i, int j) {
    int n = edges.length;
    int[][] newedges = new int[n][];
    for (int k = 0; k < n; ++k) {
      edgelist:
      {
        int z;
        search:
        {
          if (k == i) {
            for (z = 0; z < edges[k].length; ++z)
              if (edges[k][z] == j)
                break search;
          } else if (k == j) {
            for (z = 0; z < edges[k].length; ++z)
              if (edges[k][z] == i)
                break search;
          }
          //  No edge to be deleted; share this list.
          newedges[k] = edges[k];
          break edgelist;
        } //search
        //  Copy the list, omitting the edge at position z.
        int m = edges[k].length - 1;
        int ne[] = new int[m];
        arraycopy(edges[k], 0, ne, 0, z);
        arraycopy(edges[k], z + 1, ne, z, m - z);
        newedges[k] = ne;
      } //edgelist
    }
    return new Graph(newedges);
  }

  void arraycopy(int[] src, int srcPos, int[] dest, int destPos,
                 int length) {
    for (int i = 0; i < length; i++) {
      dest[destPos + i] = src[srcPos + i];
    }
  }

  void print() {
    for (int i = 0; i < edges.length; i++) {
      System.out.print(i + " |-> ");
      for (int j = 0; j < edges[i].length; j++) {
        System.out.print(edges[i][j] + " ");
      }
      System.out.println();
    }
  }
}

public class graph_break {
  public static void main(String[] args) {
    int n = 4;
    int[][] edges = new int[n][n];
    for (int i = 0; i < n; i++) {
      for (int j = 0; j < n; j++) {
        edges[i][j] = (i + j) % n;
      }
    }
    Graph graph1 = new Graph(edges);
    System.out.println("Init graph:");
    graph1.print();
    Graph graph2 = graph1.loseEdges(1,2);
    System.out.println();
    System.out.println("Graph without edges (1,2),(2,1):");
    graph2.print();
    System.out.println("Done!");
  }
}

/*
Init graph:
0 |-> 0 1 2 3
1 |-> 1 2 3 0
2 |-> 2 3 0 1
3 |-> 3 0 1 2

Graph without edges (1,2),(2,1):
0 |-> 0 1 2 3
1 |-> 1 3 0
2 |-> 2 3 0
3 |-> 3 0 1 2
Done!
*/
