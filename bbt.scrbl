#lang scribble/sigplan @nocopyright
@;-*- Scheme -*-

@(require scribble/base
          scriblib/autobib scriblib/footnote
          scribble/decode scribble/core
          scribble/manual-struct scribble/decode-struct
          scribble/html-properties scribble/tag
          scribble-math
          (only-in scribble/core style)
          "utils.rkt" "bibliography.scrbl")

@; Hide author information for submission to Scaling Bitcoin
@;@authorinfo["Author name withheld" "Affiliation withheld" "email@withheld"]
@authorinfo["François-René Rideau" "Alacris" "fare@alacris.io"]
@; http://alacris.io/

@; This document is available under the bugroff license.
@; http://www.geocities.com/SoHo/Cafe/5947/bugroff.html

@title{Binding Blockchains Together with Accountability through Computability Logic}
@; Based on a presentation given at LambdaConf 2018 2018-06-05
@; Based on a presentation given at the MIT Blockchain Club 2018-02-20

@;@conferenceinfo["Scaling Bitcoin 2018 \"Kaizen\"" "2018-10-06, Tokyo, Japan"] @copyrightyear{2018} @; SUBMITTED
@;@conferenceinfo["Scaling Bitcoin 2018 \"Kaizen\"" "2018-10-06, Tokyo, Japan"] @copyrightyear{2018} @; SUBMITTED

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
   to prevent @q{block-withholding} attacks.

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
between @q{smart contracts} and @q{legal contracts}.
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
users will lose their funds, or equivalently see them @q{frozen} indefinitely,
if their service provider somehow fails to process them;
and failure cases notably centralized authorities demanding through @q{legal} force
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
whereas a Distributed Consensus deals with @q{smart law},
where actors are mechanical processes.
A court enforces its laws socially,
with a judge as its arbiter,
and court clerks to handle title registration;
a distributed consensus enforces its @q{laws} algorithmically,
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

@subsection{What Law can or cannot do}

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

There is branch of Economics called @q{Economic Analysis of Law},
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
  When the freedom called @q{Voice} is recognized,
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
  When the freedom called @q{Exit} is recognized,
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
  Finally, when the freedom called @q{Enter} is recognized,
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
another server can @q{not publish} one billion trillion bajillion transactions,
even an uncountable infinity (though only a finite number can be non-trivial).
Our design still requires side-chain managers to regularly publish a transaction
to register updates to their side-chains,
but these can be done in arbitrarily large batches,
by publishing just a digest of the state of the chain,
plus sufficient proof that the update is correct.
There remains the need for @q{smart lawsuits} to happen on the main blockchain,
but if the design of the side-chain provides good incentives for all participants,
then these @q{smart lawsuits} will be few and far between,
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

In both cases, @q{Plan A} is @emph{Never} to go to Court;
indeed, having the judge decide the case is always @q{Plan Z},
because it will be slower and more expensive for everyone involved,
compared to settling the same case out of court
— and only more certainly so in the case of smart contracts.

As contrasted with a common conception, in our analogy,
contracts are @emph{not} for @q{evaluating code on the blockchain}.
Evaluating code on the blockchain is extremely slow and expensive,
literally millions of times more so than doing it on a regular computer
That's never a good first choice.
It will always be cheaper to do the work in a side-chain, or even, better, wholly off-chain.
Making computations on the blockchain only makes sense as a threat to potential offenders:
@q{If you fail to abide by the terms of the contract, yet refuse settlement,
in addition to paying the damages you owe, you will be forced to pay for all the court fees
associated with this million-fold expensive computation.}

@void{
  Justification for million:
  You can rent a Cloud VM for about $10 per month. That's 3.8e-8 USD/s.
  You pay for on-chain computations at about 1 GAS per microsecond, at 555 USD/ETH and 10e-8 ETH per GAS,
  for 5.55 USD/s.
  https://docs.google.com/spreadsheets/d/1m89CVujrQe5LAFJ8-YAUCcNK950dUzMQPMJBxRtGCqs/edit#gid=0
  See also
  https://youtu.be/a-xHiI-G_CQ
}


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
as long as a @q{relay} can be written that allows the smart contract to verify whether
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
Finally, those who sign contracts but fail to complete will not only lose their stake,
but will be kicked out of exchanges forever
(and if said exchange implemented KYC, potentially from all exchanges implementing KYC,
forever, or at least until they make proper amends).
Which is social enforcement on top of smart contract enforcement.


@section{A Logic for Smart Contract}

@subsection{Logic? What Logic?}

Now that we understand the purpose of smart contracts,
the question that remains is what is the most suitable logic in which
to write those smart contracts.
The same logic may also apply to the specification of @q{smart statute},
i.e. the laws that apply to all users of a blockchain,
as contrasted with contracts that only apply to those who voluntarily enter them.
Smart contracts and smart statutes together constitute @q{smart law},
the set of automated rules that apply to users of a blockchain.

