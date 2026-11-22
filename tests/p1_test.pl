:- use_module(library(plunit)).
:- use_module(library(lists)).
:- use_module(library(process)).
:- use_module(library(readutil)).

:- ensure_loaded('../code/3_q1').

% Hand-made fully filled-in solutions used by the clue tests.

solution(a,
         [p('Alex', research, python, 'AI'),
          p('Ben', development, java, web),
          p('Carla', design, 'c++', embedded),
          p('Dana', testing, javascript, data)]).

solution(b,
         [p('Alex', research, 'c++', data),
          p('Ben', development, java, 'AI'),
          p('Carla', testing, python, embedded),
          p('Dana', design, javascript, web)]).

solution(c,
         [p('Alex', research, python, 'AI'),
          p('Ben', testing, 'c++', embedded),
          p('Carla', design, java, web),
          p('Dana', development, javascript, data)]).

solution(d,
         [p('Alex', design, java, embedded),
          p('Ben', development, javascript, web),
          p('Carla', testing, python, 'AI'),
          p('Dana', research, 'c++', data)]).

leave_one_out(K, Active) :-
    findall(C, (between(1, 8, C), C \== K), Active).

leave_one_out_expectation(1, 4).
leave_one_out_expectation(2, 6).
leave_one_out_expectation(3, 13).
leave_one_out_expectation(4, 12).
leave_one_out_expectation(5, 9).
leave_one_out_expectation(6, 7).
leave_one_out_expectation(7, 5).
leave_one_out_expectation(8, 16).

expected_main_output("Alex = [design, java, AI]\nBen = [development, javascript, web]\nCarla = [research, c++, data]\nDana = [testing, python, embedded]\n").

expected_main_solution(
    [p('Alex', design, java, 'AI'),
     p('Ben', development, javascript, web),
     p('Carla', research, 'c++', data),
     p('Dana', testing, python, embedded)]).

solution_text(Solution, Text) :-
    with_output_to(
        string(Text),
        forall(member(p(Name, Dept, Lang, Project), Solution),
               format("~w = [~w, ~w, ~w]~n", [Name, Dept, Lang, Project]))).

term_contains_atom(Term, Atom) :-
    (   Term == Atom
    ->  true
    ;   compound(Term),
        Term =.. [Functor | Args],
        (   Functor == Atom
        ;   member(Arg, Args),
            term_contains_atom(Arg, Atom)
        )
    ).

line_directly_above(Lines, LinePrefix, AbovePrefix) :-
    append(_, [Above, Line | _], Lines),
    string_concat(LinePrefix, _, Line),
    string_concat(AbovePrefix, _, Above),
    !.

code_root(Root) :-
    source_file(user:clue(9, _), File),
    file_directory_name(File, CodeDir),
    file_directory_name(CodeDir, Root).

run_swipl(Root, Arguments, OutText, ErrText, Status) :-
    process_create(
        path(swipl),
        Arguments,
        [ cwd(Root),
          stdout(pipe(OutStream)),
          stderr(pipe(ErrStream)),
          process(Pid)
        ]),
    process_wait(Pid, Status),
    read_string(OutStream, _, OutText),
    read_string(ErrStream, _, ErrText),
    close(OutStream),
    close(ErrStream).

:- begin_tests(candidate_generator).

test(candidate_count, N == 13824) :-
    findall(Solution, candidate(Solution), Solutions),
    length(Solutions, N).

test(candidate_all_distinct) :-
    findall(Solution, candidate(Solution), Solutions),
    sort(Solutions, Unique),
    length(Unique, 13824).

test(candidate_names_in_order) :-
    forall(candidate(Solution),
           Solution = [p('Alex', _, _, _),
                       p('Ben', _, _, _),
                       p('Carla', _, _, _),
                       p('Dana', _, _, _)]).

test(candidate_attributes_used_once) :-
    forall(candidate(Solution),
           (   findall(D, member(p(_, D, _, _), Solution), Departments),
               msort(Departments, [design, development, research, testing]),
               findall(L, member(p(_, _, L, _), Solution), Languages),
               msort(Languages, ['c++', java, javascript, python]),
               findall(P, member(p(_, _, _, P), Solution), Projects),
               msort(Projects, ['AI', data, embedded, web])
           )).

:- end_tests(candidate_generator).

:- begin_tests(clues).

