/*@ Elaboration of types and packages.
*/
module ELABORATION-TYPES
    imports CORE-SORTS
    imports CORE-CLASSES
    imports ELABORATION-CORE
    imports PROCESS-TYPE-NAMES        // for getNamesMap()

/*@ \subsection{Elaboration of types} */

rule 'ClassOrInterfaceType(TypeK:K,, _) => TypeK [structural]
rule 'InterfaceType(TypeK:K,, _) => TypeK        [structural]
rule 'ClassType(TypeK:K,, _) => TypeK            [structural]

/*@ Resolving fully qualified type names. A name like pack.p2.A is represented as:
    'TypeName('PackageOrTypeName('PackageOrTypeName(pack),,p2),,A)
*/
// 'PackageOrTypeName(Qual,, Name)
rule 'PackageOrTypeName(KRs:KResult,, K:Id) => 'TypeName(KRs,,K) ?? 'PackageName('IdList(KRs,,'IdList(K,,.IdList)))  [structural]
// 'PackageOrTypeName(Name)
rule 'PackageOrTypeName(K:Id) => 'TypeName(K) ?? 'PackageName('IdList(K,,.IdList))  [structural]

/*@ When we search for a class qualified by another class, we simply convert
    the qualifier into a package.*/

// 'TypeName(Qual,, X:Id)
rule [TypeName-QualifiedClass]:
    'TypeName(ClassQ:ClassType,, X:Id) => 'TypeName(toPackage(ClassQ),, X)            [structural]

rule [TypeName-QualifiedPackage]:
    'TypeName(Pack:PackageId,, X:Id) => typeNameQualifiedImpl(getNamesMap(Pack), X)   [structural]

//@Retrieves the ClassType for the given names map and simple class name
syntax KItem ::= typeNameQualifiedImpl ( K, Id ) [strict(1)]

rule [typeNameQualifiedImpl-Found]:
    typeNameQualifiedImpl(mapWrap((X |-> Class:ClassType) _), X:Id) => Class

rule [typeNameQualifiedImpl-NotFound]:
    typeNameQualifiedImpl(mapWrap(NamesMap:Map), X:Id) => noValue
when notBool X in keys(NamesMap)

rule [TypeName-local-in-any-Phase]:
    <k> 'TypeName(X:Id) => Class ...</k>
    <localTypes> ListItem(mapWrap((X |-> Class:ClassType) _)) ...</localTypes>

rule [TypeName-global]:
    <k> 'TypeName(X:Id) => Class ...</k>
    <localTypes> ListItem(mapWrap(LocalTypes:Map)) ...</localTypes>
    <crntClass> CrntClass:ClassType </crntClass>
    <classType> CrntClass </classType>
    <imports>... X |-> Class:ClassType ...</imports>
when
    notBool X in keys(LocalTypes)

rule [TypeName-global-Fail]:
    <k> 'TypeName(X:Id) => noValue ...</k>
    <localTypes> ListItem(mapWrap(LocalTypes:Map)) ...</localTypes>
    <crntClass> CrntClass:ClassType </crntClass>
    <classType> CrntClass </classType>
    <imports> Imp:Map </imports>
when
    notBool X in keys(LocalTypes) andBool notBool (X in keys(Imp))

/*@ This two rules may only apply during processing of extends/implements clauses of top-level classes.
    When the class whose declaration is processed is an inner class,
    usual rules for 'TypeName apply.*/
rule [TypeName-In-ProcClassDecsPhase-Top]:
    <k> 'TypeName(X:Id) => Class ...</k>
    <crntClass> noClass </crntClass>
    <compUnitImports>... X |-> Class:ClassType ...</compUnitImports>

rule [TypeName-In-ProcClassDecsPhase-Top-Fail]:
    <k> 'TypeName(X:Id) => noValue ...</k>
    <crntClass> noClass </crntClass>
    <compUnitImports> Imp:Map </compUnitImports>
when
    notBool X in keys(Imp)

endmodule
