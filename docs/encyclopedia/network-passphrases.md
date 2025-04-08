# Network Passphrases

Diamantes’s Mainnet and Testnet each have their own unique passphrase. These are used when validating signatures on a given transaction. If you sign a transaction for one network but submit it to another, it won’t be considered valid. By convention, the format of a passphrase is ‘[Network Name] ; [Month of Creation] [Year of Creation]’.

The current passphrases for the diamcircle Pubnet and Testnet are:

- Pubnet: 'Diamante MainNet; DEP 2022'
- Testnet: 'Diamante Testnet 2024'

Passphrases serve two main purposes: (1) used as the seed for the root account (master network key) at genesis and (2) used to build hashes of transactions, which are ultimately what is signed by each signer’s secret key in a transaction envelope; this allows you to verify that a transaction was intended for a specific network by its signers.

Most SDKs have the passphrases hardcoded for the Diamante Mainnet and Testnet. If you’re running a private network, you’ll have to manually pass in a passphrase to be used whenever transaction hashes are generated. All of Diamante's official SDKs allow you to use a network with a custom passphrase.
