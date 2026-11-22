% Tests for P1 (27_q1.pl).
% Run from the 27 folder:
%   swipl -q -f tests/test_q1.pl -g run_tests -t halt

:- use_module(library(lists)).
:- use_module(library(apply)).
:- use_module(library(aggregate)).
:- consult('../code/27_q1.pl').

%! test(+Name, :Goal) is det.
%  Prints "PASS Name" if Goal succeeds, otherwise "FAIL Name" (also on exceptions).
%  test/2 succeeds exactly when Goal passes (the verdict is also printed).
test(Name, Goal) :-
    (   catch(Goal, E, (print_message(error, E), fail))
    ->  format("PASS ~w~n", [Name])
    ;   format("FAIL ~w~n", [Name]),
        fail
    ).

% The three solutions of clues 1 to 8, as named bundles.
sol(1, [p('Alex',design,java,'AI'), p('Ben',development,javascript,web),
        p('Carla',research,'c++',data), p('Dana',testing,python,embedded)]).
sol(2, [p('Alex',design,java,embedded), p('Ben',development,javascript,web),
        p('Carla',testing,python,'AI'), p('Dana',research,'c++',data)]).
sol(3, [p('Alex',testing,python,embedded), p('Ben',development,javascript,web),
        p('Carla',design,java,'AI'), p('Dana',research,'c++',data)]).

% Number of candidates satisfying clue N alone.
alone(1, 7776).
alone(2, 7776).
alone(3, 3456).
alone(4, 2592).
alone(5, 3456).
alone(6, 7776).
alone(7, 5184).
alone(8, 2592).

% Number of candidates when exactly clue K is left out of 1..8.
leave_out(1, 4).
leave_out(2, 6).
leave_out(3, 13).
leave_out(4, 12).
leave_out(5, 9).
leave_out(6, 7).
leave_out(7, 5).
leave_out(8, 16).

all_but(K, List) :-
    findall(X, (between(1, 8, X), X \== K), List).

holds_at_most_once(N, S) :-
    findall(x, clue(N, S), L),
    length(L, Len),
    Len =< 1.

expected_output("Alex = [design, java, embedded]\nBen = [development, javascript, web]\nCarla = [testing, python, AI]\nDana = [research, c++, data]\n").

run_tests :-
    findall(R, run_one(R), Results),
    length(Results, Total),
    include(==(pass), Results, Passed),
    length(Passed, P),
    format("passed ~d of ~d~n", [P, Total]).

% run_one(-Result): runs one test, unifying Result with pass or fail.
run_one(Result) :-
    test_case(Name, Goal),
    (   test(Name, Goal)
    ->  Result = pass
    ;   Result = fail
    ).

% --- candidate_solution/1 ---
test_case(candidates_count_13824,
          ( aggregate_all(count, candidate_solution(_), 13824) )).
test_case(candidates_all_distinct,
          ( findall(S, candidate_solution(S), L),
            length(L, Len),
            sort(L, Sorted),
            length(Sorted, Len) )).
test_case(candidates_format,
          ( \+ ( candidate_solution(S),
                 \+ S = [p('Alex',_,_,_), p('Ben',_,_,_), p('Carla',_,_,_), p('Dana',_,_,_)] ) )).
test_case(candidates_fully_ground,
          ( \+ ( candidate_solution(S), \+ ground(S) ) )).
test_case(candidates_permutations,
          ( \+ ( candidate_solution(S),
                 findall(D, member(p(_,D,_,_), S), Ds),
                 findall(L, member(p(_,_,L,_), S), Ls),
                 findall(P, member(p(_,_,_,P), S), Ps),
                 \+ ( msort(Ds, [design,development,research,testing]),
                      msort(Ls, ['c++',java,javascript,python]),
                      msort(Ps, ['AI',data,embedded,web]) ) ) )).