test(handmade_solutions_are_candidates) :-
    forall(solution(_, Solution), once(candidate(Solution))).

test(clue_1) :-
    solution(b, Holds),
    once(clue(1, Holds)),
    solution(a, Fails),
    once(\+ clue(1, Fails)).

test(clue_2) :-
    solution(a, Holds),
    once(clue(2, Holds)),
    solution(b, Fails),
    once(\+ clue(2, Fails)).

test(clue_3) :-
    solution(b, Holds),
    once(clue(3, Holds)),
    solution(c, Fails),
    once(\+ clue(3, Fails)).

test(clue_4) :-
    solution(a, Holds),
    once(clue(4, Holds)),
    solution(b, Fails),
    once(\+ clue(4, Fails)).

test(clue_5) :-
    solution(c, Holds),
    once(clue(5, Holds)),
    solution(a, Fails),
    once(\+ clue(5, Fails)).

test(clue_6) :-
    solution(c, Holds),
    once(clue(6, Holds)),
    solution(b, Fails),
    once(\+ clue(6, Fails)).

test(clue_7) :-
    solution(a, Holds),
    once(clue(7, Holds)),
    solution(b, Fails),
    once(\+ clue(7, Fails)).

test(clue_8) :-
    solution(b, Holds),
    once(clue(8, Holds)),
    solution(a, Fails),
    once(\+ clue(8, Fails)).

test(clue_9) :-
    solution(d, Holds),
    once(clue(9, Holds)),
    solution(c, Fails),
    once(\+ clue(9, Fails)).

test(clue_at_most_once_per_solution) :-
    forall((between(1, 9, N), solution(_, Solution)),
           (   findall(x, clue(N, Solution), Answers),
               length(Answers, Count),
               Count =< 1
           )).

:- end_tests(clues).

:- begin_tests(count_solutions).

test(count_clues_1_to_8, N == 3) :-
    count_solutions([1, 2, 3, 4, 5, 6, 7, 8], N).

test(count_no_clues, N == 13824) :-
    count_solutions([], N).

test(count_clues_1_to_9, N == 1) :-
    count_solutions([1, 2, 3, 4, 5, 6, 7, 8, 9], N).

test(count_leave_one_out) :-
    forall(leave_one_out_expectation(K, Expected),
           (   leave_one_out(K, Active),
               count_solutions(Active, Expected)
           )).

:- end_tests(count_solutions).

:- begin_tests(main_output).

test(main_printout_exact) :-
    with_output_to(string(Out), main),
    expected_main_output(Expected),
    Out == Expected.

test(main_printout_is_valid_solution) :-
    with_output_to(string(Out), main),
    expected_main_solution(Solution),
    solution_text(Solution, Out),
    forall(between(1, 8, N), clue(N, Solution)).

test(main_succeeds_once) :-
    with_output_to(string(_Captured), findall(x, main, Solutions)),
    length(Solutions, 1).

:- end_tests(main_output).

:- begin_tests(clue9_requirements).

test(clue9_unique_among_clues_1_to_8) :-
    findall(Solution,
            (solve([1, 2, 3, 4, 5, 6, 7, 8], Solution), clue(9, Solution)),
            Solutions),
    length(Solutions, 1).

test(clue9_body_has_no_friend_names) :-
    clause(user:clue(9, _), Body),
    forall(member(Name, ['Alex', 'Ben', 'Carla', 'Dana']),
           \+ term_contains_atom(Body, Name)).

test(clue9_comment_directly_above) :-
    source_file(user:clue(9, _), File),
    read_file_to_string(File, Text, []),
    split_string(Text, "\n", "", Lines),
    once(line_directly_above(Lines, "clue(9,", "% CLUE 9:")).

:- end_tests(clue9_requirements).

:- begin_tests(grader_processes).

test(grader_main_process) :-
    code_root(Root),
    run_swipl(Root,
              ['-q', '-f', 'code/3_q1.pl', '-g', 'main', '-t', 'halt'],
              Out, Err, Status),
    Status == exit(0),
    expected_main_output(Expected),
    Out == Expected,
    Err == "".

test(grader_load_process) :-
    code_root(Root),
    run_swipl(Root,
              ['-q', '-f', 'code/3_q1.pl', '-g', 'true', '-t', 'halt'],
              Out, Err, Status),
    Status == exit(0),
    Out == "",
    Err == "".

:- end_tests(grader_processes).
