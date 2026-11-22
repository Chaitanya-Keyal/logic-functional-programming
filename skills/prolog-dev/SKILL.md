---
name: prolog-dev
description: Rules, conventions, run/test commands, a self-review checklist and known AI failure modes for SWI-Prolog 9.x code in this repository (CS F301 Assignment 2, problems P1 and P2, files code/3_q1.pl and code/3_q2.pl). Load it before writing, changing, testing or reviewing any .pl file here.
---

# prolog-dev

You are helping Group 3 write SWI-Prolog for CS F301 Assignment 2. Each request is one unit of
work: one predicate, one test file, or one review. Do exactly that unit and nothing more.

## 1. Language and version

- SWI-Prolog 9.x (graded on 9.x; we develop on 9.0.4). Use standard SWI-Prolog 7+ defaults:
  `"..."` in source code is a **string**, `'...'` is an atom, `` `...` `` is a code list.
- Allowed libraries: `lists`, `apply`, `yall`, `aggregate`, and nothing else. Load the ones you
  use explicitly at the top of the file, e.g. `:- use_module(library(lists)).`
  Built-in predicates (`is/2`, `format/2,3`, `findall/3`, `forall/2`, `between/3`, `msort/2`,
  `sort/2,4`, `number_string/2`, `string_concat/3`, `atom_string/2`, etc.) are part of the
  system, not libraries, and may be used.
- Forbidden: `clpfd`/`clpz` or any other library not listed above; `assert/asserta/assertz`,
  `retract`, `b_setval`, `nb_setval`, `b_getval`, `nb_getval`, `recorda`, `flag/3`, global
  variables of any kind; `halt/0,1`; any `:- initialization(...)` directive; printing anything
  that the task does not ask for.

## 2. How the code is run (and must therefore behave)

| File | Problem | Grader command |
|------|---------|----------------|
| `code/3_q1.pl` | P1 | `swipl -q -f code/3_q1.pl -g main -t halt` |
| `code/3_q2.pl` | P2 | `swipl -q -f code/3_q2.pl -g "<goal>" -t halt` |

- The file contains only `use_module` directives for allowed libraries, comments, and clauses.
- Loading the file must print **nothing** to stdout or stderr. That rules out singleton-variable
  warnings, "Clauses of X are not together" (discontiguous) warnings, and redefinition warnings.
  Check with `swipl -q -f FILE -g true -t halt` and confirm both streams are empty.
- Predicates that are not supposed to print must not print, not even debug output.

## 3. Coding conventions

- **Names:** `snake_case` predicates and atoms, `CamelCase` variables with meaningful names
  (`Dept`, `Lang`, `Project`, `LeftExpr`), `_` or `_Name` for intentionally unused variables.
- **Layout:** all clauses of one predicate are contiguous; four-space indentation; one goal per
  line in bodies longer than two goals; `->`/`;` blocks wrapped in parentheses and aligned.
- **Header comment for every predicate**, in PlDoc style, immediately above its first clause:

  ```prolog
  %! split_list(+List, -Left, -Right) is nondet.
  %
  %  Declarative reading: Left and Right are non-empty lists and
  %  appending Left and Right gives List.
  ```

  The first line gives the mode (`+` input, `-` output, `?` either) and the determinism
  (`det`, `semidet`, `nondet`, `multi`). The reading says **what relation holds**, not the
  steps taken. For a recursive predicate also give the recursive reading of each clause, e.g.
  "the length of `[_|T]` is one more than the length of `T`".
- **Purity first:** prefer pure relations, `\+`, `once/1`, `forall/2` and if-then-else to cuts.
  If you use a cut, comment why it is safe (green cut) and what it commits to.
- **Arithmetic:** evaluate with `is/2`, compare with `=:=`, `=\=`, `<`, `>`, `=<`, `>=`. Never use
  `=` to compare numbers. Integer division is `//`; check exactness with
  `Divisor =\= 0, Dividend mod Divisor =:= 0` **before** dividing.
- **Text:** print with `format/2` using `~w` (unquoted write) and `~n`. Build a string with
  `format(string(S), Fmt, Args)` or `string_concat/3`; check the result with `string/1`.
- **No hard-coding:** answers are derived by search over the problem's domain, never typed in.

## 4. How to run and test

```bash
# load check: must print nothing at all
swipl -q -f code/3_q1.pl -g true -t halt

# run a goal exactly as the grader does
swipl -q -f code/3_q1.pl -g main -t halt
swipl -q -f code/3_q2.pl -g 'all_equations([2,4,8],Es), print(Es), nl' -t halt

# run the unit tests for one problem (exit status 0 only if all tests pass)
swipl -q -g run_tests -t halt tests/p1_test.pl
```

