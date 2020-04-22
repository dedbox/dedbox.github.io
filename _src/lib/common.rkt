#lang algebraic/racket/base

(require frog/scribble
         racket/sandbox
         scribble/core
         scribble/decode
         scribble/examples
         scribble/html-properties
         scribble/manual
         syntax/parse/define
         (for-syntax racket/base
                     racket/syntax))

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

;;; Technical Terms

(define (rtech . args)
  ($ tech #:doc '(lib "scribblings/reference/reference.scrbl") args))

(define (gtech . args)
  ($ tech #:doc '(lib "scribblings/guide/guide.scrbl") args))

(define (glink . args)
  ($ seclink #:doc '(lib "scribblings/guide/guide.scrbl") args))

(define (atech . args)
  ($ tech #:doc '(lib "algebraic/scribblings/algebraic.scrbl") args))

(define (ttech . args)
  ($ tech #:doc '(lib "template/scribblings/template.scrbl") args))

;;; Links

(define-simple-macro (deflink name url text ...)
  (begin
    (define name (hyperlink url text ...))
    (deflink* name)))

(define-simple-macro (deflink* name (~optional base))
  #:with base* (or (attribute base) (attribute name))
  #:with name. (format-id #'name "~a." (syntax-e #'name))
  #:with name! (format-id #'name "~a!" (syntax-e #'name))
  #:with name? (format-id #'name "~a?" (syntax-e #'name))
  #:with name: (format-id #'name "~a:" (syntax-e #'name))
  (begin
    (define name. (list base* "."))
    (define name! (list base* "!"))
    (define name? (list base* "?"))
    (define name: (list base* ":"))))

;;; 

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

(begin-for-syntax
  (define-syntax-rule (EXAMPLES/locations -eval)
    (...
     (λ (stx)
       (syntax-case stx ()
         [(_ expr ...) #'(examples #:eval -eval #:escape UNSYNTAX #:label #f
                                   #:preserve-source-locations expr ...)])))))

