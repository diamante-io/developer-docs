# Glossary

### Account

A central Diamante data structure to hold balances, sign transactions, and issue assets.
See the [Accounts section](/fundamentals/datastructures?id=accounts) to learn more.

### Account ID

The public key used to create an account. This key persists across different key assignments.

### Anchor

The on and off-ramps on the Diamante network that facilitate one-to-one conversion of off-chain representations to and from tokenized assets, for example, digital tokens representing bank deposits.

### Application (app)

S
A software program designed for users to carry out a specific task (other than operating the computer itself).

### Asset

Fiat, physical, or other tokens of value that are tracked, held, or transferred by the Diamante distributed network.
See the [Assets section](/fundamentals/datastructures?id=assets) to learn more.

### Balance

The amount of a given asset an account holds. Each asset has its own balance and these balances are stored in trustlines for every asset except DIAM, which is held directly by the account.

### BalanceID

Parameter required when claiming a newly created entry via the Claim claimable balance operation. See ClaimableBalanceID.

### Base fee

The fee you’re willing to pay per operation in a transaction.
This differs from the Effective Base Fee which is the actual fee paid per operation for a transaction to make it to the ledger.

### Base reserve

A unit of measurement used to calculate an account’s minimum balance. One base reserve is currently 0.5 DIAM.

### Burn

Remove an asset from circulation, which can happen in two ways: 1) a holder sends the asset back to the issuing account 2) an issuer claws back a clawback-enabled asset from a holder's account.

### Claim Predicate

A recursive data structure used to construct complex conditionals with different values of ClaimPredicateType.

### ClaimableBalanceID

A SHA-256 hash of the OperationID for claimable balances.

### Claimant

An object that holds both the destination account that can claim the ClaimableBalanceEntry and a ClaimPredicate that must evaluate to true for the claim to succeed.

### Clawback

An amount of asset from a trustline or claimable balance removed (clawed back) from a recipient’s balance sheet.

### Core Advancement Proposals (CAPs)

Proposals of standards to improve the Diamante protocol- CAPs deal with changes to the core protocol of the Diamante network.

### Create account operation

Makes a payment to a 0-balance public key (Diamante address), thereby creating the account. You must use this operation to initialize an account rather than a standard payment operation.

### Cross-asset payments

A payment that automatically handles the conversion of dissimilar assets.

### Decentralized exchange

A distributed exchange that allows the trading and conversion of assets on the network.

### External Data Representation (XDR)

The type of encoding used operations and data running on diamante-core.

### Flags

Flags control access to an asset on the account level. Learn more about flags in our Controlling Access to an Asset section.

### GitHub

An online repository for documents that can be accessed and shared among multiple users; host for the Diamante platform’s source code, documentation, and other open-source repos.

### Home domain

A fully qualified domain name (FQDN) linked to a Diamante account, used to generate an on-chain link to a Diamante Info File, which holds off-chain metadata. See the Set Options operation. Can be up to 32 characters.

### Aurora

The Diamante API, provides an HTTP interface to data in the Diamante network.

### JSON

A standardized human-readable and machine-readable format for the exchange of structured data.

### Keypair

A combined public and private key used to secure transactions. You can use any Diamante wallet, SDK, or the Diamante Laboratory to generate a valid keypair.

### Keystore

An encrypted store or file that serves as a repository of private keys, certificates, and public keys.

### Ledger

A representation of the state of the Diamante universe at a given point in time, shared across all network nodes.

### LedgerKey

LedgerKey holds information to identify a specific ledgerEntry. It is a union that can be any one of the LedgerEntryTypes (ACCOUNT, TRUSTLINE, OFFER, DATA, or CLAIMABLE_BALANCE).

### Liability

A buying or selling obligation, required to satisfy (selling) or accommodate (buying) transactions.

### DIAM

The native, built-in token on the Diamante network.

### Master key

The private key used in initial account creation.

### Minimum balance

The smallest permissible balance in diams for a Diamante account, currently 1 diam.

### Network capacity

The maximum number of operations per ledger, as determined by validator vote. Currently 1,000 operations for the mainnet and 100 operations for the testnet.

### Number of subentries

The number of entries owned by an account, used to calculate the account’s minimum balance.

### Operation

