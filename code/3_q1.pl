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
