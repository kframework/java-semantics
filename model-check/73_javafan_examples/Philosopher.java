class Philosopher extends Thread {
  int id; Fork F1 , F2; boolean dined = false;
  public Philosopher(int i, Fork f1, Fork f2) {
    this.F1 = f1; this.F2 = f2; this.id = i ; return;
  }
  public void run() {
    synchronized (F1) {
      synchronized (F2) {
        dined = true;
      }
    }
    return;
  }
  public static void main(String[] args) {
    int count = 3;
    Fork[] forks = new Fork[count] ;
    for (int i = 0; i < count; i++){ forks[i] = new Fork() ; }
    for (int i = 0; i < count; i++){
      (new Philosopher(i, forks[i], forks[(i + 1) % count])).start() ;
    }
    return;
  }
}

class Fork {}
