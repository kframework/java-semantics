// Example adapted from
// http://ironbark.bendigo.latrobe.edu.au/~mal/bitdst/ds2000/session090/lecture.html

class Node {  Object data;
              int    link;
};

class Queue1 {




   final int MAXITEMS = 10;
   Node[] queueArray = new Node[MAXITEMS];

   int front;
   int rear;
   int count;

   int topOfFreeList;



   public Queue1(){   // constructor


     // setup the free list of unused nodes

     topOfFreeList = 0;
     for (int i=0;i < MAXITEMS-1;i++){
        queueArray[i] = new Node ();
        queueArray[i].link = i+1;
     }

     queueArray[MAXITEMS-1] = new Node ();
     queueArray[MAXITEMS-1].link = -1;  // terminates freelist


     // use -1 to mark the end of a chain of nodes

     // initialize to an empty queue

     front = -1;
     rear  = front;
     count = 0;
   }
   public boolean enqueue( Object item ){
     if ( isFull() )
       return false;   // no room to add another item
     else
       {
         // 1. obtain a node from the freelist

         int temp = topOfFreeList;

         // 2. adjust freelist to exclude this node

         topOfFreeList = queueArray[topOfFreeList].link;


         // 3. adjust queue to include the new item

         if ( isEmpty() )
            front = temp;
         else
            queueArray[rear].link =temp;

         rear = temp;
         queueArray[rear].data = item;
         queueArray[rear].link = -1;

         //4. increment count to reflect the new queue length

         count = count + 1;

         return true;
       }
   }





   public Object dequeue( ){

     if ( isEmpty() )
       return null;

     else{

         // 1. get the Object at the front of the queue

         Object item = queueArray[front].data;

         // 2. adjust the links to remove the node from the queue

         int temp = front;
         front = queueArray[front].link;

         // 3. put the dequeued node back onto the free list

         queueArray[temp].link = topOfFreeList;
         topOfFreeList = temp;

         // 4. Decrement count to reflect new queue length
         count = count - 1;

         return item;
     }
  }


  public boolean isEmpty(){

   return count==0;
  }


  public boolean isFull(){

   return count==MAXITEMS;
  }


  public int length(){

   return count;
  }

  public String toString(){

    StringBuffer sb = new StringBuffer();

    int index = front;

    while (index != -1 ){
              sb.append( queueArray[index].data.toString()+ " " );
              index = queueArray[index].link;
    }

    return sb.toString();
  }

} // end of Queue class

class QTest {

   public static void main (String [] args)
   {
     Queue1 X = new Queue1();
     for(int i=0;!X.isFull();i++){
     
       X.enqueue( new Integer(i) );
       System.out.println( "After adding " + i + ", the queue contains :" + X );
     }

     System.out.println( "\n\nThe queue length= " + X.length() );
   
 
     System.out.println( "\n\n" );
 
     while( !X.isEmpty() ){ 
     
        Object item = X.dequeue();  // dequeue the front item
	
	// get integer value of the item
	
        System.out.println( "After removing " + item.toString() + ", the queue contains :" + X );
     }
     
     System.out.println(  "\n\nThe queue length= "+ X.length() );
   }

}

