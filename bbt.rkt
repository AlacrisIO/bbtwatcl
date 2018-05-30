#lang at-exp racket @; -*- Scheme -*-
#|
;; Binding Blockchains Together with Accountability through Computability Logic
;; LambdaConf 2018, June 5th 2018
;; https://lambdaconf2018.dryfta.com/en/program-schedule/program/64/binding-blockchains-together-with-accountability-through-computability-logic
;; Based on a presentation given at the MIT Blockchain Club 2018-02-20
;;
;; To compile it, use:
;;    racket bbt.rkt > bbt.html
;;
;; This document is available under the bugroff license.
;;    http://www.oocities.org/soho/cafe/5947/bugroff.html
;;
;;
;; Official Abstract:
;;
;; I will present before you the holy grail of cryptocurrency:
;; repudiable side-chains providing payments processing as fast as credit cards
;; or any other arbitrary service without sacrificing the trustless security of account holders,
;; provably bound with logical invariants
;; to a main blockchain controlled by a distributed consensus.
;;
;; I reached that grail by putting all the concepts back into place,
;; both economic and (techno)logic: the respective roles of
;; distributed chat (shared knowledge) vs. distributed consensus (common knowledge);
;; the importance of accountability in maintaining good incentives,
;; requiring actors to have skin in the game by posting bonds they'll lose if they misbehave;
;; "Exit" (and "Enter") being the mechanism to keep service providers honest,
;; when "Voice" can only coordinate people whose interests are already aligned;
;; distributed consensus as a court system that provides arbitration, not transactions;
;; and non-publication being literally infinitely faster than publication.
;;
;; Arbitration automatically resolves legal arguments where each interested party backs its claim
;; by challenging the other in an interactive proof.
;; Arbitrary logical invariants can thus be established using game semantics.
;; The natural language in which to express contracts is therefore computability logic,
;; far from the low-level virtual machines common in the industry
;; or even the functional languages proposed to replace them.
;; Well-designed contracts always provide one party a winning strategy,
;; so losers better concede early rather than lose and cover all legal costs.
;;
;; Linking two chains together requires encoding the evolving semantics of both chains in contracts.
;; This construct is very fragile to the least discrepancy
;; between the encoding and the actual chain implementation.
;; Therefore this technology demands extraction of both blockchain
;; implementation and contract evaluation language from a common logic specification,
;; one that allows for reflective representation of the blockchain's own semantics.
;;
;; Join me in the revolution of programming financial contracts with logic!
|#

(require
 scribble/html
 net/url
 (for-syntax syntax/parse))

;; http://docs.racket-lang.org/scribble/extra-style.html

;; Reveal and new html stuff
(define/provide-elements/not-empty section video) ; more tags here

