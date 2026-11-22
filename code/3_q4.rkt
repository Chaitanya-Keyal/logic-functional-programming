#lang racket/base

;; (my-length lst) -> number
;; Number of top-level elements of lst (atoms or sublists, each counting as
;; one).  Only the spine of lst is walked; sublists are not entered.
;; Recursive reading: the length of () is 0; the length of (a . rest) is
;; 1 + the length of rest.  Tail recursive: acc counts the elements seen so
;; far and rest is the part not yet counted.
(define (my-length lst)
  (let loop ([rest lst] [acc 0])
    (if (null? rest)
        acc
        (loop (cdr rest) (+ acc 1)))))

;; (my-map f lst) -> list
;; List of the results of applying f to each top-level element of lst, in
;; the same order.  Sublists are passed to f as they are, not descended
;; into.
;; Recursive reading: mapping f over () is (); mapping f over (a . rest) is
;; (f a) followed by mapping f over rest.  The recursive call is not a tail
;; call because cons needs its result, which keeps the output in order
;; without building it backwards.
(define (my-map f lst)
  (if (null? lst)
      '()
      (cons (f (car lst))
            (my-map f (cdr lst)))))

;; (insert-if-short x lst n) -> list
;; Copy of lst in which x is put at the front of every list, at every level
;; of nesting, whose length is less than n.  Lengths are measured on the
;; original list, before any insertion, so the top-level list is judged by
;; its original length even though it may gain x.  An element is a list
;; exactly when it is () or a pair; anything else is an atom and is kept as
;; it is.  () has length 0, so it becomes (x) whenever 0 < n.
;; Recursive reading: the returned inserter maps itself over every list's
;; elements first, with atoms unchanged, and then conses x on when the
;; original length of that list is less than n.
;; This is the n-specific case of make-inserter: the predicate accepts a
;; length exactly when it is less than n, so the length is compared with n
;; once per list and all the nesting work happens in the returned inserter.
(define (insert-if-short x lst n)
  ((make-inserter x (lambda (len) (< len n))) lst))

;; (print-insert-result) -> (display result)
;; Reads x, then lst, then n from standard input, and prints
;; (insert-if-short x lst n) on one line followed by one newline.  It prints
;; no prompt or other text.  let* is used because the three reads must
;; happen in order: x first, lst second, n third.
(define (print-insert-result)
  (let* ([x (read)]
         [lst (read)]
         [n (read)])
    (display (insert-if-short x lst n))
    (newline)))

;; (make-inserter x len-ok?) -> (list -> list)
;; Returns a function that copies a list, putting x at the front of every
;; list, at every level of nesting, whose length satisfies the one-argument
;; predicate len-ok?.  Lengths are measured on the original lists, before
;; any insertion, and the top-level list is treated like every other list.
;; An element is a list exactly when it is () or a pair; anything else is an
;; atom and is kept as it is.
;; Recursive reading: the returned inserter first maps itself over lst, with
;; atoms unchanged, then conses x on when (len-ok? (my-length lst)) holds
;; for the original lst.  my-map preserves the order.
(define (make-inserter x len-ok?)
  (define (inserter lst)
    (let ([processed
           (my-map (lambda (element)
                     (if (or (null? element) (pair? element))
                         (inserter element)
                         element))
                   lst)])
      (if (len-ok? (my-length lst))
          (cons x processed)
          processed)))
  inserter)
