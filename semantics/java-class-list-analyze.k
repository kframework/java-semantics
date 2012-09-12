module JAVA-CLASS-LIST-ANALYZE
    imports JAVA-CORE

syntax K ::= "classListAnalyze" "("
                                    Bag // the collection of <class> tags
                                ")"
           | "classAnalyze" "("
                                Id  //the class to be analyzed
                            ")"

rule [classListAnalyze]:
    <k> . => classListAnalyze(Classes) </k>
    <classes> Classes:Bag </classes>
    <executionPhase> "ProcessDeclarations" => "ClassListAnalyze" </executionPhase>

rule [classAnalyzeInit]:
    (. => classAnalyze(Class))
    ~>  classListAnalyze(
          (<class>
            ...
            <className> Class:Id </className>
            ...
          </class> => .Bag)
          _:Bag
        )

rule [ClassAnalyze]:
    <k> classAnalyze(Class) => K ...</k>
    <class>
      <className> Class </className>
      <declarations> K:K => . </declarations>
      ...
    </class>
    <cuClass> _ => Class </cuClass>

rule [classListAnalyzeDiscard]:
    classListAnalyze(.) => .

end module