;; Register sections (but only at the top-level)
(define-values [get-sections register-section]
  (let ([sections '()])
    (values (λ () (reverse sections))
            (λ (section) (set! sections (cons section sections))))))
(define section-toplevel? (make-parameter #t))
(define-syntax-rule (slide (options ...) stuff ...)
  (do-slide (list options ...) (λ () (list stuff ...))))
(define (do-slide options thunk)
  (let ((toplevel? (section-toplevel?)))
    (parameterize ([section-toplevel? #f])
       (let ((section (apply section (append options (thunk)))))
         (if toplevel?
             (register-section section)
             section)))))
(define group-title (make-parameter #f))
(define-syntax-rule (slide-group title stuff ...)
  (do-slide-group title (λ () (list stuff ...))))
(define (do-slide-group title thunk)
  (slide ()
   (slide () @(h1 title))
   (parameterize ([group-title title])
     (thunk))))
(define (do-group-title)
  (when (group-title)
    (p align: 'right valign: 'top (font size: 4 (b (group-title))))))
(define-syntax-rule (gslide (options ...) stuff ...)
  (slide (options ...) (do-group-title) stuff ...))
(define-syntax-rule (when-not condition body ...)
  (when (not condition) body ...))

(define (reveal-url . text)
  ;; (cons "http://cdn.jsdelivr.net/reveal.js/3.0.0/" text)
  (cons "resources/reveal/" text))

;; Quick helpers
(define-syntax-rule (defcodes lang ...)
  (begin (define (lang . text) (pre (code class: 'lang text)))
         ...))
(defcodes scheme javascript haskell)

(define (pic-url name url)
  (let ((file (string-append "resources/pic/" name)))
    (unless (file-exists? file)
      (define out (open-output-file file #:exists 'truncate))
      (call/input-url (string->url url)
                      get-pure-port
                      (λ (in) (copy-port in out)))
      (close-output-port out))
    file))

(define (L . x) (apply div align: 'left x))
(define (t . x) x)
(define (C . x) (apply div align: 'center x))
(define (CB . x) (C (apply b x)))

(define (url x) (a href: x (tt x)))
(define (comment . x) '())

(define (image name url . size)
  (img src: (pic-url name url) alt: name height: (if (empty? size) "75%" size)))

(define (fragment #:index (index 1) . body)
  (apply span class: 'fragment data-fragment-index: index body))

(define *white* "#ffffff")
(define *gray* "#7f7f7f")
(define *blue* "#0000ff")
(define *light-blue* "#b4b4ff")
(define *red* "#ff0000")
(define *light-red* "#ffb4b4")
(define *green* "#00ff00")
(define *light-green* "#b4ffb4")

(define ~ @p{ })

(define (spacing* l (space (br)))
  (cond
    ((null? l) (list space))
    ((pair? l) (append (list space)
                       (if (pair? (car l)) (car l) (list (car l)))
                       (spacing* (cdr l))))
    (else (error 'spacing*))))

(define (spacing l)
  (if (list? l)
      (cdr (spacing* (filter-not null? l)))
      l))

(define (color text #:fg (fgcolor #f) #:bg (bgcolor #f))
  (if (or fgcolor bgcolor)
      (span style: (list (if fgcolor (list "color:" fgcolor ";") '())
                     (if bgcolor (list "background-color:" bgcolor ";") '()))
            text)
      text))

(define (gray . text) (color text #:fg *gray*))

(define (bg-slide text fgcolor bgcolor)
  (λ x
    (gslide (data-background: bgcolor)
     (spacing x)
     (div align: 'right valign: 'bottom (color #:fg fgcolor text)))))

(define-syntax-rule (x-slide (options ...) x ...)
  (gslide (options ...) (spacing (list x ...))))

;;(define th-width "4%")
;;(define td-width "48%")
;;(define table-width "114%")
(define th-width "8%")
(define td-width "46%")
(define table-width "104%")

(define (th* name)
  (if name (th width: th-width (font size: "6" (color name #:fg *white*))) (td)))

(define (row name left right
             #:left-bg (left-bg #f) #:right-bg (right-bg #f) #:fragment? (fragment? #f))
  (tr
   (th* name)
   (td
    width: td-width (when left-bg bgcolor:) (when left-bg left-bg)
    (spacing left))
   (if right
       (td
        width: td-width bgcolor: right-bg
        (when fragment? class:) (when fragment? 'fragment)
        (when fragment? data-fragment-index:) (when fragment? 1)
        (spacing right))
       (td width: td-width))))


;;;; START OF THE SLIDES
(slide () @h1{Binding Blockchains Together}@h1{with Accountability}@h1{through Computability Logic}
  ~
  ~
  @p{François-René Rideau, @em{Legicash}}
  ~
  ~
  @p{LambdaConf 2018, 2018-06-05}
  @url{http://gitlab.com/legicash/bbtwatcl})

(slide-group "Introduction"
(gslide () @h1{The Take Home Points}
 ~
 @L{Take "Consensus as Court" Seriously} @comment{It's a productive story}
 ~
 @L{Solve Scaling, Interoperability, dApps}
 ~
 @L{Contracts are to @em{not} evaluate code on the blockchain}
 ~
 @L{Contract languages are @em{way} too low-level — use Formal Methods}
 @comment{
   Even FP contract languages are way too low-level.
   On the other hands, Formal Methods are still kind of FP, but on steroids, at a higher level.
 })

(gslide () @h1{Advancement Status}
 ~
 @L{This talk: only a BIG PICTURE}
 ~
 @L{Active development: now 3 full-time developers} @comment{It's not vaporware.}
 ~
 @L{Current status: Mock of a Mock on Ethereum}
 ~
 @L{SHOW ME THE CODE!}
 @L{@url{https://gitlab.com/legicash/legicash-facts}})

;;;);; Introduction
;;;(slide-group "Motivation"

(gslide () @h1{First Problem: Scaling Issue}
 @comment{Here's one kind of problem we're trying to solve}
 ~
 @L{Throughput: 7 tps for BTC, 15 for ETH}
 ~
 @L{Latency: 60 minutes for BTC, 30 for ETH}
 ~
 @L{Too little, too slow for casual payments!}
 ~
 @L{Gas, groceries, drinks, meals, etc.}
 @comment{flowers when you're late for mommy's birthday})

(gslide () @h1{Usual solution?}
 ~
 @comment{
   Fiat currencies used to have a similar issue, in that
   it used to take weeks or months for checks to clear.
   But nowadays, people don't use checks anymore, they use payment cards,
   which can confirm payment in a few seconds...
   even though it may still take months for funds to clear in the backend.
 }
 @L{Fiat currencies: fast payment via payment cards.}
 ~
 @L{Why can't we have payment card equivalent for cryptocurrency?}
 ~
 @L{Fiat "solutions" are centralized...}
 ~
 @fragment{@L{
   Real issue: not their being @em{centralized}, but @em{custodial}.
 }})

);;Movitation

(slide-group "Consensus as Court" ;; Back to First Principles
(gslide () @h1{What is a distributed consensus for?}
 ~
 @L{If everyone is honest and competent, a signed check is gold.}
 ~
 @L{You could re-endorse it eternally and never clear it.}
 ~
 @L{The Consensus is to prevent and resolve disputes.}
 ~
 @L{It is analogous to a @em{Court} — Necessarily slow and expensive.}
 @comment{
   They involve making public pronouncements that are unequivocally recognized
   by everyone all around the globe.
 })

(gslide () @h1{Don't go to Court for Casual Payment}
 ~
 @L{Court: yes to buy a house, a car.}
 ~
 @L{Court: not to buy coffee.}
 ~
 @L{Make casual payments with payment processors: that scales!}
 ~
 @L{Only go to Court if to prevent and resolve disputes.})

(gslide () @h1{Analogy between Consensus & Court}
 ~
 @L{Analogy: one Abstraction applied twice...}
 ~
 @L{Break down: ... to different parameters.}
 ~
 ~
 @L{Common Abstraction: Adjudication}
 ~
 @L{Different Parameters: Humans vs Machines}
 @comment{
   Of course, neither is a substitute for the other.
   That ought to be obvious, but apparently isn't,
   so it is important to mention it.
 })

(gslide () @h1{Analogy between Consensus & Court}
 (letrec ((td* (lambda (x) (td (color x #:fg *white*))))
          (line (lambda (name human smart)
                  (list (th* name) (td* human) (td* smart))))
          (lines (lambda (titles . xss)
                   (apply table align: 'right width: "100%"
                    (tr (map th* titles))
                    (map (lambda (xs) (apply tr (apply line xs))) xss)))))
   (apply lines
          '(("" "human law" "smart law")
            ("participants" "humans" "machines")
            ("enforcement" "social" "algorithmic")
            ("arbiter" "judge" "consensus")
            ("register" "court clerk, etc." "account table, utxos")
            ("interpretation" "flexible" "rigid")
            ("outcome" "uncertain" "certain (*)"))))
 @comment{(*) certain within operating parameters})

(gslide () @h1{What Law @em{CANNOT} do}
 ~
 @L{@q{Why don't we just make X illegal?}}
 ~
 @L{You can't decree bad behavior away.}
 ~
 @L{Murder is illegal, yet it still happens.}
 ~
 @L{Law can never prevent anyone from ever doing anything.})

(gslide () @h1{What Law @em{CAN} do}
 ~
 @L{It can only hold them accountable for what they do.}
 ~
 @L{Provide @em{incentives}. Game Theory}
 ~
 @L{Skin in the game.}
 ~
 @L{Human Law: get caught. Crypto Law: must deposit collateral.})

(gslide () @h1{Economic Analysis of Law}
 ~
 @L{Branch of Economics.}
 ~
 @L{Study how Law affects incentives of all participants.}
 ~
 @L{Consequences, not intentions.}
 ~
 @L{Applies to lawmakers, too (Public Choice Theory)})

(gslide () @h1{Kinds of Freedom: Voice, Exit, Enter}
 ~
 @L{No Voice: Just shut up and obey.}
 ~
 @L{Voice: Say whatever you want. (But: See if I care.)}
 ~
 @L{Exit: Repudiate bad service providers. (But: Who else?)}
 ~
 @L{Enter: Found a new competitor.})

(gslide () @h1{Aligning interests}
 ~
 @L{No Voice: Oppression. Destroys alignment.}
 ~
 @L{Voice: Coordination. @em{Assumes} alignment, @em{consumes} it.}
 ~
 @L{Exit: Allows alignment, but limited within Oligopoly.}
 ~
 @L{Enter: Create alignment, via Free Competition.})

(gslide () @h1{Aligning interests of Payment Processors}
 ~
 @L{On a blockchain, limited Voice, but unlimited Exit and Enter.}
 ~
 @L{Keep payment processors honest via Exit and Enter.}
 ~
 @L{Exit: Repudiation, on chain, or @em{en masse} to another processor!}
 ~
 @L{Enter: Anyone can cook.})

(gslide () @h1{Consensus as Court}
 ~
 @L{Fruitful Point of View}
 ~
 @L{Consensus provides arbitration, not transactions}
 ~
 @L{Fast Transactions on a side-chain}
 ~
 @L{Go to consensus only to resolve disputes})

); Consensus as Court (Back to First Principles)

(slide-group "Smart Contracts for Side-Chains"
(gslide () @h1{First good news! Solving Scaling}
 ~
 @L{Non-publication is infinitely faster than publication.}
 @comment{
   In the time you publish one transaction,
   I can "not publish" one billion trillion bajillion transactions.
 }
 ~
 @L{Publish title registration, in large batches.}
 ~
 @L{Publish law suits — few and far between thanks to good incentives}
 ~
 @L{Do @em{not} publish transactions on the main chain — WIN!})

(gslide () @h1{Non publication is for contracts, too!}
 ~
 @L{Publish contract with salted hashes of the clauses (Bitcoin MAST).}
 ~
 @L{Fulfill all obligations, then settle contract.}
 ~
 @L{Only if one party fails, reveal one clause to get compensation.}
 ~
 @L{Smaller, Cheaper, Faster, More Private.}
 @comment{})

(gslide () @h1{What are contracts for?}
 ~
 @L{Mechanism to create alignment of interests.}
 @comment{
   Toward a common activity, when these interests would otherwise be antagonistic.
 }
 ~
 @L{Plan A: @em{Never} going to Court.}
 @comment{Having the judge decide is plan Z.}
 ~
 @L{Contracts are @em{not} for "evaluating code on the blockchain"}
 @comment{Evaluating code on the blockchain is extremely slow and expensive,
   literally billions of times more so than doing it on a regular computer.
   That's never a good first choice.
 }
 ~
 @L{Do all the work in side-chains.}
 @comment{Stay off the main chain.})

(gslide () @h1{What do contracts consist in?}
 ~
 @L{Mutual obligations.}
 ~
 @L{A series of clauses.}
 ~
 @L{In each clause, a participant makes a promise.}
 ~
 @L{If they break their promise, a sanction punishes them.}
 @comment{})

(gslide () @h1{Example Contract: Atomic Swap}
 ~
 @L{Exchange $1000 worth between Monero and Zcash.}
 @comment{But neither of us wants to be first to send.}
 ~
 @L{Sign Ethereum contract each¹ posting a bond worth $4000.}
 @comment{
   I will promise to pay you $1000 worth of Bitcoin, or I'll lose a $4000 worth stake in Ethereum.
   You will promise to pay me $1000 worth of Zcash, or you'll lose a $4000 worth stake in Ethereum.
 }
 @comment{Actually, only the one who will pay second needs to be bonded}
 @comment{Bound parties are strongly interested in doing their part.}
 ~
 @L{Settlement is slow, but the contract is binding as soon as confirmed.}
 ~
 @L{Beware DDoS: hide behind Tor, have backup route.}
 @comment{})

(gslide () @h1{Second Good News! Solving Interoperability}
 @comment{And that's what I mean by "Binding Blockchains Together"}
 ~
 @L{No trust needed, only well-written software.}
 @comment{
   In the end, if we both use competently written software,
   we will be able to complete the trade, even though we don't trust each other.
 }
 ~
 @L{Neither currency swapped needs support contracts!}
 @comment{
   As long as short term parameters for the Proof-of-Work or Proof-of-Stake algorithm
   for each chain can be modelled in the chain in which the contracts are signed.
 }
 ~
 @L{The two currency swapped need not share cryptographic primitives.}
 @comment{
   Once again, the chain with the contracts needs support the other ones,
   but they need not support each other.

   Another very different way to bridge cryptographic primitives in some cases
   could be to use zk-SNARK to show that some precursor on one chain corresponds
   to another precursor on the other chain.
 }
 ~
 @L{@q{Free option} problem? Use matching facilitator.}
 @comment{
   Problem intrinsic to all smart contracts:
   The last one to sign always has the option not to sign.
   There are various alternatives in incentive design.
 })

(gslide () @h1{What about that large stake?}
 ~
 @L{Full bond needed to ensure complete transaction.}
 ~
 @L{Partial bond enough to ensure balanced exchange.}
 ~
 @L{Use Lightning Network style payment channels.}
 ~
 @L{Exchange $1000 at a time, repeat a thousand times.}
 @comment{
 })
);; Smart Contracts

(slide-group "A Logic for Smart Contract"
(gslide () @h1{Logic? What Logic?}
 ~
 @L{Law: verifying compliance, punishing non-compliance}
 ~
 @L{Smart: term of art for "Algorithmic"} ;; Initially buzzword bingo
 ~
 @L{Smart Law: compliance with algorithmically verifiable rules}
 ~
 @L{Computational Logic — but @em{what} logic?}
 @comment{
 })

(gslide () @h1{What is a legal argument?}
 ~
 @L{Two parties disagree about a claim.}
 ~
 @L{Each party argues it case.}
 ~
 @L{At the end, the judge finds who's right.}
 ~
 @L{It's an @em{Interactive proof}.}
 @comment{})

(gslide () @h1{What is an interactive proof?}
 @L{Let's argue: "All sheep are the same color as mine" (in CO)}
 @fragment[#:index 1]{@C{@em{∃x   ∀y      P(x,y)}}}
 @fragment[#:index 2]{@C{@em{vs}}
 @C{@em{∀x   ∃y   ¬P(x,y)}}}
 ~
 @fragment[#:index 3]{@L{Brute force: show half a million sheep to the judge.}}
 @comment{
   How can we argue in front of a judge whose time is very expensive?
   We could exhibit all the sheep one after the other in front of the court.
   It would take a lot of time to exhibit half a million sheep while following all legal procedures,
   and would cost a fortune to complete,
   assuming the judge doesn't quickly fall asleep, doesn't die of boredom,
   and doesn't die of old age either
   --- before we're done.
 }
 ~
 @fragment[#:index 4]{@L{Interaction: I exhibit my witness @em{x0}, you exhibit yours @em{y1}}}
 @comment{
   Another solution is to find two honest lawyers who will each
   honestly and capably argue their case the best possible way.
   If I argue that all sheep in Colorado are white,
   the judge will ask my lawyer to produce a sheep, and the sheep has better be white;
   this establishes existence.

   To prove universality, I cannot afford to show all the other sheep to the judge,
   or even a large fraction.
   But I can challenge you to show a sheep of a different color.
 }
 @fragment[#:index 5]{
   @L{Each witness removes a quantifier.}
   @L{The judge evaluates a closed formula.}}
 @comment{
   Interestingly, they are called witnesses in formal logic as well as in law.

   And of course, interactive proofs are not just for sheep.
   I can argue that the latest entry for my account on the blockchain has ETH 1000, that you owe me.
   You now have to either show a more recent entry for my account with less than that, or you owe me.
   The formula for the latest entry is that there exists an entry such that for all entries,
   the second entry is earlier than the former.
 })

(gslide () @h1{Game Semantics}
 ~
 @L{Translate any formula into a game.}
 ~
 @L{@em{If} the formula is decidable, then good guys have a winning strategy.}
 ~
 @L{If all quantifiers are over known finite data structure, good guys win.}
 ~
 @L{What is the logic built on Game Semantics?}
 @comment{})

(gslide () @h1{Computability Logic}
 ~
 @L{Game Semantics first, syntax second.}
 ~
 @L{Contains fragment of Classical, Intuitionnistic and Linear logic.}
 ~
 @L{Define your own logic operators in terms of games to play.}
 ~
 @L{Add fragments for Blockchain: epistemic, temporal... logic.}
 @comment{
   Propositional Logic + Quantification over large data structures
   Resource Conservation: Linear Logic
   Conservation through Time & Timeouts: Temporal Logic
   Ownership: Epistemic Logic
   Third party litigation: Multi-player games!
})

(gslide () @h1{Higher-Level View of Smart Contracts}
 ~
 @L{A contract (logical specification) is a small piece of a dApp.}
 ~
 @L{A lawsuit (interactive proof) is a small piece of a contract.}
 ~
 @L{An contract invocation (interaction step) is a small piece of a lawsuit.}
 ~
 @L{A "contract VM" operation is a small piece of a contract invocation.}
 @comment{})

(gslide () @h1{Programming using Logic}
 @p{
   @br[]
   @cite{A programming language is low level when its programs @br[] require attention to the irrelevant.}
   — Alan Perlis
 }
 ~
 @L{Contract invocation, even with FP, is @em{way} too low-level.}
 ~
 @L{Program in terms of logical invariants and variants @em{of your dApp}.}
 ~
 @L{Use a DSL based on the appropriate logic: Computability Logic.}
 ~
 @comment{})

(gslide () @h1{What Low-level VM for Contracts?}
 ~
 @L{Of course use Functional Programming — Logic made computable.}
 ~
 @L{Verification, not computation: no unbounded recursion.}
 @comment{No "Turing-equivalence" needed. Bitcoiners will be happy.}
 ~
 @L{All cryptographic primitives of all blockchains to contract about.}
 ~
 @L{Access to blockchain (and other?) data via "oracles".}
 @comment{})

(gslide () @h1{How to minimize interaction steps?}
 @L{Number of steps: sum/product alternations, dichotomies}
 @comment{
   Quantifiers are for general dependent sums and products,
   but regular sums of constructors or products of terms are a special case.
   Beware of unary representations, such as naïve blockchain
 }
 ~
 @L{Minimize steps: Skolemization.}
 @C{@em{∀x:X  ∃y:Y  P(x,y)     ⇔     ∃f:X→Y  ∀x:X  P(x,f(x))}}
 @L{Group all the ∃ to the left. All proofs in two steps max!}
 ~
 @L{In practice: publish a detailed indexed trace of the computation.}
 @L{Expensive, but paid for by the bad guy.}
 @L{Trade-off between space and time.}
 @comment{
   If the full index can be too expensive, keep it four steps, or six, etc.

   (Beware though that proofs in more than two steps require third-party litigation.)
 })

(gslide () @h1{Third Party Litigation}
 ~
 @L{What if Alice and Trent collude to defraud Bob & other users?}
 ~
 @L{Alice (Sybil attacker): "Gimme one million dollars!"}
 @L{Trent (dishonest contract manager): "You're right, I concede."}
 @L{Bob (contract user): "Hey, there's no money left in the contract!"}
 ~
 @L{Solution: Bob (or anyone) can offer a better argument than Trent's}
 @comment{
   Alice gets thrown out of court, Trent loses his license,
   Bob gets rewarded based on court fees, etc.
   Of course, to avoid double jeopardy (and double-spending of damages),
   only the first successful counter-claimant wins.

   Unlike Human law, no verifiable notion of "having standing/interest in the case"
   All identities are pseudonymous, anyway.
 })

(gslide () @h1{Why Formal methods?}
 ~
 @L{Solutions: obvious with the right POV, unconceivable without.}
 @comment{
   You might not even see the issue without Formal Methods.
 }
 ~
 @L{Many moving parts. The least discrepancy and the edifice crumbles.}
 ~
 @L{Most parts can be fixed after deployment. Contracts cannot.}
 ~
 @L{If the greatest specialist lose 300M$ to a mistake in 400 loc...}
 @comment{})

(gslide () @h1{Moving parts that need be consistent}
 @L{Logical specification.}
 ~
 @L{Actual client and server code.}
 ~
 @L{Contract to hold people accountable.}
 ~
 @L{On-chain lawyer strategies to invoke the contract.}
 ~
 @L{Off-chain lawyer strategy to watch others and advise user.}
 @comment{
   Watch activity on the chain,
   take correct steps,
   stop users from making mistakes,
   explain what's happening to users.
 }
 ~
 @L{Generate tests}
 @comment{
 })

(gslide () @h1{Solution: Extract Everything from a Same Spec}
 ~
 @L{Ensure all parts are in synch with each other:}
 ~
 @L{Generate everything from a single specification}
 ~
 @L{Reason about the specification}
 ~
 @L{Reason about the generators}
 @comment{})
); A Logic for Smart Contracts

(slide-group "The Court Registry"
(gslide () @h1{The Need for Shared Knowledge}
 ~
 @L{Black sheep hidden in hangar.}
 ~
 @L{Winning strategy requires truth + knowledge.}
 @L{Good Guy Wins requires @em{Shared Knowledge}.}
 ~
 @L{@em{Closed contract}: Shared Knowledge easy, but no Scaling.}
 @L{@em{Open contract}: Scaling easy, but no Shared Knowledge. Solution???}
 @comment{})

(gslide () @h1{Court Registry}
 ~
 @L{"Oracle" for public data availability.}
 ~
 @L{Allows for third-party verification of all transactions.}
 ~
 @L{Solution to "Block Withholding Attack" (see Plasma)}
 ~
 @L{Preimage not enough: Must transitively validate against schema.}
 @comment{Against data schema})

(gslide () @h1{Court Registry Issues}
 ~
 @L{50% attack. Consider quorum @em{q} of underwriting registrars.}
 @L{If @em{q} collude: block withholding. If @em{1-q} collude, registration denial.}
 ~
 @L{"Oracle": Closed (oligopoly), or Open (bribing is legal!)}
 @comment{
   Open Oracle == "TCR", Token-Curated Registry.
   Our current solution: closed for now, repudiate as soon as fishy.
 }
 ~
 @L{Ideally, register on the main chain — but can it already scale?})

(gslide () @h1{Shared Knowledge vs Common Knowledge}
 ~
 @L{Concepts from @em{Epistemic Logic}}
 ~
 @L{Shared Knowledge: what @em{everybody knows}}
 @L{Gossip Network. Detects double-spending. Prevents Triple-spending.}
 ~
 @L{Common Knowledge: what @em{everybody knows that everybody knows…}}
 @L{Consensus. Resolves double-spending. Much more expensive to achieve.}
 @comment{
   Shared Knowledge can serve as a precursor to Common Knowledge.
   Obviously it is strictly less powerful than Common Knowledge, and much cheaper to achieve:
   it requires no synchronization between the participants and can be reasonably achieved in seconds.
   Meanwhile Common Knowledge takes tens of minutes to achieve with current technology.
   (Even though Hashgraph claims it can achieve Common Knowledge in a matter of seconds
   using gossip-on-gossip, though it's unclear how well this result applies
   to an open adversarial network.)
   Keeping the trace always beats just doing the thing. Optimal by construction.
 }
 ~
 @comment{
 })

(gslide () @h1{Repudiable Facilitators}
 ~
 @L{Managers for Open Contracts.}
 ~
 @L{Everyone can verify integrity, denounce fraud (Voice)}
 @L{Repudiable / Non-custodial (Exit)}
 @L{Anyone can open a rival side-chain (Enter)}
 @L{Bonded so they can't profitably cheat (Skin in the Game)}
 @L{Can only do the Right Thing. At worst: fail to advance.}
 ~
 @L{Double as mutual verifiers. Maybe part of Court Registry.}
 @comment{})

(gslide () @h1{Fast Payment via Repudiable Facilitators}
 ~
 @L{Can Solve Fast Payment at Scale: locally centralized.}
 ~
 @L{Only Floating is unsafe (Limited Damages, Insurable)}
 ~
 @L{Bond >> Floating (Interests Aligned)}
 ~
 @L{Merchant chooses whom to trust. Fallback to slow payment.}
 @comment{})

(gslide () @h1{Beyond Fast Payment}
 ~
 @L{dApps that extend Fast Payment: non-custodial exchange…}
 ~
 @L{Anonymous rather than fast: Zcash-on-Ethereum…}
 ~
 @L{Future: Develop arbitrary dApps with Computability Logic.}
 ~
 @L{(Computability) Logic is not just for cryptocurrency dApps…}
 @comment{})

); Court Registry
#| MAKE SLIDES


(gslide () @h1{TITLE}
 ~
 @L{X1}
 ~
 @L{X2}
 ~
 @L{X3}
 ~
 @L{X4}
 @comment{})

------>8------>8------>8------>8------>8------>8------>8------>8------>8------

 (gslide () @h1{What we want}
  @CB{Fast yet Secure Transactions}
  @CB{Atomic Swap without Trusted Third Party}
  @CB{Decentralized Exchange}
  @CB{Safe Arbitrary User-defined Side-Chains})

 (gslide () @h1{How we get there}
  @CB{Back to Principles: Consensus as a Court of Law}
  @CB{Smart Legal Arguments: Game Semantics}
  @CB{Smart Law: Computability Logic}
  @CB{The Holy Grail: Bind Blockchains Together})

  (gslide () @h1{Smart means Automated}))

(slide-group "Back to Principles: Consensus as a Court of Law"
 (gslide () @h1{Consensus as Court})
 (gslide () @h1{Accountability via Exit})
 (gslide () @h1{Micro-Accountability via Bonds})
 (gslide () @h1{Side-Chain Accountability via Repudiability})
 (gslide () @h1{Main-Chain Accountability via Forking}))

(slide-group "Smart Legal Arguments: Game Semantics"
 (gslide () @h1{Smart Legal Argument as Verification Game})
 (gslide () @h1{Good Contracts do NOT go to Court})
 (gslide () @h1{Notaries })
 (gslide () @h1{Micro-Accountability via Bonds})
 (gslide () @h1{Side-Chain Accountability via Repudiability})
 (gslide () @h1{Main-Chain Accountability via Forking}))

The Essential Duty of a Notary
it is of vital importance to the system that no data is made part of the Consensus unless all data relevant to smart law that is transitively reachable from it by the following digests in a content-addressed store is itself shared knowledge.
Prior technology sadly offers no way to safely delegate checks that something is shared knowledge before it is validated as suitable to include in the Consensus.
Binding Two Chains Together
Contract Logic
The surface logic in which the laws and contracts are specified, in addition to those primitives, contain logical quantifiers, connectors and modes as per computability logic, including linear logic, temporal logic, etc.
Response Window
The total number of interactions required in a smart legal procedure is bounded by the number of alternations of nested logical quantifiers in the formula being argued.
Third-party litigation
third parties may litigate to enforce contracts and laws they are not directly interested in.
Loss of License
Blockchain Upgrade
changes to the semantic of a blockchain should only take effect after a sufficient delay.
the solution to having long-term contracts that bind two complex evolving blockchains involves having each chain maintain and publish on itself a complete reflective logical description of the chain’s logic in its own logic.
Managing Forks

|#

(slide-group "Conclusion"
(gslide () @h1{The Take Home Points (redux)}
 ~
 @L{Take "Consensus as Court" Seriously} @comment{It's a productive story}
 ~
 @L{Solve Scaling, Interoperability, dApps}
 ~
 @L{Contracts are to @em{not} evaluate code on the blockchain}
 ~
 @L{Contract languages are @em{way} too low-level — use Formal Methods}
 @comment{
   Even FP contract languages are way too low-level.
   On the other hands, Formal Methods are still kind of FP, but on steroids, at a higher level.
 })

(gslide () @h1{The Meta-Story}
 ~
 @L{Seek the essence of a problem, stripped from incidentals.}
 ~
 @L{Demand the ability to reason logically, for machines and humans.}
 ~
 @L{Maintain structural correspondance between computation and logic.}
 ~
 @L{… That's the essence of Functional Programming / Category Theory!}
 @comment{
   When you go to the essence, make it explicit, and strip everything else...
   You've got the approach of Category Theory,
   which is what is good about Functional Programming
 }
 ;; ~ @p[class: 'fragment]{Any question?}
 ))

(output-xml
 @html{
   @head{
     @link[rel: 'stylesheet href: "resources/my.css"]
     @link[rel: 'stylesheet href: @reveal-url{css/reveal.css}]
     @link[rel: 'stylesheet href: @reveal-url{css/theme/black.css}]
     @link[rel: 'stylesheet href: @reveal-url{lib/css/zenburn.css}]
     @link[rel: 'stylesheet href: "resources/my.css"]
   }
   @body{
     @div[class: 'reveal]{@div[class: 'slides]{@get-sections}}
     @script[src: @reveal-url{lib/js/head.min.js}]
     @script[src: @reveal-url{js/reveal.min.js}]
     @script/inline{
       Reveal.initialize({
         dependencies: [
           {src: "@reveal-url{plugin/highlight/highlight.js}",
            async: true, callback: () => hljs.initHighlightingOnLoad()}],
         controls: false
       });
     }}})

#|
cut as much of the introduction as possible

Joseph Poon's talk at Deconomy 2018: "Consensus and Cryptoeconomic Incentive Mechanisms" https://youtu.be/nZKdy7kZGBc

Bigger emphasis on logic & formal methods --- prune more social
Have a concrete example.
Example for Skolemization.
|#
