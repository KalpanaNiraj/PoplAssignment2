---
name: scheme-dev
description: Conventions, allowed built-ins, run/test commands, self-review checklist and known AI failure modes for writing Racket 8.x (#lang racket/base) solutions in CS F301 Assignment 2 (files 27_q3.rkt, 27_q4.rkt). Use for any Scheme function, test file or Scheme code review in this repository.
---

# scheme-dev: Racket/Scheme skill for CS F301 Assignment 2

## 1. Language and environment

- **Racket 8.x** (tested with 8.18), every file starts with exactly `#lang racket/base`.
- **Only these built-ins may be used:** `define`, `lambda`, `let`, `let*`, `letrec`, named `let`,
  `if`, `cond` (with `else`), `and`, `or`, `not`, `begin`, `quote` / `'`, `cons`, `car`, `cdr`,
  `list`, every `c[ad]{2,4}r` composition (`cadr`, `cddr`, `caddr`, `cdddr`, `cadddr`, ...),
  `null?`, `pair?`, `eq?`, `assq`, `assoc`, `+ - * < > <= >= =`, `max`, `display`, `newline`.
  **S2 additionally allows `read`.**
- **Forbidden (non-exhaustive):** `set!` and all mutation, vectors, hash tables, strings,
  `do`, `for` and every `for/...` loop, `length`, `append`, `reverse`, `map`, `filter`, `foldl`,
  `foldr`, `member`, `memq`, `list-ref`, `list-tail`, `apply`, `void`, `when`, `unless`, `case`,
  `else` outside `cond`, `printf`, `write`, `number?`, `symbol?`, `list?`, `equal?`, `zero?`,
  `add1`, `sub1`, `quotient`, `define-values`, `values`, `error`. If one is needed, write a helper
  with a `my-` prefix (`my-reverse`, `my-length`, `my-map`, `my-append`).
- The file contains **only definitions**. No top-level calls, no printing at load time, no
  `provide`, no `module+ main`, no `module+ test`. The grader appends its own calls.

## 2. Coding conventions

- **Naming:** kebab-case (`print-inorder`, `my-length`, `inorder-acc`). Predicates end in `?`
  (`leaf?`, `len-ok?`). Accumulator parameters are named `acc`.
- **Every function has a comment block** directly above it:
  ```racket
  ;; (my-length lst) -> number
  ;; Recursive reading: the length of () is 0; the length of (x . rest) is
  ;; 1 + the length of rest. Tail-recursive via acc.
  ```
  The comment gives the signature and a **recursive (inductive) reading**: base case(s) and how
  the answer for a bigger input is built from answers on smaller inputs.
- **All state goes through arguments.** No mutation, no global accumulators.
- **Prefer tail recursion** where natural (named `let` loops with an accumulator, then a final
  `my-reverse`). Structural recursion on trees (two recursive calls) is fine, but keep
  list-processing helpers tail-recursive so lists of 10,000 elements are safe.
- Distinguish lists from atoms with `pair?` / `null?` only (there is no `list?`, `symbol?`, or
  `number?`). A value `v` is a list iff `(or (null? v) (pair? v))`.
- Indent with 2 spaces, close all parentheses on the last line of the form.

## 3. How to run and test

The grader runs `racket 27_q3.rkt` and `racket 27_q4.rkt` after appending its own calls.
On this machine Racket is installed project-locally; if `racket` is not on `PATH`, use
`../.tools/racket/racket.exe` (the `.tools` folder sits next to the repository folder,
i.e. `c:\Users\kalpa\OneDrive\Desktop\Kalpana\Popl_Assignment2\.tools\racket\racket.exe`).

Tests live in `tests/` (one per problem). A test file may use full `racket/base` (the restriction
applies to the solution files only) and loads the solution with `require` of a copy or with
`(load ...)`-free textual inclusion. The simplest robust pattern used in this repository:

```racket
#lang racket/base
(require racket/port racket/file)
;; evaluate the solution file with extra calls appended, capture stdout, compare to expected
```

S2 is tested by piping standard input, e.g. `echo "42 ((1 2) (3 4 5) (6) ()) 3" | racket file.rkt`
where the file ends with `(print-insert-result)`.

Every example in the assignment PDF must be a test, plus edge cases: empty tree / empty list,
single node, skewed trees, `n = 0`, deep nesting (depth 100) and long lists (10,000 elements).

## 4. Self-review checklist (apply BEFORE answering)

1. First line is `#lang racket/base`; nothing is called or printed at top level.
2. **Scan every identifier** against the allowed list in section 1. Any `length`, `append`,
   `reverse`, `map`, `else` outside `cond`, `when`, `unless`, `void`, `list?`, `equal?` is a bug.
3. Every `cond` ends with an `else` clause; every `if` has both branches.
4. Base cases: does the function handle `()` (empty tree / empty list) correctly?
5. Output format: `display` of a list prints `(1 2 3)`; each print function ends with exactly one
   `newline`; nothing else is printed (no prompt, no labels).
6. Recursion depth: list helpers are tail-recursive (safe for 10,000 elements); tree/nesting
   recursion depth is bounded by the nesting depth (100), which is fine.
7. Measurements (like list length in S2) are taken on the **original** list, before modification.
8. Higher-order functions return a `lambda`; no partial application helpers that do not exist
   in `racket/base` (`curry` is not allowed).
9. Comment block with a recursive reading present above every function.
10. Mentally run every example from the spec and state the printed output.

## 5. Known failure modes of AI tools in Scheme/Racket

- **Using forbidden built-ins out of habit**: `length`, `append`, `reverse`, `map`, `filter`,
  `foldl`, `list?`, `equal?`, `when`, `unless`, `void`, `printf`, `add1`, `string-append`.
- **`#lang racket` instead of `#lang racket/base`**, or adding `(provide ...)`/`module+ main`.
- **Printing at top level** (leaving `(print-inorder t1)` or test calls in the solution file).
- **Using `write`/`print` instead of `display`**; or printing a trailing space / missing newline.
- **Quadratic `append` in traversals** (`(append (inorder l) (list v) (inorder r))`) rather than
  an accumulator that conses onto the result from the right.
- **Off-by-one in height** (single node must be height 1, empty tree 0) and **counting `()` as
  a leaf**.
- **Measuring length after insertion** in nested-list problems, so a list of length n-1 becomes
  length n and is treated differently.
- **Treating the empty list as an atom** (it is a list; `(pair? '())` is `#f` but
  `(null? '())` is `#t`).
- **Non-tail recursion over 10,000-element lists** in helpers like `my-length`.
- **Mutation via `set!`** to accumulate results, or **`define` inside expressions** in illegal
  positions.

## 6. Working agreement for this group

- One prompt = one unit of work (one function, one test file or one review). Answer only that unit.
- Reply with the code for that unit in a single fenced code block, followed by the recursive
  reading and the result of the self-review checklist. Do not write the complete solution to a
  whole problem in one answer.
- Do not create or modify files inside the repository; the group pastes accepted code into the
  solution files. You may run code in a scratch folder to check your answer before replying.