% --- each clue on its own ---
test_case(Name, Goal) :-
    alone(N, Count),
    format(atom(Name), 'clue_~d_alone_count_~d', [N, Count]),
    Goal = ( aggregate_all(count, ( candidate_solution(S), clue(N, S) ), C), C =:= Count ).

test_case(clue_9_accepts_solution_2,
          ( sol(2, S), clue(9, S) )).
test_case(clue_9_rejects_solution_1,
          ( sol(1, S), \+ clue(9, S) )).
test_case(clue_9_rejects_solution_3,
          ( sol(3, S), \+ clue(9, S) )).
test_case(clue_9_alone_rejects_some_candidates,
          ( aggregate_all(count, ( candidate_solution(S), clue(9, S) ), C), C > 0, C < 13824 )).

test_case(Name, Goal) :-
    between(1, 3, I),
    format(atom(Name), 'solution_~d_satisfies_clues_1_to_8', [I]),
    Goal = ( sol(I, S), forall(between(1, 8, N), clue(N, S)) ).

test_case(Name, Goal) :-
    between(1, 9, N),
    format(atom(Name), 'clue_~d_succeeds_at_most_once', [N]),
    Goal = ( \+ ( candidate_solution(S), \+ holds_at_most_once(N, S) ) ).

% --- count_solutions/2 ---
test_case(count_empty_is_13824,
          ( count_solutions([], 13824) )).
test_case(count_clues_1_to_8_is_3,
          ( count_solutions([1,2,3,4,5,6,7,8], 3) )).
test_case(count_clues_1_to_9_is_1,
          ( count_solutions([1,2,3,4,5,6,7,8,9], 1) )).
test_case(count_reversed_order_is_3,
          ( count_solutions([8,7,6,5,4,3,2,1], 3) )).
test_case(count_shuffled_order_is_3,
          ( count_solutions([5,1,8,3,7,2,6,4], 3) )).
test_case(count_reversed_with_9_is_1,
          ( count_solutions([9,8,7,6,5,4,3,2,1], 1) )).
test_case(count_duplicates_ignored,
          ( count_solutions([1,1,2,2,3,3,4,5,6,7,8,8], 3) )).
test_case(count_subset_8_3_5_is_144,
          ( count_solutions([8,3,5], 144) )).
test_case(count_only_clue_9_matches_filter,
          ( count_solutions([9], C),
            aggregate_all(count, ( candidate_solution(S), clue(9, S) ), C) )).
test_case(Name, Goal) :-
    alone(N, Count),
    format(atom(Name), 'count_single_clue_~d_is_~d', [N, Count]),
    Goal = count_solutions([N], Count).
test_case(Name, Goal) :-
    leave_out(K, Count),
    format(atom(Name), 'count_leave_out_clue_~d_is_~d', [K, Count]),
    Goal = ( all_but(K, List), count_solutions(List, Count) ).
test_case(count_is_deterministic,
          ( findall(N, count_solutions([1,2,3], N), L), length(L, 1) )).

% --- main/0 and print_person/1 ---
test_case(main_output_exact,
          ( with_output_to(string(Out), main),
            expected_output(Expected),
            Out == Expected )).
test_case(main_succeeds_exactly_once,
          ( findall(x, with_output_to(string(_), main), L), length(L, 1) )).
test_case(main_solution_satisfies_clues_1_to_8,
          ( findall(S, ( candidate_solution(S), forall(between(1, 9, N), clue(N, S)) ), [Only]),
            forall(between(1, 8, M), clue(M, Only)),
            sol(2, Only),
            with_output_to(string(Out), maplist(print_person, Only)),
            expected_output(Out) )).
test_case(main_prints_four_lines,
          ( with_output_to(string(Out), main),
            split_string(Out, "\n", "", Parts),
            Parts = [_, _, _, _, ""] )).
test_case(print_person_format,
          ( with_output_to(string(Out), print_person(p('Dana', research, 'c++', 'AI'))),
            Out == "Dana = [research, c++, AI]\n" )).
