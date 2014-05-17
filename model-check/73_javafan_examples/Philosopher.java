/*
v1.
Older version of the program, no output, but each Philosopher have a bool variable dined.
No way to distinguish the order in which philosophers dined: 6 minutes run on windows, 2 solutions.

v2. No dined variable, instead each philosopher prints a message when he eats.
  We have to synchronize printing as well, otherwise th variable assignment that happens inside printing will
  lead to state space explosion.

kjrun.sh --search -v --timeout=0 ../model-check/73_javafan_examples/Philosopher.java

In the current setup the rules tagged with [transition-threading] are:
  - Variable access/assignment
  - Printing to <out>, just the final rule
  - A lot of rules in api-threads.k
*/
class Philosopher extends Thread {
  int id; Fork F1 , F2;
  public Philosopher(int i, Fork f1, Fork f2) {
    this.F1 = f1; this.F2 = f2; this.id = i ; return;
  }
  public void run() {
    synchronized (F1) {
      synchronized (F2) {
        System.out.println("Philosopher " + id + " dined.");
      }
    }
    return;
  }
  public static void main(String[] args) {
    int count = 3;
    Fork[] forks = new Fork[count] ;
    for (int i = 0; i < count; i++){ forks[i] = new Fork() ; }
    Philosopher[] philosophers = new Philosopher[3];
    for (int i = 0; i < count; i++){
      philosophers[i] = new Philosopher(i, forks[i], forks[(i + 1) % count]);
    }
    for (int i = 0; i < count; i++) { philosophers[i].start(); }
    return;
  }
}

class Fork {}
