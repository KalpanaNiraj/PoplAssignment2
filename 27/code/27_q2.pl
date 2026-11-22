% CS F301 Assignment 2 - P2: Form a Valid Arithmetic Equation

:- use_module(library(lists)).

%! split_nonempty(+List, -Left, -Right) is nondet.
%  Declarative reading: Left and Right are both non-empty lists and
%  append(Left, Right, List) holds.
split_nonempty([First|Rest], [First|Left], Right) :-
    split_nonempty_aux(Rest, Left, Right).

%! split_nonempty_aux(+Rest, -Left, -Right) is nondet.
%  Declarative reading: Right is non-empty, and Left followed by Right is Rest.
split_nonempty_aux([Head|Tail], [], [Head|Tail]).
split_nonempty_aux([Head|Tail], [Head|Left], Right) :-
    split_nonempty_aux(Tail, Left, Right).

%! apply_op(?Op, +A, +B, -Value) is nondet.
%  Declarative reading: Op is one of +, -, *, / and Value is the integer
%  A Op B; for / the divisor B is non-zero and divides A exactly.
apply_op(+, A, B, Value) :- Value is A + B.
apply_op(-, A, B, Value) :- Value is A - B.
apply_op(*, A, B, Value) :- Value is A * B.
apply_op(/, A, B, Value) :-
    B =\= 0,
    A mod B =:= 0,
    Value is A // B.

%! expr(+Numbers, -Tree, -Value) is nondet.
%  Declarative reading: Tree is an expression tree whose leaves, read left to
%  right, are exactly Numbers (non-empty), every division inside Tree is exact
%  with non-zero divisor, and Value is the integer value of Tree.
expr([N], N, N).
expr(Numbers, bin(Op, LeftTree, RightTree), Value) :-
    split_nonempty(Numbers, Left, Right),
    expr(Left, LeftTree, LeftValue),
    expr(Right, RightTree, RightValue),
    apply_op(Op, LeftValue, RightValue, Value).

%! op_prec(+Op, -Prec) is semidet.
%  Declarative reading: Prec is the binding strength of operator Op
%  (higher binds tighter).
op_prec(+, 1).
op_prec(-, 1).
op_prec(*, 2).
op_prec(/, 2).

%! expr_string(+Tree, -String) is det.
%  Declarative reading: String is the space-free canonical text of Tree:
%  a number in decimal, or left operand, operator, right operand, where an
%  operand is parenthesised exactly when the left/right rule requires it.
expr_string(Number, String) :-
    integer(Number),
    format(string(String), "~d", [Number]).
expr_string(bin(Op, Left, Right), String) :-
    op_prec(Op, Prec),
    left_string(Prec, Left, LeftString),
    right_string(Prec, Right, RightString),
    format(string(String), "~w~w~w", [LeftString, Op, RightString]).

%! left_string(+ParentPrec, +Tree, -String) is det.
%  Declarative reading: String is the text of Tree as the left operand of an
%  operator of precedence ParentPrec; parenthesised iff Tree's top operator
%  has strictly lower precedence than ParentPrec.
left_string(ParentPrec, Tree, String) :-
    expr_string(Tree, Inner),
    (   top_prec(Tree, Prec), Prec < ParentPrec
    ->  format(string(String), "(~w)", [Inner])
    ;   String = Inner
    ).

%! right_string(+ParentPrec, +Tree, -String) is det.
%  Declarative reading: String is the text of Tree as the right operand of an
%  operator of precedence ParentPrec; parenthesised iff Tree's top operator
%  has precedence lower than or equal to ParentPrec.
right_string(ParentPrec, Tree, String) :-
    expr_string(Tree, Inner),
    (   top_prec(Tree, Prec), Prec =< ParentPrec
    ->  format(string(String), "(~w)", [Inner])
    ;   String = Inner
    ).

%! top_prec(+Tree, -Prec) is semidet.
%  Declarative reading: Tree is a compound bin(Op, _, _) and Prec is the
%  precedence of Op; fails for a plain number.
top_prec(bin(Op, _, _), Prec) :-
    op_prec(Op, Prec).
