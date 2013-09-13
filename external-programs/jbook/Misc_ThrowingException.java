// Example adapted from
// http://www.thrishna.com/java/examples/java/exception/ThrowingException.htm

public class Misc_ThrowingException {

   public void foo( boolean throwException ) throws Exception{
     System.out.println( "in foo" );

     if( throwException ){
       System.out.println( "throwing exception" );
       throw new Exception( "testing exception" );
     }

     System.out.println( "after throwing exception" );
   }

   public static void main( String[] arg ){
     Misc_ThrowingException tester = new Misc_ThrowingException();

     try{
       System.out.println( "calling foo" );
       tester.foo( false );
       System.out.println( "called foo" );

       System.out.println( "calling foo" );
       tester.foo( true );
       System.out.println( "will not reach here" );
     }catch( Exception e ){
       System.out.println( "got exception " + e + e.toString() );
     }
   }
}

