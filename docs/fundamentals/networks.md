# Networks

Diamante has two networks: the public network (Mainnet), and the test network (Testnet). Mainnet is the main network used by applications in production. It connects to real financial rails and requires DIAM to cover minimum balances, transaction fees, and rent. The Testnet is a smaller, free-to-use network maintained by DDF that functions like the Mainnet but doesn’t connect to real money. It has a built-in testnet DIAM faucet (called Friendbot), and it resets on a regular cadence, so it's the best place for developers to test applications when they need a stable environment that mirrors Mainnet functionality.

### Stats: Mainnet versus Testnet

<br>

#### Mainnet

- Validator nodes are run by the public.
- DDF offers a free [Aurora](https://mainnet.diamcircle.io/) instance to interact with the Mainnet with a limited set of history, or you can run your own or use an instance offered by an infrastructure provider.
- You need to fund your account with DIAM from another account.
- Mainnet is limited to 1,000 operations per ledger and will be limited to a maximum of 30 transactions per ledger.
- See more detailed network settings in the section on Fees and Metering in the Soroban docs.
- No publicly available RPC.

#### Testnet

- DDF runs three core validator nodes.
- DDF offers a free [Aurora](https://diamtestnet.diamcircle.io/) instance you can use to interact with the Testnet.
- Friendbot is a faucet you can use for free Testnet DIAM.
- Testnet is limited to 100 operations per ledger.

### Friendbot

Friendbot is a bot that funds accounts with fake DIAM on Testnet. You can request DIAM from Friendbot using the DIAM Laboratory or with SDK. Requests to Friendbot are rate-limited, so use it wisely. Friendbot provides 500 fake DIAM when funding a new account.

### Testnet Data Reset

Testnet is reset periodically to the genesis ledger to declutter the network, remove spam, reduce the time needed to catch up on the latest ledger, and help maintain the system. Resets clear all ledger entries (accounts, trustlines, offers, etc.), transactions, and historical data from Diamante Core and Aurora.

### Test Data Automation

It is recommended that you have testing infrastructure that can repopulate the Testnet with useful data after a reset. This will make testing more reliable and will help you scale your testing infrastructure to a private network if you choose to do so.

A script can automate this entire process by creating an account with Friendbot and submitting a set of transactions that are predefined as a part of your testing infrastructure.

### What Testnet Should and Should Not Be Used For

<br>

#### Testnet is good for

- Creating test accounts (with funding from Friendbot).
- Developing applications and exploring tutorials on Diamante without the potential to lose any assets.
- Testing existing applications against new releases or release candidates of Diamante Core and Aurora.
- Performing data analysis on a smaller, non-trivial data set compared to the Mainnet.

#### Testnet is bad for

- Load and stress testing.
- High availability test infrastructure- DDF does not guarantee Testnet availability.
- Long-term storage of data on the network since the network resets periodically.

### Moving Your Project from Testnet to Production

Mainnet and Testnet each have their own unique passphrase, which is used to validate signatures on a given transaction.

The current passphrases for the Diamante Mainnet and Testnet are:

- Mainnet (Pubnet): Diamante MainNet; DEP 2022
- Testnet: Diamante Testnet 2024

For applications that don’t rely on the state of the network (such as specific accounts needing to exist), you move to production by changing the network passphrase and ensuring your aurora instance is connected to Mainnet.

If you’ve been running a Diamante Core or Aurora instance against the Testnet and want to switch to production, changing the passphrase will require both respective databases to be completely reinitialized. If you run your own RPC on Testnet, you may want to use an RPC service when you move to Mainnet.

To learn more about network passphrases, see our Network Passphrase Encyclopedia Entry.