Law is about verifying compliance to rules,
with punishing consequences attached to a verified non-compliance.
@q{Smart} is a term of art for @q{Algorithmic}
(though it might have originated from marketroid buzzword bingo).
The basic logic of smart contract should therefore be one
of verifying whether some algorithmic computations did or didn't happen,
with given outcomes.
It's a computational logic for verified computations;
but not just any verifications:
those possible via a @q{smart legal argument} made in front of the @q{smart court}.


@subsection{What is a smart trial?}

In a trial (smart or human),
two parties disagree about a claim.
One party claims that a given clause of a given contract (or statute) applies to a particular situation;
the other party disputes the claim and argues otherwise.
They hold their argument publicly in front of a judge,
who presides the debate and hears both parties' arguments.
After the hearing, the judge issues his opinion and adjudicates the case,
his decision having consequences regarding the allocation of the resources at stake during the trial.
The judge may also reject invalid arguments and punish parties that fail to play the game properly.

In a @q{smart trial}, this process is algorithmic,
with the @q{smart lawyers} being each party's client software invoking the relevant @q{smart contract},
and the @q{smart judge} being the distributed consensus rules for the evaluation of said @q{smart contract},
and these rules being deterministic algorithms.
In other words, a @q{smart lawsuit} is what logicians call an @emph{Interactive proof}.


@subsection{What is an interactive proof?}

To illustrate an interactive proof, let's consider an argument
where Alice and Bob argue respectively for and against this claim by Alice:
@q{All sheep are the same color as mine}.
In the context of a side-chain, white sheep and black sheep
would be replaced by valid and invalid transactions on that side-chain.
Symbolically, the argument will be on a proposition of the form:
@$${\exists x \forall y P(x,y)}
(There exists an @${x} such that for all @${y}, the formula @${P(x,y)} holds.)

For Alice to argue her point, she could easily exhibit in court
some sheep of hers as a witness for @emph{x}.
On the other hand, it would be prohibitively slow and expensive for her
to produce in court each and every sheep in the world;
not only would she be bankrupted by the cost of the proceedings,
but the judge would fall asleep counting the sheep,
retire and die of old age if not of boredom, before the case is adjudicated.
And that's assuming there were a way to track every sheep in the world at a given time,
otherwise how how would the court ascertain that none had been kept out of court?
For a blockchain, this strategy would require the entire contents of the side-chain
to be published on the main chain at the least dispute,
which completely voids any pretense of using side-chains as a way to scale transactions
beyond what is possible on the main chain.

But instead of one party having to do all the arguing,
interactive proofs work by requiring both parties to take part in the argument.
Alice has to show her white sheep, which is cheap and easy for her;
but then instead of judge Judy requiring Alice to painfully show that there is no black sheep,
Judy challenges Bob to back his claim by cheaply exhibiting a black sheep in court.
If Bob can, Judy checks that the two sheep are different color, and Bob wins the case;
if bob cannot, Judy checks that the two sheep are the same color (or that Bob failed to reply in time),
and Alice wins the case.

This strategy can be generalized to arbitrary logical formulas.
For every existential quantifier @${\exists} that she has to argue Alice can cheaply produce a witness;
for an universal quantifier @${\forall }, arguing is too expensive for Alice — but is cheap for Bob!
Indeed, notice that the negation of @${\exists x \forall y P(x,y)}
can be written not just as @${¬ \exists x \forall y P(x,y)} but also as @${\forall x \exists y ¬P(x,y)}:
every existential quantifier in Alice's claim is a universal quantifier in Bob's claim, and vice versa.
Alice can provide witnesses for her side of the claim;
Bob can provide witnesses for his side of the claim.
Judy, the judge, will require them to provide witnesses in turn,
each time removing one quantifier from the formula and binding the variable with a constant witness.
Since there are a relatively small finite number of quantifiers in the formula in the contract clause,
after a small number of interactions in court, known in advance,
the formula will have been reduced to a closed formula without quantifiers,
where all the variables have been bound to relevant witnesses;
Judy can plug the variable values in the formula, see whether it's true of false,
and adjudicate the case depending on who was right.
(Interestingly, the word @q{witness} is actually used in formal logic as well as in law.)

And of course, interactive proofs can be used to establish more than sheep color or transaction validity.
For instance, they can be used to withdraw money from an account:
Alice can argue that she has 1000 tokens on Bob's side-chain, and claim them.
As a witness, Alice is required to exhibit a transaction confirmation signed by Bob,
that says that her account had 1000 tokens.
Bob can yield, or Bob is required to exhibit a transaction later than Alice's confirmation,
that shows that Alice has since spent enough money that
there are fewer than 1000 tokens left in Alice's account.


@subsection{Game Semantics}

There is a subfield of formal logic called @q{Game Semantics}
that will translate any logical formula into a interactive verification game.
This translation has the important property that the player defending a claim
has a computable @emph{winning strategy} that, if he follows it,
will ensures that he wins the game, if and only if the proposition is provable.
If the formula is @emph{decidable}, then whichever party will be in the right
will have a winning strategy — in other words, @emph{the good guys win}.

