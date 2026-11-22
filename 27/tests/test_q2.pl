% Tests for P2 (27_q2.pl).
% Run from the 27 folder:
%   swipl -q -f tests/test_q2.pl -g run_tests -t halt

:- use_module(library(lists)).
:- use_module(library(apply)).
:- consult('../code/27_q2.pl').

%! test(+Name, :Goal) is det.
%  Prints PASS or FAIL for Goal and records the outcome with a result fact
%  threaded through run_tests/0 (no assert is used).
test(Name, Goal, Result) :-
    (   catch(Goal, E, (print_message(error, E), fail))
    ->  format("PASS ~w~n", [Name]), Result = pass
    ;   format("FAIL ~w~n", [Name]), Result = fail
    ).

%! no_spaces(+String) is semidet.
%  String contains no space character.
no_spaces(String) :-
    \+ sub_string(String, _, _, _, " ").

%! all_strings_ok(+List) is semidet.
%  Every element is a string without spaces containing exactly one "=".
all_strings_ok(Equations) :-
    forall(member(E, Equations),
           (   string(E),
               no_spaces(E),
               split_string(E, "=", "", [_, _])
           )).

%! tests(-Tests) is det.
%  Tests is the list of Name-Goal pairs that run_tests/0 executes.
tests([
    % ---- assignment examples ----
    example1-(all_equations([4,2,5,3], Es1),
              Es1 == ["4*2-5=3","4*2=5+3","4-2=5-3","4/2=5-3",
                      "4=2*(5-3)","4=2+(5-3)","4=2+5-3"]),
    example2-(all_equations([2,3,4], [])),
    example3-(all_equations([2,4,8], ["2*4=8"])),
    generate_member-(generate_equation([4,2,5,3], G),
                     member(G, ["4*2-5=3","4*2=5+3","4-2=5-3","4/2=5-3",
                                "4=2*(5-3)","4=2+(5-3)","4=2+5-3"])),
    generate_fails-(\+ generate_equation([2,3,4], _)),
    % ---- edge cases ----
    empty_all-(all_equations([], [])),
    single_all-(all_equations([5], [])),
    empty_generate_fails-(\+ generate_equation([], _)),
    single_generate_fails-(\+ generate_equation([5], _)),
    empty_count-(count_equations([], 0)),
    single_count-(count_equations([5], 0)),
    zeros_pair-(all_equations([0,0], ["0=0"])),
    zeros_triple-(all_equations([6,0,0], ["6*0=0"])),
    no_zero_div-(all_equations([6,0,0], Z), \+ member("6=0/0", Z),
                 forall(member(E0, Z), \+ sub_string(E0, _, _, _, "/0"))),
    zero_over_zero-(all_equations([0,0,0], Z3),
                    forall(member(E1, Z3), \+ sub_string(E1, _, _, _, "/0"))),
    ones-(all_equations([1,1], ["1=1"])),
    inexact_division_pruned-(all_equations([7,2,3], [])),
    inner_exact_division-(all_equations([6,3,2], Ed),
                          memberchk("6/3=2", Ed)),
    division_of_sum-(all_equations([3,5,2,4], Ds),
                     memberchk("(3+5)/2=4", Ds)),
    negative_intermediate-(all_equations([1,2,3,4], Neg),
                           Neg == ["1-2=3-4","1=2+(3-4)","1=2+3-4"]),
    negative_intermediate_b-(all_equations([2,3,4,5], Neg2),
                             memberchk("2-3=4-5", Neg2)),
    plain_sum-(all_equations([1,2,3], ["1+2=3"])),
    % ---- result properties ----
    results_are_strings-(all_equations([4,2,5,3], R1), all_strings_ok(R1),
                         maplist(string, R1)),
    generate_is_string-(generate_equation([4,2,5,3], G2), string(G2),
                        no_spaces(G2)),
    results_sorted_unique-(all_equations([1,2,3,4], R2),
                           sort(R2, R2s), R2 == R2s),
    results_sorted_unique_b-(all_equations([4,2,5,3], R3),
                             msort(R3, R3m), R3 == R3m,
                             sort(R3, R3s), length(R3, N3),
                             length(R3s, N3)),
    results_all_valid_strings-(all_equations([1,2,3,4,5], R4),
                               R4 \== [], all_strings_ok(R4)),
    count_matches_length-(all_equations([4,2,5,3], R5),
                          length(R5, Len5), count_equations([4,2,5,3], Len5),
                          Len5 =:= 7),
    count_matches_length_b-(all_equations([1,2,3,4,5], R6),
                            length(R6, Len6),
                            count_equations([1,2,3,4,5], Len6)),
    all_equations_det-(findall(X, all_equations([4,2,5,3], X), [_])),
    % ---- canonical printing ----
    print1-(expr_string(bin(*,bin(+,4,2),3), "(4+2)*3")),
    print2-(expr_string(bin(+,4,bin(*,2,3)), "4+2*3")),
    print3-(expr_string(bin(*,bin(/,8,4),2), "8/4*2")),
    print4-(expr_string(bin(/,8,bin(*,4,2)), "8/(4*2)")),
    print5-(expr_string(bin(-,bin(-,1,2),3), "1-2-3")),
    print6-(expr_string(bin(-,1,bin(-,2,3)), "1-(2-3)")),
    print7-(expr_string(bin(+,1,bin(+,2,3)), "1+(2+3)")),
    print8-(expr_string(bin(+,bin(+,1,2),3), "1+2+3")),
    print9-(expr_string(bin(*,2,bin(-,5,3)), "2*(5-3)")),
    print10-(expr_string(bin(+,2,bin(-,5,3)), "2+(5-3)")),
    print11-(expr_string(bin(-,bin(+,2,5),3), "2+5-3")),
    print_leaf-(expr_string(7, "7")),
    print_leaf_string-(expr_string(12, S12), string(S12)),
    % ---- building blocks ----
    split_four-(findall(L-R, split_nonempty([4,2,5,3], L, R), Sp),
                Sp == [[4]-[2,5,3],[4,2]-[5,3],[4,2,5]-[3]]),
    split_short-(\+ split_nonempty([], _, _), \+ split_nonempty([1], _, _)),
    apply_div_exact-(apply_op(/, -6, 3, -2)),
    apply_div_inexact-(\+ apply_op(/, 7, 2, _)),
    apply_div_zero-(\+ apply_op(/, 5, 0, _)),
    apply_negative-(apply_op(-, 3, 5, -2)),
    apply_enumerates-(findall(Op, apply_op(Op, 8, 4, _), Ops),
                      Ops == [+,-,*,/]),
    expr_pairs-(findall(T-V, expr([4,2], T, V), Tv),
                Tv == [bin(+,4,2)-6,bin(-,4,2)-2,bin(*,4,2)-8,bin(/,4,2)-2]),
    expr_count-(findall(T, expr([1,2,3], T, _), Ts), length(Ts, 20)),
    expr_empty_fails-(\+ expr([], _, _)),
    % ---- termination / size ----
    count_eight-(count_equations([1,2,3,4,5,6,7,8], N8), N8 =:= 4804)
]).

%! run_tests is det.
%  Runs every test, prints one PASS/FAIL line each and a summary line.
run_tests :-
    tests(Tests),
    run_all(Tests, Results),
    length(Results, Total),
    include(==(pass), Results, Passed),
    length(Passed, PassCount),
    format("passed ~d of ~d~n", [PassCount, Total]).

%! run_all(+Tests, -Results) is det.
%  Results holds pass or fail for each Name-Goal pair, in order.
run_all([], []).
run_all([Name-Goal|Rest], [Result|Results]) :-
    test(Name, Goal, Result),
    run_all(Rest, Results).
