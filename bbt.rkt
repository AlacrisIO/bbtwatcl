#lang at-exp racket @; -*- Scheme -*-
#|
;; Binding Blockchains Together with Accountability through Computability Logic
;; LambdaConf 2018, June 5th 2018
;; https://lambdaconf2018.dryfta.com/en/program-schedule/program/64/binding-blockchains-together-with-accountability-through-computability-logic
;; Based on a presentation given at the MIT Blockchain Club 2018-02-20

;; To compile it, use:
;;    racket bbt.rkt > bbt.html

;; This document is available under the bugroff license.
;;    http://www.oocities.org/soho/cafe/5947/bugroff.html


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

(require scribble/html "reveal.rkt")

(slide () @h1{Binding Blockchains Together}@h1{with Accountability}@h1{through Computability Logic}
  ~
  ~
  @p{François-René Rideau, @em{Legicash}}
  @C{fare@"@"legi.cash}
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
 @L{@em{Legicash}: now 3 full-time developers} @comment{It's not vaporware.}
 ~
 @L{Current status: Mock on Ethereum}
 ~
 @L{SHOW ME THE CODE!   @url{https://j.mp/LegicashCodeReleasePreview}})

;;;);; Introduction
;;;(slide-group "Motivation"

(gslide () @h1{First Problem: Scaling Issue}
 @comment{Here's one kind of problem we're trying to solve}
 ~
 @L{Throughput: 7 tps for BTC, 15 for ETH (vs > 2000 tps for CC)}
 ;; TODO: identify the max transaction throughput of credit card processors.
 ~
 @L{Latency: 60 min for BTC, 30 for ETH (vs 7 s for CC)}
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
   I can "not publish" one billion trillion bajillion transactions.
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
 @L{If the greatest specialist lose 300M$ to a mistake in 400 loc...}
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
 @L{WE SAME ISSUES AS EVERYONE ELSE}
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
 @L{Given a problem, seek its essence, stripped from incidentals.}
 ~
 @L{Find the ability to reason logically, for machines and humans.}
 ~
 @L{Match the structure of the computation to that of the logic.}
 ~
 @L{… That's the essence of Functional Programming / Category Theory!}
 @comment{
   When you go to the essence, make it explicit, and strip everything else...
   You've got the approach of Category Theory,
   which is what is good about Functional Programming
 }
 ;; ~ @p[class: 'fragment]{Any question?}
 )

(gslide () @h1{Contact}
 ~
 @L{I NEED MORE INFO!   @em{Legicash} @url{https://legi.cash/}}
 ~
 @L{I WANT TO HELP!   Telegram @url{https://t.me/LegicashCommunity}}
 ~
 @L{TAKE MY MONEY!   Whitepaper @url{https://j.mp/FaCTS}}
 ~
 @L{SHOW ME THE CODE!   @url{https://j.mp/LegicashCodeReleasePreview}}))


#|

Blockchain Upgrade
changes to the semantic of a blockchain should only take effect after a sufficient delay.
the solution to having long-term contracts that bind two complex evolving blockchains involves
having each chain maintain and publish on itself a complete reflective logical description
of the chain’s logic in its own logic.

Managing Forks

|#

(reveal)