In particular, if all quantifiers in the formula are over known finite data structure
(e.g. a blockchain, whether a main-chain or side-chain),
and all the functions used in the formula are total and computable,
then the formula is decidable and good guys win indeed.
Therefore, Game Semantics can be used to argue pretty arbitrary contracts
as long as the contract clauses can be expressed as logical formulas over blockchains.
It can bind blockchains together!
But that also means that our basic logical combinators and quantifiers
must all correspond to what can be argued using Game Semantics.

Now what does a logic look like that is built from the ground up on Game Semantics?

@subsection{Computability Logic}

Giorgi Japaridze has been developing exactly such logic since 2003,
and he called it @emph{Computability Logic}.
Unlike previous approaches of trying to retrofit some game semantics
under an existing logical syntax,
Computability Logic is a "Game Semantics first, syntax second" approach:
it starts from games and then creates syntax for the formulas
that can be proven using those games.

Computability Logic naturally contains fragments of
Propositional Logic, Classical Logic, Intuitionnistic Logic, and Linear logic,
which makes it suitable to describe all the usual properties of computations.
Linear Logic can notably express the notion of resources that are spent as they are used.

If and when we need more logical operators,
we can define our own logic operators in terms of verification games to play.
And indeed, we will need more logical operators to properly model blockchains:
We will notably want to use epistemic logic
to represent user identities through knowledge of secret keys,
and temporal logic to represent timeouts and synchronization,
or to express conservation of resources through time.
Then, combining the user identities (via epistemic logic) and resources (via linear logic)
allows to express resource ownership.

One unusual dimension in which we will extend game semantics is to allow for multi-player games,
so as to model third party litigation (see @secref{Third Party Litigation}):
when resources for more than two people are at stake,
anyone, and not just the two people who start the lawsuit,
can offer to improve on the arguments offered by previous lawyers,
so that bad players can't collude to let false conclusions prevail
and extract third party money from the contract.


@subsection{Higher-Level View of Smart Contracts}

What is the proper level of abstraction at which to write logical specifications?

What ultimately matters to the end-user is the utility and security of some overall dApp.
Whether it is an application on their cell-phone
that provides them with fast transactions between multiple cryptocurrencies, or
an enterprise service that automatically settles payment for the delivery of physical goods
in a worldwide distribution network,
or some other application as visible to the user:
in the end, the user wants to think as little as possible of the underlying technical details,
and be able to think strictly in terms of the abstractions that make sense to the user.

Now, the dApp is made mainly of the trusted computers of each participant.
A @q{smart contract}, that logically specifies the respective duties of the participants,
is but is a small piece of the dApp.
A @q{smart lawsuit}, that is an interactive proof of whether some participant failed
to fulfill some specific duty he agreed to in the contract,
is but a small piece of what that contract covers.
A @q{smart contract function invocation}, which advances one step in the interactive proof,
is but a small piece of what constitutes the smart lawsuit.
A @q{smart contract VM} operation is a small piece of a smart contract function invocation.

Most current approaches to developing smart contract focus on the bottom two layers
of this @q{semantic tower}.
The key claim of this paper is that while these bottom two layers are of course important to get right,
they are both the relatively straightforward part and a focus at the wrong level of abstraction.
Indeed, to quote Alan Perlis:
@emph{A programming language is low level when its programs require attention to the irrelevant.}

To address the concerns of the user, contracts must be written at the highest level of abstraction possible;
and that level is that of the dApp, and
of the logical invariants of this dApp that the smart contract enforces.
To write those invariants, you must use a language that is concerned
not with smart contract function invocations,
but with the behavior of dApp participants.
In other words, the correct level of abstraction to write contracts is indeed
Computability Logic, with suitable extensions for epistemic logic, temporal logic,
and any other relevant aspect of distributed computations with transfer of cryptocurrency.


@subsection{What Low-level VM for Contracts?}

Of course, even when contracts are, rightfully, written in a suitably high-level logic,
there still remains the need for a low-level @q{contract virtual machine},
defined with bit-precise accuracy for deterministic verifiability,
so that the contracts can be run on a blockchain.
What does our paradigm tell us about what this contract virtual machine should look like?

Since our dApps are specified using logic in general,
we can use the Curry-Howard isomorphism between logical proofs and functional programs
to extract from the specification the code run by the participants.
The natural paradigm in which dApps are written is thus Functional Programming;
or rather, an extension of Functional Programming with distributed computation primitives
that correspond to suitable modalities of our variant of Computability Logic.

However, the contract virtual machine is what is run by the @q{judge}.
It cannot run them because it has no direct I/O capabilities.
But it doesn't need to, either.
What it needs to do is @emph{verify} those computations, not run them.
And to verify computations, the judge has no use of unbounded recursion,
nor of data structure constructors; it only needs to destructure or fold existing data structures,
provided as contract parameters or program constants.
In other words, destructors may output data into variables,
but constructors may input data only from constants, and output constants at compile-time.

