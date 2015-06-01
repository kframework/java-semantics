module ELABORATION-ARRAYS
    imports CORE-SORTS
    imports ELABORATION-CORE
    imports ELABORATION-EXPRESSIONS//for elabExpAndType

//@ \subsection{Desugaring of array declarators with c-style dimensions and initializers}

/*@ C-style array declaration
    Applied in both elaboration and execution phase
*/
rule [elab-LocalVarDec-ArrayVarDecId-desugar]:
    elab('LocalVarDecStm('LocalVarDec(
      _:K,,
      (T:Type => arrayOf T),,
      'VarDecList('VarDec('ArrayVarDecId(
          X:Id,,
          ([]:Dim Ds:Dims => Ds)
      ),, _:KList //possible initializer
    ),, .VarDecList))))                                                [structural]

rule [elab-LocalVarDec-ArrayVarDecId-discard]:
    elab('LocalVarDecStm('LocalVarDec(_:K,, T:Type,, 'VarDecList('VarDec(
        ( 'ArrayVarDecId( X:Id,, .Dims ) => X ),,
        _:KList //possible initializer
    ),, .VarDecList))))                                               [structural]

rule [elab-LocalVarDec-ArrayInit-desugar]:
    elab('LocalVarDecStm('LocalVarDec(_:K,, T:Type,, 'VarDecList('VarDec(
      X:Id,,
      ( 'ArrayInit(InitK:K) => 'NewArray(T,, .Dims,, 'ArrayInit(InitK)))
    ),, .VarDecList))))                                                [structural]

//same three rules for fields

rule [FieldDec-ArrayVarDecId-desugar]:
    'FieldDec(
      _:K,,
      (T:Type => arrayOf T),,
      'VarDecList('VarDec('ArrayVarDecId(
          X:Id,,
          ([]:Dim Ds:Dims => Ds)
      ),, _:KList //possible initializer
    ),, .VarDecList))                                                 [structural]

rule [FieldDec-ArrayVarDecId-discard]:
    'FieldDec(_:K,, T:Type,, 'VarDecList('VarDec(
        ( 'ArrayVarDecId( X:Id,, .Dims ) => X ),,
        _:KList //possible initializer
    ),, .VarDecList))                                                 [structural]

rule [FieldDec-ArrayInit-desugar]:
    'FieldDec(_:K,, T:Type,, 'VarDecList('VarDec(
      X:Id,,
      ( 'ArrayInit(InitK:K) => 'NewArray(T,, .Dims,, 'ArrayInit(InitK)))
    ),, .VarDecList))                                                 [structural]

//first two rules - desugaring C-like array declarations, for params

/*@ Thi rule and the next one may happen both in elaboration, execution or process members phases.
They are required to be [anywhere]. */
rule [Param-ArrayVarDecId-desugar]:
    'Param(
      _:K,,
      (T:Type => arrayOf T),,
      'ArrayVarDecId(
          X:Id,,
          ([]:Dim Ds:Dims => Ds)
      )
    )                                                   [structural, anywhere]

rule [Param-ArrayVarDecId-Discard]:
    'Param(
      _:K,, T:Type,,
      ( 'ArrayVarDecId( X:Id,, .Dims ) => X )
    )                                                   [structural, anywhere]

/*@ \subsection{Elaboration of array-related expressions} */

rule [elabEnd-ArrayAccess]:
    elabEnd('ArrayAccess(cast(arrayOf T:Type, TargetExp:K),, IndexTE:K))
    => elabRes(cast(T, 'ArrayAccess(cast(arrayOf T, TargetExp),, IndexTE)))

rule [elabEnd-Field-ArrayLength]:
    elabEnd('Field(cast(arrayOf T:Type, Qual:K),, X:Id))
    => elabRes(cast(int, 'Field(cast(arrayOf T, Qual),, X)))
when
    Id2String(X) ==String "length"

rule [elabEnd-NewArray-EmptyDims]:
    elabEnd('NewArray( (T:Type => arrayOf T),, _,, ([]:Dim Ds:Dims => Ds)))
        [structural]

rule [elabEnd-NewArray]:
    elabEnd('NewArray(T:Type,, DimExprs:DimExps,, .Dims))
    => elabExpAndType('NewArray(T,, DimExprs,, .Dims), getArrayType(T, DimExprs))
        [structural]

//@ Computes the array type based on allocated elem type and number of allocated dimensions.
syntax KItem ::= getArrayType ( Type, DimExps )                          [function]
rule getArrayType(T:Type, [K] DimExprs:DimExps) => getArrayType(arrayOf T, DimExprs)
rule getArrayType(T:Type, .DimExps) => T

rule [elabEnd-NewArray-ArrayInit-Preprocess]:
    elabEnd('NewArray((T:Type => arrayOf T),, ([]:Dim Ds:Dims => Ds),, 'ArrayInit(_)))

rule [elabEnd-NewArray-ArrayInit]:
    elabEnd('NewArray(arrayOf T:Type,, .Dims,, 'ArrayInit(InitContent)))
    => elabRes(cast(arrayOf T, 'NewArray(arrayOf T:Type,, .Dims,, 'ArrayInit(InitContent))))

endmodule
