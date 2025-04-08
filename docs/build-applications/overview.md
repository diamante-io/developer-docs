# Overview

Diamante is an open-source distributed ledger that you can use as a backend to power various applications and services, such as wallets, payment apps, currency exchanges, micropayment services, platforms for in-game purchases, and more — check out projects being built on Diamante: Diamante Ecosystem Projects.

Diamante has built-in logic for key storage, creating accounts, signing transactions, tracking balances, and queries to the Diamante database, and anyone can use the network to issue, store, transfer, and trade assets.

This documentation will walk you through how to build a wallet with the Wallet SDK (recommended) or an example payment application with the JS Diamante SDK (legacy).

## Anchors

Many Diamante assets connect to real-world currencies, and Diamante has open protocols for integrating deposits and withdrawals of these assets via the anchor network. Because of this, a Diamante-based application can take advantage of real banking rails and connect to real money.

## Diamante Ecosystem Proposals (DEPs)

Diamante-based products and services interoperate by implementing various Diamante Ecosystem Proposals (DEPs), which are publicly created, open-source documents that live in a GitHub repository and define how asset issuers, anchors, wallets, and other service providers interact with each other.

As a wallet, the most important DEPs are DEP-24: Hosted Deposit and Withdrawal, and DEP-31: Cross Border Payments API, DEP-10: Diamante Authentication, DEP-12: KYC API, and DEP-38: Anchor RFQ API.

This documentation will walk you through how to build wallets using the Wallet SDK (Kotlin and Typescript are currently supported) and how to build a comprehensive basic payment application.
