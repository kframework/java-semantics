// Example adapted from
// http://www.thrishna.com/java/examples/java/algo/Prime.htm

/* find all the prime numbers from 1 to max */

 public class Prime{

   public static void main(String argv[]){
/*
    if( arg.length != 1 ){
      System.out.println( "usage: java Prime max" );
      return;
    }
*/

    int max = 15; // Integer.parseInt( arg[0] ); 

    if( max < 2 ){
      System.out.println( "max should be greater than 1" );
      return;
    }

    System.out.println( 2 );

    for(int i=3;i <= max;i++){ 
      int n= i/2; // (int)Math.sqrt(i);
      boolean isprime = true;

      for(int k=2;k <= n;k++){
        if( i%k==0 ){
           isprime = false;
           break;
        }
      }

      if( isprime == true )
        System.out.println( i );
    }
  }
 }




