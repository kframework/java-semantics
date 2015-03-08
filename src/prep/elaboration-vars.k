module ELABORATION-VARS
    imports CORE-SORTS
    imports ELABORATION-CORE

//@ Elaboration of rules in java-var-lookup
//@ Both unqualified and qualified AmbName.
rule [elabEnd-AmbName]:
    elabEnd('AmbName(Ks:KList)) => elabEnd('ExprName(Ks)) ?? 'TypeName(Ks) ?? 'PackageName([Ks])

rule [elabEnd-ExprName-localVar-ok]:
    <k> elabEnd('ExprName(X:Id)) => elabRes(cast(T, 'ExprName(X))) ...</k>
    <elabEnv> ListItem(mapWrap((X |-> T:Type) _)) ...</elabEnv>

rule [elabEnd-localVar-to-noValue]:
    <k> elabEnd('ExprName(X:Id)) => externalVar(X, Class) ...</k>
    <elabEnv> ListItem(mapWrap(ElabEnv:Map)) ...</elabEnv>
    <crntClass> Class:ClassType </crntClass>
when notBool (X in keys(ElabEnv))

//@ This could be either a field, or a local var of some enclosing block.
syntax KItem ::=  externalVar (
                Id,       //X - var name
                ClassType //Class - innermost class where the name should be searched
              )

rule [externalVar]:
    <k>
      externalVar(X:Id, Class:ClassType)
      => elabEnd('Field( cast(Class, 'QThis(Class)),, X ))
          ?? elabOuterLocalVar(X, Class) ?? externalVar(X, EnclosingClass)
      ...
    </k>
    <classType> Class </classType>
    <enclosingClass> EnclosingClass:ClassType </enclosingClass>

rule [externalVar-noClass]:
    externalVar(_, noClass) => noValue

/*@ Attempts to resolve this expression into a local var from the enclosing local environment
    of type being precisely the given class.
*/
syntax KItem ::=  elabOuterLocalVar (
                Id,       //X - var name
                ClassType //Class - the possibly local class whose local env should be searched
              )

rule [elabOuterLocalVar-ok]:
    <k>
      elabOuterLocalVar(X:Id, Class:ClassType)
      =>  #if Class ==K CrntClass
            //this way in constructors we will access the parameter $local_var, not the field
            #then elab('Field('ExprName(String2Id("$local_env")),, X))

            //if this is an outer var for some enclosing class, always access it via a field
            #else elab('Field('Field('QThis(Class),, String2Id("$local_env")),, X))
          #fi
      ...
    </k>
    <crntClass> CrntClass:ClassType </crntClass>
    <classType> Class </classType>
    <enclosingLocalEnv>... X |-> T:Type ...</enclosingLocalEnv>

rule [elabOuterLocalVar-not-found]:
    <k>
      elabOuterLocalVar(X:Id, Class:ClassType) => noValue
      ...
    </k>
    <classType> Class </classType>
    <enclosingLocalEnv> EnclosingLocalEnv:Map </enclosingLocalEnv>
when
    notBool X in keys(EnclosingLocalEnv)

rule [elabEnd-ExprName-qualified]:
    elabEnd('ExprName(QualK:K,,X:Id)) => elabEnd('Field(QualK,,X))

rule [elabEnd-Field-of-package]:
    elabEnd('Field( _:PackageId,, _:Id )) => noValue  [structural]

rule [elabEnd-Field-of-noValue]:
    elabEnd('Field( noValue,, _:Id )) => noValue      [structural]

//@Computation of instance and static environment of a class, e.g. set of fields

/*@ Searches the given field name in the given type (set of types), both static and instance context.

Important!!! The name is searched in this type and base types only. It is not searched in outer classes.
  That is the job of externalVar().
*/
syntax KItem ::=  elabLookup (
                Id,       //The field to search
                ClassType //The current class under search
              )
            | elabLookup (
                Id, //The field to search
                Set //A set of interfaces under search
              )

rule [elabLookup-Found-instance]:
    <k> elabLookup(X:Id, Class:ClassType) => fieldEntry(Class, X, T, instanceCT) ...</k>
    <classType> Class </classType>
    <instanceFields> [_,, 'FieldDec(_:K,, T:Type,, ['VarDec(X)]),, _] </instanceFields>

