#lang at-exp racket @; -*- Scheme -*-
#|
;; Alacris: Language Abstraction for [V]erifiable Blockchain Distributed Applications
;; IOHK Summit, April 18th 2019
;;

;; To compile it, use:
;;    racket lavbda.rkt > lavbda.html

;; This document is available under the bugroff license.
;;    http://tunes.org/legalese/bugroff.html

;; Abstract Abstract: Alacris chief architect François-René Rideau discusses the operating system's
;; domain specific language for developing distributed apps that can be automatically verified to
;; protect their assets against known attack techniques, and used to specify multi-party protocols
;; to be run on clients and servers as well as smart contracts.

;; Abstract: It is extremely hard to build non-trivial Blockchain Distributed Applications (DApps)
;; that can hope to remain secure when protecting large assets against dedicated attackers.
;; The Alacris Operating System is growing a Domain Specific Language (DSL) to enable development
;; of DApps that can be automatically formally verified to run correctly even when faced with
;; adversarial behavior. More than libraries on a general purpose language, the DSL can enforce
;; global program invariants. More than a smart contract language, the DSL specifies a multiparty
;; protocol, from which all code can be extracted, correctly, that will run on clients and servers
;; as well as in blockchain smart contracts. The DApp compilation strategies can be ported to all
;; blockchains and may address interoperability, scalability and privacy.
|#

(require scribble/html "reveal.rkt")

(define *white* "#ffffff")
(define *gray* "#7f7f7f")
(define *blue* "#0000ff")
(define *light-blue* "#b4b4ff")
(define *red* "#ff0000")
(define *light-red* "#ffb4b4")
(define *green* "#00ff00")
(define *light-green* "#b4ffb4")

(define orig-th th)
(define orig-td td)

(define (xth . x) (apply th fgcolor: *green* bgcolor: *light-blue* x))
(define (xtd . x) (apply td fgcolor: *green* bgcolor: *light-red* x))
(define (td+ . x) (apply td fgcolor: *green* bgcolor: *light-green* x))
(define (td- . x) (apply td fgcolor: *green* bgcolor: *light-red* x))
(define (td= . x) (apply td fgcolor: *green* bgcolor: *light-blue* x))

