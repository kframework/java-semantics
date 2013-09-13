// Example adapted from
// http://www.thrishna.com/java/examples/java/object/Department.htm

public class Misc_Department {

   private Employee[] employees; //has a relationship

   public Misc_Department() {
     employees = new Employee[5];
     employees[0] = new Manager( "mark" );
     employees[1] = new Programmer( "tom" );
     employees[2] = new Manager( "alice" );
     employees[3] = new Programmer( "mat" );
     employees[4] = new Programmer( "jim" );
   }

   public void listAllEmployees(){

     for (int i=0;i < employees.length;i++){
       System.out.println(
         employees[i].getName() + " " + employees[i].whoAreYou() );
     }
   }

   public static void main( String[] arg ){

     Misc_Department department = new Misc_Department();
     department.listAllEmployees();
   }
 }

 /*base class*/
 class Employee{

   private String name;

   public Employee( String name ){
     this.name = name;
   }

   public String getName(){
     return name;
   }

   public String whoAreYou(){
     return "Employee";
   }
 }

 /* is a relationship */
 class Manager extends Employee{

   public Manager( String name ){
     super( name );
   }

   public String whoAreYou(){
     return "Manager";
   }
 }

 /* is a relationship */
 class Programmer extends Employee{

   public Programmer( String name ){
     super( name );
   }

   public String whoAreYou(){
     return "Programmer";
   }
}