Such an impoverished language is purposefully @q{Turing-equivalent}
— which is actually a plus, to get it eventually accepted as part of Bitcoin.
It is impractical to conduct any computation in the restricted contract virtual machine;
but that machine is ideally suited as the target language into which to automatically extract
referees for verification games from logical specifications.

Before the verification may happen, the judge in practice may also require
the contract virtual machine to contain a good set of all the cryptographic primitives
that may be used in all the blockchains that contracts may be written about;
to write those contracts may further require suitable @q{oracles} that relay the state
of other blockchains and non-blockchain computations.
After the verification happens, the contract virtual machine must also
possess the ability to trigger some actions such
as distributing frozen assets, confiscating collateral bonds, paying damages, etc.


@subsection{Issue: number of interaction steps}

An interactive proof may take as many steps of interaction with the consensus
as there are alternations between
on the one hand @${\exists} quantifiers and other non-dependent sums or disjunctions,
and on the other hand @${\forall} quantifiers and other non-dependent products and conjunctions.
A dichotomy, if necessary, may take tens (or even hundreds) of steps.
If, to prevent race conditions and censorship via DDoS or temporary miner capture,
each party is granted a challenge timeout of an hour or two to post its next step,
a few tens of steps is a day, a few hundreds of steps is weeks, thousands are months, etc.
This delay can be prohibitively long and make the entire system unusable.
Unary representations, such as naïve blockchaining, are worst of all.
It is therefore important to write specifications in such a way as to minimize
minimize the number of quantifier alternations, and thus of steps required to complete a transaction.

Happily, there is a technique to minimize the number of steps required to complete an interactive proof,
that corresponds to the logical transformation called @q{Skolemization}.

Consider a formula of the form @${\forall x : X \exists y : Y P(x,y)},
where adversary challenges you with an @${X}, and you reply with a @${Y}.
It can be transformed into an equivalent formula of the form
@${\exists f : X \longrightarrow Y \forall x : X P(x,f(x))},
with the substitution that @${y = f(x)}:
now you publish in advance a finite map associating to whichever potential challenge in @${X}
your response in @${Y}, then you challenge the adversary with an @${X}.
Using this transformation, we can group all the @${\exists} to the left,
and the @${\forall} to the right,
so that all proofs can be argued in two steps max!

Publishing a map in advance also lets the adversary search the map for data,
so he further doesn't have to go through a lengthy round of challenges and responses
to search the map for content (which supposes the map is indexed well-enough
to make theses searches possible in a small number of steps, to begin with).
On the other hand, if data were so well indexed as to be searchable for justifications
and counter-justifications to an exit transaction, then a verification game
that uses such search could could potentially be used to survive
the lack of a working court registry (see below?).

@; Lambda-lifting? not really.

In practice, this technique can be used to transform the formula,
wherein one party publishes a detailed indexed trace
of the computation they claim to have evaluated correctly,
and the other party must show where this trace has an invalid transition.
Building and publishing this table can be expensive,
but the cost can be shifted away from those who run the infrastructure:
If the index is a shared expense used for all transactions,
such as the index of all confirmations on a side-chain,
then the incremental cost of maintaining it is constant per new transaction
and can be paid for by those who want to issue those transactions.
If the index is specific to a particular transaction,
then the protocol can be tweaked so that it the table is only built and published on demand,
upon an explicit challenge by some party accusing the other of impropriety on the consensus;
whichever party builds and publishes the table either is culpable and deserves to pay,
or is innocent, and will recover the cost of building and publishing the table
from the bond posted by the other party.

Skolemization,
once a purely theoretical magic trick used by logicians wondering about infinite logical models,
is now a very practical tool to offer a trade-off between space and time
to developers of crypto-financial smart contracts.
With exponentially larger indexes, you can reduce the number of interaction steps, down to two.
With each couple of additional interaction steps,
you can vastly decrease the size of the indexes that both parties may have
to deterministically compute or to publish and download.
If building a full index is too expensive, the protocol can thus be modified
so there will be four steps instead of two, or six, etc.
Beware, though, that proofs in more than two steps require
a lot of additional complications due to third-party litigation.


@subsection{Third Party Litigation}

What if, in a contract that holds money from more than two parties,
two parties, including the manager of the contract, collude to sue each other and defraud other users?
Let's call Trent the trusted manager of the contract,
Alice the participant who is suing Trent
and Bob the third party who has money in the contract.
Alice and Trent are possibly Sybil identities for the legendary malicious actor Mallory.

Alice, the attacker, would accuse Trent on the consensus, and claim @q{one million dollars!}
that she was never owed.
Trent, the dishonest contract manager, instead of showing a proof that Alice is wrong,
would concede the case.
Judy would then award the money to Alice,
and the contract would have no money left to pay Bob when Bob legitimately requests to get his money back.

The solution to this problem is that Bob,
or anyone watching and verifying the transactions of that contract
(traditionally called Victor)
should be allowed to offer a better argument than Trent's.
Then, Alice gets thrown out of court and loses her bond;
Trent loses a large chunk of his bond, and his license to manage the contract.
Bob, or Victor, collect part of these forfeited bonds as a reward for his good deed.
And all the participants in the contract now get their money out at the expense of Trent.

