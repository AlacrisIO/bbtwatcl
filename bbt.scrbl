#lang scribble/sigplan @nocopyright
@;-*- Scheme -*-

@(require scribble/base
          scriblib/autobib scriblib/footnote
          scribble/decode scribble/core
          scribble/manual-struct scribble/decode-struct
          scribble/html-properties scribble/tag
          (only-in scribble/core style)
          "utils.rkt" "bibliography.scrbl")

@; Hide author information for submission to Scaling Bitcoin
@;@authorinfo["François-René Rideau" "Legicash" "fare@legi.cash"]
@authorinfo["Author name withheld" "Affiliation withheld" "email@withheld"]
@; http://legi.cash/

@; This document is available under the bugroff license.
@; http://www.geocities.com/SoHo/Cafe/5947/bugroff.html

@title{Binding Blockchains Together with Accountability through Computability Logic}
@; Based on a presentation given at LambdaConf 2018 2018-06-05
@; Based on a presentation given at the MIT Blockchain Club 2018-02-20

@conferenceinfo["Scaling Bitcoin 2018 \"Kaizen\"" "2018-10-06, Tokyo, Japan"] @copyrightyear{2018} @; SUBMITTED

@abstract{
We take the analogy between Consensus and Court from where TrueBit and Plasma left it,
and advance it further.
We thereby propose to use side-chains constrained by a smart contract
to scale cryptocurrency distributed applications (dApps),
and implement features such as cross-chain interoperability, anonymity or low-latency.
We also argue that the point of contracts is @emph{not} to evaluate code on the blockchain,
but only to verify execution of the dApp and keep the interests of participants aligned;
our design thus requires a sufficiently-advanced contract language, but not Turing-equivalence.
We contend that existing smart contract languages are way too low-level
as they focus on individual contract invocations;
instead we offer to automatically extract smart contracts
from a formal specification of a dApp's invariants.
Finally, we present a Court Registry as a solution to block withholding attacks.
}


@keywords{
  Smart Contracts,
  Scaling,
  dApps,
  Layer 2 Solution,
  Consensus as Court,
  Formal Methods
}

@section{Introduction}

@subsection{Claims}

We propose a solution based on side-chains with a two-way peg to scale cryptocurrency transactions
and implement features such as cross-chain interoperability, anonymity or low-latency.

Our two main innovations are:
(1) formal logic, enforced using verification games automatically deduced using game semantics,
   to describe the invariants that side-chain managers must preserve; and
(2) a court registry, combined gossip network and oracle for the public availability of data,
   to prevent "block-withholding" attacks.

Otherwise, our solution reuses well-known design elements such as:
(a) a single manager for the side-chain with proof-of-authority,
    so the side-chain can scale it as well as any other centralized solution;
(b) a bond posted by the manager as collateral to keep them honest;
(c) limits on floating transactions so dishonest managers cannot recover their bonds by multi-spending;
(d) a contract that ensures users can get their money out even if the manager fails,
    so the chain is essentially non-custodial;
(e) Plasma-style exit games in case the court registry fails, to disincentivize its capture.

While we are currently implementing it on Ethereum, our design could work on
any blockchain with sufficiently-advanced contracts;
we do not require Turing-equivalent from the scripting language, though we do require
features not currently present in Bitcoin.

Our solution is based on the analogy between the distributed consensus as a court system,
between "smart contracts" and "legal contracts".
We take that analogy a bit further than TrueBit or Plasma, but also understand its limits.

@subsection{Plan}

We will start by going back to first principles when discussing
the analogy between distributed consensus and court system.
From these principles, we will deduce a design whereby transactions happen mainly on side-chains.

In a second part, we will the use of then discuss how smart contracts
may bind blockchains together in general,
and bind side-chains to main blockchains in particular.

Then, we will explore the logic intrinsic to the problem of smart contracts.
We will notably discuss how Game Semantics can be used to argue arbitrary logical formulas
as smart contract clauses.

Finally, we will introduce a Court Registry as a solution to the problem of block withholding.
We will explain that it helps with scaling as compared to the usual consensus,
because it only needs shared knowledge rather than common knowledge, which is cheaper.


@section{Back to First Principles} @; Consensus as Court

@subsection{The Scaling Issue}

Current cryptocurrency systems don't yet scale to the level of their ambitions.
The throughput for Bitcoin is about 7 transactions per second (tps);
Ethereum can sustain about 15 tps.
This is in contrast to traditional payment card systems,
that average at several thousands of transactions per second,
with peeks over ten thousand transactions per second at rush hour during Christmas holidays.
Several existing or upcoming blockchains support or will support some form of sharding
to solve the throughput issue. Though there is no clear winner yet in that space,
we can hope that this issue will be satisfactorily solved in a few years at most.
In case none of the existing alternatives is satisfactory,
the present paper offers a solution of its own.

