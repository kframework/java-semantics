// Example adapted from
// http://www.thrishna.com/java/examples/java/thread/Thread1.htm

public class Thread1 extends Thread{

   private int id;

   public Thread1( int id ){
     this.id = id; 
   }

   public void run(){
     for(int i=0;i < 20;i++){
       System.out.println( "In thread no " + id + ":" + i ); 
       // yield();
     }
   }

   public static void main( String[] arg ){
     for(int i=0;i < 10;i++){
       new Thread1( i ).start();
     }
   }
 }