There are more complications: many people may, rightfully or wrongfully,
claim to have better arguments than Trent. If the interactive proof takes more than two steps
(a claim from Alice then a response by Trent), then the judge must keep track of all the
ongoing arguments and counter-arguments.
Yet, to avoid double jeopardy, and the double-spending of damages,
that could also be a sneaky way to get money illegitimately out of the contract,
only the first successful counter-claimant should be rewarded.
All claimants and counter-claimants should post a bond sufficient to cover "court fees"
sufficient for other parties to throw them out of court if they are proven wrong;
yet in the case of a race condition where multiple counter-claimants may post good counter-argument
yet only one get rewarded, the other ones should be able to recover most of their bond;
this is made simpler if there is a deterministic way to sort the arguments for a counter-claim,
such that the contract can sort the many counter-claims, reward the "best" and earliest argument,
refund those who made the same argument (or reject them early without taking their bond,
if they lose the race condition to be first to post that argument),
and throw out the others, who forfeit their bonds.

There are many details to get right with respect to third party litigation,
but the general principle is ultimately straightforward and automatable,
though it isn't typically seen in Game Semantics.
Note, however, that this principle of third party litigation is required in @q{smart law},
but absent in @q{human law}, where typically,
no one shall be heard by the court unless they have a standing in the case,
or some other interest recognized by the court.
Because @q{smart law} deals with pseudonymous identities hidden by cryptography,
there is no @emph{a priori} verifiable and enforceable notion of having interest in a case,
so the @q{smart court} will hear anyone who posts a sufficient bond,
and punish those who waste the time of court by forfeiting their bond.


@subsection{Why Formal methods?}

All the solutions offered so far, including their complications,
are relatively obvious once you look at the problem of scaling cryptocurrency dApps
from the point of view of @q{smart law} using Formal Methods.
Without an understanding of those Formal Methods, these solutions were unconceivable.
Even without actually using mechanized Formal Methods, these methods were already
essential in designing a powerful solution to a pressing problem.
But there are good reasons why Formal Methods are also important when implementing these solutions.

The proposed dApp designs, while conceptually minimally simple, still have many moving parts:

@itemlist[
@item{Logical specification.}
@item{Actual code for clients.}
@item{Actual code for servers.}
@item{Actual code for verifiers.}
@item{On-chain Contract to hold actors accountable.}
@item{On-chain lawyer strategies to invoke the contract.}
@item{Off-chain lawyer strategy to watch others and advise users.}
@item{Tests to convince bad guys not to try.}]

The off-chain lawyer strategy consist in watching activity related to the contract,
deciding when to sue or not to sue, but also stopping users from making mistakes
that would cause them to forfeit their bonds, prompting the users to do the right thing instead,
and explaining why some actions are good and others are bad, when a user is confused
or otherwise has to make a hard decision.
As for the tests, they must constantly illustrate on a test network how the bad guys cannot win,
by exploring a wide range of scenarios that cover all known attack vectors—because
it is not enough to prove the code correct according to some specification,
one must also show how the actual code fares in hostile situations;
otherwise the robustness of the system is not believable.

Now, the least discrepancy between any two of those parts, and the entire edifice would crumble.
Most parts can be fixed after deployment, if they haven't been exploited yet.
But contracts in particular cannot be fixed after deployment;
at least not without sacrificing the trustlessness that makes cryptocurrency solutions
worth the price of eschewing centralized solutions.
Now, if even the greatest specialists in Ethereum smart contracts have lost hundreds of millions
of dollars worth to a small mistake in 400 lines of contract code,
what hope is there for mere mortals to write larger, more elaborate contracts,
without a fatal bug?

There again, Formal Methods offer a solution to ensure that all parts are in synch with each other:
The dApp shall be written by automatically extracting all those crucial moving parts
from a single logical specification.
It then becomes possible to reason about the specification,
and to reason about the extractors that generate the various code components from the specification,
and to make sure they all make sense and are coherent with each other.
Only such a solution can technically help dApps scale to a size
beyond what fits in the head of a single extremely careful programmer.
On the social aspect of software development, there are of course other useful approaches,
such as clean room design, adversarial code review,
red team that tries to destroy the software built by the blue team, etc.
But these approaches address independent concerns;
they neither replace Formal Methods nor are replaced by them.


@section{The Court Registry}

@subsection{The Need for Shared Knowledge}

In our design based on interactive proofs,
one requirement may have seemed trivial but actually wasn't:
the need for all quantifiers to be over @emph{known} finite data structures.
For the good guys to win, they must know what strategy to follow,
and that requires having access to the evidence and knowing the facts on the ground.
But what if the bad guy could hide those facts?