Even then, another scaling issue, the latency issue remains largely unaddressed.
Fully confirming a transaction takes about 60 minutes for Bitcoin, or 25 minutes for Ethereum,
versus about 7 seconds for traditional payment card systems.
Even the best proposed algorithms seem to take minutes to reach consensus,
and those altcoins that cut corners in this respect
may to be vulnerable to double-spending attacks.

In any case, this makes current and near future cryptocurrencies
generally unsuitable for use in casual payments,
to paid for gas, groceries, drinks, meals, etc.,
or for flowers when you're late for your mother's birthday.


@subsection{Traditional solutions}

Fiat currencies used to have a similar issue, in that
it used to take weeks or months for checks to clear.
But nowadays, people don't use checks anymore, they use the aforementioned payment cards,
that can confirm payment in a few seconds...
even though it may still take days or months for funds to fully clear in the backend.

Why can't we have payment card equivalent for cryptocurrency?
The obvious answer is that fiat solutions are centralized,
which sacrifices the essential feature that makes cryptocurrencies interesting in the first place.
However, we will argue that the real issue with traditional solutions is not that they are
@emph{centralized} as such, but that they are @emph{custodial}:
users will lose their funds, or equivalently see them "frozen" indefinitely,
if their service provider somehow fails to process them;
and failure cases notably centralized authorities demanding through "legal" force
such failure from the provider.

@subsection{What is a distributed consensus for?}

Now why do cryptocurrencies need a distributed consensus, to begin with?
@emph{If} everyone were always honest and competent, a signed check would be gold:
by hypothesis, it would always be backed by appropriate resources,
that would never be double-spent.
You could keep re-endorsing a check eternally and never clear it.

Unhappily, honesty and competence are not always the case, and
a few dishonest or incompetent people can make the entire system crumble.
That's where the Distributed Consensus is useful:
by providing a universally clear order between all claimed transactions,
it can prevent future disputes regarding transactions,
and resolve existing disputes regarding smart contracts.

In this, it is analogous to a @emph{Court} — Necessarily slow and expensive.
Indeed, both Distributed Consensus and Courts involve making public pronouncements
that are unequivocally recognized by everyone all around the globe.
This intrinsically takes time compared to private transactions between two individuals only.

That is why people go to Court or to the Consensus of a blockchain
to buy a house, a car, or similarly make large payments that do not require low latency.
But no one goes to Court to settle payment for a coffee,
and neither should anyone go to a blockchain's distributed consensus
to similarly settle small and fast payments.
Instead, for cryptocurrencies as well as for fiat currencies,
it should be appropriate to rely on somewhat trusted payment processors
to make these casual payments:
it is a solution known to scale!

Ideally, people would therefore use the Distributed Consensus like they use a Court system:
only to prevent disputes by registering titles, which can be done cheaply and en masse,
and to resolve disputes by hearing and adjudicating lawsuits
in case one party breaches their part of a contract.
Instead, the bulk of transactions would happen privately in side-chains,
each managed by one or many managers, who will be held accountable if they fail to do their part,
through a sufficient bond that they must post as collateral.
And these transactions could be fast, because they are locally centralized,
even though the ultimate security of the system, and the guarantee that user funds are safe,
will reside in the distributed consensus, which is as decentralized as can be.


@subsection{The Analogy between Consensus and Court}

There is a clear analogy between Consensus and Court,
but this analogy also has limits where it breaks down.

Both systems deal with replacing disputes with peace,
but a Court deals with human laws, where participants are humans,
whereas a Distributed Consensus deals with "smart law",
where actors are mechanical processes.
A court enforces its laws socially,
with a judge as its arbiter,
and court clerks to handle title registration;
a distributed consensus enforces its "laws" algorithmically,
with a distributed process as its arbiter,
and distributed tables to handle title registration.
A court often has a somewhat flexible interpretation of law,
that can rely on wisdom and finess, and that allows it
to adapt to new unforeseen circumstances, but
make the outcome of lawsuits quite uncertain and risky;
a distributed consensus has a rigid interpretation of law,
based on logic and probabilities,
that makes it unsuitable to adapt to future changes,
but provides certainty of outcome and comparably fast adjudication,
as long as the system runs within its operating parameters.

Of course, to a functional programmer,
@emph{an analogy is one abstraction applied twice}:
the common pattern of the analogy is the common structure of a same function,
and where the analogy breaks down is when the same function
is applied to to different parameters.
In this case, the common abstraction is a system for adjudication of claims,
and the different parameters pertain to the participants being humans or machines.
This difference makes it clear that court systems and distributed consensus,
human law and smart law, are no substitute for each other,
thus clarifying an all-too-common misconception.
Understanding both the common pattern and the different parameters
allows for a productive and safe use of the analogy
at generating solutions to issues with cryptocurrencies.

