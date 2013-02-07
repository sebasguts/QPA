# GAP Implementation
# This file was generated from 
# $Id: idempotent.gi,v 1.1 2010/05/07 13:30:13 sunnyquiver Exp $
#

#######################################################################
##
#F  PrimitiveIdempotents( <A> )
##
##  This function takes as an argument a finite dimensional semisimple 
##  algebra  <A>  for a finite field and returns a complete set of 
##  primitive idempotents  { e_i }  such that  
##                     A \simeq  Ae_1 + ... + Ae_n.
##
##  TODO: Understand what this function actually does.
##
InstallGlobalFunction("PrimitiveIdempotents",
    function(A)
    local F, d, e, eA, r, m, E, b, one, i, s, j, x, e_hat;

    F := LeftActingDomain(A);
    d := Dimension(A);
    e := HOPF_SingularIdempotent(A);
    eA := e*A;

    r := Dimension(eA);  # Dimension of a copy of the center of A. 
    m := d / r;          # Matrix dimension (rows and cols)
    E := List([1..m], x -> Zero(A));
    E[1] := e;
    s := Zero(A);
    one := MultiplicativeNeutralElement(A);
    b := BasisVectors(Basis(A));

    for i in [2..m] do
        s := s + E[i-1];
        j := 0;
        repeat
            j := j+1;
            x := (one - s)*b[j]*e;
        until x <> Zero(A);
        e_hat := HOPF_LeftIdentity(x*A);
        E[i] := e_hat*(one - s);
    od;
    return E;
end
);

#######################################################################
##
#F  HOPF_MinPoly( <A>, <a> )
##
##  This function takes as an argument a finite dimensional algebra  <A>
##  over a field  K  and an element  <a>  in this algebra and returns 
##  the monic polynomial  f  of smallest degree such that  f(a) = 0  in
##  <A>. 
##
InstallGlobalFunction(HOPF_MinPoly,
    function( A, a )
    local F, vv, sp, x, cf, f;

    F := LeftActingDomain(A);
    vv := [ MultiplicativeNeutralElement( A ) ];
    sp := MutableBasis(F, vv);
    x := ShallowCopy(a);
    while not IsContainedInSpan( sp, x ) do
        Add(vv,x);
        CloseMutableBasis(sp, x);
        x := x*a;
    od;
    sp := UnderlyingLeftModule(ImmutableBasis(sp));
    cf := ShallowCopy( - Coefficients(BasisNC(sp,vv), x));
    Add(cf, One(F));
    f := ElementsFamily(FamilyObj(F));
    f := LaurentPolynomialByCoefficients( f, cf, 0 );
    return f;
end
);

#######################################################################
##
#F  HOPF_ZeroDivisor( <A> )
##
##  This function takes as an argument a finite dimensional semisimple 
##  algebra  <A>  over a finite field and returns a list of two elements  
##  [a, b]  in  <A>  such that  a*b = 0  in <A>, if  <A> is not 
##  commutative. If  <A>  is commutative, it returns an empty list.
##
##  TODO: When  <A>  is commutative, check if the number of central
##  idempotents are than 1, if so return [e, 1-e] for a central idempotent
##  e.  If the number of central idempotents are 1, then  <A>  is a field
##  and therefore has no non-zero zero divisor and return an empty list.
##   
InstallGlobalFunction(HOPF_ZeroDivisor,
  function(A)
    local F, d, b, bv, cf, x, m, facts, one, f, g;
    if IsCommutative(A) then
        return [];
    fi;

    F := LeftActingDomain(A);
    if not (IsFinite(F) and IsFiniteDimensional(A)) then
        Error("Algebra A must be finite.");
    fi;
    d := Dimension(A);
    b := CanonicalBasis(A);
    bv := BasisVectors(b);
    repeat
        cf := List([1..d], x -> Random(F));
        x := LinearCombination(bv, cf);
        m := HOPF_MinPoly(A, x);
        facts := Factors( PolynomialRing(F), m);
    until Length(facts) > 1;
    one := MultiplicativeNeutralElement(A);
    f := facts[1];
    g := Product(facts{[2..Length(facts)]});
    return [Value(f, x, one), Value(g, x, one)];
end
);

#######################################################################
##
#F  HOPF_LeftIdentity( <A> )
##
##  This function takes as an argument a finite dimensional algebra 
##  <A>  and returns a left identity for  <A>, if such a thing exists.   
##  Otherwise it returns fail.
##
InstallGlobalFunction(HOPF_LeftIdentity,
  function(A)
    local F, b, bv, n, equ, zero, one, zerovec, vec, row, p, sol,
          i, j;

    F := LeftActingDomain(A);
    b := CanonicalBasis(A);
    bv := BasisVectors(b);
    n := Dimension(A);

    equ := [];
    zero := Zero(F);
    one := One(F);
    zerovec := ListWithIdenticalEntries(n^2, zero);
    vec := ShallowCopy(zerovec);

    for i in [1..n] do
        row := ShallowCopy(zerovec);
        for j in [1..n] do
            p := (j-1)*n;
            row{[p+1..p+n]} := Coefficients(b, b[i]*b[j]);
        od;
        Add(equ, row);
        vec[ (i-1)*n + i ] := one;
    od;
    sol := SolutionMat(equ,vec);
    if sol <> fail then
        sol := LinearCombination(bv, sol);
    fi;
    return sol;
end
);

#######################################################################
##
#F  HOPF_SingularIdempotent( <A> )
##
##  This function takes as an argument a finite dimensional semisimple 
##  algebra  <A>  and returns a primitive idempotent for  <A>?   
##  
##  TODO: Understand what this function actually does.
##
InstallGlobalFunction(HOPF_SingularIdempotent,
  function(A)
    local z, b, bv, x, li, e;

    while not IsCommutative(A) do
        z := HOPF_ZeroDivisor(A);
        b := Basis(A);
        bv := BasisVectors(b);
        x := z[1];
        li := x*A;
        e := HOPF_LeftIdentity(li);

        A := Algebra(LeftActingDomain(A), List(bv, x->e*x*e));
    od;

    return MultiplicativeNeutralElement(A);
  end
);