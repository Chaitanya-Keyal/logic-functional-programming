:- use_module(library(lists)).

%! candidate(-Solution) is multi.
%
%  Solution is a list of four terms p(Name, Dept, Lang, Project) in the
%  order Alex, Ben, Carla, Dana. The departments, languages and projects
%  are each a permutation of the four values of that attribute, so every
%  friend has a different value for every attribute and every value of
%  every attribute is used exactly once.
candidate([p('Alex', AlexDept, AlexLang, AlexProject),
           p('Ben', BenDept, BenLang, BenProject),
           p('Carla', CarlaDept, CarlaLang, CarlaProject),
           p('Dana', DanaDept, DanaLang, DanaProject)]) :-
    permutation([research, development, design, testing],
                [AlexDept, BenDept, CarlaDept, DanaDept]),
    permutation([python, java, 'c++', javascript],
                [AlexLang, BenLang, CarlaLang, DanaLang]),
    permutation(['AI', web, embedded, data],
                [AlexProject, BenProject, CarlaProject, DanaProject]).

%! clue(+N, +Solution) is semidet.
%
%  Clue N holds in Solution, a fully filled-in list of four friends.

% CLUE 1: The friend who prefers the AI project does not work in research and is not Dana.
clue(1, Solution) :-
    member(p(Name, Dept, _, 'AI'), Solution),
    Dept \== research,
    Name \== 'Dana'.

% CLUE 2: Alex does not work in development and does not prefer C++.
clue(2, Solution) :-
    member(p('Alex', Dept, Lang, _), Solution),
    Dept \== development,
    Lang \== 'c++'.

% CLUE 3: The friend working in the testing department likes Python.
clue(3, Solution) :-
    member(p(_, testing, python, _), Solution).

% CLUE 4: Ben prefers web projects and does not work in testing.
clue(4, Solution) :-
    member(p('Ben', Dept, _, web), Solution),
    Dept \== testing.

% CLUE 5: The friend whose favorite language is Java works in the design department.
clue(5, Solution) :-
    member(p(_, design, java, _), Solution).

% CLUE 6: Carla's project preference is not embedded, and her department is not development.
clue(6, Solution) :-
    member(p('Carla', Dept, _, Project), Solution),
    Dept \== development,
    Project \== embedded.

% CLUE 7: Dana's favorite language is not Java, and she works in research or testing.
clue(7, Solution) :-
    member(p('Dana', Dept, Lang, _), Solution),
    Lang \== java,
    (   Dept == research
    ;   Dept == testing
    ).

% CLUE 8: The friend who prefers data projects works in research and does not use JavaScript.
clue(8, Solution) :-
    member(p(_, research, Lang, data), Solution),
    Lang \== javascript.

%! solve(+Active, -Solution) is nondet.
%
%  Solution is a candidate from candidate/1 and every clue whose number
%  is in the list Active holds in Solution. Clue numbers that are not in
%  Active are ignored, and duplicate numbers in Active do not produce
%  duplicate solutions.
solve(Active, Solution) :-
    candidate(Solution),
    forall(member(Number, Active), clue(Number, Solution)).

%! main is det.
%
%  Prints one solution satisfying clues 1 to 8, one line per friend in
%  the order Alex, Ben, Carla, Dana.
main :-
    once(solve([1, 2, 3, 4, 5, 6, 7, 8], Solution)),
    forall(member(p(Name, Dept, Lang, Project), Solution),
           format("~w = [~w, ~w, ~w]~n",
                  [Name, Dept, Lang, Project])).

%! count_solutions(+Active, -N) is det.
%
%  N is the number of solutions that satisfy exactly the clues whose
%  numbers occur in Active; clues whose numbers do not occur are ignored.
count_solutions(Active, N) :-
    findall(Solution, solve(Active, Solution), Solutions),
    length(Solutions, N).
