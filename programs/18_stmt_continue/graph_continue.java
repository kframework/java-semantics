/* JLS $14.16. Test of continue statement with labels.
In the graph-break example in the preceding section, one of the break statements
is used to finish execution of the entire body of the outermost for loop. This
break can be replaced by a continue if the for loop itself is labeled.
*/
class Graph {
  int edges[][];

  Graph(int[][] edges) {
    this.edges = edges;
  }

  Graph loseEdges(int i, int j) {
    int n = edges.length;
    int[][] newedges = new int[n][];
    edgelists:
    for (int k = 0; k < n; ++k) {
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
          continue edgelists;
        } //search
        //  Copy the list, omitting the edge at position z.
        int m = edges[k].length - 1;
        int ne[] = new int[m];
        arraycopy(edges[k], 0, ne, 0, z);
        arraycopy(edges[k], z + 1, ne, z, m - z);
        newedges[k] = ne;
    }  //edgelists
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

public class graph_continue {
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
    Graph Graph = graph1.loseEdges(1,2);
    System.out.println();
    System.out.println("Graph without edges (1,2),(2,1):");
    Graph.print();
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
