class Cell {
  private int content;
  public int get() {
    return content;
  }

  public void set(int i) {
    content = i;
  }

  public void inc(int i) {
    set(get() + i);
  }
}

class BackupCell extends Cell {
  private int backup;

  public void set(int i) {
    backup = get();
    super.set(i);
  }

  public void restore() {
    super.set(backup);
  }
}

class Exercise5_2_4 {
  public static void main(String[] args) {
    BackupCell c = new BackupCell();
    c.set(1);
    c.inc(2);
    System.out.println(c.get());
    c.restore();
    System.out.println(c.get());
  }
}

