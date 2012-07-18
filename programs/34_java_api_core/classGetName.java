class Musketeer {}
class DArtagnan extends Musketeer {}

public class classGetName {
  public static void main(String[] args) {
    System.out.println("new Musketeer().getClass().getName() = "
        + new Musketeer().getClass().getName());
    DArtagnan dartagnanDA = new DArtagnan();
    Musketeer musketeerDA = dartagnanDA;
    Object objectDA = dartagnanDA;
    System.out.println("dartagnanDA.getClass().getName() = "
        + dartagnanDA.getClass().getName());
    System.out.println("musketeerDA.getClass().getName() = "
        + musketeerDA.getClass().getName());
    System.out.println("objectDA.getClass().getName() = "
        + objectDA.getClass().getName());
    System.out.println("Done!");
  }
}

// new Musketeer().getClass().getName() = Musketeer
// dartagnanDA.getClass().getName() = DArtagnan
// musketeerDA.getClass().getName() = DArtagnan
// objectDA.getClass().getName() = DArtagnan
// Done!
