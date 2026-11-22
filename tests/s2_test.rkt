#lang racket

;; Tests for S2 (code/3_q4.rkt).
;;
;; Each case is run the way the grader does it: the text of the solution
;; file is copied to a temporary module, the test definitions and calls are
;; appended, and that module is executed with the racket executable.  Stdout
;; must match exactly, stderr must be empty, and the exit status must be 0.
;; For print-insert-result the test also feeds standard input.
;;
;; The tests check that the unmodified solution is silent, that
;; insert-if-short is defined exactly once, and that the solution uses only
;; allowed identifiers (read is allowed for S2).

(require rackunit
         racket/file
         racket/list
         racket/port
         racket/runtime-path
         racket/string
         racket/system)

(define-runtime-path solution-path "../code/3_q4.rkt")

;; -------------------------------------------------------------------------
;; Running the solution like the grader
;; -------------------------------------------------------------------------

(define racket-executable
  (or (find-executable-path "racket")
      (error 's2-test "could not find the racket executable")))

;; (run-racket-file file stdin-text) -> (values exit-code stdout-text stderr-text)
;; Runs file with the racket executable, feeds stdin-text to its standard
;; input, closes that input, then captures stdout and stderr separately.
(define (run-racket-file file stdin-text)
  (define info (process*/ports #f #f #f racket-executable file))
  (define stdout-port (list-ref info 0))
  (define stdin-port (list-ref info 1))
  (define stderr-port (list-ref info 3))
  (define control (list-ref info 4))
  (display stdin-text stdin-port)
  (close-output-port stdin-port)
  (define stdout-text (port->string stdout-port))
  (define stderr-text (port->string stderr-port))
  (close-input-port stdout-port)
  (close-input-port stderr-port)
  (control 'wait)
  (values (control 'exit-code) stdout-text stderr-text))

;; (run-solution-with appended stdin-text) -> (values exit-code stdout-text stderr-text)
;; Writes a temporary module containing the solution text followed by
;; appended, runs it with stdin-text on standard input, and removes the
;; temporary directory afterwards.
(define (run-solution-with appended stdin-text)
  (define directory (make-temporary-directory))
  (dynamic-wind
    void
    (lambda ()
      (define temporary-file (build-path directory "s2-under-test.rkt"))
      (define solution-text (file->string solution-path))
      (call-with-output-file temporary-file
        #:exists 'replace
        (lambda (out)
          (display solution-text out)
          (unless (string-suffix? solution-text "\n")
            (newline out))
          (display appended out)))
      (run-racket-file temporary-file stdin-text))
    (lambda ()
      (delete-directory/files directory))))

(define (lines->string lines)
  (string-append (string-join lines "\n") "\n"))

(define (check-case label appended stdin-text expected-stdout)
  (define-values (status stdout-text stderr-text)
    (run-solution-with appended stdin-text))
  (check-equal? status 0 (format "~a: exit status" label))
  (check-equal? stderr-text "" (format "~a: stderr" label))
  (check-equal? stdout-text expected-stdout (format "~a: stdout" label)))

;; -------------------------------------------------------------------------
;; Assignment examples through print-insert-result (stdin)
;; -------------------------------------------------------------------------

(check-case
 "example 1"
 "(print-insert-result)\n"
 "42 ((1 2) (3 4 5) (6) ()) 3\n"
 (lines->string '("((42 1 2) (3 4 5) (42 6) (42))")))

(check-case
 "example 2"
 "(print-insert-result)\n"
 "0 (((1) 2) (3) ((4 5 6) ())) 3\n"
 (lines->string '("((0 (0 1) 2) (0 3) (0 (4 5 6) (0)))")))

(check-case
 "example 3"
 "(print-insert-result)\n"
 "7 () 3\n"
 (lines->string '("(7)")))

(check-case
 "example 4"
 "(print-insert-result)\n"
 "7 () 0\n"
 (lines->string '("()")))

;; -------------------------------------------------------------------------
;; my-length
;; -------------------------------------------------------------------------

(check-case
 "my-length"
 (string-append
  "(display (my-length '())) (newline)\n"
  "(display (my-length '(1 2 3))) (newline)\n"
  "(display (my-length '((1 2) (3 4 5) (6) ()))) (newline)\n"
  "(display (my-length '(((1) 2) (3) ((4 5 6) ())))) (newline)\n"
  "(define big-list-length-test\n"
  "  (let loop ([k 10000] [acc '()])\n"
  "    (if (= k 0) acc (loop (- k 1) (cons k acc)))))\n"
  "(display (my-length big-list-length-test)) (newline)\n")
 ""
 (lines->string '("0" "3" "4" "3" "10000")))

;; -------------------------------------------------------------------------
;; my-map
;; -------------------------------------------------------------------------

(check-case
 "my-map"
 (string-append
  "(display (my-map (lambda (e) (+ e 1)) '(1 2 3))) (newline)\n"
  "(display (my-map (lambda (e) (list e)) '())) (newline)\n"
  "(display (my-map (lambda (e) (list e)) '(a (b) ()))) (newline)\n"
  "(define big-list-map-test\n"
  "  (let loop ([k 10000] [acc '()])\n"
  "    (if (= k 0) acc (loop (- k 1) (cons k acc)))))\n"
  "(define big-map-result\n"
  "  (my-map (lambda (e) (+ e 1)) big-list-map-test))\n"
  "(display (my-length big-map-result)) (newline)\n"
  "(display (equal? big-map-result\n"
  "                (let loop ([k 10000] [acc '()])\n"
  "                  (if (= k 0) acc\n"
  "                      (loop (- k 1) (cons (+ k 1) acc)))))) (newline)\n")
 ""
 (lines->string
  '("(2 3 4)"
    "()"
    "((a) ((b)) (()))"
    "10000"
    "#t")))

;; -------------------------------------------------------------------------
;; insert-if-short: n = 0, n = 1, symbols, nested empties
;; -------------------------------------------------------------------------

(check-case
 "insert-if-short edge cases"
 (string-append
  "(display (insert-if-short 'x '(1 2) 0)) (newline)\n"
  "(display (insert-if-short 'x '() 0)) (newline)\n"
  "(display (insert-if-short 'x '(() (1) ((2))) 1)) (newline)\n"
  "(display (insert-if-short 'z '(a (b c) ()) 3)) (newline)\n"
  "(display (insert-if-short 'q '(((()))) 1)) (newline)\n")
 ""
 (lines->string
  '("(1 2)"
    "()"
    "((x) (1) ((2)))"
    "(a (z b c) (z))"
    "((((q))))")))

;; -------------------------------------------------------------------------
;; insert-if-short: lengths are measured before insertion
;; -------------------------------------------------------------------------

(check-case
 "insert-if-short measures original lengths"
 (string-append
  "(display (insert-if-short 'x '(1 2) 3)) (newline)\n"
  "(display (insert-if-short 'x '(1 2) 4)) (newline)\n"
  "(display (insert-if-short 'x '(1 2 3) 3)) (newline)\n"
  "(display (insert-if-short 'x '((1 2) (3 4 5)) 3)) (newline)\n")
 ""
 (lines->string
  '("(x 1 2)"
    "(x 1 2)"
    "(1 2 3)"
    "(x (x 1 2) (3 4 5))")))

;; -------------------------------------------------------------------------
;; insert-if-short: nesting depth 100
;; -------------------------------------------------------------------------

(check-case
 "insert-if-short depth 100"
 (string-append
  "(define chain-100\n"
  "  (let loop ([k 100] [acc '()])\n"
  "    (if (= k 0) acc (loop (- k 1) (list acc)))))\n"
  "(define depth-1-expected\n"
  "  (let loop ([k 100] [acc '(7)])\n"
  "    (if (= k 0) acc (loop (- k 1) (list acc)))))\n"
  "(define depth-101-expected\n"
  "  (let loop ([k 100] [acc '(7)])\n"
  "    (if (= k 0) acc (loop (- k 1) (cons 7 (list acc))))))\n"
  "(display (equal? (insert-if-short 7 chain-100 1)\n"
  "                 depth-1-expected)) (newline)\n"
  "(display (equal? (insert-if-short 7 chain-100 101)\n"
  "                 depth-101-expected)) (newline)\n")
 ""
 (lines->string '("#t" "#t")))

;; -------------------------------------------------------------------------
;; insert-if-short: 10,000 elements, small n and large n
;; -------------------------------------------------------------------------

(check-case
 "insert-if-short 10000 elements"
 (string-append
  "(define big-list-insert-test\n"
  "  (let loop ([k 10000] [acc '()])\n"
  "    (if (= k 0) acc (loop (- k 1) (cons k acc)))))\n"
  "(display (equal? (insert-if-short 0 big-list-insert-test 5000)\n"
  "                 big-list-insert-test)) (newline)\n"
  "(display (equal? (insert-if-short 0 big-list-insert-test 10000)\n"
  "                 big-list-insert-test)) (newline)\n"
  "(define big-inserted\n"
  "  (insert-if-short 0 big-list-insert-test 10001))\n"
  "(display (my-length big-inserted)) (newline)\n"
  "(display (equal? big-inserted\n"
  "                (let loop ([k 10000] [acc '()])\n"
  "                  (if (= k 0) (cons 0 acc)\n"
  "                      (loop (- k 1) (cons k acc)))))) (newline)\n")
 ""
 (lines->string '("#t" "#t" "10001" "#t")))

;; -------------------------------------------------------------------------
;; make-inserter with different predicates
;; -------------------------------------------------------------------------

(check-case
 "make-inserter predicates"
 (string-append
  "(display ((make-inserter 42 (lambda (len) (< len 3)))\n"
  "          '((1 2) (3 4 5) (6) ()))) (newline)\n"
  "(display ((make-inserter 'z (lambda (len) (= len 2)))\n"
  "          '(((1) 2) (3) ((4 5 6) ())))) (newline)\n"
  "(display ((make-inserter 'w (lambda (len) (> len 2)))\n"
  "          '((1 2) (3 4 5) (6)))) (newline)\n"
  "(display ((make-inserter 'k (lambda (len) (= len 2)))\n"
  "          '((1 2) 3))) (newline)\n")
 ""
 (lines->string
  '("((42 1 2) (3 4 5) (42 6) (42))"
    "((z (1) 2) (3) (z (4 5 6) ()))"
    "(w (1 2) (w 3 4 5) (6))"
    "(k (k 1 2) 3)")))

;; -------------------------------------------------------------------------
;; Unmodified solution must print nothing
;; -------------------------------------------------------------------------

(define (check-unmodified-solution)
  (define-values (status stdout-text stderr-text)
    (run-racket-file solution-path ""))
  (check-equal? status 0 "unmodified solution: exit status")
  (check-equal? stdout-text "" "unmodified solution: stdout")
  (check-equal? stderr-text "" "unmodified solution: stderr"))

(check-unmodified-solution)

;; -------------------------------------------------------------------------
;; Exactly one definition of insert-if-short
;; -------------------------------------------------------------------------

(define (check-single-insert-if-short-definition)
  (define source (file->string solution-path))
  (define matches
    (regexp-match* #rx"\\(define[ \t]+\\(insert-if-short" source))
  (check-equal? (length matches) 1
                "solution must define insert-if-short exactly once"))

(check-single-insert-if-short-definition)

;; -------------------------------------------------------------------------
;; Whitelist check
;; -------------------------------------------------------------------------

;; Every composition of car and cdr up to four levels: car, cdr, caar, cadr,
;; ..., cddddr.
(define (cxr-symbols)
  (define (ad-strings n)
    (if (= n 0)
        '("")
        (for*/list ([tail (in-list (ad-strings (- n 1)))]
                    [letter (in-list '("a" "d"))])
          (string-append letter tail))))
  (for*/list ([n (in-range 1 5)]
              [middle (in-list (ad-strings n))])
    (string->symbol (string-append "c" middle "r"))))

;; The S2 whitelist: the common whitelist plus read.
(define whitelist
  (append
   '(define lambda let let* letrec if cond else and or not begin quote
     cons car cdr list null? pair? eq? assq assoc
     + - * < > <= >= = max display newline read)
   (cxr-symbols)))

(define (strip-lang-line source)
  (regexp-replace #rx"^#lang[^\n]*\n?" source ""))

(define (read-all-forms source)
  (define in (open-input-string source))
  (let loop ([forms '()])
    (define form (read in))
    (if (eof-object? form)
        (reverse forms)
        (loop (cons form forms)))))

;; Names introduced as parameters, including a dotted rest parameter.
(define (parameter-names params)
  (cond
    [(null? params) '()]
    [(symbol? params) (list params)]
    [(pair? params)
     (append
      (if (symbol? (car params))
          (list (car params))
          (parameter-names (car params)))
      (parameter-names (cdr params)))]
    [else '()]))

(define (binding-names bindings)
  (for/list ([binding (in-list bindings)])
    (car binding)))

;; The value expressions of let-family bindings.
(define (binding-value-forms bindings)
  (for/list ([binding (in-list bindings)])
    (cadr binding)))

;; All names bound by define, lambda, let, let*, letrec and named let.
(define (collect-bindings form)
  (cond
    [(pair? form)
     (define head (car form))
     (cond
       [(eq? head 'quote) '()]
       [(eq? head 'define)
        (define target (cadr form))
        (append
         (if (pair? target)
             (cons (car target) (parameter-names (cdr target)))
             (list target))
         (collect-bindings* (cddr form)))]
       [(eq? head 'lambda)
        (append (parameter-names (cadr form))
                (collect-bindings* (cddr form)))]
       [(memq head '(let let* letrec))
        (define rest (cdr form))
        (define named? (symbol? (car rest)))
        (define name (and named? (car rest)))
        (define bindings (if named? (cadr rest) (car rest)))
        (define body (if named? (cddr rest) (cdr rest)))
        (append
         (if named? (list name) '())
         (binding-names bindings)
         (collect-bindings* (binding-value-forms bindings))
         (collect-bindings* body))]
       [else
        (collect-bindings* form)])]
    [else '()]))

(define (collect-bindings* forms)
  (append-map collect-bindings forms))

;; Every symbol outside quoted data.
(define (used-symbols form)
  (cond
    [(symbol? form) (list form)]
    [(pair? form)
     (if (eq? (car form) 'quote)
         '()
         (append-map used-symbols form))]
    [else '()]))

(define (whitelist-failures source)
  (define forms (read-all-forms (strip-lang-line source)))
  (define bound (append-map collect-bindings forms))
  (define used (remove-duplicates (append-map used-symbols forms) eq?))
  (for/list ([symbol (in-list used)]
             #:unless (or (memq symbol whitelist)
                          (memq symbol bound)))
    symbol))

(define (check-whitelist)
  (define failures (whitelist-failures (file->string solution-path)))
  (check-equal? failures '()
                (format "forbidden or unbound symbols in solution: ~s"
                        failures)))

(check-whitelist)

;; Sanity checks for the whitelist scanner itself.
(check-equal? (whitelist-failures
               (string-append "#lang racket/base\n"
                              "(define (uses-length tree) (length tree))\n"))
              '(length)
              "whitelist scanner should reject length")

(check-equal? (whitelist-failures
               (string-append "#lang racket/base\n"
                              "(define (uses-named-let tree)\n"
                              "  (let walk ([node tree]) (walk node)))\n"))
              '()
              "whitelist scanner should accept named-let bindings")

(check-equal? (whitelist-failures
               (string-append "#lang racket/base\n"
                              "(define quoted '(length append))\n"))
              '()
              "whitelist scanner should ignore quoted data")

(check-equal? (whitelist-failures
               (string-append "#lang racket/base\n"
                              "(define (reads-one) (read))\n"))
              '()
              "whitelist scanner should accept read for S2")
