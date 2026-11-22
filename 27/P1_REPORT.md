# P1.b Report: how many solutions do clues 1 to 8 allow?

## Result

With clues 1 to 8 active, N = 3. The command is run from the folder that contains `27_q1.pl`:

    swipl -q -f 27_q1.pl -g "count_solutions([1,2,3,4,5,6,7,8],N), print(N), nl" -t halt

It prints `3`. For comparison, `count_solutions([], N)` gives N = 13824 (4! * 4! * 4! candidates).

## The three solutions (department, language, project)

| Friend | Solution 1 | Solution 2 | Solution 3 |
|--------|------------|------------|------------|
| Alex   | design, java, AI | design, java, embedded | testing, python, embedded |
| Ben    | development, javascript, web | development, javascript, web | development, javascript, web |
| Carla  | research, c++, data | testing, python, AI | design, java, AI |
| Dana   | testing, python, embedded | research, c++, data | research, c++, data |

## What N = 3 means

N > 0, so the eight clues are consistent. N > 1, so they do not determine the puzzle: the puzzle is under-determined.

All three solutions agree on:
- Ben: development, javascript, web.
- Alex works in design or testing, never in research or development.
- Dana works in research or testing, never in design or development.
- The same four bundles of attributes appear in every solution: (development, javascript, web), (research, c++, data), (design, java, AI or embedded) and (testing, python, AI or embedded).
  - Research always goes with c++ and data.
  - Design always goes with java.
  - Testing always goes with python.

What is not forced is who holds which bundle, and which of design and testing gets AI and which gets embedded.

## Is any clue redundant?

N when exactly one clue is left out of 1..8:

| Left out | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 |
|----------|---|---|---|---|---|---|---|---|
| N        | 4 | 6 | 13 | 12 | 9 | 7 | 5 | 16 |

Every value is greater than 3. Removing any single clue lets extra solutions in, so no clue is redundant: each one rules out at least one candidate that the other seven allow. Clue 8 does the most work (16 without it); clue 1 the least (4).

## Why a name-free clue can keep only one solution

Written as sets of (department, language, project) bundles, ignoring names:

- Solution 1: {(design,java,AI), (development,javascript,web), (research,c++,data), (testing,python,embedded)}
- Solution 2: {(design,java,embedded), (development,javascript,web), (testing,python,AI), (research,c++,data)}
- Solution 3: {(testing,python,embedded), (development,javascript,web), (design,java,AI), (research,c++,data)}

Solutions 1 and 3 are the same set of bundles; they differ only in who holds them (Alex and Carla swap bundles). A clue that mentions friends only through attribute values sees only this set, so it cannot tell solutions 1 and 3 apart: it keeps both or drops both. Solution 2 has a different set (design goes with embedded, testing with AI), so only solution 2 can be isolated by a name-free clue.

## Repair: clue 9

    % CLUE 9: The friend who prefers the embedded project works in the design department.

It holds in solution 2 only (in solutions 1 and 3 the embedded project goes with testing). With it, `count_solutions([1,2,3,4,5,6,7,8,9], N)` gives N = 1. The remaining solution is solution 2, and `main/0` (which checks clues 1 to 9) prints:

    Alex = [design, java, embedded]
    Ben = [development, javascript, web]
    Carla = [testing, python, AI]
    Dana = [research, c++, data]