An individual command that modifies the ledger.

### OperationID

Contains the transaction source account, sequence number, and the operation index of the CreateClaimableBalance operation in a transaction.

### Order

An offer to buy or sell an asset.

### Orderbook

A record of outstanding orders on the Diamante network.

### Passive order

An order that does not execute against a marketable counter order with the same price; filled only if the prices are not equal.

### Passphrase

The Mainnet and Testnet each have their own unique passphrase, which are used to validate signatures on a given transaction.

### Pathfinding

The process of determining the best path of a payment, evaluating the current orderbooks, and finding the series of conversions to achieve the best rate.

### Payment channel

Allows two parties who frequently transact with one another to move the bulk of their activity off-chain, while still recording opening balances and final settlement on-chain.

### Precondition

Optional requirements you can add to control a transaction’s validity.

### Price

The ratio of the quote asset and the base asset in an order.

### Public key

The public part of a keypair that identifies a Diamante account. The public key is public- it is visible on the ledger, anyone can look it up, and it is used when sending payments to the account, identifying the issuer of an asset, and verifying that a transaction is authorized.

### Mainnet or Pubnet

The Diamante Public Network, aka mainnet, the main network used by applications in production.

### Rate-limiting

aurora rate limits on a per-IP-address basis. By default, a client is limited to 3,600 requests per hour, or one request per second on average.

### Sequence number

Used to identify and verify the order of transactions with the source account.

### Secret (private) key

The private key is part of a keypair, which is associated with an account. Do not share your secret key with anyone.

### DEPs (Diamante Ecosystem Proposals)

Standards and protocols to allow the Diamante ecosystem to interoperate.

### Signer

Refers to the master key or to any other signing keys added later. A signer is defined as the pair: public key + weight. Signers can be set with the Set Options operation.

### Source account

The account that originates a transaction. This account also provides the fee and sequence number for the transaction.

### Starlight

Diamante’s layer 2 protocol that allows for bi-directional payment channels.

### Diamante

A decentralized, federated peer-to-peer network that allows people to send payments in any asset anywhere in the world instantaneously, and with minimal fees.

### Diamante Consensus Protocol (DCP)

Provides a way to reach consensus without relying on a closed system to accurately record financial transactions.

### Diamante Core

A replicated state machine that maintains a local copy of a cryptographic ledger and processes transactions against it, in consensus with a set of peers; also, the reference implementation for the peer-to-peer agent that manages the Diamante network.

### Diamante Development Foundation (DDF)

A non-profit organization founded to support the development and growth of the Diamante network.

### Diamante.toml

A formatted configuration file containing published information about a node and an organization. For more, see the Diamante Info File spec (DEP-0001).

### Jots

As cents are to dollars, jots are to assets: the smallest unit of an asset, one ten-millionth.

### Testnet

The Diamante Test Network is maintained by the Diamante Development Foundation, which developers can use to test applications. Testnet is free to use and provides the same functionality as the main (public) network.

### Threshold

The level of access for an operation.
Also used to describe the ratio of validator nodes in a quorum set that must agree in order to reach consensus as part of the Diamante Consensus Protocol.

### Time bounds

An optional feature you can apply to a transaction to enforce a time limit on the transaction; either the transaction makes it to the ledger or times out (fails) depending on your time parameters.

### Transaction

A group of 1 to 100 operations that modify the ledger state.

### Transaction envelope

A wrapper for a transaction that carries signatures.

### Transaction fee

Diamante requires a small fee for all transactions to prevent ledger spam and prioritize transactions during surge pricing.

### Trustline

An explicit opt-in for an account to hold a particular asset that tracks liabilities, the balance of the asset, and can also limit the amount of an asset that an account can hold.

### UNIX timestamp

An integer representing a given date and time, as used on UNIX and Linux computers.

### Validator

A basic validator keeps track of the ledger and submits transactions for possible inclusion. It ensures reliable access to the network and sign-off on transactions. A full validator performs the functions of a basic validator, but also publishes a history archive containing snapshots of the ledger, including all network transactions and their results.

### DIAM 

The native currency of the Diamante network.

### Wallet

An interface that gives a user access to an account stored on the ledger; that access is controlled by the account’s secret key. The wallet allows users to store and manage their assets.