(define (d (repetitions 1)) (make-string repetitions #\u202F)) ; U+202F NARROW NO-BREAK SPACE > <

(slide ()
  @table[(tr(td width: "33%")(td (div fgcolor: *red*
  @b{@(d 3)@(d)𝕃@(d)anguage @(br)
     @(d 3)@(d)𝔸@(d)bstraction for @(br)
     ⟦𝕍⟧@(d)erifiable @(br)
     @(d 4)𝔹@(d 2)lockchain @(br)
     @(d 4)𝔻@(d 2)istributed @(br)
     @(d 4)𝔸@(d)pplications}))(td width: "33%"))]
  ~
  @p{François-René Rideau, @em{Alacris}}
  @C{fare@"@"alacris.io}
  ~
  @p{IOHK Summit, 2019-04-11}
  @url{https://alacris.io/}) ;; lavbda.alacris.io

(slide-group "Introduction"
(gslide () @h1{Why No DApps? a Vicious Circle}
 ~
 (let-values (((x y z t) (values "No apps" "No users" "No money" "No tech")))
   (let ((td (lambda x (apply td style: "align: center; border: none;" x))))
     (table class: "noborder" id: "noborder"
      (tr (td)   (td)      (td x) (td)      (td))
      (tr (td)   (td "⬈") (td)   (td "⬊") (td))
      (tr (td t) (td)      (td)   (td)      (td y))
      (tr (td)   (td "⬉") (td)   (td "⬋") (td))
      (tr (td)   (td)      (td z) (td)      (td)))))
 ~
 @fragment{That's a bootstrap issue!})

(gslide () @h1{What Missing Tech?}
 ~
 @p{Scalability}
 @p{Usability}
 @p{Portability}
 @p{Interoperability}
 ~
 @h3{Security}
 @comment{})

(gslide () @h1{Why is Security so Hard?}
 @L{All code is fragile.}
 @L{The Internet is hostile.}
 @L{Mistakes are irreversible.}
 ~
 @L{The "bug budget" is zero.}
 @L{The stakes are very high.}
 @comment{Parity Wallet: 400 lines, one bug, 280 M$ disappeared!}
 @L{Usual languages, tools and methodologies don't even try.}
 @comment{
In Blockchain software, your "bug budget" is zero. Common software development languages, tools and methodologies don't even try to reach this level of quality, and fall way short if used.Blockchain is Dijkstra's paradise, where mathematically rigorous correctness is paramount.
Blockchain is Dijkstra's Paradise})

(gslide () @h1{How Do Common Approaches Fall Short?}
 @L{No automated reasoning, no static guarantees}
 @L{Fragility: even correct today, bitrotten tomorrow}
 ~
 @L{Libraries for existing languages}
 @L{Make Reasoning harder: more ways to shoot your own foot!}
 ~
 @L{No enforcement of global domain invariants}
 @L{Debugging at the wrong level of abstraction})

(gslide () @h1{A Solution for Blockchain Development?}
 @L{Solution: EWD's approach—use math, prove everything correct.}
 @L{Even incomplete, logic provides a ratchet vs known attacks.}
 ~
 @L{DSL: abstract over complexity, don't leak it.}
 @L{Make Reasoning easier: make errors unexpressible.}
 ~
 @L{Enforce domain-related invariants}
 @L{Debug the program in terms of revelant concepts})

 @L{Even posting a transaction reliably is surprisingly hard.}
 @L{Opposition: not accidental mistakes, but deliberate attacks.}
 ;;@L{Running a node is hard. Not running a node is risky.}
 ~
 @L{Need better languages to safely build applications.}
 @L{Need robust runtimes and libraries for basic services.})

#|
(gslide () @h1{Bonus Blockchain Problem: Privacy}
 @L{Account holders want identities and amounts hidden}
 @L{In a multiparty application, minimize information sharing}
 @comment{Where the OO slogan of "Information hiding" is actually meaningful}
 ~
 @L{Pseudonymity is not anonymity.}
 @L{Consensus is intrinsically public.}
 ~
 @L{Homomorphic Encryption. Onion Routing. MAST...}
 @L{A complete development platform must support many such tools.})


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
 @L{Pro: fast because centralized. Con: custodial, trusted third party.}
 ~
 @L{Why can't we have payment card equivalent for cryptocurrency?}
 @L{"Trusted Third Parties are security holes" — Nick Szabo}
 ~
 @L{Technical centralization with economic decentralization?}
 @L{Centralized acceptable, custodial bad.})

(gslide () @h1{Our Approach}
 ~
 @L{Back to Principle: What is a Blockchain?}
 @L{Find its essential logic, offer according tools}
 ~
 @L{Take the "smart contract" analogy seriously}
 @L{The consensus is a court system}
 ~
 @L{Write dApps using Logic}
 @L{Extract the computations from the Logic})

(gslide () @h1{Layer 1, 2, 3}
 ~
 @L{Layer 1: Consensus network}
 @L{Bitcoin, Ethereum…}
 ~
 @L{Layer 2: Smart Contracts on Layer 1}
 @L{Side-chains, state channels…}
 ~
 @L{Layer 3: Contracts on Layer 2}
 @L{More of the same, but at larger scale})

(gslide () @h1{Near Future: Layer 1 Commoditized}
 ~
 @L{Scalability and Interoperability will be solved}
 @L{Anyone can hold any coin, pay in any other coin in seconds}
 ~
 @L{Markets will drive all tokens down to cost of production}
 @L{No reason to hold onto lots of "utility tokens"}
 ~
 @L{Only a few actual cryptocurrencies will keep value}
 @L{Whichever they are, end of the speculation bubble})

(gslide () @h1{Layer 2 is where the value is}
 ~
 @L{The next big chunk value added will be in Layer 2}
 @L{Non-custodial exchanges, fast payment systems, contracts}
 ~
 @L{But dApps are very difficult to write}
 ~
 @L{We are building a Blockchain Layer 2 Operating System}
 @L{To be to Blockchain what Microsoft was to the PC Revolution})

);;Movitation

(slide-group "Consensus as Court" ;; Back to First Principles
(gslide () @h1{What is a distributed consensus for?}
 ~
 @L{@em{If} everyone is honest and competent, a signed check is gold.}
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
 @L{Make casual payments with payment processors: it scales!}
 ~
 @L{Only go to Court to prevent and resolve disputes.})

(gslide () @h1{Analogy between Consensus & Court}
 (simple-table
  '(("" "human law" "smart law")
    ("participants" "humans" "machines")
    ("enforcement" "social" "algorithmic")
    ("arbiter" "judge" "consensus")
    ("register" "court clerk, etc." "account table, utxos")
    ("interpretation" "flexible" "rigid")
    ("outcome" "uncertain" "certain (*)")))
 @comment{(*) certain within operating parameters})

(gslide () @h1{Analogies for Functional Programmers}
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
 @L{It can only hold actors accountable for what they do.}
 ~
 @L{Provide @em{incentives}. Game Theory}
 ~
 @L{Skin in the game.}
 ~
 @L{Human Law: can get caught. Smart Law: must deposit collateral.})

(gslide () @h1{Economic Analysis of Law}
 ~
 @L{Branch of Economics.}
 ~
 @L{Study how Law affects incentives of all participants.}
 ~
 @L{Consequences, not intentions.}
 ~
 @L{Applies to lawmakers, too (Public Choice Theory)})

(gslide () @h1{Kinds of Freedom vs Alignment of Interests}
 (simple-table
  `(("" "Allowed Individual Action" "Effect on Interests")
    ("None" "Just shut up & obey"
     "Generate Chaos, Oppose Interests")
    ("Voice" "Say whatever you want, Vote" ;; But: See if I care.
     "Create Coordination, Consumes Alignment")
    ("Exit" "Repudiate a bad provider" ;; But: Who else?
     , @div{Finds Alignment, @br[] Within Limited Choice})
    ("Enter" "Found a new competitor" "Create Alignment, Generate Order"))))

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
 @L{Do @em{not} publish transactions on the main chain — WIN!}
 ~
 @L{Non-publication is infinitely faster than publication.}
 @comment{
   In the time you publish one transaction,
   I can "not publish" one billion trillion bajillion transactions, even ℵ₄₂
 }
 ~
 @L{Publish title registration, in large batches.}
 ~
 @L{Publish law suits — few and far between thanks to good incentives})

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
   literally millions of times more so than doing it on a regular computer.
   That's never a good first choice.

   [Justification for million:
    You can rent a Cloud VM for about $10 per month. That's 3.8e-8 USD/s.
    You pay for on-chain computations at about 1 GAS per microsecond, at 555 USD/ETH and 10e-8 ETH per GAS,
    for 5.55 USD/s.
    https://docs.google.com/spreadsheets/d/1m89CVujrQe5LAFJ8-YAUCcNK950dUzMQPMJBxRtGCqs/edit#gid=0
    See also
    https://youtu.be/a-xHiI-G_CQ
   ]
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
 ;;; EMPHASIZE CROSS-CHAIN INTEROPERABILITY
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

;; NB: Time is short, so skip over that slide
(gslide () @h1{Swapping without a large stake}
 ~
 @L{Full bond needed to ensure complete transaction.}
 ~
 @L{Partial bond enough to ensure balanced exchange.}
 ~
 @L{Use Lightning Network style payment channels.}
 ~
 @L{Exchange $1000 at a time, repeat a thousand times.}
 @comment{
   You get a smaller guarantee, for a smaller bond.

   Social enforcement: whoever fails to complete their part
   will be kicked out of exchanges forever.
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
 @fragment[#:index 3]{@C{@em{vs}}
 @C{@em{∀x   ∃y   ¬P(x,y)}}}
 ~
 @fragment[#:index 2]{@L{Brute force: show half a million sheep to the judge.}}
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

(gslide () @h1{Issue: number of interaction steps}
 @L{Number of steps: alternations of ∃ vs ∀; dichotomies}
 @comment{
   Mind though that each time you challenge the other party,
   you have to give them ample enough time to respond; say two hours.
   This means that a formula with a lot of alternations between ∃ vs ∀
   (or non-dependent sums and products),
   say to do a dichotomy search or two, may take a week;
   a badly written specification with a thousand alternations
   may lead taking months to interactively argue a case.
   Unary representations, such as naïve blockchaining,
   are worst of all.
 }
 ~
 @comment{
   Happily, there are techniques to minimize the number of steps required
   to complete an interactive proof.
 }
 @L{Minimize steps: Skolemization.}
 @C{@em{∀x:X  ∃y:Y  P(x,y)     ⇔     ∃f:X→Y  ∀x:X  P(x,f(x))}}
 @L{Group all the ∃ to the left. All proofs in two steps max!}
 @comment{
   In the first case, the adversary challenges you with an X, and you reply with a Y.

   In the second case, you publish in advance a map associating to whichever potential challenge in X
   your response in Y, then you challenge the adversary with an X.

   Actually, publishing a map in advance also lets the adversary search the map for data,
   so he further doesn't have to go through a lengthy round of challenges and responses
   to search the map for content.

   On the other hand, data that is so well indexed as to be searchable for justifications
   and counter-justifications to an exit transaction could potentially be used
   to survive the lack of a court registry(?)

   Lambda-lifting? not really.
 }
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
 @L{If the greatest specialists lost 280M$ to a mistake in 400 loc...}
 @comment{})

(gslide () @h1{Moving parts that need be consistent}
 @L{- Logical specification.}
 @L{- Actual code for clients.}
 @L{- Actual code for servers.}
 @L{- Actual code for verifiers.}
 @L{- On-chain Contract to hold actors accountable.}
 @L{- On-chain lawyer strategies to invoke the contract.}
 @L{- Off-chain lawyer strategy to watch others and advise users.}
 @comment{
   Watch activity on the chain,
   take correct steps,
   stop users from making mistakes,
   explain what's happening to users.
 }
 @L{- Tests to convince bad guys not to try.}
 @comment{
   Proving it correct is necessary but not enough.
 })

(gslide () @h1{Solution: Extract Everything from a Same Spec}
 ~
 @L{Ensure all parts are in synch with each other:}
 @L{Generate everything from a single specification}
 ~
 @L{Present: run a multiparty distributed computation}
 @L{Past: check invariants of verifiable traces}
 @L{Future: reason about all possible future traces})

(gslide () @h1{Alternate Validation Backends}
 (small
 (table
  (tr
   @xth{}
   @xth[width: "25%"]{On-chain validation}
   @xth[width: "25%"]{Interactive Proof}
   @xth[width: "25%"]{Non-Interactive Proof})
  (tr
   @xth{Cost}
   @td-{Expensive}
   @td+{Cheap}
   @td-{Expensive})
  (tr
   @xth{Who pays}
   @td-{Everyone}
   @td+{Bad guy}
   @td-{Good guy})
  (tr
   @xth{Latency}
   @td+{milliseconds}
   @td-{hours}
   @td={seconds})
  (tr
   @xth{Quantifiers}
   @td+{∃ ∀}
   @td+{+ ∃ ∀}
   @td-{∃ only})
  (tr
   @xth{Privacy}
   @td-{Must be public}
   @td+{Can be private}
   @td+{Can be private})
  (tr
   @xth{Complexity}
   @td+{Done already}
   @td-{Lots of moving parts}
   @td={Few complex parts}))))

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
 @L{WE HAVE THE SAME ISSUES AS EVERYONE ELSE}
 ~
 @L{50% attack. Consider quorum @em{q} of underwriting registrars.}
 @L{If @em{q} collude: block withholding. If @em{1-q} collude, registration denial.}
 ~
 @L{"Oracle" dilemma: Closed (oligopoly), or Open (bribing is legal!)}
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
 @L{Consensus. Resolves double-spending. Much more expensive.}
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
 @L{Double as mutual verifiers. May be part of Court Registry.}
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

(slide-group "Conclusion"
(gslide () @h1{The Take Home Points (redux)}
 ~
 @L{Building secure DApps is extremely hard,}
 @L{a DSL makes it tractable.}
 ~
 @L{Automatic Cascading Verification of correctness,}
 @L{from DSL down to bit-bashing, composing full abstractions.}
 ~
 @L{Blockchain-Agnostic Model: Consensus-as-Court}
 @L{brings portability, interoperability, scalability.})

#|
(gslide () @h1{The Meta-Story}
 ~
 @L{Match the structure of the computation to that of the logic.}
 ~
 @L{… That's the essence of XXX}
 @comment{
 }
 ;; ~ @p[class: 'fragment]{Any question?}
 )
|#
(gslide () @h1{Contact}
 ~
 @L{I NEED MORE INFO!   Medium @url{https://medium.com/alacris}}
 ~
 @L{TAKE MY MONEY!   Our website @url{https://alacris.io/}}
 ~
 @L{I WANT TO HELP!   Telegram @url{https://t.me/alacrisio}}
 ~
 @L{SHOW ME THE CODE!   @url{https://github.com/AlacrisIO/}}))


#|

Blockchain Upgrade
changes to the semantic of a blockchain should only take effect after a sufficient delay.
the solution to having long-term contracts that bind two complex evolving blockchains involves
having each chain maintain and publish on itself a complete reflective logical description
of the chain’s logic in its own logic.

Managing Forks

|#

(reveal)

#|

The Alacris Operating System is growing a Domain Specific Language (DSL) to specify Blockchain DApps that can be Formally Verified to be correct.

Why a DSL?
Libraries for existing languages offer more ways to shoot oneself in the foot—verification is harder! A DSL can automatically enforce restrictions and verify program invariants with Z3.

A DApp is much more than a smart contract. From a single DSL specification, we extract all code running on clients and servers as well as smart contracts using End-Point Projection.

A DSL enables Automatic Cascading Verification of the entire semantic tower, with full abstraction, from user specification down to bit bashing. Prove your modular extensions correct in Coq.

A DSL abstracts over multiple backends, offers portability, interoperability across blockchains.


Correctness Properties to Automatically Verify:
User-defined protocol invariants.
Linear Resources, Access Control, Time Bounds.
Game-Theoretic Liveness: progress if all actors honest.
Game-Theoretic Safety: no loss to bad actors.

Verification techniques:
Type theory, theorem proving, model checking, strand spaces, dynamical system simulation, and composable
implementation layers through category theory.

Blockchain-Agnostic Model: Consensus-as-Court
Specify smart contract clauses as logical formulas.
Game Semantics: Good guy has winning strategy.
Bad guy loses, pays damages and fees out of bond.
⚠ All evidence must be Mutual Knowledge (MK).
Scale with general purpose MK validator network.
Option: zkproofs for privacy, non-interactive validation.
|#
|#

