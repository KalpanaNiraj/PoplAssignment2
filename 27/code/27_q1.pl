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

%! clue(+N, +Solution) is semidet.
%  Declarative reading: clue N (1..8) holds in the fully filled-in Solution.
clue(1, Solution) :-
    once(member(p(Name, Dept, _, 'AI'), Solution)),
    Dept \== research,
    Name \== 'Dana'.
clue(2, Solution) :-
    once(member(p('Alex', Dept, Lang, _), Solution)),
    Dept \== development,
    Lang \== 'c++'.
clue(3, Solution) :-
    once(member(p(_, testing, Lang, _), Solution)),
    Lang == python.
clue(4, Solution) :-
    once(member(p('Ben', Dept, _, Project), Solution)),
    Project == web,
    Dept \== testing.
clue(5, Solution) :-
    once(member(p(_, Dept, java, _), Solution)),
    Dept == design.
clue(6, Solution) :-
    once(member(p('Carla', Dept, _, Project), Solution)),
    Project \== embedded,
    Dept \== development.
clue(7, Solution) :-
    once(member(p('Dana', Dept, Lang, _), Solution)),
    Lang \== java,
    memberchk(Dept, [research, testing]).
clue(8, Solution) :-
    once(member(p(_, Dept, Lang, data), Solution)),
    Dept == research,
    Lang \== javascript.

%! main is det.
%  Declarative reading: main prints, one line per friend in the order Alex, Ben,
%  Carla, Dana, the first candidate solution (in the order of candidate_solution/1)
%  that satisfies clues 1 to 8.
main :-
    once(( candidate_solution(Solution),
           forall(between(1, 8, N), clue(N, Solution)) )),
    maplist(print_person, Solution).

%! print_person(+Person) is det.
%  Declarative reading: a line "Name = [Dept, Lang, Project]" is written for
%  Person = p(Name, Dept, Lang, Project); atoms are written without quotes.
print_person(p(Name, Dept, Lang, Project)) :-
    format("~w = [~w, ~w, ~w]~n", [Name, Dept, Lang, Project]).
