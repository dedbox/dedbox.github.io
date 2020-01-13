#lang scribble/manual

Title: Winter 2020 Prospective
Date: 2020-01-13T14:07:32
Tags: journal

@(define-syntax-rule (defterm name location title ...)
  (define name (seclink "top" #:doc location #:indirect? #t title ...)))

@defterm[GLM-for-Racket '(lib "glm/scribblings/glm.scrbl")]{GLM for Racket}

@defterm[template-macros '(lib "template/scribblings/template.scrbl")]{template macros}

@defterm[graphics-engine '(lib "graphics-engine/scribblings/graphics-engine.scrbl")]{graphics-engine}

@defterm[lang-voxel '(lib "voxel/scribblings/voxel.scrbl")]{#lang voxel}

@defterm[Neuron '(lib "neuron/scribblings/main.scrbl")]{Neuron}

@defterm[Algebraic-Racket '(lib "algebraic/scribblings/algebraic.scrbl")]{Algebraic Racket}

@define[lang-voxel. @list[@lang-voxel "."]]

@; #############################################################################

I've decided to make a serious effort this year to start using this blog as a
project catalog and public relations vehicle. There should be at least one
place on the Internet I can point to as a portfolio that isn't GitHub. So, in
that spirit, here's what the next few months are starting to look like.

<!-- more -->

The C++ back end for @GLM-for-Racket has been in limbo for a month. I'm gonna
punt for now and use the fastest pure-Racket method compatible with
@template-macros, then it's back to @graphics-engine and @lang-voxel. If
@GLM-for-Racket wraps early enough, February will be screencast mania! @Neuron
and @Algebraic-Racket need some attention, too, which should wrap by end of
February as well.

In March, work on the graphics libraries will start to wind down and I'll move
onto live audio. By summer time, I want to be able to perform #lang-based sets
live.
