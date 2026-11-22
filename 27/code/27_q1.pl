% CS F301 Assignment 2 - P1: Department Assignment Puzzle, Reloaded
% Run: swipl -q -f 27_q1.pl -g main -t halt

:- use_module(library(lists)).
:- use_module(library(apply)).
:- use_module(library(yall)).
:- use_module(library(aggregate)).

%! candidate_solution(-Solution) is nondet.
%  Declarative reading: Solution is a list
%  [p('Alex',D1,L1,P1), p('Ben',D2,L2,P2), p('Carla',D3,L3,P3), p('Dana',D4,L4,P4)]
%  such that [D1,D2,D3,D4] is a permutation of [research,development,design,testing],
%  [L1,L2,L3,L4] is a permutation of [python,java,'c++',javascript], and
%  [P1,P2,P3,P4] is a permutation of ['AI',web,embedded,data].
candidate_solution([p('Alex',D1,L1,P1), p('Ben',D2,L2,P2),
                    p('Carla',D3,L3,P3), p('Dana',D4,L4,P4)]) :-
    permutation([research, development, design, testing], [D1,D2,D3,D4]),
    permutation([python, java, 'c++', javascript], [L1,L2,L3,L4]),
    permutation(['AI', web, embedded, data], [P1,P2,P3,P4]).