@subsection{What Law @emph{can} or @emph{cannot} do}

When faced with a social issue X, many people jump to the suggestion
@q{Why don't we just make X illegal?} — a reflex cultivated by demagogues.
Unhappily, bad behavior cannot be simply decreed away.

For instance, (mass)murder is illegal (at least when committed by people not wearing official uniforms),
yet it still happens (even by people not wearing official uniforms).
Law can never prevent anyone from ever doing anything.
To believe otherwise is magic thinking, not rooted in reality.

One thing that law @emph{can} do, however, is to hold actors accountable for their behavior.
It can make murder something that people won't want to commit, to order, or to preach,
because it will no longer be in their best interest after suitable retaliatory consequences are enacted.
In other words, laws can provide (or then again fail to provide) proper @emph{incentives}.
And this a topic for @emph{Game Theory}, a field of knowledge at the intersection of
Economics, Mathematics, and Military Science — that is familiar (or ought to be)
to software security professionals in general, and those who design cryptocurrency solutions in particular.

What Game Theory teaches us is that for incentives to be affected by any retaliatory system of law,
participants need to have @emph{skin in the game}.
With Human Law, ultimately, offenders can caught physically,
and made to face whatever punishment awaits them.
With Smart Law, and especially so in systems that have any modicum of anonymity or pseudonymity
and interaction at high speed, physically catching the offenders is not feasible,
and instead, a skin in the game is reguarly achieved by participants having to deposit a collateral,
or otherwise risking to forfeit a profit
(Note that these techniques also available between humans,
and are historically particularly developed where physical enforcement is difficult or expensive).

@subsection{Economic Analysis of Law}

There is branch of Economics called "Economic Analysis of Law",
that studies how various actual or potential law do or may affect
the incentive structure of the many participants.
Notably, it studies those incentives in terms of
the actual consequences of enacting the law when those incentives are created or modified,
and not in terms of the displayed intentions of the law-makers
as they prepare propaganda to get their laws to be accepted by the public that is imposed those laws.
The economic analysis of law even applies to the behavior of lawmakers,
in a subfield called Public Choice Theory — but that is a topic for another day.

However, one thing that economic analysis of law establishes, that is relevant to our topic,
is the relationship between the kinds of freedom that laws recognize to the public,
and how those freedoms affect the alignment of interests
between those who produce a service and those who consume this service.
And this relationship still holds when the service in question is the enforcement of law itself.

@itemlist[
@item{
  When no freedom is recognized to the consumers,
  besides shutting up and obeying the rules set by the producers,
  then the producers individually possess a de jure monopoly,
  and the incentives of the law generate chaos,
  wherein the interests of the producers and consumers are radically opposed.
}
@item{
  When the freedom called "Voice" is recognized,
  and consumers may express their discontent as well as their satisfaction,
  and maybe even vote on various issues,
  then the system has incentives for coordination of interests between producers and consumers.
  However the voicing process not only depends on an existing alignment of interests,
  but actively consumes and slowly destroys this alignment;
  and when this alignment is present no more (and sooner than later, it won't),
  the consumers can voice all the discontent they want,
  the producers will constitute a de facto monopoly as a class,
  that just won't care and won't budge when their class interests are at stake.
}
@item{
  When the freedom called "Exit" is recognized,
  and consumers may repudiate the producers they don't like,
  and unilaterally exit from any producer's their set of customers to use another producer instead,
  then incentives provide alignment of interests between producers and consumers,
  — but only within the limited choice of the set of available enforcement providers.
  If no existing provider provides satisfactory service, no satisfactory service will be found.
  And eventually, there may also be a slow drift toward
  disalignment of class interests between the oligopoly of enforcers and the mass of regular participants;
  this drift will only go faster as this oligopoly uses regulatory capture
  to artificially highten the barrier to entry to new producers.
}
@item{
  Finally, when the freedom called "Enter" is recognized,
  and regular participants may not just exit from the customership of unsatisfactory enforcers,
  but enter the market for enforcement,
  but also start their own competing production service without artificially high the barrier to entry,
  then and only then will the interests of producers and consumers be aligned.
  Indeed the process of free competition between producers is just another name
  for this freedom that consumers have to fully choose their producers,
  including entering the market as well as exiting it.
  This freedom is what actively creates alignment of interests
  where this alignment didn't preexist;
  it is what ultimately generates order.
}]


@subsection{Aligning interests of Payment Processors}

In cryptocurrency applications, there is a limited role for Voice,
as part of voting mechanisms for establishing a consensus itself;
but there is unlimited scope for Exit and Enter.
Thus, side-chain managers can be kept honest because a smart contract
will ensure that not only can their customers unilaterally exit their side-chains,
but any user unsatisfied with their price or service level
may enter the competition and become a manager for a competing side-chain.

The freedom of Exit will be enforced through the ability of customers to
repudiate the side-chain even without the cooperation of the side-chain manager,
and either get their money back individually on the main blockchain,
or transfer it @emph{en masse} to another side-chain.

The freedom of Enter will be enforced through the ability of users
to start their own side-chain, with no barrier of entry beside the ability
to run suitable servers in a robust enough way somewhere on the Internet,
and posting a bond sufficient to convince some customers to use their service.
Anyone can cook — but only those who do it well will attract and keep customers.


@subsection{Consensus as Court}

All in all, considering the analogy between Consensus and Court
is a fruitful point of view.
It can generate solutions to problems yet unsolved in the cryptocurrency industry.

According to this analogy, the Distributed Consensus should be used mainly to provide arbitration,
and not to process everyday transactions.
Instead, transactions can scale on a side-chain,
and the consensus will only be used to prevent and resolve disputes.


@section{Smart Contracts for Side-Chains}

@subsection{Solving Scaling}

Some first good news about our side-chains is that they solve scaling issues.
Indeed, by @emph{not} publishing transactions on the main chain,
the intrinsic limitations of current and future blockchains
will not be bottlenecks anymore as to the volume and speed of everyday transactions.

Considering throughput, non-publication is infinitely faster than publication:
in the time that one may publish a single transaction on blockchain with distributed consensus,
another server can "not publish" one billion trillion bajillion transactions,
even an uncountable infinity (though only a finite number can be non-trivial).
Our design still requires side-chain managers to regularly publish a transaction
to register updates to their side-chains,
but these can be done in arbitrarily large batches,
by publishing just a digest of the state of the chain,
plus sufficient proof that the update is correct.
There remains the need for "smart lawsuits" to happen on the main blockchain,
but if the design of the side-chain provides good incentives for all participants,
then these "smart lawsuits" will be few and far between,
since no one is interested in ever entering such a lawsuit.

@subsection{Non publication for contracts}

Contracts too can benefit from non-publication:
a typical contract will consist just in a standard template
to collect posted bonds, allow for consensual settlement,
and timeout if some party fails to respond
— plus a salted hash of the actual contract clauses,
in the style of a Bitcoin MAST.

The normal use of a contract is:
(a) participants each sign the contract,
which involves posting proper bonds as collateral,
with a timeout to cancel the contract and return those bonds in case one party fails;
(b) once everyone is bound, each participant doing their expected part,
abiding by duties specified in the relevant clauses of the contract;
(c) once every participant has fulfilled all their obligations,
everyone signs a settlement and promptly getting their collateral back,
adjusted as per the settlement.

Any other use is abnormal:
One offending party fails to do their part.
One offended party invokes the contract in court, i.e. in front of the consensus,
by revealing the clause that was broken to get compensation.
A lawsuit results, with each party arguing their case (or failing to do so);
in the end, the case is adjudicated by judge,
i.e. by the consensus evaluating the smart contract invocations.
The party that failed is made to lose part or all of their collateral to cover damages and court fees;
the victim is compensated, and the case is closed.
If one party makes spurious or exaggerated claims, they will be found wrong,
thrown out of court, and made to cover all court fees.

Non-publication of contract clauses should thus be the normal way to use smart contracts,
which will result in smart contracts to be smaller, cheaper and faster
to publish on the distributed consensus, and also more private as to their contents.


@subsection{What are contracts for?}

Contracts, whether human contracts or smart contracts,
consist in mutual obligations, detailed in a series of clauses.
In each clause, one participant or class of participants makes a promise.
If they break their promise, a sanction punishes them.
In the end, they are mechanisms to create alignment of interests
of many parties toward a common activity,
when these interests would otherwise be antagonistic.

In both cases, "Plan A" is @emph{Never} to go to Court;
indeed, having the judge decide the case is always "Plan Z",
because it will be slower and more expensive for everyone involved,
compared to settling the same case out of court
— and only more certainly so in the case of smart contracts.

As contrasted with a common conception, in our analogy,
contracts are @emph{not} for "evaluating code on the blockchain".
Evaluating code on the blockchain is extremely slow and expensive,
literally millions of times more so than doing it on a regular computer
That's never a good first choice.
It will always be cheaper to do the work in a side-chain, or even, better, wholly off-chain.
Making computations on the blockchain only makes sense as a threat to potential offenders:
"If you fail to abide by the terms of the contract, yet refuse settlement,
in addition to paying the damages you owe, you will be forced to pay for all the court fees
associated with this million-fold expensive computation."

#|
  Justification for million:
  You can rent a Cloud VM for about $10 per month. That's 3.8e-8 USD/s.
  You pay for on-chain computations at about 1 GAS per microsecond, at 555 USD/ETH and 10e-8 ETH per GAS,
  for 5.55 USD/s.
  https://docs.google.com/spreadsheets/d/1m89CVujrQe5LAFJ8-YAUCcNK950dUzMQPMJBxRtGCqs/edit#gid=0
  See also
  https://youtu.be/a-xHiI-G_CQ
|#


@subsection{Example Contract: Atomic Swap}

Let's suppose Alice and Bob want to exchange $1000 worth between Monero and Zcash.
Since they do not trust each other, indeed,
since they are both hidden behind random-looking pseudonymous addresses,
neither of them wants to be first to send money,
as the other would have no incentive to reciprocate.
But since they both want the exchange to happen, they can sign a suitable contract on Ethereum,
by each posting a bond worth $4000 to that contract.
Alice promises to pay Bob $1000 worth of Monero at the agreed rate,
or lose her $4000 worth stake in Ethereum.
Bob promises to pay Bob $1000 worth of Zcash at the agreed rate,
or lose his $4000 worth stake in Ethereum.
Now that both parties are bonded, they are both strongly interested in doing their part.
The settlement may still be as slow as the slowest of the chains involved,
but the contract is effective as soon as both bonds are posted on the Ethereum blockchain.

Actually, the contract is so effective that there is a potential attack wherein
Mallory convinces Alice to sign such a contract, then conducts a denial of service attack on Alice
such that Alice cannot do her part of the contract, and Mallory can collect the damages.
To prevent such attacks, Alice must be careful never to sign such a contract
unless she is hiding behind an anonymizing relay network such as Tor,
and/or is using a highly redundant and secure server infrastructure
that can resist DDoS attacks.
At the very least, she ought to have a backup route to the Internet,
for instance, using a cell phone provider as well as a landline,
so that she can still complete her side of the contract
if Mallory manages to cut her main access to cryptocurrency networks.


@subsection{Solving Interoperability}

The above atomic swap smart contract illustrates how smart contracts
can solve the issue of interoperability between blockchains,
and indeed @emph{binding blockchains together}.

No trust in the counterparty is needed,
only an audit of well-written software.
If all parties use competently written software,
they will be able to complete trades across multiple blockchains,
even though they don't trust each other.
Also note that none of the currencies being swapped or otherwise transacted with
needs to support smart contracts,
as long as a "relay" can be written that allows the smart contract to verify whether
specific transactions were or weren't posted on a given blockchain,
the contract can include clauses about these transactions.
For a short-term contract, it is enough to identify in advance
the near future parameters of the Proof-of-Work or Proof-of-Stake algorithm
(difficulty, winning lottery tickets, etc.),
so that the contract can subsequently verify that a future block
is indeed a confirmed part of the relayed blockchain.
For a long-run contract, it may be necessary to consult an intermediate contract
that incrementally tracks the relevant parameters of each other blockchain.

Also note that the currencies being swapped need not share cryptographic primitives,
as long as the blockchain that holds the contracts itself has all the necessary primitives.
In the case of atomic transactions, it is even possible to use zk-SNARKs off-chain
to prove that given precommitment on one chain corresponds to the same secret
as a precommitment using a different digest algorithm on another chain,
which further reduces the need for common on-chain cryptographic primitives.

As for signing any kind of contract, there remains the problem of the @emph{free option}
possessed by the last signatory, who may or may not choose to sign the contract and post his bond
until the last moment allowed by the contract's time out,
whereas the resources already posted by the previous participants are locked.
In the case of an atomic swap, this last participant may thus benefit from the volatility of the market
to either commit the swap or not depending on which direction the market moves during the timeout period.
This is a general problem with any smart contract, but there again,
side-chain managers can provide the service to @emph{match} traders in a fair, auditable way:
the smart contract can hold them accountable neither to cheat nor to fail in any egregious way;
all they can do to distinguish themselves from their competitors
is thus their tiers of quality and quantity of service,
and the according fee schedules for what they charge their users;
and free competition will pressure them towards providing services
that their customers find competitive.

@subsection{Swapping without a large stake}

The above atomic swap contracts require each party,
or at least the party that will post the second transaction,
to post a bond larger than the transaction amount.
This is a significant inconvenience, especially when
parties are not necessarily able or willing to hold a large balance
on the chain in which contracts are written.

Happily, this constraint can be done away with,
at the expense of introducing the risk of incomplete exchanges
for only part of the initially desired amount.
Alice and Bob will post a limited bond, say worth $400,
on the contract blockchain;
instead of verifying a single atomic swap,
the contract will specify a series of atomic swaps,
possibly to be done via payment channels in the style of the Bitcoin Lightning Network.
Each swap may be only $100,
but since the swaps are repeated, the total amount can be any amount that makes sense
in a number of repetitions that is large enough to reach that amount,
yet small enough so that the currency pair isn't too volatile in the time necessary for the repetition.
Once again, payment channels can tremendously accelerate this construction.
This kind of atomic swap is similar to the Interledger Protocol,
except that the contract allows for large increments as long as sufficient bonds are posted,
instead of only small increments worth a few cents at a time.
Millions of dollar worth of cryptocurrency can be swapped
with a latency limited only by the speed of the contract blockchain,
with a few hundreds of dollar of collateral.
And if the contract blockchain is itself a reasonably trusted (and insured?) neutral side-chain,
said latency can itself be very low,
allowing for atomic swaps of large amounts in short periods of time,
while momentarily immobilizing only a relatively small bond from the participants,
and with low fees.

Ultimately, there is always the possibility that the other party will fail to complete the transaction,
and/or that the side-chain manager will fail at the most improprietous moment.
In any case, the possibility or even worse, the actuality, of failure to have their expectations met
can be especially stressful to those who issue trade orders.

But our design will make that an unlikely scenario that goes against
the self-interest of the failing party,
will make that an insurable scenario thanks to the limits on floating transactions.

You get a smaller guarantee, for a smaller bond.
Social enforcement: whoever fails to complete their part
will be kicked out of exchanges forever.


@section{A Logic for Smart Contract}

@subsection{Logic? What Logic?}

Law: verifying compliance, punishing non-compliance

Smart: term of art for "Algorithmic" (initially buzzword bingo).

Smart Law: compliance with algorithmically verifiable rules.

Computational Logic — but @emph{what} logic?

@subsection{What is a legal argument?}

Two parties disagree about a claim.

Each party argues it case.

At the end, the judge finds who's right.

It's an @emph{Interactive proof}.


@subsection{What is an interactive proof?}

Let's argue: "All sheep are the same color as mine" (in Japan).

@emph{∃x   ∀y      P(x,y)}
@emph{vs}
@emph{∀x   ∃y   ¬P(x,y)}

Brute force: show half a million sheep to the judge.
   How can we argue in front of a judge whose time is very expensive?
   We could exhibit all the sheep one after the other in front of the court.
   It would take a lot of time to exhibit half a million sheep while following all legal procedures,
   and would cost a fortune to complete,
   assuming the judge doesn't quickly fall asleep, doesn't die of boredom,
   and doesn't die of old age either
   --- before we're done.

Interaction: I exhibit my witness @emph{x0}, you exhibit yours @emph{y1}
   Another solution is to find two honest lawyers who will each
   honestly and capably argue their case the best possible way.
   If I argue that all sheep in Colorado are white,
   the judge will ask my lawyer to produce a sheep, and the sheep has better be white;
   this establishes existence.

   To prove universality, I cannot afford to show all the other sheep to the judge,
   or even a large fraction.
   But I can challenge you to show a sheep of a different color.

   Each witness removes a quantifier.
   The judge evaluates a closed formula.
   Interestingly, they are called witnesses in formal logic as well as in law.

   And of course, interactive proofs are not just for sheep.
   I can argue that the latest entry for my account on the blockchain has ETH 1000, that you owe me.
   You now have to either show a more recent entry for my account with less than that, or you owe me.
   The formula for the latest entry is that there exists an entry such that for all entries,
   the second entry is earlier than the former.

@subsection{Game Semantics}

Translate any formula into a game.

@emph{If} the formula is decidable, then good guys have a winning strategy.

If all quantifiers are over known finite data structure, good guys win.

What is the logic built on Game Semantics?

@subsection{Computability Logic}

Game Semantics first, syntax second.

Contains fragment of Classical, Intuitionnistic and Linear logic.

Define your own logic operators in terms of games to play.

Add fragments for Blockchain: epistemic, temporal... logic.

Propositional Logic + Quantification over large data structures

Resource Conservation: Linear Logic

Conservation through Time & Timeouts: Temporal Logic

Ownership: Epistemic Logic

Third party litigation: Multi-player games!

@subsection{Higher-Level View of Smart Contracts}

A contract (logical specification) is a small piece of a dApp.

A lawsuit (interactive proof) is a small piece of a contract.

An contract invocation (interaction step) is a small piece of a lawsuit.

A "contract VM" operation is a small piece of a contract invocation.


@subsection{Programming using Logic}

@emph{A programming language is low level when its programs require attention to the irrelevant.}
— Alan Perlis

Contract invocation, even with FP, is @emph{way} too low-level.

Program in terms of logical invariants and variants @emph{of your dApp}.

Use a DSL based on the appropriate logic: Computability Logic.

@subsection{What Low-level VM for Contracts?}

Of course use Functional Programming — Logic made computable.
Verification, not computation: no unbounded recursion.
No "Turing-equivalence" needed. Bitcoiners will be happy.

All cryptographic primitives of all blockchains to contract about.
Access to blockchain (and other?) data via "oracles".

@subsection{Issue: number of interaction steps}

Number of steps: alternations of ∃ vs ∀; dichotomies
  Mind though that each time you challenge the other party,
  you have to give them ample enough time to respond; say two hours.
  This means that a formula with a lot of alternations between ∃ vs ∀
  (or non-dependent sums and products),
  say to do a dichotomy search or two, may take a week;
  a badly written specification with a thousand alternations
  may lead taking months to interactively argue a case.
  Unary representations, such as naïve blockchaining,
  are worst of all.

  Happily, there are techniques to minimize the number of steps required
  to complete an interactive proof.

Minimize steps: Skolemization.
 @emph{∀x:X  ∃y:Y  P(x,y)     ⇔     ∃f:X→Y  ∀x:X  P(x,f(x))}
 Group all the ∃ to the left. All proofs in two steps max!

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

In practice: publish a detailed indexed trace of the computation. Expensive, but paid for by the bad guy. Trade-off between space and time.
  If the full index can be too expensive, keep it four steps, or six, etc.

  (Beware though that proofs in more than two steps require third-party litigation.)

@subsection{Third Party Litigation}

What if Alice and Trent collude to defraud Bob & other users?
Alice (Sybil attacker): "Gimme one million dollars!" Trent (dishonest contract manager): "You're right, I concede." Bob (contract user): "Hey, there's no money left in the contract!"
Solution: Bob (or anyone) can offer a better argument than Trent's
  Alice gets thrown out of court, Trent loses his license,
  Bob gets rewarded based on court fees, etc.
  Of course, to avoid double jeopardy (and double-spending of damages),
  only the first successful counter-claimant wins.

  Unlike Human law, no verifiable notion of "having standing/interest in the case"
  All identities are pseudonymous, anyway.


@subsection{Why Formal methods?}

Solutions: obvious with the right POV, unconceivable without.
  You might not even see the issue without Formal Methods.

Many moving parts. The least discrepancy and the edifice crumbles.
Most parts can be fixed after deployment. Contracts cannot.
If the greatest specialists lost 280M$ to a mistake in 400 loc...
@subsection{Moving parts that need be consistent}

@itemlist[
@item{Logical specification.}
@item{Actual code for clients.}
@item{Actual code for servers.}
@item{Actual code for verifiers.}
@item{On-chain Contract to hold actors accountable.}
@item{On-chain lawyer strategies to invoke the contract.}
@item{Off-chain lawyer strategy to watch others and advise users.}
@item{Tests to convince bad guys not to try.}]

Off-chain strategy: Watch activity on the chain,
take correct steps, stop users from making mistakes, explain what's happening to users.

Tests: Proving it correct is necessary but not enough.

@subsection{Solution: Extract Everything from a Same Spec}

Ensure all parts are in synch with each other:
Generate everything from a single specification
Reason about the specification
Reason about the generators); A Logic for Smart Contracts

@section{The Court Registry}

@subsection{The Need for Shared Knowledge}

Black sheep hidden in hangar.

Winning strategy requires truth + knowledge. Good Guy Wins requires @emph{Shared Knowledge}.

@emph{Closed contract}: Shared Knowledge easy, but no Scaling.

@emph{Open contract}: Scaling easy, but no Shared Knowledge. Solution???

@subsection{Court Registry}
"Oracle" for public data availability.

Allows for third-party verification of all transactions.

Solution to "Block Withholding Attack" (see Plasma)

Preimage not enough: Must transitively validate against schema. Against data schema})

