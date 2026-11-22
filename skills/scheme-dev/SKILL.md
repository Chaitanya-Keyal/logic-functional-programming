---
name: scheme-dev
description: Rules, the exact built-in whitelist, conventions, run/test commands, a self-review checklist and known AI failure modes for the Racket (#lang racket/base) code in this repository (CS F301 Assignment 2, problems S1 and S2, files code/3_q3.rkt and code/3_q4.rkt). Load it before writing, changing, testing or reviewing any .rkt file here.
---

# scheme-dev

You are helping Group 3 write Scheme in Racket for CS F301 Assignment 2. Each request is one
unit of work: one function (or one small group of helpers that exist only to serve it), one test
file, or one review. Do exactly that unit and nothing more.

## 1. Language, version and the whitelist

- Racket 8.x. Every solution file starts with exactly this first line: `#lang racket/base`
- **Only these built-ins may appear in `code/*.rkt`:**

  | Group | Allowed |
  |-------|---------|
  | Binding and definition | `define`, `lambda`, `let`, `let*`, `letrec`, named `let` |
  | Control | `if`, `cond` (with `else`), `and`, `or`, `not`, `begin` |
  | Data | `quote` (written `'`), `cons`, `car`, `cdr`, `list`, every `c[ad]r` composition up to four levels (`cadr`, `cddr`, `caddr`, `cdddr`, `cadddr`, `cddddr`, `caadr`, ...) |
  | Predicates | `null?`, `pair?`, `eq?` |
  | Association lists | `assq`, `assoc` |
  | Arithmetic and comparison | `+`, `-`, `*`, `<`, `>`, `<=`, `>=`, `=`, `max` |
  | Output | `display`, `newline` |
  | Input (S2 only) | `read` |

  Literals are fine: numbers, `#t`, `#f`, and quoted data such as `'()` or `'(1 2)`.
- **Everything else from racket/base is forbidden.** In particular: `set!` and relatives, vectors,
  hash tables, strings (including string literals such as `" "`), characters, loops (`do`,
  `for`, `for/list`, ...), `length`, `append`, `reverse`, `map`, `filter`, `foldl`, `foldr`,
  `apply`, `member`, `memq`, `list-ref`, `list-tail`, `last`, `equal?`, `eqv?`, `zero?`,
  `add1`, `sub1`, `min`, `abs`, `quotient`, `number?`, `symbol?`, `list?`, `empty?`, `first`,
  `rest`, `empty`, `null` (the constant; write `'()`), `when`, `unless`, `case`, `match`, `λ`,
  `displayln`, `printf`, `write`, `print`, `error`, `void`, `values`, `define-values`,
  `provide`, `require`, `module+`, `struct`.
- If you need a list utility, write it yourself from the whitelist, named with a `my-` prefix
  (`my-length`, `my-map`, `my-append`, `my-reverse`).

## 2. How the code is run (and must therefore behave)

| File | Problem | Grader |
|------|---------|--------|
| `code/3_q3.rkt` | S1 | `racket 3_q3.rkt` after appending its own `define`s and calls to the end of the file |
| `code/3_q4.rkt` | S2 | `racket 3_q4.rkt` after appending its calls; `print-insert-result` reads stdin |

- The file contains **only definitions** (and comments). No top-level calls, no top-level
  expressions (Racket prints the value of a top-level expression), no example data.
- `racket FILE` on the unmodified file must print nothing and exit with status 0.
- The grader appends code to the same module. A name defined both by us and by the grader is a
  "duplicate definition" error, so never define generic names such as `t1`, `t2`, `t3`, `tree`,
  `lst`, `x`, `n` or `test` at top level. Use specific helper names (`inorder-acc`, `tree-height`).
- No `provide`/`require`: the grader does not import the file, it runs it.
- Every printing function ends its output with exactly one `(newline)`. Print whole lists with a
  single `display` of a list value (that gives `(1 2 3)`, `()`, `(b a c)`); never assemble
  output from string pieces.

## 3. Coding conventions

- **Names:** `kebab-case`; predicates end in `?`; re-implemented library functions use `my-`.
- **Comment block above every function** with its contract, purpose and recursive reading:

  ```racket
  ;; (my-length lst) -> number
  ;; Number of top-level elements of lst.
  ;; Recursive reading: the length of () is 0; the length of (a . rest) is
  ;; 1 + the length of rest. Tail recursive: acc counts the elements seen so far.
  ```

- **State only through arguments:** no mutation, no global variables. Accumulators are extra
  parameters (of a helper or a named `let`).
- **Tail recursion where it is natural:** use an accumulator so the recursive call is the last
  thing done when the result is built left to right or as a count. Do not contort tree recursion;
  one recursive call can be a tail call and the other not.
- **Atoms vs lists:** an element is a list exactly when `(or (null? e) (pair? e))`; otherwise it is
  an atom. Compare numbers with `=`, symbols with `eq?`.
- Keep linear work linear: no repeated `my-append` inside a loop over a long list.

## 4. How to run and test

```bash
racket code/3_q3.rkt      # must print nothing

# simulate the grader: copy the file to a temp dir, append calls, run
tmp=$(mktemp -d)
cp code/3_q3.rkt "$tmp/s1.rkt"
printf '%s\n' "(define t1 '(4 (2 (1 () ()) (3 () ())) (6 (5 () ()) (7 () ()))))" \
              "(print-all-traversals t1)" >> "$tmp/s1.rkt"
racket "$tmp/s1.rkt"

# S2 reads x, lst, n from stdin
cp code/3_q4.rkt "$tmp/s2.rkt" && echo "(print-insert-result)" >> "$tmp/s2.rkt"
echo "42 ((1 2) (3 4 5) (6) ()) 3" | racket "$tmp/s2.rkt"

# unit tests (exit status is non-zero if any check fails)
raco test tests/s1_test.rkt
```

Test files (`tests/s1_test.rkt`, `tests/s2_test.rkt`) may use full Racket (`rackunit`,
`racket/system`, `racket/port`, `racket/file`, `racket/runtime-path`); the whitelist applies to
`code/` only. A test file must:

1. Run the solution the way the grader does: write a temp file containing the solution's text
   followed by the calls, run it with the `racket` executable (feeding stdin for S2), and compare
   **stdout exactly** (including the final newline) and check that **stderr is empty**.
2. Check that running the unmodified solution file prints nothing.
3. Contain a **whitelist check**: read every form of the solution file, collect each symbol used
   outside quoted data, and fail if a symbol is neither in the whitelist above nor bound in the
   file itself (by `define`, a `lambda`/`define` parameter list, or a `let`-family binding,
   including a named `let` name).
4. Cover every example from the assignment handout, plus edge cases.

## 5. Self-review checklist (apply before every answer)

Go through each item and fix what fails before you reply. In your reply, say briefly which
checks you ran and their results.

1. **Scope:** I wrote or changed only the function(s) this request names. Everything else in the
   file is untouched. I did not run any git command.
2. **Header:** the first line is exactly `#lang racket/base`; the file holds only `define`s and
   comments; no `provide`, `require` or submodules.
3. **Whitelist:** every identifier I used is in the table in section 1 or is defined/bound in
   this file. I looked specifically for `displayln`, `length`, `append`, `reverse`, `map`,
   `equal?`, `list?`, `number?`, `symbol?`, `when`, `else` outside `cond`, and string literals.
4. **Silent load:** `racket FILE` prints nothing.
5. **Exact output:** with the grader's calls appended, the output matches the handout character
   for character, ending in one newline.
6. **Edge cases:** empty tree/list, a single node, unbalanced trees, symbols as values, nested
   empty lists, `n = 0`, nesting depth 100, a 10,000-element list.
7. **Style:** no mutation, state passed in arguments, tail recursion where natural, no quadratic
   helpers, comment block with contract and recursive reading on every function.
8. **Evidence:** I ran the examples and tests and report the actual results.

## 6. Known failure modes of AI tools in Racket/Scheme (avoid these)

- Writing `#lang racket` (or no `#lang` line) instead of `#lang racket/base`.
- Reaching for forbidden built-ins out of habit: `length`, `append`, `reverse`, `map`, `filter`,
  `foldl`, `apply`, `equal?`, `list?`, `number?`, `symbol?`, `zero?`, `add1`, `when`, `unless`,
  `displayln`, `printf`, `first`/`rest`, `empty`/`null`.
- Formatting output by hand with string literals (`(display " ")`, `(display "(")`) instead of
  displaying a list value.
- Leaving example trees (`(define t1 ...)`) or calls at top level, which prints at load time or
  collides with the grader's own definitions.
- Adding `provide`, `require`, `(module+ test ...)` or `(module+ main ...)` to a solution file.
- Tree bugs: visiting right before left; the empty tree counted as a leaf; a node with one child
  counted as a leaf; height off by one (`()` has height 0, a single node height 1).
- Accumulator bugs: building the list backwards and then "fixing" it with the forbidden `reverse`,
  or with a quadratic hand-written append.
- Nested-list bugs: treating `()` inside a list as an atom (it is a list of length 0), measuring
  the length after inserting, forgetting that the top-level list is a list too, or not recursing
  into sublists of lists that are themselves not short.
- Using `eq?` on numbers; assuming `let` evaluates its bindings in order (use `let*` when the
  order matters, e.g. sequential `read`s).
- Printing prompts or extra text in a function that reads standard input; missing the final
  newline.
- Claiming that code "works" or "tests pass" without running it.
