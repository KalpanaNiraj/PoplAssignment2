---
name: prolog-dev
description: Conventions, run/test commands, self-review checklist and known AI failure modes for writing SWI-Prolog 9.x solutions in CS F301 Assignment 2 (files 27_q1.pl, 27_q2.pl). Use for any Prolog predicate, test file or Prolog code review in this repository.
---

# prolog-dev: SWI-Prolog skill for CS F301 Assignment 2

## 1. Language and environment

- **SWI-Prolog 9.x** (tested with 9.2.9). Plain ISO-style Prolog plus SWI built-ins.
- **Allowed libraries only:** `lists`, `apply`, `yall`, `aggregate`. Load them explicitly with
  `:- use_module(library(lists)).` and so on. Nothing else (no `clpfd`, no `dcg/basics`, no `strings`).
- **Forbidden:** `assert/1`, `asserta/1`, `assertz/1`, `retract/1`, `b_setval/2`, `nb_setval/2`,
  `b_getval/2`, `nb_getval/2`, any `:- initialization(...)` directive, and calling `halt/0` yourself.
- The file contains **only definitions** (clauses and `use_module` directives). Loading the file
  must print nothing. Only `main/0` (P1) prints, and only the exact lines required.
- In P2, **never build a string and parse it back** (`term_string/2`, `term_to_atom/2`,
  `read_term_from_atom/3`, `number_codes` on a whole expression) to evaluate it. Evaluate the
  expression tree directly.

## 2. Coding conventions

- **Naming:** predicates and variables use `snake_case` / `CamelCase` respectively, with
  descriptive names (`split_list/3`, `expr_value/2`, not `p/3`, `f/2`). Helper predicates get a
  short purpose suffix (`_acc`, `_aux`) only when they are accumulator versions.
- **Mode/type comment above every predicate** in PlDoc style:
  ```prolog
  %! expr_value(+Expr, -Value) is semidet.
  %  Declarative reading: Value is the integer value of expression tree Expr,
  %  where every division in Expr is exact and has a non-zero divisor.
  ```
  `+` = input (bound), `-` = output, `?` = either. Determinism: `det`, `semidet`, `nondet`.
- **Declarative reading is mandatory.** Every predicate's comment states what is TRUE when the
  predicate succeeds ("X is ... such that ..."), not a procedure ("loop over ...").
- One clause per idea; keep clauses short. Use `\+` for negation-as-failure only on goals whose
  variables are bound at call time.
- Use `is/2` only with fully instantiated right-hand sides; use `=:=`, `=\=` for numeric comparison,
  `==`, `\==` for structural comparison, `=` only for unification.
- Atoms that start with an uppercase letter or contain special characters must be quoted:
  `'Alex'`, `'AI'`, `'c++'`.
- Strings: SWI-Prolog double quotes produce **strings** (`"4*2=5+3"`), not code lists. Build
  output strings with `format(string(S), Fmt, Args)` or `atomics_to_string/2`, `string_concat/3`.

## 3. How to run and test

The grader runs exactly:

```sh
swipl -q -f 27_q1.pl -g main -t halt
swipl -q -f 27_q1.pl -g "count_solutions([1,2,3,4,5,6,7,8],N), print(N), nl" -t halt
swipl -q -f 27_q2.pl -g "all_equations([4,2,5,3],Es), print(Es), nl" -t halt
```

On this machine SWI-Prolog is installed project-locally; if `swipl` is not on `PATH`, use
`../.tools/swipl/bin/swipl.exe` (the `.tools` folder sits next to the repository folder,
i.e. `c:\Users\kalpa\OneDrive\Desktop\Kalpana\Popl_Assignment2\.tools\swipl\bin\swipl.exe`).

Test files live in `tests/` (one per problem) and use only the allowed libraries. Pattern:

```prolog
:- consult('../code/27_q2.pl').
test(Name, Goal) :-
    (   catch(Goal, E, (print_message(error, E), fail))
    ->  format("PASS ~w~n", [Name])
    ;   format("FAIL ~w~n", [Name])
    ).
run_tests :- test(example1, all_equations([2,4,8], ["2*4=8"])), ... .
```

Run with `swipl -q -f tests/test_q2.pl -g run_tests -t halt`. Every example in the assignment
PDF must be a test, plus edge cases (empty list, one element, zeros, division by zero, negative
intermediate values, failure cases).

## 4. Self-review checklist (apply BEFORE answering)

1. Does the code load with **no warnings** (singleton variables, discontiguous clauses, clauses
   not together)? Prefix intentionally unused variables with `_`.
2. Are all clauses of one predicate **contiguous**? (`clue/2` clauses must sit together.)
3. Is every arithmetic goal called with bound operands? No `is/2` on unbound right-hand sides,
   no `X > Y` with unbound X.
4. Does any predicate **loop** on backtracking or when the answer is "no"? Check base cases and
   that every recursive call is on a strictly smaller input.
5. Does a predicate that must **fail** (e.g. no valid equation, list of length 0 or 1) actually fail
   instead of raising an exception? Division by zero must be prevented, not caught.
6. Are atoms quoted correctly (`'AI'`, `'c++'`, `'Alex'`)? Is output exactly the required format
   (spacing, commas, line breaks, no extra output)?
7. No forbidden built-ins (section 1), no unapproved libraries, no `initialization`, no `halt`.
8. Are duplicates possible in `findall/3` results? If the spec says "without duplicates", use
   `sort/2` or make the generator produce each answer once.
9. Is the declarative reading comment present and true for every predicate?
10. Mentally run at least one example from the spec through the code and state the result.

## 5. Known failure modes of AI tools in Prolog

- **Unquoted capitalised atoms**: writing `AI` or `Alex` (which are variables) instead of `'AI'`,
  `'Alex'`. Silent bug: unifies with anything.
- **Negation before binding**: `\+ member(X, L)` or `X \= Y` while X is unbound always fails or
  succeeds wrongly. Constraints with negation must run after generation.
- **Hard-coding the puzzle answer** instead of deriving it from the clues.
- **Using `is/2` for comparison** (`X is Y` where both bound is fine, but `X = Y+1` does not
  evaluate).
- **Integer vs float division**: `/` may produce a float or rational; use `//` with a `mod` check
  (or `divmod/4`) for exact integer division, and check the divisor is non-zero first.
- **Infinite left recursion** in grammar-style generators (`expr --> expr, op, expr`): always split
  the number list first so recursion is on a shorter list.
- **Duplicate solutions** from symmetric generation; forgetting `sort/2` or `list_to_set/2`.
- **Missing cuts / extra choice points** making `main/0` print twice, or **wrong use of cut**
  removing valid solutions.
- **Printing with `print/1` or `write/1`** where quotes or spacing differ from the required format
  (`write('c++')` prints `c++`, `print('c++')` prints `'c++'`).
- **Discontiguous clause warnings** when clauses of one predicate are separated by other code.
- **Strings vs atoms vs code lists**: returning `'4*2=5+3'` (atom) or a code list when a string
  is required; `format(atom(A), ...)` vs `format(string(S), ...)`.
- Calling non-existent or non-SWI predicates (e.g. `string_join/3`, `sum/2`) from other
  Prolog dialects or Python habits.

## 6. Working agreement for this group

- One prompt = one unit of work (one predicate, one test file or one review). Answer only that unit.
- Reply with the code for that unit in a single fenced code block, followed by a short
  declarative explanation and the result of the self-review checklist. Do not write the
  complete solution to a whole problem in one answer.
- Do not create or modify files inside the repository; the group pastes accepted code into the
  solution files. You may run code in a scratch folder to check your answer before replying.