@subsection{Court Registry Issues}

WE HAVE THE SAME ISSUES AS EVERYONE ELSE

50% attack.
Consider quorum @emph{q} of underwriting registrars.
If @emph{q} collude: block withholding. If @emph{1-q} collude, registration denial.
Optimal is @emph{q = 50%}

"Oracle" dilemma: Closed (oligopoly), or Open (bribing is legal!)
Open Oracle == "TCR", Token-Curated Registry.
Our current solution: closed for now, repudiate as soon as fishy.

Ideally, register on the main chain — but can it already scale?

@subsection{Shared Knowledge vs Common Knowledge}

Concepts from @emph{Epistemic Logic}

Shared Knowledge: what @emph{everybody knows} Gossip Network. Detects double-spending. Prevents Triple-spending.

Common Knowledge: what @emph{everybody knows that everybody knows…} Consensus. Resolves double-spending. Much more expensive.

Shared Knowledge can serve as a precursor to Common Knowledge.
Obviously it is strictly less powerful than Common Knowledge, and much cheaper to achieve:
it requires no synchronization between the participants and can be reasonably achieved in seconds.
Meanwhile Common Knowledge takes tens of minutes to achieve with current technology.
(Even though Hashgraph claims it can achieve Common Knowledge in a matter of seconds
using gossip-on-gossip, though it's unclear how well this result applies
to an open adversarial network.)
Keeping the trace always beats just doing the thing. Optimal by construction.


