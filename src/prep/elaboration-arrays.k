module ELABORATION-ARRAYS
    imports CORE-SORTS
    imports ELABORATION-CORE

//@ \subsection{Desugaring of array declarators with c-style dimensions and initializers}

syntax KLabel ::= "'ArrayVarDecId"
                | "'ArrayInit"

/*@ C-style array declaration
    Applied in both elaboration and execution phase
*/
rule [elab-LocalVarDec-ArrayVarDecId-desugar]:
    elab('LocalVarDec(
      _:K,,
      (T:Type => arrayOf T),,
      ['VarDec('ArrayVarDecId(
          X:Id,,
          [('Dim(.KList) => .KList) ,,_]
      ),, _:KList //possible initializer
    )]))                                                [structural]

rule [elab-LocalVarDec-ArrayVarDecId-discard]:
    elab('LocalVarDec(_:K,, T:Type,, ['VarDec(
        ( 'ArrayVarDecId( X:Id,, [.KList] ) => X ),,
        _:KList //possible initializer
    )]))                                                [structural]

rule [elab-LocalVarDec-ArrayInit-desugar]:
    elab('LocalVarDec(_:K,, T:Type,, ['VarDec(
      X:Id,,
      ( 'ArrayInit(InitK:K) => 'NewArray(T,, [.KList],, 'ArrayInit(InitK)) )
    )]))                                                [structural]

//same three rules for fields

rule [FieldDec-ArrayVarDecId-desugar]:
    'FieldDec(
      _:K,,
      (T:Type => arrayOf T),,
      ['VarDec('ArrayVarDecId(
          X:Id,,
          [('Dim(.KList) => .KList) ,,_]
      ),, _:KList //possible initializer
    )])                                                 [structural]

rule [FieldDec-ArrayVarDecId-discard]:
    'FieldDec(_:K,, T:Type,, ['VarDec(
        ( 'ArrayVarDecId( X:Id,, [.KList] ) => X ),,
        _:KList //possible initializer
    )])                                                 [structural]

rule [FieldDec-ArrayInit-desugar]:
    'FieldDec(_:K,, T:Type,, ['VarDec(
      X:Id,,
      ( 'ArrayInit(InitK:K) => 'NewArray(T,, [.KList],, 'ArrayInit(InitK)) )
    )])                                                 [structural]

//first two rules - desugaring C-like array declarations, for params

/*@ Thi rule and the next one may happen both in elaboration, execution or process members phases.
They are required to be [anywhere]. */
rule [Param-ArrayVarDecId-desugar]:
    'Param(
      _:K,,
      (T:Type => arrayOf T),,
      'ArrayVarDecId(
          X:Id,,
          [('Dim(.KList) => .KList) ,,_]
      )
    )                                                   [structural, anywhere]

rule [Param-ArrayVarDecId-Discard]:
    'Param(
      _:K,, T:Type,,
      ( 'ArrayVarDecId( X:Id,, [.KList] ) => X )
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

//@ 'ArrayType(T:Type)
syntax KLabel ::= "'ArrayType"

context 'ArrayType(HOLE)
rule 'ArrayType(T:Type) => arrayOf T     [structural]

rule [elabEnd-NewArray-EmptyDims]:
    elabEnd('NewArray( (T:Type => arrayOf T),, [_],,
        [ ( 'Dim(.KList) => .KList ) ,,_:KList] ))
        [structural]

rule [elabEnd-NewArray]:
    elabEnd('NewArray(T:Type,, [Dims:KList],, [.KList]))
    => elabExpAndType('NewArray(T,, [Dims],, [.KList]), getArrayType(T, [Dims]))
        [structural]

//@ Computes the array type based on allocated elem type and number of allocated dimensions.
syntax KItem ::= getArrayType ( Type, KListWrap )                          [function]
rule getArrayType(T:Type, [K:K,,Dims:KList]) => getArrayType(arrayOf T, [Dims])
rule getArrayType(T:Type, [.KList]) => T

rule [elabEnd-NewArray-ArrayInit-Preprocess]:
    elabEnd('NewArray((T:Type => arrayOf T),, [('Dim(.KList) => .KList),, _],, 'ArrayInit(_)))

rule [elabEnd-NewArray-ArrayInit]:
    elabEnd('NewArray(arrayOf T:Type,, [.KList],, 'ArrayInit([InitContent:KList])))
    => elabRes(cast(arrayOf T, 'NewArray(arrayOf T:Type,, [.KList],, 'ArrayInit([InitContent:KList]))))

endmodule
