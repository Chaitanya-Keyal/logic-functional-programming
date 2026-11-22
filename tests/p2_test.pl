:- use_module(library(plunit)).
:- use_module(library(lists)).
:- use_module(library(process)).

:- prolog_load_context(directory, TestDirectory),
   directory_file_path(TestDirectory, '../code/3_q2.pl', SolutionFile),
   assertz(solution_file(SolutionFile)),
   ensure_loaded(SolutionFile).

%  Leaves of an expression tree, from left to right.
leaves(Number, [Number]) :-
    integer(Number).
leaves(bin(_, Left, Right), Leaves) :-
    leaves(Left, LeftLeaves),
    leaves(Right, RightLeaves),
    append(LeftLeaves, RightLeaves, Leaves).

%  Value of an expression tree, computed independently of expression/3.
eval_tree(Number, Number) :-
    integer(Number).
eval_tree(bin(Op, Left, Right), Value) :-
    eval_tree(Left, LeftValue),
    eval_tree(Right, RightValue),
    apply_op(Op, LeftValue, RightValue, Value).

%  Equation is built from two trees with equal values; both sides are
%  evaluated with eval_tree/2, so this checks values without parsing
%  the equation string.
equation_from_equal_trees(List, Equation) :-
    append(LeftNumbers, RightNumbers, List),
    LeftNumbers = [_|_],
    RightNumbers = [_|_],
    expression(LeftNumbers, LeftTree, LeftValue),
    expression(RightNumbers, RightTree, RightValue),
    eval_tree(LeftTree, LeftCheck),
    eval_tree(RightTree, RightCheck),
    LeftValue =:= LeftCheck,
    RightValue =:= RightCheck,
    LeftCheck =:= RightCheck,
    expression_string(LeftTree, LeftText),
    expression_string(RightTree, RightText),
    string_concat(LeftText, "=", LeftTextEquals),
    string_concat(LeftTextEquals, RightText, Equation).

%  A string contains no space character.
has_no_space(String) :-
    \+ sub_string(String, _, _, _, " ").

:- begin_tests(apply_op).

test(addition) :-
    apply_op(+, 6, 3, Value),
    Value == 9.

test(subtraction) :-
    apply_op(-, 6, 3, Value),
    Value == 3.

test(multiplication) :-
    apply_op(*, 6, 3, Value),
    Value == 18.

test(exact_division) :-
    apply_op(/, 6, 3, Value),
    Value == 2.

test(zero_dividend) :-
    apply_op(/, 0, 5, Value),
    Value == 0.

test(negative_dividend) :-
    apply_op(/, -6, 3, Value),
    Value == -2.

test(negative_divisor) :-
    apply_op(/, 6, -3, Value),
    Value == -2.

test(both_negative) :-
    apply_op(/, -6, -3, Value),
    Value == 2.

test(inexact_division_fails, [fail]) :-
    apply_op(/, 7, 2, _).

test(inexact_division_negative_fails, [fail]) :-
    apply_op(/, -7, 2, _).

test(division_by_zero_fails, [fail]) :-
    apply_op(/, 6, 0, _).

test(operator_enumeration) :-
    findall(Op, apply_op(Op, 6, 3, _), Ops),
    Ops == ['+', '-', '*', '/'].

test(operator_values) :-
    findall(Value, apply_op(_, 6, 3, Value), Values),
    Values == [9, 3, 18, 2].

test(values_are_integers) :-
    forall(apply_op(_, 6, 3, Value), integer(Value)).

:- end_tests(apply_op).

:- begin_tests(expression).

test(single_number_count) :-
    findall(Tree, expression([5], Tree, _), Trees),
    length(Trees, 1).

test(two_numbers_count) :-
    findall(Tree, expression([1, 2], Tree, _), Trees),
    length(Trees, 3).

test(three_numbers_count) :-
    findall(Tree, expression([1, 2, 3], Tree, _), Trees),
    length(Trees, 20).

test(four_numbers_count) :-
    findall(Tree, expression([4, 2, 5, 3], Tree, _), Trees),
    length(Trees, 176).

test(no_duplicate_trees) :-
    forall(member(Numbers, [[5], [1, 2], [1, 2, 3], [4, 2, 5, 3]]),
           (   findall(Tree, expression(Numbers, Tree, _), Trees),
               msort(Trees, Sorted),
               sort(Trees, Unique),
               Sorted == Unique
           )).

test(leaves_in_input_order) :-
    forall(member(Numbers, [[5], [1, 2], [1, 2, 3], [4, 2, 5, 3]]),
           forall(expression(Numbers, Tree, _),
                  (   leaves(Tree, TreeLeaves),
                      TreeLeaves == Numbers
                  ))).

test(empty_list_fails, [fail]) :-
    expression([], _, _).

:- end_tests(expression).

:- begin_tests(expression_string).

test(parenthesised_sum_times) :-
    expression_string(bin(*, bin(+, 4, 2), 3), String),
    String == "(4+2)*3".

test(times_binds_tighter) :-
    expression_string(bin(+, 4, bin(*, 2, 3)), String),
    String == "4+2*3".

test(left_associative_division_times) :-
    expression_string(bin(*, bin(/, 8, 4), 2), String),
    String == "8/4*2".

test(parenthesised_product_divisor) :-
    expression_string(bin(/, 8, bin(*, 4, 2)), String),
    String == "8/(4*2)".

test(left_associative_subtraction) :-
    expression_string(bin(-, bin(-, 1, 2), 3), String),
    String == "1-2-3".