A bad guy could be hiding a black sheep in a hangar,
or an invalid check to themselves in a sea of valid transactions,
and the good guys wouldn't be able to find the correct argument to show to the judge,
at least certainly not in the desired two steps of a fast skolemized proof:
the bad guy would publish the alleged digest of his table,
but since the good guys can't actually see the content of the table,
they wouldn't be able to exhibit the contradiction in it.

This is an attack called @q{block withholding} in the Plasma paper,
because the attacker, who manages a side-chain, published the digest of a block
representing the state of his side-chain, but hides the block itself.

A winning strategy requires not just the truth to be on your side,
but also the knowledge of that truth.
For the good guys to win, it is necessary that the evidence be @emph{Shared Knowledge}.

In a @emph{closed contract}, such as a channel in the Bitcoin Lightning Network,
with a finite number of participants,
who are required to all sign each and every message for the contract to make progress,
this shared knowledge comes for marginally free:
since everyone by construction can demand to see every message that matters
before they accept to sign it, there is no hidden data that the bad guys can use.
However, such closed contracts intrinsically cannot scale
beyond a few tens of technically savvy participants
who all possess robust servers online to listen to the other participants
and sign all the relevant messages in a timely manner.

In an @emph{open contract}, with one or a small number of technically savvy managers who sign the messages,
and an unlimited number of regular customers who don't have to worry about it,
it is easy to scale the number of participants to millions or even billions;
but how can we ensure that the data shall become shared knowledge,
such that the managers cannot cheat?


@subsection{Court Registry}

Our general solution to this problem is a @emph{Smart Court Registry}.
By analogy with a human @q{court registry}, it has clerks
who record data, titles, claims, transactions, etc.,
that can later be used as evidence in court if needed to settle a dispute.

In terms more familiar to developers of @q{smart contracts}, this court registry is
an @q{Oracle} for the public availability of registered data:
the registry can undersign data as being available in a way that is considered trustworthy
to the signatories of a contracts and accepted by the judge in case of dispute.
Unlike oracles that try to relay events done wholly outside the blockchain,
and subject to deception about those events,
this particular oracle only relays events that it itself makes happen:
the making sure that data that it has seen is made available to verifiers rather than withheld.
That is one crucial source of failure modes less than more general oracles,
though there of course remain other issues intrinsic to any oracle, to establish their trustworthiness.

Still, assuming for now that a Court Registry can be safely constructed,
open contracts that involve interactive proofs can simply require all state updates by managers
to only be valid if all data was duly registered with the Court Registry.
Then, all relevant data is known, third parties can verify all transactions,
and there can be no @q{block withholding attack}.

Note however, that it is not enough for the managers to register
the preimage of the one cryptographic digest representing the state of the side-chain:
this preimage only contains one top-level record, whereas all transitive data in the side-chain,
all the blocks of the side-chain, the entirety of all its Merkle trees, must have been seen and republished.
Therefore, the registry must be aware of the @emph{schema} of the data registered to it,
and must include a (digest of) the schema together with the (digest of) the data
when it signs that it indeed has seen some kind of data and all its transitive dependencies.


@subsection{Court Registry Issues}

As mentioned above, a Court Registry has the same general security issues as any blockchain solution.

The Court Registry is subject to a @q{51% attack}.
Consider the quorum @${q} of registrars required to underwrite data used in a side-chain state update,
whichever way the registrars are weighed.
If registrars totalling a weight equal of larger than @${q} collude or are otherwise dishonest,
then they can underwrite a state update without actually making the data available,
thus allowing the bad guys to launch block withholding attacks.
If registrars totalling a weight equal of larger than @${1-q} collude or are otherwise dishonest,
then they can deny the honest side-chain managers the signatures necessary to their state updates,
and hold these managers and their customers hostage.
The optimal value of @${q} that minimizes the attack surface
for both blockwithholding and denial of service is @${q = 50\%},
and there are actually @q{50% attacks}.

To prevent these @q{50% attacks}, the Court Registry, like all Oracles, has the following dilemma:
signatories could be part of a closed set of trusted participants,
in which case it constitutes an oligopoly,
with the associated problems in terms of long term alignment between oligopolists and customers,
and of a relatively centralized design subject to political pressure;
or signatories could be part of an open set, where shares in the oracle can be sold and bought with token
(such an Oracle is also called a Token-Curated Registry, or TCR),
in which case bribing is legal, and the registry can simply be bought off,
if it is undercapitalized compared to the value it protects.

There are stopgaps measures. The Registry could start as closed in practice,
and become more open as capital flows in.
Some kind of @q{alarm bell}, when pulled in a duly authorized way,
could declare the Court Registry as captured by the bad guys, at which point
the system would revert to the kinds of @q{exit games} used by the Plasma design
to cope with block withholding.
These exit games intrinsically do not scale; they are very slow and costly;
but at least they can deny from bad guys the ability to capture the capital protected by the court registry,
thus decreasing the incentive to capture said registry to begin with.

Ideally, the main chain could serve as court registry, at least in fall back cases.
But that supposes that the main chain can already scale,
at which point the court registry cannot be used as a scaling solution,
only as a cost saving solution assuming sufficient trust in the source registry and side-chain managers.


