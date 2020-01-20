#lang scribble/manual

Title: Documentation As a Creative Force
Date: 2020-01-20T09:59:48
Tags: journal

@require{../lib/common.rkt}

@define[template-pkg
  @hyperlink["https://pkgs.racket-lang.org/package/template"
  ]{template}]

@define[reference-manual
  @seclink["top" #:doc '(lib "template/scribblings/template.scrbl")
  ]{reference manual}]

@define[template-macros
  @ttech{template macros}]

@define[README.md
  @hyperlink["https://github.com/dedbox/racket-template/blob/master/README.md"
  ]{README.md}]

@; #############################################################################

Docs for the @template-pkg package are coming together nicely. The
architectural details are starting to jump off the page, so I'm slowing down
to fold them into the code base as they emerge.

<!-- more -->

Documentation is an essential part of my creative process. It exposes the
@deftech{low-frequency patterns}---the high-level concepts and techniques that
enable the collective expression of disparate elements---in a code base.
Dialing into ``the right frequency'' inexorably leads to profoundly simpler
code with more features and fewer bugs.

For @template-macros, I've got four technical documents cooking:

@itemlist[
  @item{An API reference}
  @item{An overview of the API}
  @item{A @README.md file}
  @item{A blog-style introduction}
]

In writing each one, I take a distinct perspective that supports the others.
The first two comprise the @reference-manual to be served by Racket's official
documentation repository. Together, they give a comprehensive account of the
concepts, forms, and functions provided by the @template-pkg package. The
@README.md file summarizes the project and explains how to install, use, and
contribute to it. The blog intro makes a case for depending on the
@template-pkg package in other projects.

The API reference was easiest to start with, which is typical, in my
experience. Reference material is special in the sense that hard facts tend to
speak for themselves, thus freeing attention for higher level concerns like
consistent naming and algorithmic robustness without having to contextualize
anything for skeptical readers. With very few exceptions, everything in the
API reference is illustrated by live example code. Early in the drafting
process, these examples can act as insurance against bad prose and accelerate
evolution of the language design.

The blog intro is, in a pragmatic sense, the inverse of the @reference-manual
perspective. Its job is to convert the skeptical reader into an active user,
so contextualization is really all that matters. This is the hardest part for
me. To pitch @template-macros confidently, I need to know that what I'm saying
is interesting, refutable, and true. Gaining sufficient clarity can be a
challenge, but it's almost always worth the trouble.

Yesterday, I resolved an awkward tension between template variables bound to
identifiers versus those that aren't. While struggling with the blog intro, I
discovered that the way I'm projecting variable resolution into identifier
names can be extended to any literal data form, including strings, regular
expressions, and even hash keys! Once I understood the @tech{low-frequency
pattern} here---that all non-trivial transformations occur inside the literal
data---most of the prototype's flexibilty became unnecessary. Trimming the fat
is already revealing a more compact, elegant, and robust core.
