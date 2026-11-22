# Group 3 - CS F301 Assignment 2
#   make test   run every test file (one per problem)
#   make demo   run the handout examples the way the grader does
#   make clean  remove the build/ scratch directory used by `make demo`

SWIPL ?= swipl
RACKET ?= racket
RACO ?= raco

T1 := '(4 (2 (1 () ()) (3 () ())) (6 (5 () ()) (7 () ())))
T2 := '(1 () (2 () (3 () ())))
T3 := '(a (b () ()) (c () ()))

.PHONY: test test-p1 test-p2 test-s1 test-s2 demo clean

test: test-p1 test-p2 test-s1 test-s2

test-p1:
	$(SWIPL) -q -g run_tests -t halt tests/p1_test.pl

test-p2:
	$(SWIPL) -q -g run_tests -t halt tests/p2_test.pl

test-s1:
	$(RACO) test tests/s1_test.rkt

test-s2:
	$(RACO) test tests/s2_test.rkt

demo:
	@mkdir -p build
	@echo '== P1 main'
	@$(SWIPL) -q -f code/3_q1.pl -g main -t halt
	@echo '== P1 count_solutions for clues 1-8 and 1-9'
	@$(SWIPL) -q -f code/3_q1.pl -g 'count_solutions([1,2,3,4,5,6,7,8], N), print(N), nl' -t halt
	@$(SWIPL) -q -f code/3_q1.pl -g 'count_solutions([1,2,3,4,5,6,7,8,9], N), print(N), nl' -t halt
	@echo '== P2 all_equations([4,2,5,3]) and all_equations([2,4,8])'
	@$(SWIPL) -q -f code/3_q2.pl -g 'all_equations([4,2,5,3], Es), print(Es), nl' -t halt
	@$(SWIPL) -q -f code/3_q2.pl -g 'all_equations([2,4,8], Es), print(Es), nl' -t halt
	@echo '== S1 t1, t2, t3 and the empty tree'
	@cp code/3_q3.rkt build/s1_demo.rkt
	@printf '%s\n' \
	  "(define t1 $(T1))" "(define t2 $(T2))" "(define t3 $(T3))" \
	  "(print-inorder t1)" "(print-all-traversals t1)" "(print-height-and-leaves t1)" \
	  "(print-all-traversals t2)" "(print-height-and-leaves t2)" \
	  "(print-all-traversals t3)" "(print-height-and-leaves t3)" \
	  "(print-all-traversals '())" "(print-height-and-leaves '())" >> build/s1_demo.rkt
	@$(RACKET) build/s1_demo.rkt
	@echo '== S2 print-insert-result on the four handout inputs'
	@cp code/3_q4.rkt build/s2_demo.rkt
	@echo '(print-insert-result)' >> build/s2_demo.rkt
	@for input in '42 ((1 2) (3 4 5) (6) ()) 3' '0 (((1) 2) (3) ((4 5 6) ())) 3' '7 () 3' '7 () 0'; do \
	  printf '%s  =>  ' "$$input"; echo "$$input" | $(RACKET) build/s2_demo.rkt; \
	done

clean:
	rm -rf build
