public class min {

public static void main(String[] args) {
     System.out.println("min of 4 and 5 is" + min(4, 5));
}
//@min(x,y)==minInt(x,y)
static int min(int x, int y)
{
  if (x <= y)
    return x;
  else
    return y;
}
}
