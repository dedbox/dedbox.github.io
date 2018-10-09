#lang scribble/manual

Title: What is a synchronization diagram?
Date: 2018-07-08T13:06:25
Tags: cmx, concurrency, diagrams

@require[
  (for-label cmx
             event
             (except-in racket/base filter)
             (only-in racket/function curry))
]

A synchronization diagram displays the synchronization behavior of a set of
threads as a sequence of discrete events between them. A diagram contains a
fixed number of rows starting on the left and extending to the right by some
number of columns. Each row models the behavior of a thread, and each column
represents a synchronizing event. Time flows from left to right.

The simplest diagram is a channel put/get interaction.

@verbatim[#:indent 1]|{
       |      put  ,--. ||
putter |  v  ----->|ch| ||
       |           `--' ||
       +                +
       | ,--. get       ||
getter | |ch|----->  v  ||
       | `--'           ||
}|

A more interesting example is the cmx forward construct.

@racketblock[
  (define (#,(racketid forward) m1 m2)
    (bind (accept m1) (curry offer m2)))
]

Here's a "proof" that it works.

@verbatim[#:indent 1]|{
        |      offer   ,--. :                   | ,--. accept       |     put  ,--. ||
say     |  m0 -------->|m1| :                   | |m0|--------> m*  |  v ----->|m*| ||
        |              `--' :                   | `--'              |          `--' ||
        +                   +                   +                   +               +
        | ,--. accept       |      offer   ,--. ||                  :               :
forward | |m1|--------> m0  |  m0 -------->|m2| ||                  :               :
        | `--'              |              `--' ||                  :               :
        +                   +                   +                   +               +
        :                   | ,--. accept       |      offer   ,--. | ,--. get      ||
hear    :                   | |m2|--------> m0  |  m* -------->|m0| | |m*|-----> v  ||
        :                   | `--'              |              `--' | `--'          ||
}|

Clearly, all threads finish (at the double bars). Less obviously,
@racket[hear] is not able to commit to the exchange until after @racket[say]
has initiated. Most importantly, @racket[say] and @racket[hear] finish
together, as @racketid[v] is delivered.

For cmx constructs, a row corresponds to an expression in the calculus of
mediated exchange and the diagram condenses neatly.

@verbatim[#:indent 1]|{
say     | offer m1 m0    :                | m* = accept m0 | put m* v   ||
forward | m0 = accept m1 | offer m2 m0    ||               :            :
hear    :                | m0 = accept m2 | offer m0 m*    | v = get m* ||
}|

I've drawn many synchronization diagrams on paper and as picts, and I need to
decide where to put them. The protocol used by cmx was discovered by
iteratively modeling events, determining what went wrong, and adjusting the
model; this modeling process might be worth documenting, too.

About three months ago, I caught a synchronization timing bug in the code
@racket[dispatch] replaces and I just finished integrating cmx (and
event-lang) back into Neuron to squash it.
