#lang racket

;; Tests for S1 (code/3_q3.rkt).
;;
;; Each solution case is run the way the grader does it: the text of the
;; solution file is copied to a temporary module, the test definitions and
;; calls are appended, and that module is executed with the racket
;; executable.  Stdout must match exactly, stderr must be empty, and the exit
;; status must be 0.  The tests also check that the unmodified solution is
;; silent and that the solution uses only allowed identifiers.

(require rackunit
         racket/file
         racket/list
         racket/port
         racket/runtime-path
         racket/string
         racket/system)

(define-runtime-path solution-path "../code/3_q3.rkt")

;; -------------------------------------------------------------------------
;; Running the solution like the grader
;; -------------------------------------------------------------------------

(define racket-executable
  (or (find-executable-path "racket")
      (error 's1-test "could not find the racket executable")))

;; (run-racket-file file) -> (values exit-code stdout-text stderr-text)
;; Runs file with the racket executable, captures its stdout and stderr
;; separately, and waits for it to finish.
(define (run-racket-file file)
  (define info (process*/ports #f #f #f racket-executable file))
  (define stdout-port (list-ref info 0))
  (define stdin-port (list-ref info 1))
  (define stderr-port (list-ref info 3))
  (define control (list-ref info 4))
  (define stdout-text (port->string stdout-port))
  (define stderr-text (port->string stderr-port))
  (close-input-port stdout-port)
  (close-output-port stdin-port)
  (close-input-port stderr-port)
  (control 'wait)
  (values (control 'exit-code) stdout-text stderr-text))

;; (run-solution-with appended) -> (values exit-code stdout-text stderr-text)
;; Writes a temporary module containing the solution text followed by
;; appended, runs it, and removes the temporary directory afterwards.
(define (run-solution-with appended)
  (define directory (make-temporary-directory))
  (dynamic-wind
    void
    (lambda ()
      (define temporary-file (build-path directory "s1-under-test.rkt"))
      (define solution-text (file->string solution-path))
      (call-with-output-file temporary-file
        #:exists 'replace
        (lambda (out)
          (display solution-text out)
          (unless (string-suffix? solution-text "\n")
            (newline out))
          (display appended out)))
      (run-racket-file temporary-file))
    (lambda ()
      (delete-directory/files directory))))

(define (lines->string lines)
  (string-append (string-join lines "\n") "\n"))

(define (check-case label appended expected-stdout)
  (define-values (status stdout-text stderr-text)
    (run-solution-with appended))
  (check-equal? status 0 (format "~a: exit status" label))
  (check-equal? stderr-text "" (format "~a: stderr" label))
  (check-equal? stdout-text expected-stdout (format "~a: stdout" label)))

;; -------------------------------------------------------------------------
;; Assignment examples
;; -------------------------------------------------------------------------

(check-case
 "t1"
 (string-append
  "(define t1 '(4 (2 (1 () ()) (3 () ())) (6 (5 () ()) (7 () ()))))\n"
  "(print-inorder t1)\n"
  "(print-all-traversals t1)\n"
  "(print-height-and-leaves t1)\n")
 (lines->string
  '("(1 2 3 4 5 6 7)"
    "(1 2 3 4 5 6 7)"
    "(4 2 1 3 6 5 7)"
    "(1 3 2 5 7 6 4)"
    "(3 4)")))

(check-case
 "t2"
 (string-append
  "(define t2 '(1 () (2 () (3 () ()))))\n"
  "(print-inorder t2)\n"
  "(print-all-traversals t2)\n"
  "(print-height-and-leaves t2)\n")
 (lines->string
  '("(1 2 3)"
    "(1 2 3)"
    "(1 2 3)"
    "(3 2 1)"
    "(3 1)")))

(check-case
 "t3"
 (string-append
  "(define t3 '(a (b () ()) (c () ())))\n"
  "(print-inorder t3)\n"
  "(print-all-traversals t3)\n"
  "(print-height-and-leaves t3)\n")
 (lines->string
  '("(b a c)"
    "(b a c)"
    "(a b c)"
    "(b c a)"
    "(2 2)")))

(check-case
 "empty tree"
 (string-append
  "(print-inorder '())\n"
  "(print-all-traversals '())\n"
  "(print-height-and-leaves '())\n")
 (lines->string
  '("()"
    "()"
    "()"
    "()"
    "(0 0)")))

;; -------------------------------------------------------------------------
;; Edge cases
;; -------------------------------------------------------------------------

(check-case
 "single node"
 (string-append
  "(print-inorder '(5 () ()))\n"
  "(print-all-traversals '(5 () ()))\n"
  "(print-height-and-leaves '(5 () ()))\n")
 (lines->string
  '("(5)"
    "(5)"
    "(5)"
    "(5)"
    "(1 1)")))

(check-case
 "left-only chain"
 (string-append
  "(print-inorder '(3 (2 (1 () ()) ()) ()))\n"
  "(print-all-traversals '(3 (2 (1 () ()) ()) ()))\n"
  "(print-height-and-leaves '(3 (2 (1 () ()) ()) ()))\n")
 (lines->string
  '("(1 2 3)"
    "(1 2 3)"
    "(3 2 1)"
    "(1 2 3)"
    "(3 1)")))

(check-case
 "node with one empty subtree"
 (string-append
  "(print-inorder '(1 (2 () ()) ()))\n"
  "(print-all-traversals '(1 (2 () ()) ()))\n"
  "(print-height-and-leaves '(1 (2 () ()) ()))\n")
 (lines->string
  '("(2 1)"
    "(2 1)"
    "(1 2)"
    "(2 1)"
    "(2 1)")))

(check-case
 "mixed numbers and symbols"
 (string-append
  "(print-inorder '(a (1 () ()) (b () (2 () ()))))\n"
  "(print-all-traversals '(a (1 () ()) (b () (2 () ()))))\n"
  "(print-height-and-leaves '(a (1 () ()) (b () (2 () ()))))\n")
 (lines->string
  '("(1 a b 2)"
    "(1 a b 2)"
    "(a 1 b 2)"
    "(1 2 b a)"
    "(3 2)")))

(define (numbers->string numbers)
  (string-append "(" (string-join (map number->string numbers) " ") ")"))

(define deep-ascending (range 1 1001))
(define deep-descending (range 1000 0 -1))

(check-case
 "deep unbalanced tree (depth 1000)"
 (string-append
  "(define deep\n"
  "  (let loop ([k 1000] [acc '()])\n"
  "    (if (= k 0)\n"
  "        acc\n"
  "        (loop (- k 1) (list k acc '())))))\n"
  "(print-inorder deep)\n"
  "(print-all-traversals deep)\n"
  "(print-height-and-leaves deep)\n")
 (lines->string
  (list (numbers->string deep-descending)
        (numbers->string deep-descending)
        (numbers->string deep-ascending)
        (numbers->string deep-descending)
        "(1000 1)")))

;; -------------------------------------------------------------------------
;; Unmodified solution must print nothing
;; -------------------------------------------------------------------------

(define (check-unmodified-solution)
  (define-values (status stdout-text stderr-text)
    (run-racket-file solution-path))
  (check-equal? status 0 "unmodified solution: exit status")
  (check-equal? stdout-text "" "unmodified solution: stdout")
  (check-equal? stderr-text "" "unmodified solution: stderr"))

(check-unmodified-solution)

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

(define whitelist
  (append
   '(define lambda let let* letrec if cond else and or not begin quote
     cons car cdr list null? pair? eq? assq assoc
     + - * < > <= >= = max display newline)
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
