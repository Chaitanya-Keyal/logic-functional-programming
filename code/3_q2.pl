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

%! expression_string(+Tree, -String) is det.
%
%  String is the canonical text of the expression tree Tree, without
%  spaces. Multiplication and division bind tighter than addition and
%  subtraction, and operators are left-associative: a binary left
%  operand is parenthesised only when its operator binds less tightly
%  than the parent's, a binary right operand when it binds equally
%  tightly or less tightly. A leaf is never parenthesised.
expression_string(Number, String) :-
    integer(Number),
    number_string(Number, String).
expression_string(bin(Op, Left, Right), String) :-
    expression_string(Left, LeftText0),
    expression_string(Right, RightText0),
    (   Left = bin(LeftOp, _, _),
        ( Op == '*' ; Op == '/' ),
        ( LeftOp == '+' ; LeftOp == '-' )
    ->  format(string(LeftText), '(~w)', [LeftText0])
    ;   LeftText = LeftText0
    ),
    (   Right = bin(RightOp, _, _),
        (   ( Op == '*' ; Op == '/' )
        ;   ( RightOp == '+' ; RightOp == '-' )
        )
    ->  format(string(RightText), '(~w)', [RightText0])
    ;   RightText = RightText0
    ),
    format(string(String), '~w~w~w', [LeftText, Op, RightText]).

%! equation(+List, -Equation) is nondet.
%
%  Equation is the canonical string L=R of an equation formed from the
%  non-empty list List by splitting it into two non-empty consecutive
%  parts, turning the left part into an expression L and the right
%  part into an expression R, and requiring L and R to have the same
%  integer value. Every number of List is used exactly once and in the
%  given order.
equation(List, Equation) :-
    append(LeftNumbers, RightNumbers, List),
    LeftNumbers = [_|_],
    RightNumbers = [_|_],
    expression(LeftNumbers, LeftTree, Value),
    expression(RightNumbers, RightTree, Value),
    expression_string(LeftTree, LeftText),
    expression_string(RightTree, RightText),
    string_concat(LeftText, "=", LeftTextEquals),
    string_concat(LeftTextEquals, RightText, Equation).

%! generate_equation(+List, -Equation) is semidet.
%
%  Equation is one canonical string of a valid equation for List.
%  The predicate commits to the first such equation and fails when
%  List has no valid equation.
generate_equation(List, Equation) :-
    once(equation(List, Equation)).

%! all_equations(+List, -Equations) is det.
%
%  Equations is the list of all canonical strings of valid equations
%  for List, without duplicates and in the standard order of terms.
%  Equations is [] when List has no valid equation.
all_equations(List, Equations) :-
    findall(Equation, equation(List, Equation), AllEquations),
    sort(AllEquations, Equations).