@subsection{Repudiable Facilitators}

Managers for Open Contracts.

Everyone can verify integrity, denounce fraud (Voice) Repudiable / Non-custodial (Exit) Anyone can open a rival side-chain (Enter) Bonded so they can't profitably cheat (Skin in the Game) Can only do the Right Thing. At worst: fail to advance.

Double as mutual verifiers. May be part of Court Registry.

@subsection{Fast Payment via Repudiable Facilitators}

Can Solve Fast Payment at Scale: locally centralized.

Only Floating is unsafe (Limited Damages, Insurable)

Bond >> Floating (Interests Aligned)

Merchant chooses whom to trust. Fallback to slow payment.


@subsection{Beyond Fast Payment}

dApps that extend Fast Payment: non-custodial exchange…

Anonymous rather than fast: Zcash-on-Ethereum…

Future: Develop arbitrary dApps with Computability Logic.

(Computability) Logic is not just for cryptocurrency dApps…


@section{Conclusion}

@subsection{The Take Home Points (redux)}

Take "Consensus as Court" Seriously. It's a productive story.

Solve Scaling, Interoperability, dApps.

Contracts are to @emph{not} evaluate code on the blockchain.

Contract languages are @emph{way} too low-level — use Formal Methods.
  Even FP contract languages are way too low-level.
  On the other hands, Formal Methods are still kind of FP, but on steroids, at a higher level.


