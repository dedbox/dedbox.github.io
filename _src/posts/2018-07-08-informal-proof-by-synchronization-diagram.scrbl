#lang scribble/manual

Title: Informal proof by synchronization diagram
Date: 2018-07-08T11:02:27
Tags: cmx, concurrency, diagrams

@(require (for-label racket/base event (except-in cmx filter say hear forward)))

Let @racketid[v] be some value. Denote by @racketid[mK] the mediator
identified by (sub)script @racketid[K], and by @racketid[m-NAME] the mediator
identified by name @racketid[NAME]. Define the primitive mediated operations
(@racket[offer], @racket[accept], @racket[put], @racket[get]) as in
@url{http://docs.racket-lang.org/cmx/}.

Further, 

@racketblock[
  (define (say m v [m0 (make-mediator)])
    (seq (offer m m0) (bind (accept m0) (λ (m*) (put m* v)))))

  (define (hear m)
    (bind (accept m) (λ (m0) (seq (offer m0 m0) (get m0)))))

  (define (forward m1 m2)
    (bind (accept m1) (λ (m0) (offer m2 m0))))
]

and

@racketblock[
(define m-say (make-mediator))
(define m-hear (make-mediator))
(define sayer (thread (λ () (sync (say m-say v)))))
(define hearer (thread (λ () (sync (hear m-hear)))))
(define forwarder (thread (λ () (sync (forward m-say m-hear)))))
]

Then the synchronization diagram for @racketid[say], @racketid[forward], and
@racketid[hear] is:

@verbatim[#:indent 1]|{
say     | offer m1 m0    :                | m* = accept m0 | put m* v   ||
forward | m0 = accept m1 | offer m2 m0    ||               :            :
hear    :                | m0 = accept m2 | offer m0 m*    | v = get m* ||
}|

@bold{Theorem [Progress]:} @emph{A forwarded say/hear exchange never gets
stuck.}

@bold{Proof}: By demonstration.

Let @racketid[m0] be a fresh mediator, and suppose each of (say, hear,
forward) is running in a separate thread, as shown above, at some time
@var{t0}.

Note that each primitive operation must be paired with a complementary
operation in another thread, through a shared mediator, to succeed at run
time.

The following ordered sequence of successful pairings is observed:

At some time @emph{t1} > @emph{t0}, the sayer transfers @racketid[m0] to
the forwarder through the control channel of racketid[m-say].

At some time @emph{t2} > @emph{t1}, the forwarder transfers @racketid[m0] to the
hearer through the control channel of @racketid[m-hear] and then ends.

From this point on, the remaining threads behave as in the second half of a
simple say/hear exchange:

At some time @emph{t3} > @emph{t2}, the hearer transfers @racketid[m0] to the sayer
through the control channel of @racketid[m0].

At some time @emph{t4} > @emph{t3}, the sayer transfers @racketid[v] to the
hearer through the data channel of @racketid[m0] and then both threads end. ∎
