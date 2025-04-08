# Diamante Data Structures

## Ledgers

A ledger in the Diamante network represents the state of the Diamante network at a specific point in time. It is shared across all Core nodes in the network and contains information about accounts and balances, orders on the distributed exchange, smart contract data, and any other persisting data.

In other blockchains, this concept is often referred to as a "block", and the entire blockchain is sometimes called "the ledger".

In every Diamante Consensus Protocol round, the network reaches consensus on which transaction set to apply to the last closed ledger. When the new set is applied, a new "last closed ledger" is defined. Each ledger is cryptographically linked to the unique previous ledger, creating a historical chain that goes back to the genesis ledger.

Data within the ledger is stored as ledger entries. Possible ledger entries in Diamante include:

- **Accounts**
- **Claimable balances**
- **Liquidity pools**
- **Contract data**

Every ledger has a ledger header. To learn more about what is contained in the ledger header, refer to our [Encyclopedia -> Ledger Header Encyclopedia Entry](/encyclopedia/ledger-headers).

## Accounts

Accounts are a fundamental data structure in the Diamante network, responsible for holding balances, signing transactions, and issuing assets. An account can only exist with a valid keypair and must maintain the required minimum balance of DIAM (Diamante's native cryptocurrency).

For information regarding minimum balance requirements, refer to the [Diamante DIAM Section](/fundamentals/diams).

### Account Fields

1. **Account ID**: A unique identifier for the account.
2. **Balances**: The balances held within the account.
3. **Flags**: Flags associated with the account.
4. **Home Domain (up to 32 characters)**: A domain associated with the account.
5. **Liabilities**: Liabilities information for the account.
6. **Number of entries sponsored by this account**: Total entries sponsored by this account.
7. **Number of sponsored reserves**: The count of sponsored reserves.
8. **Number of subentries**: The number of subentries within the account.
9. **Sequence number**: The sequence number of the account.
10. **Signers**: Information about signers associated with the account.
11. **Thresholds**: Threshold values for the account.
12. **Base reserves and subentries**: Account data stored in subentries, where each subentry increases the account's minimum balance.

### Base Reserves

A base reserve is a unit of measurement used to calculate an account’s minimum balance in Diamante. Currently, one base reserve is equivalent to 0.5 DIAM.

### Subentries

Account data is organized in subentries, where each subentry incrementally increases the account’s minimum balance by one base reserve (0.5 DIAM). An account is limited to a maximum of 1,000 subentries. Possible subentries include:

- Trustlines (for traditional assets and pool shares)
- Offers
- Additional signers
- Data entries (created with the manageData operation, not smart contract ledger entries)

### Trustlines

Trustlines are an explicit opt-in for an account to hold and trade a specific asset in Diamante. To hold a particular asset, an account must establish a trustline with the issuing account using the `change_trust` operation. Trustlines track the balance of an asset and can also impose limits on the amount of an asset that an account can hold.

For an account to receive any asset except the native DIAM, a trustline must be established. While you can create a claimable balance to send assets to an account without a trustline, the recipient must create a trustline to claim that balance. Refer to the [Encyclopedia -> Claimable Balances Encyclopedia Entry](/encyclopedia/claimable-balances) for more information.

Trustlines also track liabilities, including buying liabilities and selling liabilities. An account's trustline must always have a balance sufficiently large to satisfy its selling liabilities and a balance sufficiently below its limit to accommodate its buying liabilities.

# Assets

Accounts on the Diamante network play a crucial role in tracking, holding, and transferring various types of assets. These assets can represent a wide range of values, including cryptocurrencies (e.g., bitcoin or ether), fiat currencies (e.g., dollars or pesos), tokens (e.g., NFTs), pool shares, and even bonds and equity.

### Identifying Characteristics

Assets on Diamante have two primary identifying characteristics: the asset code and the issuer. Since multiple organizations can issue a credit representing the same asset, asset codes often overlap. Assets are uniquely identified by the combination of their asset code and issuer.

Creating Smart Contract Tokens

You can create smart contract tokens using the Token Interface, but in most cases, it's possible and recommended to wrap a Diamante asset using the Diamante Asset Contract for use in smart contracts.

### Asset Components

<br>

#### Asset Code

Learn more about asset codes in the [Naming an Asset section](/issue-assets/asset-design?id=naming-an-asset).

#### Issuer

There is no dedicated operation to create an asset on Diamante. Instead, assets are created with a payment operation: an issuing account makes a payment using the asset it’s issuing, and that payment creates the asset on the network.

The public key of the issuing account is linked on the ledger to the asset, and responsibility for and control over an asset reside with the issuing account. Settings are stored at the account level on the ledger, and the issuing account is where you use set_options operations to link to meta-information about an asset and set authorization flags.

### Representation

In aurora, assets are represented in a JSON object:

```json5
{
  asset_code: "DiamanteToken",
  asset_issuer: "GC2BKLYOOYPDEFJKLKY6FNNRQMGFLVHJKQRGNSSRRGSMPGF32LHCQVGF",
  // `asset_type` is used to determine how asset data is stored.
  // It can be `native` (Diams), `credit_alphanum4`, or `credit_alphanum12`.
  asset_type: "credit_alphanum12",
}
```

### Amount Precision

Each asset amount is encoded as a signed 64-bit integer in the XDR structures used by Diamante to encode transactions. The asset amount unit seen by end-users is scaled down by a factor of ten million (10,000,000) to arrive at the native 64-bit integer representation.

For example, the integer amount value 25,123,456 equals 2.5123456 units of the asset. This scaling allows for seven decimal places of precision in human-friendly amount units.

The smallest non-zero amount unit, also known as a jot, is 0.0000001 (one ten-millionth) represented as an integer value of one. The largest amount unit possible is 922,337,203,685.4775807.

Relevance in aurora and Diamante Client Libraries

In aurora and client-side libraries such as js-diamante-sdk, the integer encoded value is abstracted away. Many APIs expect an amount in unit value (the scaled-up amount displayed to end-users). Some programming languages (such as go) have problems maintaining precision on a number amount. It is recommended to use "big number" libraries that can record arbitrary-precision decimal numbers without a loss of precision.

### Deleting or Burning Assets

To delete or "burn" an asset on Diamante, you must send it back to the account that issued it.

# Diamante Operations and Transactions

### Operations and transactions: how they work

To perform actions with an account on the Diamante network, you compose operations, bundle them into a transaction, and then sign and submit the transaction to the network. Smart contract transactions (those with `InvokeHostFunctionOp`, `ExtendFootprintTTLOp`, or `RestoreFootprintOp` operations) can only have one operation per transaction.

### Operations

Operations are individual commands that modify the ledger. Operations are used to send payments, invoke a smart contract function, enter orders into the decentralized exchange, change settings on accounts, and authorize accounts to hold assets.

All operations fall into one of three threshold categories: low, medium, or high, and each threshold category has a weight between 0 and 255 (which can be determined using set_options). Thresholds determine what signature weight is required for the operation to be accepted. For example, let’s say an account sets the medium threshold weight to 5. If the account wants to successfully establish a trustline with the changeTrust operation, the weight of the signature(s) must be greater than or equal to 5.

To learn more about signature weight, see the [Encyclopedia -> Signature and Multisignature Encyclopedia Entry](/encyclopedia/sig-multisig?id=signatures-and-multisig).
s
View a comprehensive list of Diamante operations and their threshold levels in the [List of Operations](/fundamentals/operations) section.

### Transactions

The Diamante network encodes transactions using a standardized protocol called External Data Representation (XDR). You can read more about this in our [Encyclopedia -> XDR Encyclopedia Entry](/encyclopedia/xdr).

Accounts can only perform one transaction at a time.

Transactions comprise a bundle of between 1-100 operations (except smart contract transactions, which can only have one operation per transaction) and are signed and submitted to the ledger by accounts. Transactions always need to be authorized by the source account’s public key to be valid, which involves signing the transaction object with the public key’s associated secret key. A transaction plus its signature(s) is called a transaction envelope.

A transaction may need more than one signature- this happens if it has operations that affect more than one account or if it has a high threshold weight. Check out the [Encyclopedia -> Signature and Multisignature Encyclopedia Entry](/encyclopedia/sig-multisig?id=signatures-and-multisig) for more information.

Transactions are atomic, meaning if one operation in a transaction fails, all operations fail, and the entire transaction is not applied to the ledger.

Operations are executed for the source account of the transaction unless an operation override is defined.

### Transaction Attributes

- Fee
- List of Operations
- List of Signatures
- Memo or Muxed Account
- Sequence Number
- Source Account

## Transaction and operation validity

<br>

#### Preconditions (Optional)

<br>

#### Time Bounds

Valid if within set time bounds of the transaction

Time bounds are an optional UNIX timestamp (in seconds), determined by ledger time, of a lower and upper bound of when a transaction will be valid. If a transaction is submitted too early or too late, it will fail to make it into the transaction set.

Setting time bounds on transactions is highly encouraged, and many SDKs enforce them.

If `maxTime` is 0, upper time bounds are not set. In this case, if a transaction does not make it to the transaction set, it is kept in memory and continuously tries to make it to the next transaction set. Because of this, we advise that all transactions are created with time bounds to invalidate transactions after a certain amount of time, especially if you plan to resubmit your transaction at a later time.

#### Ledger Bounds

Valid if within the set ledger bounds of the transaction

Ledger bounds apply to ledger numbers. With these defined, a transaction will only be valid for ledger numbers that fall within the determined range.

#### Minimum Sequence Number

If a minimum sequence number is set, the transaction will only be valid when its source account’s sequence number (call it S) is large enough. Specifically, it’s valid when S satisfies `minSeqNum <= S < tx.seqNum`.

If this precondition is omitted, the default behavior applies: the transaction’s sequence number must be exactly one greater than the account’s sequence number.

#### Minimum Sequence Age

Transaction is valid after a particular duration (expressed in seconds) elapses since the account’s sequence number age.

#### Minimum Sequence Ledger Gap

Valid if submitted in a ledger meeting or exceeding the source account’s sequence number age

#### Extra Signers

Valid if submitted with signatures that fulfill each of the extra signers

### Operation Validity

When a transaction is submitted to a node, the node checks the validity of each operation in the transaction before attempting to include it in a candidate transaction set. These initial operation validity checks are intended to be fast and simple, with more intensive checks coming after the fees have been consumed.

For an operation to pass this validity check, it has to meet the following conditions:

- **The signatures on the transaction must be valid for the operation**: The signatures are from valid signers for the source account of the operation.The combined weight of all signatures for the source account of the operation meets the threshold for the operation.

- **The operation must be well-formed**: Typically, this means checking the parameters for the operation to see if they’re in a valid format. For example, only positive values can be set for the amount of a payment operation.

- **The operation must be valid in the current protocol version of the network**: Deprecated operations, such as inflation, are invalid by design.

### Transaction Validity

Finally, the following transaction checks take place:

- **Source account**: The source account must exist on the ledger.
- **Fee**: The fee must be greater than or equal to the network minimum fee for the number of operations submitted as part of the transaction.
- **Fee-bump**: See Validity of a [Encyclopedia -> Fee-Bump Transaction section](/encyclopedia/fee-bump-transactions).
- **Sequence number**: The sequence number must be one greater than the sequence number stored in the source account entry when the transaction is applied unless sequence number preconditions are set. When checking the validity of multiple transactions with the same source account in a candidate transaction set, they must all be valid transactions and their sequence numbers must be offset by one. Then they are ordered and applied according to their sequence number.

- **List of Operations**: Each operation must pass all the validity checks for an operation, described in the Operation Validity section above.

- **List of Signatures**:

  - Meet signature requirements for each operation in the transaction
  - Appropriate network passphrase is part of the transaction hash signed by each signer
  - Combined weight of the signatures for the source account of the transaction meets the low threshold for the source account.

- **Memo (if applicable)**:
  The memo type must be a valid type, and the memo itself must adhere to the formatting of the memo type.
