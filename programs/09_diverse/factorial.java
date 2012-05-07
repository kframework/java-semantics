class main {
  int factorial(int y) {
    if (y == 1) {
      return 1;
    } else {
      return y*factorial(y-1);
    }
  }

  int read() {
    return Integer.parseInt(System.console().readLine());
  }

  void main(String[] args) {
    System.out.print("Input a natural numer: ");
    int n = read();
    System.out.println("Factorial of "+n+" is: "+factorial(n));
    System.out.print("Done!"+"\n");
  }
}