@subsection{Shared Knowledge vs Common Knowledge}

The branch of logic known as @emph{Epistemic Logic} informs us about the commonality and differences
between a court registry and a distributed consensus.

In Epistemic Logic, there is a notion of @emph{Shared Knowledge}: it is what @emph{everybody knows}.
It models the knowledge that is built by a Gossip Network, and instituted by the court registry.
Thanks to Shared Knowledge, you can detect double-spending, and you can prevent triple-spending,
because no one will accept any transaction based on resources that are already known to be double-spent.
But shared knowledge by itself offers no way to resolve the disputes that it detects.

In Epistemic Logic, there is also the notion of @emph{Common Knowledge}:
it is what @emph{everybody knows that everybody knows that everybody knows…}
It models that knowledge that is built by a Distributed Consensus, the basis of all blockchain designs.
Thanks to Common Knowledge, you can resolve disputes and designate a one legitimate owner for disputed funds,
thanks to a total ordering of all transactions that prevents double-spending.
But common knowledge is intrinsically much more expensive to achieve than shared knowledge.

Now, shared knowledge can serve as a precursor to common knowledge.
Obviously it is strictly less powerful than common knowledge, and cheaper to achieve:
it requires no synchronization between the participants and can be reasonably achieved in seconds
in good conditions.
Shared knowledge can be achieved within @${O(n)} messages between registrars,
whereas common knowledge requires at least @${O(n \log n)} messages, or worse,
where @${n} is the number of registrars necessary to establish quorum.
Meanwhile common knowledge may still take tens of minutes to achieve with current technology,
at least in adversarial conditions (it may be much faster when there is no ongoing attack attempt).
Interestingly, there is a way to use the same gossip network to smoothly upgrade knowledge
from private knowledge to shared knowledge to common knowledge,
as participants publish their data to the court registrars,
who their exchange with each other not just said data,
but also the epistemic status of what registrars know that other registrars know.
This epistemic knowledge suffices to reconstitute a trace of
all the communications that happened within the registry,
and can be used to extract whatever information any other consensus algorithm can,
thus making the construction optimal.

One advantage of building the consensus and court registry from the same gossip network
is that double-spends can be solved in favor of whichever transaction
was seen earlier by the gossip network,
requiring a 34% attack to invalidate a transaction
that was seen as a undisputed candidate by the shared knowledge.
This increases the value of the court registry as a way to speed up transactions.


@subsection{Repudiable Facilitators}

To summarize our dApp scaling solution, what we have in the end is a notion of Repudiable Facilitators,
who are Managers for Open Contracts, holding each other accountable in a gossip network
that plays the role of a Court Registry.

Facilitators are held accountable because everyone can verify their integrity and denounce fraud;
this provides the freedom to Voice concerns.
They are repudiable because customers may unilaterally remove their funds from their management,
making this management practically non-custodial;
this provides the freedom to Exit customership.
Finally, anyone can open a rival side-chain and become a facilitator,
providing the freedom to Enter competition.
Facilitators are bonded, so they can't profitably cheat,
ensuring they have Skin in the Game and that their interests are aligned with those of regular users.
Validation of transactions through the contract ensures that
facilitators can only do the Right Thing;
at worst, facilitators may cause their side-chain to fail to make progress,
but cannot make it do anything invalid with impunity.
Facilitators double as mutual verifiers, as they are part of the Court Registry,
and interested in keeping the other facilitators honest.

Facilitators can cause merchants to lose of money by colluding with customers to double-spend,
but only within the limits of a floating limit much less than the bond they thereby forfeit,
which constitutes a limited, insurable, event, that goes against their interest.
In normal operations, merchants can therefore reasonably accept transactions
with low latency after confirmation solely from the court registry and not yet from the consensus.
Facilitators therefore constitute an acceptable solution to scaling issues:
making a lot of small transactions with low latency with reasonable economic expectations of success.
Merchant may still choose whom to trust, and fallback to slow payment through the consensus
if a customer has no facilitator that the merchant trusts.
Assuming the consensus is itself derived from the court registry,
even those slow payments can be sped up
in the common case that there is no active attack on the network.

We thus believe our design constitutes a practical solution to cryptocurrency scaling issues.


@subsection{Beyond Fast Payment}

Helping dApps scale is not limited to fast payment within a given cryptocurrency:
the same approach can also solve interoperability between blockchains and enable
the construction of non-custodial exchange with fast transactions,
and atomic payments from one network to the other.

Instead of building side-chains optimized for speed,
one could also build a side-chain optimized for privacy:
a contract could specify a side-chain that behaves like Zcash, Monero or MimbleWimble,
yet is backed 100% by tokens on the Ethereum or Tezos network.
To preserve the privacy of the amounts transacted, there would be no way to enforce floating limits,
and therefore no way to make fast payments insurable;
therefore users would always have to wait for confirmation on the main chain.
But the construction would otherwise allow to safely combine the economic value of one network
with the privacy guarantees of another.

