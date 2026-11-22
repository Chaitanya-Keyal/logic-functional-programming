# CS F301 Assignment 2: Logic and Functional Programming (Group 3)

| Name | ID number | GitHub |
|------|-----------|--------|
| Chaitanya Keyal | 2023B4A70727H | [Chaitanya-Keyal](https://github.com/Chaitanya-Keyal) |
| Arpit Wallecha | 2023B3A70482H | [arpitwallecha](https://github.com/arpitwallecha) |
| Vishesh Agarwal | 2023B4A70611H | [vish-1115](https://github.com/vish-1115) |
| Abhishek Verma | 2023B4A71256H | [abhishekverma555](https://github.com/abhishekverma555) |

Two Prolog problems (P1, P2) and two Scheme problems (S1, S2). The repository root is the `GROUPID/` folder of the required layout, with group ID `3`.

## Layout

| Path | Contents |
|------|----------|
| `code/` | `3_q1.pl` (P1), `3_q2.pl` (P2), `3_q3.rkt` (S1), `3_q4.rkt` (S2) |
| `tests/` | One test file per problem: `p1_test.pl`, `p2_test.pl`, `s1_test.rkt`, `s2_test.rkt` |
| `skills/` | `prolog-dev/SKILL.md`, `scheme-dev/SKILL.md` |
| `prompts/` | The prompts we gave the AI, word for word: `P1.md`, `P2.md`, `S1.md`, `S2.md` |
| `P1_REPORT.md` | P1.b: N for clues 1 to 8 and what it says about the puzzle |
| `Makefile` | `make test` runs all tests, `make demo` runs the handout examples |
| `opencode.json` | Makes the skills in `skills/` available to OpenCode |

## Running

Environment: SWI-Prolog 9.x and Racket 8.x (developed with SWI-Prolog 9.0.4 and Racket 8.10).

```bash
# as the grader runs the code
swipl -q -f code/3_q1.pl -g main -t halt
swipl -q -f code/3_q2.pl -g 'all_equations([4,2,5,3], Es), print(Es), nl' -t halt
racket code/3_q3.rkt          # definitions only: prints nothing until calls are appended
racket code/3_q4.rkt          # same; (print-insert-result) reads x, lst and n from stdin

make test    # all four test files (plunit and rackunit)
make demo    # every example from the handout, run the grader's way
```

The tests run the solutions the way the grader does (a separate `swipl`/`racket` process, with the
calls appended to a copy of the Racket files) and compare the output byte for byte. The Racket
tests also check that the solution files use only the allowed built-ins. GitHub Actions runs
`make test` on every push.

## Solutions in brief

- **P1** (`3_q1.pl`): `candidate/1` enumerates all 24³ = 13,824 assignments without looking at
  any clue; `clue(N, S)` is one clause per clue; `solve/2` keeps the candidates in which every
  active clue holds (checked with `forall/2`, so nothing is counted twice). Clues 1 to 8 leave
  **3 solutions**, and two of them hold the same (department, language, project) triples, so a
  clue that names no friend can only keep the third: clue 9 is "the friend working in the testing
  department prefers the AI project". See [`P1_REPORT.md`](P1_REPORT.md).
- **P2** (`3_q2.pl`): `expression/3` builds every expression tree over a list (split into two
  non-empty parts, recurse, join with `apply_op/4`, which allows only exact division by a non-zero
  number); `equation/2` splits the list once for `=` and keeps pairs of sides with equal values;
  `expression_string/2` prints a tree with the canonical parenthesis rule. Strings are built only
  for valid equations and are never parsed back.
- **S1** (`3_q3.rkt`): inorder, preorder and postorder lists are built with accumulators (no
  append); height is 0 for `()` and 1 + the larger subtree height; leaves are counted with a
  named-let accumulator.
- **S2** (`3_q4.rkt`): `my-length` (tail recursive) and `my-map`; `make-inserter` returns a
  recursive function that maps itself over sublists and puts `x` in front of every list whose
  original length satisfies `len-ok?`; `insert-if-short` is `make-inserter` with `(< len n)`.

## How we used AI

We used [OpenCode](https://opencode.ai) with the model `tff/deepseek-v4.1-flash-1017`, run from the
repository root so it loaded our skills (`opencode.json` points it at `skills/` and blocks git
commands). There was one OpenCode session per problem. Every prompt asked for one unit of work (one
predicate or function, one test file, one analysis or one review), and every prompt is in
`prompts/` word for word with a note on what we checked and kept. Each unit was reviewed and
re-run by us before it was committed together with its prompt, so the commit history follows the
problems section by section.

Commits follow [Conventional Commits](https://www.conventionalcommits.org), scoped by problem (`p1`,
`p2`, `s1`, `s2`) or by area (`skills`, `opencode`).