Test files live in `tests/` (one per problem: `p1_test.pl`, `p2_test.pl`) and use `plunit`
(test files may use any library; the restrictions apply to `code/` only):

```prolog
:- use_module(library(plunit)).
:- ensure_loaded('../code/3_q2').        % path is relative to the test file

:- begin_tests(p2_examples).
test(two_four_eight, Es == ["2*4=8"]) :- all_equations([2,4,8], Es).
test(no_equation, [fail]) :- generate_equation([2,3,4], _).
:- end_tests(p2_examples).
```

- Compare exact values with `==` (a string is not equal to an atom or a code list).
- Capture printed output with `with_output_to(string(Out), main)` and compare it to the full
  expected text, including the final newline.
- Every example given in the assignment handout must appear as a test, plus edge cases
  (empty input, one element, zeros, impossible inputs, larger inputs for speed).
- Run the tests yourself and report the real result. Never claim a test passes without running it.

## 5. Self-review checklist (apply before every answer)

Go through each item and fix what fails before you reply. In your reply, say briefly which
checks you ran and their results.

1. **Scope:** I wrote or changed only the predicate(s) this request names. Everything else in
   the file is untouched. I did not run any git command.
2. **Loads silently:** `swipl -q -f FILE -g true -t halt` prints nothing (no singleton,
   discontiguous or redefinition warnings).
3. **Rules:** no `halt`, no `initialization`, no assert/retract/global variables, only
   `lists`/`apply`/`yall`/`aggregate`, no `clpfd`, nothing printed that was not asked for.
4. **Determinism and counting:** a check that is used inside `findall/3` or `aggregate_all/3`
   succeeds at most once per candidate (wrap nondeterministic checks in `once/1`, `\+ \+`, or
   use `forall/2`), so nothing is counted twice. No duplicate answers from overlapping clauses.
5. **Termination:** every recursion consumes a strictly smaller bounded structure. Inputs `[]`,
   one-element lists and impossible inputs **fail** (or give `[]`/`0` where specified) instead of
   looping or throwing.
6. **Arithmetic safety:** no division by zero, no inexact division, no `is/2` with unbound
   operands, no float or rational results where an integer is meant.
7. **Types and format:** strings are SWI strings (`string/1` is true); printed output matches the
   required text character for character (spaces, commas, case, no quotes, final newline).
8. **Docs:** every predicate has a mode/determinism header and a declarative reading.
9. **Evidence:** I ran the assignment's examples and the relevant tests and compared exactly.

## 6. Known failure modes of AI tools in Prolog (avoid these)

- Reaching for `clpfd`, `assert`/`retract` counters, `nb_setval`, or `between/3` + `nth1/3`
  index juggling where a simple list relation is clearer.
- Pruning the search space with problem-specific facts inside the generator, so the "generator"
  only produces some candidates. Then counting with a subset of the constraints gives the wrong
  number. A generator must produce the whole domain; constraints are checked separately.
- Nondeterministic tests (`member/2` that can match several elements, or a clause that can
  succeed in two ways) that make `findall/3` count the same solution more than once.
- Overlapping base and recursive clauses (e.g. a `[]` clause plus a clause that also accepts `[]`)
  that return duplicate answers.
- Using `=` for arithmetic, `is/2` with unbound right-hand sides (instantiation errors), `/`
  instead of `//`, forgetting the zero-divisor check (an exception instead of a failure).
- Mixing up strings, atoms and code lists: `format(atom(A), ...)` gives an atom,
  `atomic_list_concat/2` gives an atom, `"..."` gives a string; tests then fail on `==`.
- Printing with `print/1`, `writeq/1`, `~q` or `~p`, which add quotes (`'c++'`, `'AI'`), or
  `~w` on a whole list, which prints `[a,b]` without the spaces a required format may need.
- Generating expressions by unbounded left recursion (`expr(E) :- expr(L), ...`) that never
  terminates; always split the finite input first and recurse on strictly smaller parts.
- Building a string and parsing it back (`term_to_atom/2`, `term_string/2`,
  `read_term_from_atom/3`) to evaluate it, which P2 forbids.
- Leaving clauses of one predicate separated by other code (discontiguous warning at load time),
  or leaving singleton variables.
- Adding `:- initialization(main).`, `halt.`, or test calls to the solution file.
- Hard-coding the answer of a puzzle instead of deriving it.
- Claiming that code "works" or "tests pass" without having run it.
