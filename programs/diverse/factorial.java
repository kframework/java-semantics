public class Main {
  int factorial(int y) {
    if (y == 1) {
      return 1;
    } else {
      return y*factorial(y-1);
    }
  }

  void main(string[] args) {
    print("Input a natural numer: ");
    int n = read();
    print("Factorial of ",n," is: ",factorial(n),"\n");
  }
}
