#lang scribble/manual

Title: Template Macros, Initial Release
Date: 2020-03-17T07:00:00
Tags: announcement, Racket, meta-programming

@require[
  "../lib/common.rkt"
  scribble/examples
  @for-label[
    racket/base
    racket/string
    racket/syntax
    template
  ]
]

@;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@; Examples

@define[template-evaluator (module-language-evaluator 'racket/base)]

@define-syntax-rule[(example expr ...)
  @examples[
    #:eval template-evaluator
    #:label #f
    #:preserve-source-locations
    expr ...]]

@define-syntax-rule[(EXAMPLE expr ...)
  @examples[
    #:eval template-evaluator
    #:escape UNSYNTAX
    #:label #f
    #:preserve-source-locations
    expr ...]]

@example[#:hidden
  @require[template @for-syntax[racket/base racket/string]]
]

@;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@; Links

@define[the-url]{https://github.com/dedbox/racket-template}
@define[Template-Macros @hyperlink[the-url]{Template Macros}]
@define[Template-macros @hyperlink[the-url]{Template macros}]
@define[template-macros @hyperlink[the-url]{template macros}]
@define[template-macro @hyperlink[the-url]{template macro}]
@define[Racket @hyperlink["https://racket-lang.org/"]{Racket}]
@define[fear-of-macros-url]{http://www.greghendershott.com/fear-of-macros/pattern-matching.html#%28part._.Another_example%29}

@;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

I'm pleased to announce @Template-Macros, an experimental meta-programming
technique that dramatically simplifies the generation of higher-order @Racket
meta-programs.

<!-- more -->

@Template-macros infiltrate the spaces underserved by @Racket's existing
pattern-based and procedural macros, such as the insides of literal data,

@example[
(with-template ([X 1] [Y 2]) (values XY3 "YX0" #rx"^X+Y$"))
]

or in the various quoted forms;

@example[
(with-template ([X a] [Y b]) '(+X+ #'!Y!))
]

and when one @template-macro is used by another, the results are spliced.

@example[
(begin-template (list (for/template ([K (in-range 10)]) K)))
]

@Template-macros eliminate common technical barriers to higher-order @Racket
meta-programming by preempting the default macro expander. The current API
offers a lot more than I could jam into a release announcement, and it's still
growing! In the coming weeks and months, I'll try to post some topic-focused
tutorials that highlight the wealth of functionality @template-macros provide
to the practicing language-oriented @Racket programmer.

But the next time you face a wall of @racket[format-id]s,

@example[
(for*/template ([M (in-range 1 6)]
                [N (in-range 1 6)])
  (define idMxN
    (list (for/template ([I (in-range 1 (add1 M))])
            `(vector ,@(list (for/template ([J (in-range 1 (add1 N))])
                               (if-template (= I J) 1 0)))))))
  (when-template (= M N)
    (define idM idMxN)))
id5
]

or trip on a missing @racket[syntax-local-introduce],

@example[
(define-template (urlang-js modpath)
  (let ()
    (local-require (only-in modpath the-javascript))
    (the-javascript)))
]

or struggle to interleave @hyperlink[fear-of-macros-url]{a medley} of
functions with ``syntax'' in their names,

@EXAMPLE[
(define-template (hyphen-define* Names Args Body)
  (define #,(string->symbol (string-join (map symbol->string 'Names) "-"))
    (λ Args Body)))
(hyphen-define* (foo bar baz) (v) (* 2 v))
(foo-bar-baz 50)
]

give @template-macros a try and let me know how it goes!
