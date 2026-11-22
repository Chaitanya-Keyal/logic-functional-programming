# P1 Report

## Solutions of clues 1–8

```bash
swipl -q -f code/3_q1.pl -g "count_solutions([1,2,3,4,5,6,7,8], N), format('N = ~w~n', [N])" -t halt
```

```
N = 3
```

So clues 1–8 do **not** determine a unique solution: exactly three assignments satisfy all eight.

| Solution | Alex | Ben | Carla | Dana |
|---|---|---|---|---|
| S1 | design / java / AI | development / javascript / web | research / c++ / data | testing / python / embedded |
| S2 | design / java / embedded | development / javascript / web | testing / python / AI | research / c++ / data |
| S3 | testing / python / embedded | development / javascript / web | design / java / AI | research / c++ / data |

Each cell is department / favorite language / project.

## Why a name-free ninth clue can keep exactly one solution

A clue that names no friend can refer only to attribute values, so its truth depends on the set of `(Dept, Lang, Project)` triples, not on which name holds which triple. Rows S1 and S3 have the same set:

- S1 and S3: `{(design, java, 'AI'), (development, javascript, web), (research, 'c++', data), (testing, python, embedded)}`
- S2: `{(design, java, embedded), (development, javascript, web), (research, 'c++', data), (testing, python, 'AI')}`

S1 and S3 differ only by permuting the friends, so every name-free sentence true in one is true in the other; no such clue can isolate either of them. S2 has a different triple set and is the only solution containing `(design, java, embedded)` and `(testing, python, 'AI')`. A name-free clue asserting one of those triples is therefore true only in S2, which is why a ninth clue can keep exactly one solution.

## Clue 9

As written in `code/3_q1.pl`:

```prolog
% CLUE 9: The friend working in the testing department prefers the AI project.
clue(9, Solution) :-
    member(p(_, testing, _, 'AI'), Solution).
```

```bash
swipl -q -f code/3_q1.pl -g "count_solutions([1,2,3,4,5,6,7,8,9], N), format('N = ~w~n', [N])" -t halt
```

```
N = 1
```

Checking clue 9 against the three solutions of clues 1–8 gives `S1 false`, `S2 true`, `S3 false`; the sole remaining solution is S2.

## `main/0`

`main/0` is unchanged and prints the first solution of clues 1–8 (S1), as P1.a asks:

```
Alex = [design, java, AI]
Ben = [development, javascript, web]
Carla = [research, c++, data]
Dana = [testing, python, embedded]
```