test(parenthesised_right_subtraction) :-
    expression_string(bin(-, 1, bin(-, 2, 3)), String),
    String == "1-(2-3)".

test(parenthesised_right_addition) :-
    expression_string(bin(+, 1, bin(+, 2, 3)), String),
    String == "1+(2+3)".

test(left_associative_addition) :-
    expression_string(bin(+, bin(+, 1, 2), 3), String),
    String == "1+2+3".

test(results_are_strings_without_spaces) :-
    forall(member(Tree, [bin(*, bin(+, 4, 2), 3),
                         bin(+, 4, bin(*, 2, 3)),
                         bin(*, bin(/, 8, 4), 2),
                         bin(/, 8, bin(*, 4, 2)),
                         bin(-, bin(-, 1, 2), 3),
                         bin(-, 1, bin(-, 2, 3)),
                         bin(+, 1, bin(+, 2, 3)),
                         bin(+, bin(+, 1, 2), 3)]),
           (   expression_string(Tree, String),
               string(String),
               has_no_space(String)
           )).

test(all_trees_have_distinct_strings) :-
    findall(String,
            (   expression([1, 2, 3, 4], Tree, _),
                expression_string(Tree, String)
            ),
            Strings),
    length(Strings, Total),
    sort(Strings, Unique),
    length(Unique, Distinct),
    Total == 153,
    Distinct == 153.

:- end_tests(expression_string).

:- begin_tests(generate_equation).

test(one_of_assignment_equations) :-
    generate_equation([4, 2, 5, 3], Equation),
    memberchk(Equation, ["4*2-5=3", "4*2=5+3", "4-2=5-3", "4/2=5-3",
                         "4=2*(5-3)", "4=2+(5-3)", "4=2+5-3"]),
    string(Equation).

test(succeeds_exactly_once) :-
    findall(Equation, generate_equation([4, 2, 5, 3], Equation), Equations),
    length(Equations, 1).

test(leaves_no_choicepoint) :-
    %  With call_cleanup/2 the cleanup runs immediately on deterministic
    %  success and is deferred only while a choicepoint remains.
    call_cleanup(generate_equation([4, 2, 5, 3], _), CleanupRan = yes),
    CleanupRan == yes.

test(no_equation_fails, [fail]) :-
    generate_equation([2, 3, 4], _).

test(empty_list_fails, [fail]) :-
    generate_equation([], _).

test(single_number_fails, [fail]) :-
    generate_equation([7], _).

test(accepts_bound_valid_equation) :-
    generate_equation([4, 2, 5, 3], "4=2+5-3").

:- end_tests(generate_equation).

:- begin_tests(all_equations).

test(assignment_list) :-
    all_equations([4, 2, 5, 3], Equations),
    Equations == ["4*2-5=3", "4*2=5+3", "4-2=5-3", "4/2=5-3",
                  "4=2*(5-3)", "4=2+(5-3)", "4=2+5-3"].

test(no_equation_list) :-
    all_equations([2, 3, 4], Equations),
    Equations == [].

test(two_four_eight) :-
    all_equations([2, 4, 8], Equations),
    Equations == ["2*4=8"].

test(empty_list) :-
    all_equations([], Equations),
    Equations == [].

test(single_number) :-
    all_equations([7], Equations),
    Equations == [].

test(zeros_no_division) :-
    all_equations([0, 0, 0], Equations),
    Equations == ["0*0=0", "0+0=0", "0-0=0",
                  "0=0*0", "0=0+0", "0=0-0"].

test(sorted_and_duplicate_free) :-
    forall(member(List, [[4, 2, 5, 3], [2, 3, 4], [2, 4, 8],
                         [], [7], [0, 0, 0]]),
           (   all_equations(List, Equations),
               sort(Equations, Sorted),
               Equations == Sorted
           )).

test(sides_have_equal_values) :-
    forall(member(List, [[4, 2, 5, 3], [2, 4, 8], [0, 0, 0],
                         [1, 2, 3, 4, 5, 6]]),
           (   all_equations(List, Equations),
               forall(member(Equation, Equations),
                      equation_from_equal_trees(List, Equation))
           )).

:- end_tests(all_equations).

:- begin_tests(count_equations).

test(assignment_counts) :-
    count_equations([4, 2, 5, 3], N1),
    count_equations([2, 3, 4], N2),
    count_equations([2, 4, 8], N3),
    N1 == 7,
    N2 == 0,
    N3 == 1.

test(empty_list) :-
    count_equations([], N),
    N == 0.

test(single_number) :-
    count_equations([7], N),
    N == 0.

test(six_numbers) :-
    count_equations([1, 2, 3, 4, 5, 6], N),
    N == 101.

test(eight_numbers) :-
    get_time(Start),
    count_equations([1, 2, 3, 4, 5, 6, 7, 8], N),
    get_time(End),
    N == 4804,
    Elapsed is End - Start,
    Elapsed < 10.

:- end_tests(count_equations).

:- begin_tests(grader).

test(loads_silently) :-
    solution_file(SolutionFile),
    process_create(path(swipl),
                   ['-q', '-f', SolutionFile, '-g', 'true', '-t', 'halt'],
                   [ stdout(pipe(OutPipe)),
                     stderr(pipe(ErrPipe)),
                     process(Pid)
                   ]),
    read_string(OutPipe, _, Out),
    read_string(ErrPipe, _, Err),
    close(OutPipe),
    close(ErrPipe),
    process_wait(Pid, Status),
    Out == "",
    Err == "",
    Status == exit(0).

:- end_tests(grader).
