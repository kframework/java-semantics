require "core-sorts.k"

module TO-STRING
    imports CORE-SORTS

/*@ Converts all possible Java values into String. Used mostly for printing and String + operator.
    Conversion for other value forms is defined in other modules.
*/
syntax K ::= toString ( K )   [strict]

rule toString(Str:String :: _) => Str
rule toString(I:Int :: char) => chrChar(I)
rule toString(I:Int :: T:Type) => Int2String(I)
    when T =/=K char
rule toString(Fl:Float :: _) => Float2String(Fl)
rule toString(true::_) => "true"
rule toString(false::_) => "false"
rule toString(null::_) => "null"

//@ toString(arrayOf T)

rule toString(arrayOf byte)  => "[B"
rule toString(arrayOf short) => "[S"
rule toString(arrayOf int)   => "[I"
rule toString(arrayOf long)  => "[J"
rule toString(arrayOf char)  => "[C"
rule toString(arrayOf bool)  => "[Z"

rule toString(arrayOf class Class:Id) => 'Plus("[L",, 'Plus(toString(class Class) ,,";"))

rule toString(arrayOf arrayOf T:Type) => 'Plus("[",, toString(arrayOf T))

rule [toString-ClassType-TopLevelWithPackage]:
    <k>
      toString(class ClassId:Id) => Id2String(ClassId)
      ...
    </k>
    <classType> class ClassId </classType>
    <enclosingClass> noClass </enclosingClass>
when
    retainHead(Id2String(ClassId), 1) =/=String "."

rule [toString-ClassType-TopLevelWithDefaultPackage]:
    <k>
      toString(class ClassId:Id) => trimHead(Id2String(ClassId), 1)
      ...
    </k>
    <classType> class ClassId </classType>
    <enclosingClass> noClass </enclosingClass>
when
    retainHead(Id2String(ClassId), 1) ==String "."

rule [toString-ClassType-Inner]:
    <k>
      toString(class ClassId:Id)
      => 'Plus(
            toString(class OuterClassId),,
            "$" +String Id2String(SimpleName)
         )
      ...
    </k>
    <classType> class ClassId </classType>
    <enclosingClass> class OuterClassId:Id </enclosingClass>
    <namesToClasses>... _ |-> mapWrap(SimpleName:Id |-> class ClassId _:Map) ...</namesToClasses>

//@ \texttt{toString for objectClosure}

rule toString(objectClosure(I:Int, Obj:KList/*ObjLayers*/, ObjLocalClassesEnv:Map) :: T:Type)
    =>  elab('Invoke(
          'MethodName(objectClosure(I, Obj, ObjLocalClassesEnv) :: T,, String2Id("toString")),,
          'ListWrap(.KList)
        ))
        [anywhere]

endmodule
