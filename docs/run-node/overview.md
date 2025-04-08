# Overview

Diamante is a peer-to-peer network made up of nodes, which are computers that keep a common distributed [ledger](/fundamentals/datastructures?id=ledgers) and communicate to validate and add [transactions](/fundamentals/datastructures?id=diamante-operations-and-transactions) to it. Nodes use a program called Diamante Core — an implementation of the [Diamante Consensus Protocol](/fundamentals/consensus) — to stay in sync as they work to agree on the validity of transaction sets and to apply them to the ledger. Generally, nodes reach consensus, apply a transaction set, and update the ledger every 3-5 seconds.

You don’t need to run a node to build on Diamante: you can start developing with go SDK use public instances of Aurora to query the ledger and submit transactions right away. In fact, the Diamante Development Foundation offers two public instances of Aurora — one for the public network and one for the testnet.

Even if you do want to run your own instance of Aurora, it bundles its own version of Core and manages its lifetime entirely, so there's no need to run a standalone instance.

If you’re serious about building on Diamante, have a production-level product or service that requires high-availability access network, or want to help increase network health and decentralization, then you probably do want to run a node, or even a trio of nodes (more on that in the Tier 1 section). At that point, you have a choice: you can pay a service provider like Blockdaemon to set up and run your node for you, or you can do it yourself.

If you’re going the DIY route, this section of the docs is for you. It explains the technical and operational aspects of installing, configuring, and maintaining a Diamante Core node, and should help you figure out the best way to set up your Diamante integration.

The basic flow, which you can navigate through using the menu on the left, goes like this:

1. Choose which type of node you want to run
2. Prepare Your Environment
3. Install Diamante Core
4. Configure Diamante Core
5. Join the network
6. Monitor and maintain your node
7. Join the validators channels to stay on top of critical upgrades and network votes

### Types of nodes

All nodes perform the same basic functions: they run Diamante Core, connect to peers, submit transactions, store the state of the ledger in a SQL [database](/run-node/configuring?id=database), and keep a duplicate copy of the ledger in flat XDR files called [buckets](/run-node/configuring?id=buckets). Though all nodes also support Aurora, the Diamante API, this is a deprecated way of architecting your system and will be discontinued soon. If you want to run Aurora, you don't need a separate Diamante Core node.

In addition to those basic functions, there are two key configuration options that determine how a node behaves. A node can:

- Participate in consensus to [validate transactions](/run-node/configuring?id=validating).
- Publish an [archive](/run-node/pub-history-archives) that other nodes can consult to find the complete history of the network.

To make things easier, we’ll define three types of nodes based on permutations of those two options: Basic Validator, Full Validator, and Archiver. You’ll notice that they all support Aurora and submit transactions to the network:

| Type of Node    | Supports Aurora | Submits Transactions | Validates Transactions | Publishes History |
| --------------- | --------------- | -------------------- | ---------------------- | ----------------- |
| Basic Validator | ✔️              | ✔️                   | ✔️                     |                   |
| Full Validator  | ✔️              | ✔️                   | ✔️                     | ✔️                |
| Archiver        | ✔️              | ✔️                   |                        | ✔️                |

> In the past, there was also a Watcher node, which was designed to run alongside Aurora for transaction submission and observing ledger changes but not participate in validation or history publication. This architecture was deprecated as of Aurora 2.0, which bundles an optimized "Captive" Core for its operational needs.

So why choose one type over another? Let’s break it down a bit and take a look at what each type is good for.

#### Basic Validator

**Validating, no public archive**

A Basic Validator keeps track of the ledger and submits transactions for possible inclusion, but it is not [configured to publish history archives](/run-node/configuring?id=validatingn). It does require a secret key and is configured to participate in consensus by voting on — and signing off on — changes to the ledger, meaning it supports the network and increases decentralization.

The advantage: Signatures can serve as official endorsements of specific ledgers in real-time. That’s important if, for instance, you issue an asset on Diamante that represents a real-world asset: you can let your customers know that you will only honor transactions and redeem assets from ledgers signed by your validator, and in the unlikely scenario that something happens to the network, you can use your node as the final arbiter of truth. Setting up your node as a validator allows you to resolve any questions upfront and in writing about how you plan to deal with disasters and disputes.

**Use a Basic Validator to ensure reliable access to the network and sign off on transactions.**

#### Full Validator

**Validating, offers public archive**

A Full Validator is the same as a Basic Validator except that it also publishes a [History Archive](/run-node/pub-history-archives) containing snapshots of the ledger, including all transactions and their results. A Full Validator writes to an internet-facing blob store — such as AWS or Azure — so it's a bit more expensive and complex to run, but it also does the most to support the network’s resilience and decentralization.

When other nodes join the network — or experience difficulty and temporarily fall out of sync — they can consult archives offered by Full Validators to catch up on the history of the network. Redundant archives prevent a single point of failure and allow network participants to verify the veracity of a given history.

**Use a Full Validator to sign off on transactions and to contribute to the health and decentralization of the network.**

#### Archiver

**Non-validating, offers a public archive**

An Archiver is a rare bird: like a Full Validator, it publishes the activity of the network in long-term storage; unlike a Full Validator, it does not participate in consensus.

Archivers help with decentralization a bit by offering redundant accounts of the network’s history, but they don’t vote or sign ledgers, so their usefulness is fairly limited. If you run a Diamante-facing service, like a blockchain explorer, you may want to run one. Otherwise, you’re probably better off choosing one of the other two types.

**Use an archiver if you want to referee the network, which is unlikely.**
