/*
kjkompile.sh --threading
kjrun.sh --search -v --timeout=0 ../model-check/73_examples/Philosopher.java

Result: 7 solutions (3! good solutions + 1 deadlock), in 1m50s on windows.

In the current setup the rules tagged with [transition-threading] are:
  - Field access/assignment (just fields, not local variables)
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