In the future, arbitrary dApps could be developed using the same variant of Computability
that we are implementing, and share the same court registry
as a means to enforce shared knowledge of side-chain data.
While it is technically possible for anyone to fork our code and start their own court registry,
it is economically risky to multiply small undercapitalized court registries
that are cheap to capture, and the economic equilibrium is that everyone should be using
the same court registry that we are going to launch.

Finally, if and when we develop tools based on Computability Logic to build secure dApps,
the same tools will be available to build secure dApps even in cases that do not require smart contracts.
Our technology may help tremendously reduce the number of security issues that plague the Internet of today,
beyond mere cryptocurrency applications.


@section{Conclusion}

@subsection{The Take Home Points}

We have argued that the analogy of @q{Consensus as Court} should be taken seriously.
It's a productive story that leads to practical solutions to pressing problems,
as well as to understanding why some sought solutions are impossible.

Based on this analogy as well as on Formal Methods, we have proposed solutions
to dApp scaling issues, as well as to interoperability between blockchains.
Our approach is general purpose rather than specific to an application.

From our paradigm, we have claimed that the purpose of contracts is @emph{not}
to evaluate code on the blockchain, which is an intrinsically expensive and impractical thing.
Rather, the purpose of contracts is to threaten bad players with evaluating code on the blockchain,
at their expense, with further punishment as a consequence through the forfeiture of a bond.

Finally, we have concluded that current generation of Smart Contract languages,
even the more @q{functional} ones, are @emph{way} too low-level for the purpose of developing safe dApps.
Instead, we propose the use of Formal Methods and a variant of Computability Logic
as a way to specify dApp invariants and extract the many components of a dApp's code.
In a way, Formal Methods are still some kind of Functional Programming,
but on steroids, at a higher level.


@subsection{Advancement Status}

This talk is only a big picture of what
we are currently building at Alacris.

Our design is far from fully implemented yet, but it is not complete vaporware:
We are three developers working full-time on building the solution,
with over seven thousand lines of code, mostly in OCaml,
currently interfacing with the Ethereum network as our consensus.
We are incrementally evolving our code-base
from a demo with a lot of stubs to a complete robust product
@~cite[LegicashCodeReleasePreview].


@subsection{The Meta-Story}

At a higher level, the approach we have followed was, given a problem,
first to identify its essence, stripped from incidentals,
and find the natural overall paradigm for the problem domain.
Then, we sought the ability to reason logically, for machines and humans, about that problem domain,
and finally, we matched the structure of the computation to that of the logic.
In a word, the approach we followed @emph{was} Functional Programming,
or, under another name, Category Theory:
Go to the essence of things, make it explicit, strip everything else, and compute with logic.

This is a powerful approach that can and probably should be more systematically applied
to more problem domains.


@subsection{Contact Information}

(Information withheld, pending review.)

@;I NEED MORE INFO!   @emph{Alacris} @url{https://alacris.io/}
@;I WANT TO HELP!   Telegram @url{https://t.me/Alacris}
@;TAKE MY MONEY!   Previous Whitepaper @url{https://j.mp/FaCTS}
@;SHOW ME THE CODE!   @url{https://j.mp/LegicashCodeReleasePreview}}))


@subsection{Future Challenges}

Even when we complete our design, there are many challenges, both conceptual and practical,
that await us on the way to completely solving blockchain issues.
One important challenge is in how to deal with blockchain upgrade:
when the specification of a blockchain changes and it @emph{hard forks},
all the contracts written before the hard fork may become invalid.
Changes to the semantic of a blockchain should therefore only take effect after a sufficient delay
for contract participants to update their contracts or exit them.
Long-term contracts should have suitable provisions for cases when an upgrade happen.
Some blockchains may provide an abstract enough contract API that remains valid
even when the blockchain evolves, allowing to write contracts that are abstract enough
to survive upgrades that do not alter too much the structure of the blockchain.
But even these blockchains might some day face the necessity of a hard fork that breaks those APIs.

Interestingly, the maximally upgradable API that a blockchain may offer would be
a complete specification in logical terms of the logical semantics of the blockchain,
written in the contract logic of the blockchain itself,
including a reflective description of the contract logic.
Similar reflective specifications can also help make side-chains upgradable,
but also make them virtualizable, and allow contracts and their own side-chain
to be moved from one blockchain to another.

Another issue with side-chains is to manage the case when the parent chain
that hosts the consensus for the side-chain itself forks.
In some cases, the side-chain may want to remain only on one fork;
in other cases, it may fork itself;
it is not always clear how to support that technically.


@(generate-bib)

@void{
I reached that grail by putting all the concepts back into place,
both economic and (techno)logic: the respective roles of
distributed chat (shared knowledge) vs. distributed consensus (common knowledge);
the importance of accountability in maintaining good incentives,
requiring actors to have skin in the game by posting bonds they'll lose if they misbehave;
@q{Exit} (and @q{Enter}) being the mechanism to keep service providers honest,
when @q{Voice} can only coordinate people whose interests are already aligned;
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

}
