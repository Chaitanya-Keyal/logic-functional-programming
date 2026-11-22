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

%! expression(+Numbers, -Tree, -Value) is nondet.
%
%  Tree is an expression tree whose leaves are exactly the numbers of
%  the non-empty list Numbers, each used once and in the given order,
%  and Value is the integer value of Tree. Every division in Tree is
%  exact and has a non-zero divisor.
%
%  A one-element list is a leaf holding that number. A list of two or
%  more numbers is split into two non-empty consecutive parts; the
%  left part forms the left sub-tree, the right part the right
%  sub-tree, and an operator joins their values.
expression([Number], Number, Number) :-
    integer(Number).
expression(Numbers, bin(Op, LeftTree, RightTree), Value) :-
    Numbers = [_, _|_],
    append(LeftNumbers, RightNumbers, Numbers),
    LeftNumbers = [_|_],
    RightNumbers = [_|_],
    expression(LeftNumbers, LeftTree, LeftValue),
    expression(RightNumbers, RightTree, RightValue),
    apply_op(Op, LeftValue, RightValue, Value).
