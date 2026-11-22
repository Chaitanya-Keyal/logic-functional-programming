%! apply_op(?Op, +A, +B, -Value) is nondet.
%
%  Value is the integer result of applying the operator Op to the
%  integers A and B. Op is one of +, -, * and /; when Op is unbound,
%  the four operators are enumerated on backtracking. For / the
%  division must be exact and the divisor non-zero, so the clause
%  fails when B is 0 or when A is not a multiple of B.
apply_op(+, A, B, Value) :-
    Value is A + B.
apply_op(-, A, B, Value) :-
    Value is A - B.
apply_op(*, A, B, Value) :-
    Value is A * B.
apply_op(/, A, B, Value) :-
    B =\= 0,
    A mod B =:= 0,
    Value is A // B.
