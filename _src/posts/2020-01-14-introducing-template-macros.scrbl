#lang scribble/manual

Title: Introducing: Template Macros!
Date: 2209-01-14T17:34:08
Tags: Racket, meta-programming, news

@;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

@require{../lib/common.rkt}

@require[
  @for-label[
    (except-in glsl #%module-begin)
    racket/base
    racket/contract
    syntax/parse/define
    (except-in template #%module-begin)
  ]
]

@define[template-eval (module-language-evaluator 'racket/base)]
@define-syntax[example (examples/locations template-eval)]

@example[
  #:hidden
  (require racket/contract
           racket/function
           template)
]

@;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

@ttech{Template macros} are macros whose variables and sub-templates are
resolved @emph{before} normal @rtech{expansion} takes over, enabling powerful
meta-program generation techniques without having to adjust any @rtech{scope
sets} manually.

<!-- more -->

@section*{Dead Simple Code Generation for Racket}

@ttech{Template macros} integrate Racket's pattern-based and procedural macro
APIs and then throw in a dash of
@hyperlink["https://en.wikipedia.org/wiki/Template_metaprogramming"]{template
meta-programming} for a little spice. The result is a powerful code generation
API with four key features:

@itemlist[

  @item{When invoked, a @ttech{template macro}'s variables are resolved before
  its body is expanded.}

  @item{Iterative and recursive templates can be defined with less escapes to
  ``phase 1.''}

  @item{The variables of a @ttech{template macro} are visible pretty much
  @emph{everywhere} inside its body.}

  @item{Generated code inherits the caller's lexical context, as if the caller
  had typed everything in themselves.}

]

To get started with template macros, install
@hyperlink["https://pkgs.racket-lang.org/package/template"]{template} from the
official Racket package repository. See
@hyperlink["https://github.com/dedbox/racket-template/blob/master/README.md"]{README.md}
for details.

@section*{Early Variable Resolution}

With @tech{template macros}, variable resolution occurs @emph{after} the
@rtech{read} pass but @emph{before} the @rtech{expand} pass, trivializing the
hygienic generation of identifiers and the infiltration of @racket[quote]d
forms and other literal data.

When the expander finds @tech{template macro} variables inside an identifier,
it performs the following steps:

@itemlist[
  #:style 'ordered

  @item{Unwrap the identifier's @rtech{syntax object} to expose its
  @rtech{symbol}.}

  @item{@racket[write] the symbol to a string.}

  @item{Resolve the @tech{template macro} variables in the string.}

  @item{@racket[read] the modified string to produce a replacement datum.}

  @item{Wrap the replacement datum with the lexical context of the enclosing
  @tech{template macro}'s use site.}

]

Here's a simple example that shows how easily @ttech{template macro} variables
can be used to generate literal data.

@example[
  (begin-template ([$x 1] [$y 2] [$z !])
    (writeln (sub1 $x$y00))
    (writeln '($x-$y$z "$y-$x$z")))
]

In practice, synthesizing definitions, as demonstrated in the example below,
is a pretty handy meta-programming technique. A bijective composition is a
pair of functions that invert each other when composed.

@example[
  (define-template (define-bijective-composition $T1 $E1 $T2 $E2)
    (define/contract $T1->$T2 (-> $T1? $T2?) $E2)
    (define/contract $T2->$T1 (-> $T2? $T1?) $E1))
]

For comparison, here's an equivalent definition using
@racket[define-simple-macro] from the @seclink["top" #:doc '(lib
"syntax/scribblings/syntax.scrbl")]{syntax} meta-programming library.

@racketblock[
  (define-simple-macro (define-bijective-composition T1 E1 T2 E2)
    #:with T1->T2 (format-id this-syntax "~a->~a"
                             (syntax->datum #'T1)
                             (syntax->datum #'T2))
    #:with T2->T1 (format-id this-syntax "~a->~a"
                             (syntax->datum #'T2)
                             (syntax->datum #'T1))
    #:with T1? (format-id this-syntax "~a?" (syntax->datum #'T1))
    #:with T2? (format-id this-syntax "~a?" (syntax->datum #'T2))
    (begin
      (define/contract T1->T2 (-> T1? T2?) E2)
      (define/contract T2->T1 (-> T2? T1?) E1)))
]

Because Racket can't know in general what my priorities are, I have to
manually specify the lexical context of each new identifier or it won't be
bound to anything once the caller regains control. All those @racket[#:with]
clauses add noise to a definition. For large code bases that generate lots of
one-off identifiers, too many @racket[#:with] clauses will force the defining
macro's pattern onto a separate page from its body. For an example of this
effect in the wild, see
@hyperlink["https://github.com/dedbox/racket-glm/blob/9ab93fe8549f6ce8da29ce651a175bf35a4d996d/private/vector.rkt"]{here}.

Here's a bijective composition between real numbers and strings:

@example[
  (define-bijective-composition
    real (compose read open-input-string)
    string (curry format "~a"))
]

It generates and defines two identifiers: @racketid[string->real] and
@racket[real->string]. It also uses, but does not define, two more
identifiers: @racket[real?] and @racket[string?].

@example[
  (string->real (real->string 123))
  (real->string (string->real "987"))
  (eval:error (string->real -1))
]

@section*{Concise Template Generation Syntax}

Iteration and recursion forms are just ordinary macros. While they can be used
like any other macro, some forms behave differently when used inside the body
of another @tech{template macro}.

Internally, every @tech{template macro} expands to a use of
@racket[begin-template], which in turn expands to a use of @racket[begin],
allowing @racket[begin-template] to inherit its splicing behavior in
non-@rtech{expression contexts} for free. When @racket[begin-template] is used
inside another @tech{template macro}, this behavior extends into
@rtech{expression contexts} as well.

@subsection*{Comprehensions}

@racketblock[
  (code:comment "a 10x10 identity matrix")
  (begin-template ()
    (list (for/template ([$row (in-range 10)])
            (vector (for/template ([$col (in-range 10)])
                      (if-template (= $row $col) 1 0))))))
]

This @tech{template macro} generates the following expression, which produces
a list of vectors.

@racketblock[
  (list (vector 1 0 0 0 0 0 0 0 0 0)
        (vector 0 1 0 0 0 0 0 0 0 0)
        (vector 0 0 1 0 0 0 0 0 0 0)
        (vector 0 0 0 1 0 0 0 0 0 0)
        (vector 0 0 0 0 1 0 0 0 0 0)
        (vector 0 0 0 0 0 1 0 0 0 0)
        (vector 0 0 0 0 0 0 1 0 0 0)
        (vector 0 0 0 0 0 0 0 1 0 0)
        (vector 0 0 0 0 0 0 0 0 1 0)
        (vector 0 0 0 0 0 0 0 0 0 1))
]

@tech{Template macros} can also escape to the expanding environment. The
@racket[untemplate] and @racket[untemplate-splicing] forms evaluate an
expression with @racket[syntax-local-eval] and then inject the caller's
lexical context into any non-syntax return values. @tech{Template macro}
variables are still visible inside these forms.

@example[
  (define-template (slow-fibonaccis $n)
    (if-template (<= $n 2)
      (build-list $n (λ _ 1))
      (let ([fibs (slow-fibonaccis (untemplate (sub1 $n)))])
        (cons (+ (car fibs) (cadr fibs)) fibs))))
]

When @racketid[$n] is, say 5, @racket[slow-fibonaccis] first expands to

@racketblock[
  (let ([fibs (slow-fibonaccis 4)])
    (cons (+ (car fibs) (cadr fibs)) fibs))
]

The fully expanded @tech{template} is

@racketblock[
  (let ([fibs (let ([fibs (let ([fibs (build-list 2 (λ _ 1))])
                            (cons (+ (car fibs) (cadr fibs)) fibs))])
                (cons (+ (car fibs) (cadr fibs)) fibs))])
    (cons (+ (car fibs) (cadr fibs)) fibs))
]

The code above runs quickly, but recursively generating and expanding every
branch takes a while. The @racket[fast-fibonaccis] function below improves
performance by calculating the whole series in one expansion step.

@example[
  (define-template (fast-fibonaccis $n)
    (if-template (<= $n 2)
      '(untemplate (build-list $n (λ _ 1)))
      '(untemplate (for/fold ([fibs '(1 1)])
                             ([_ (in-range (- $n 2))])
                     (cons (+ (car fibs) (cadr fibs)) fibs)))))
  (fast-fibonaccis 20)
]

Inside a @tech{template}, @racket[unsyntax] and @racket[unsyntax-splicing] are
aliases for @racket[untemplate] and @racket[untemplate-splicing],
respectively, when they occur outside @racket[quasisyntax]. In the code below,
@racket[small-fast-fibonacis] behaves identically to @racket[fast-fibonaccis].

@example[#:escape UNSYNTAX
  (define-template (small-fast-fibonaccis $n)
    (if-template (<= $n 2)
      '#,(build-list $n (λ _ 1))
      '#,(for/fold ([fibs '(1 1)])
                   ([_ (in-range (- $n 2))])
           (cons (+ (car fibs) (cadr fibs)) fibs))))
  (small-fast-fibonaccis 20)
]

@subsection*{Recursion}

@; @section*{Module-

@subsection*{The Module Language}

@subsection*{#lang template}


@; - bijective composition
@; - define-shader

@; 2. Convenient Escape Hatches

@; - untemplate
@; - untemplate-splicing

@; 3. Sequencing Templates

@; - begin-template
@; - begin0-template

@; 4. Selection Templates

@; - if-template
@; - cond-template
@; - when-template
@; - unless-template

@; 5. Iteration Templates

@; - for/template
@; - for*/template

@; 6. Template Recursion

@; - slow-fibonacci
@; - fast-fibonacci
@; - faster-fibonacci

@; 7. #lang template

@; - define-vector-type
