#lang algebraic/racket/base

(require racket/sandbox
         scribble/core
         scribble/decode
         scribble/examples
         scribble/html-properties
         scribble/manual)

(provide (all-defined-out)
         (for-syntax (all-defined-out)))

(define (~cite . args) (list ~ (superscript ($ cite args))))

(define sec-hr (elem #:style (style "secsep" (list (alt-tag "hr")))))

(define (section* #:tag [tag #f] . args)
  (list ($ section #:tag tag #:style 'unnumbered args)
        sec-hr))

(define section**
  (λ args (list ($ section #:style '(unnumbered toc-hidden) args) sec-hr)))
(define subsection* (λ args ($ subsection #:style 'unnumbered args)))

(define (rtech . args)
  ($ tech #:doc '(lib "scribblings/reference/reference.scrbl") args))

(define (atech . args)
  ($ tech #:doc '(lib "algebraic/scribblings/algebraic.scrbl") args))

(define (gtech . args)
  ($ tech #:doc '(lib "scribblings/guide/guide.scrbl") args))

(define (glink . args)
  ($ seclink #:doc '(lib "scribblings/guide/guide.scrbl") args))

(define (grammar name . rules)
  (tabular
   #:sep (hspace 1)
   #:style "grammar"
   #:column-properties '(left center left right)
   (let loop ([fst (emph name)]
              [snd "⩴"]
              [rules rules])
     (if (null? rules)
         null
         (cons (list fst snd (caar rules) (list (hspace 4) (cadar rules)))
               (loop "" "|" (cdr rules)))))))

(define-syntax-rule (hash-lang mod)
  (list
   (seclink "hash-lang" #:doc '(lib "scribblings/guide/guide.scrbl") "#lang")
   " "
   (racketmodname mod)))

(define (docref doc . args)
  ($ seclink "top" #:doc doc #:indirect? #t args))

;;; ----------------------------------------------------------------------------
;;; Evaluators

(define-syntax-rule (module-language-evaluator mod-name)
  (call-with-trusted-sandbox-configuration
   (λ ()
     (parameterize ([sandbox-output       'string]
                    [sandbox-error-output 'string])
       (make-base-eval #:lang mod-name '(void))))))

(define-syntax-rule (module-language-evaluator* mod-name)
  (call-with-trusted-sandbox-configuration
   (λ ()
     (parameterize ([sandbox-output       'string]
                    [sandbox-error-output 'string])
       (make-base-eval #:lang mod-name)))))

;;; ----------------------------------------------------------------------------
;;; Examples

(begin-for-syntax
  (define-syntax-rule (examples/locations -eval)
    (...
     (λ (stx)
       (syntax-case stx ()
         [(_ expr ...) #'(examples #:eval -eval #:label #f
                                   #:preserve-source-locations expr ...)])))))