@subsection{Advancement Status}

This talk: only a @emph{big picture}.

Our design is not fully implemented yet, but it is not complete vaporware:
We are three developers working full-time on building the solution.
We are incrementally evolving our OCaml code-base
from a demo with a lot of stubs to a complete robust product
@~cite[LegicashCodeReleasePreview].


@subsection{The Meta-Story}

Given a problem, seek its essence, stripped from incidentals.
Find the ability to reason logically, for machines and humans.
Match the structure of the computation to that of the logic.
… That's the essence of Functional Programming / Category Theory!
  When you go to the essence, make it explicit, and strip everything else...
  You've got the approach of Category Theory,
  which is what is good about Functional Programming

@subsection{Contact Information}

(Information withheld, pending review.)

@;I NEED MORE INFO!   @emph{Legicash} @url{https://legi.cash/}
@;I WANT TO HELP!   Telegram @url{https://t.me/LegicashCommunity}
@;TAKE MY MONEY!   Whitepaper @url{https://j.mp/FaCTS}
@;SHOW ME THE CODE!   @url{https://j.mp/LegicashCodeReleasePreview}}))


@subsection{Future Challenges}

Blockchain Upgrade:
changes to the semantic of a blockchain should only take effect after a sufficient delay.
the solution to having long-term contracts that bind two complex evolving blockchains involves
having each chain maintain and publish on itself a complete reflective logical description
of the chain’s logic in its own logic.

Managing Forks...


@(generate-bib)

#|
I reached that grail by putting all the concepts back into place,
both economic and (techno)logic: the respective roles of
distributed chat (shared knowledge) vs. distributed consensus (common knowledge);
the importance of accountability in maintaining good incentives,
requiring actors to have skin in the game by posting bonds they'll lose if they misbehave;
"Exit" (and "Enter") being the mechanism to keep service providers honest,
when "Voice" can only coordinate people whose interests are already aligned;
distributed consensus as a court system that provides arbitration, not transactions;
and non-publication being literally infinitely faster than publication.

Arbitration automatically resolves legal arguments where each interested party backs its claim
by challenging the other in an interactive proof.
Arbitrary logical invariants can thus be established using game semantics.
The natural language in which to express contracts is therefore computability logic,
far from the low-level virtual machines common in the industry
or even the functional languages proposed to replace them.
Well-designed contracts always provide one party a winning strategy,
so losers better concede early rather than lose and cover all legal costs.

Linking two chains together requires encoding the evolving semantics of both chains in contracts.
This construct is very fragile to the least discrepancy
between the encoding and the actual chain implementation.
Therefore this technology demands extraction of both blockchain
implementation and contract evaluation language from a common logic specification,
one that allows for reflective representation of the blockchain's own semantics.

Join me in the revolution of programming financial contracts with logic!

|#
