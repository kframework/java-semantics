// Example 77 from page 59 of Java Precisely edition 1 (The MIT Press 2002)
// Author: Peter Sestoft (sestoft@dina.kvl.dk)


class Bank {
  private int account1 = 10, account2 = 20;
  synchronized public void transfer(int amount) {
    int new1 = account1 - amount;
    //Util.pause(10);
    account1 = new1; account2 = account2 + amount;
    System.out.println("Sum is " + (account1+account2));
} }

class Clerk extends Thread {
  private Bank bank;
  public Clerk(Bank bank) { this.bank = bank; }
  public void run() {
    for (int i=0; i<10; i++) {                                  // Forever
      bank.transfer(10);      //   transfer money
      //Util.pause(200, 300);                     //   then take a break
} } }

class Example77 {
  public static void main(String[] args) {
    Bank bank = new Bank();
    new Clerk(bank).start(); new Clerk(bank).start();
} }

// Pseudo-random numbers and sleeping threads


