#lang at-exp racket @; -*- Scheme -*-
#|
;; Verifying dApp Computations on a Blockchain
;; Deepspec Summer School 2018, July 19th 2018
;; https://docs.google.com/spreadsheets/d/1ScqaHW0HCb_ehU0LXQ2K4TUcWX9Ton8GvKa-2-vruC4/edit?ts=5b329ac#gid=596021454
;; Based on a presentation given at LambdaConf 2018, 2018-06-05

;; To compile it, use:
;;    racket vdacoab.rkt > vdacoab.html

;; This document is available under the bugroff license.
;;    http://tunes.org/legalese/bugroff.html


;; Official Abstract:
;;
;; At the intersection of Game Theory and Game Semantics, of Logic and Probabilities,
;; of asynchronous distributed calculi and consensual sequential computations,
;; of static proofs and dynamic reflection, of cryptographic privacy and public verifiability
;; — there is the specification and proven-correct extraction of a distributed application (dApp)
;; where the interests of participants are kept aligned by a cryptocurrency smart contract.
;; I will discuss the challenges that the Legicash team is trying to solve using Coq,
;; as we are developing a new approach to building dApps that are correct by construction,
;; and thereby solve scalability and interoperability issues for blockchains.

|#

(require scribble/html "reveal.rkt")

(slide () @h1{Verifying dApp Computations on a Blockchain}
  ~
  ~
  @p{François-René Rideau, @em{Legicash}}
  @C{fare@"@"legi.cash}
  ~
  ~
  @p{Deepspec Summer School 2018, July 19th 2018}
  @url{http://bbt.legi.cash/vdacoab.html})

(gslide () @h1{The Take Home Points}
 ~
 @L{Solve Scalability, Interoperability, Safety issues for dApps}
 ~
 @L{Consensus as Court, Lawsuit as Interactive Proof}
 ~
 @L{Game Theory, Game Semantics, Temporal Logic, Epistemic Logic}
 ~
 @L{Higher-Level: dApp invariants, not contract virtual machines})

(gslide () @h1{Cryptocurrency dApp issues}
 ~
 @L{Scale: from 10 tps to 1e5 and beyond, latency 60 min to 6 s}
 ~
 @L{Interoperate: contracts that bind across multiple blockchains}
 ~
 @L{Be safe: don't lose USD 3e7 to one bug in 400 lines of code}
 ~
 @L{Have a paradigm: not just random code and silly games})

(gslide () @h1{Consensus as Court}
 ~
 @L{An analogy is one abstraction, instantiated twice}
 ~
 @L{Common Abstraction: dispute prevention and resolution system}
 ~
 @L{Distinct Parameters: humans & rhetoric vs computers & logic}
 ~
 @L{What are @q{Smart Lawsuits}? Interactive Proofs!})

(gslide () @h1{Interactive Proof}
 ~
 @L{Game Semantics: Transform formula into verification game}
 ~
 @L{Exhibit witness for my ∃. My ∀ is your ∃, so I challenge you.}
 ~
 @L{One step per (dependent) product/sum alternation.}
 ~
 @L{Skolemization: @tt{∀x:X ∃y:Y P(x,y)} @em{becomes} @tt{∃f:X→Y ∀x:X P(x,f(x))}})

(gslide () @h1{What Logic?}
 @L{Game Theory: align participants' interests}
 @L{Game Semantics: validate past events}
 @L{Epistemic Logic: you are what you know}
 @L{Temporal Logic: multiple possible futures, timeouts}
 ~
 @L{Computability Logic: (game) Semantics first, syntax second}
 @L{... it already has Classical, Intuitionnistic, Linear fragments}
 @L{Coq: internal models, reflection and extraction}
 @L{Layers: verify the past, make the present, reason about future})

(gslide () @h1{A Higher-Level Paradigm}
  @L{Invariants for all future dApp evaluations (Coq)}
  @L{Regular behavior for each participant (OCaml)}
  @L{Referee to resolve disputes about past behavior (EVM)}
  @L{Strategies to argue the verification game in court (TBD)}
  @L{Vigilantism to watch the network and stop the bad guys (TBD)}
  @L{Counsel to explain consequences of (in)action (Expert System)}
  @L{Showcase for robustness vs attack scenarios (Integration Tests)}
  ~
  @L{Low-level detail: semantics of invididual contract invocation})

(gslide () @h1{Shared Knowledge: the Court Registry}
 ~
 @L{Winning Strategy for good guys @em{iff} predicate decidable}
 ~
 @L{BUT to find it, must only quantify over @em{Shared Knowledge}}
 ~
 @L{Shared Knowledge, precursor to Common Knowledge}
 ~
 @L{Court Registry: Oracle for public data availability})

(gslide () @h1{Thanks}
 ~
 @L{Our startup:   @em{Legicash} @url{https://legi.cash/}}
 ~
 @L{WE ARE HIRING!   Coq clubbers wanted}
 ~
 @L{WE ARE SEEKING COLLABORATORS!   Research grant proposals}
 ~
 @L{SHOW ME THE CODE!   @url{https://j.mp/LegicashCodeReleasePreview}})

(reveal)