rule [elabLookup-Found-static]:
    <k> elabLookup(X:Id, Class:ClassType) => fieldEntry(Class, X, T, staticCT) ...</k>
    <classType> Class </classType>
    <staticFields> [_,, 'FieldDec(['Static(_)],, T:Type,, ['VarDec(X)]),, _] </staticFields>

rule [elabLookup-Found-constant]:
    <k> elabLookup(X:Id, Class:ClassType) => TV ...</k>
    <classType> Class </classType>
    <constantEnv>... X |-> TV:TypedVal ...</constantEnv>

/*@If X is not found in the current class, search for it first in base interfaces, then in the base class.
This order is necessary to avoid the case when base class has a private field X, and base
interfaces have a public one. In this case we should choose the field from the interface.
*/
rule [elabLookup-NextClass]:
    <k>
      elabLookup(X:Id, Class:ClassType) => elabLookup(X, BaseInterfaces) ?? elabLookup(X, BaseClass)
      ...
    </k>
    <classType> Class </classType>
    <extends> BaseClass:ClassType </extends>
    <implements> BaseInterfaces:Set </implements>
    <instanceFields> [InstanceVarDecs:KList] </instanceFields>
    <staticFields> [StaticVarDecs:KList] </staticFields>
    <constantEnv> ConstantEnv:Map </constantEnv>
when
    notBool ( nameInVarDecs(X, [InstanceVarDecs]) ==K true
              orBool nameInVarDecs(X, [StaticVarDecs]) ==K true
              orBool (X in keys (ConstantEnv))
    )

rule [elabLookup-NotFound]:
    elabLookup(X:Id, noClass) => noValue

rule [elabLookup-Set]:
    elabLookup(X:Id, SetItem(Class:ClassType) Rest:Set)
    => elabLookup(X, Class) ?? elabLookup(X, Rest)

rule [elabLookup-Set-NotFound]:
    elabLookup(_, .Set) => noValue

syntax KItem ::=  nameInVarDecs(
                Id,       //Target name
                KListWrap //The list of variable declarations, each of the form
                          //  'LocalVarDec(.K,, T:Type,, ['VarDec(X)])
              )
              [function]

rule nameInVarDecs(X:Id, [_,, _:KLabel(.K,, T:Type,, ['VarDec(X)]),, _]) => true

rule [elabEnd-This]:
    <k> elabEnd('This(.KList) => 'QThis(Class)) ...</k>
    <crntClass> Class:ClassType </crntClass>

rule [elabEnd-QThis-InstanceCT]:
    <k> elabEnd('QThis(Class:ClassType)) => elabRes(cast(Class, 'QThis(Class))) ...</k>
    <contextType> instanceCT </contextType>

rule [elabEnd-QThis-StaticCT]:
    <k> elabEnd('QThis(_)) => noValue ...</k>
    <contextType> staticCT </contextType>

rule [elabEnd-Field-QualRef]:
    elabEnd('Field(cast(Class:ClassType, Qual:K),, X:Id))
    => elabFieldImpl(cast(Class, Qual), elabLookup(X, Class))

rule [elabEnd-Field-QualClass]:
    elabEnd('Field(Class:ClassType,, X:Id))
    => elabFieldImpl(noValue, elabLookup(X, Class))

// 'SuperField(X:Id)

rule [elabEnd-SuperField]:
    <k>
      elabEnd('SuperField(X:Id) => 'QSuperField(Class,, X:Id))
      ...
    </k>
    <crntClass> Class:ClassType </crntClass>

// 'QSuperField(Class:ClassType,, X:Id)

rule [elabEnd-QSuperField]:
    <k>
      elabEnd('QSuperField(Class:ClassType,, X:Id))
      => elabFieldImpl(cast(Class, 'QThis(Class)), elabLookup(X, BaseClass))
      ...
    </k>
    <classType> Class </classType>
    <extends> BaseClass:ClassType </extends>

//@Computed the Cast expression for a given expression and its type
syntax KItem ::=  elabFieldImpl (
                K,  // Field qualifier exp (noValue for fields qualified by a class)
                K   //elabLookup(...), computes into fieldEntry(...) or noValue
              )
              [strict(2)]

/*@ A representation of fields used in elaboration phase. */
syntax KResult ::=  fieldEntry (
                      ClassType,  // target class
                      Id,         // X - field name
                      Type,       // Field type
                      ContextType // staticCT | instanceCT
                    )

rule elabFieldImpl(QualExp:K, fieldEntry(Class:ClassType, X:Id, T:Type, instanceCT))
    => elabRes(cast(T, 'Field(cast(Class, QualExp),, X)))

rule elabFieldImpl(_, fieldEntry(Class:ClassType, X:Id, T:Type, staticCT))
    => elabRes(cast(T, 'Field(Class,, X)))

//@for constant fields
rule elabFieldImpl(_, TV:TypedVal) => TV

rule elabFieldImpl(_, noValue) => noValue

endmodule
