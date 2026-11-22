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
