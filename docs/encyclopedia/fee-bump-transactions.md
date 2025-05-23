# Fee-bump Transactions

Fee-bump transactions enable an account to pay the transaction fees for an existing transaction without having to re-sign the transaction or manage sequence numbers.

A fee-bump transaction is made of two parts:

1. An inner transaction envelope with its signature(s)
2. An outer transaction envelope with the fee-bump transaction and fee account signature

## Common Use Cases

You may want to consider using fee bumps when:

- You’re building a service where you want to cover user fees
- You want to increase the fee on an existing transaction so it has a better chance of making it to the ledger during surge pricing
- You need to adjust the fee on a pre-authorized transaction so it can make it to the ledger if minimum network fees have increased

## Attributes

<br/>

#### Existing Transaction Envelope (Inner Transaction)

Before creating a fee-bump transaction, you must first have a transaction wrapped with its signatures in a transaction envelope. We’ll call this transaction the inner transaction.

#### Fee Account

The account that will pay the fee for the fee-bump transaction. This account will incur the fee instead of the source account specified in the inner transaction. The sequence number is still taken from the source account, however.

#### Fee

The maximum per-operation fee you’re willing to pay for the fee-bump transaction. The fee-bump transaction is one operation. Therefore, the total number of operations is equal to the number of operations in the inner transaction plus one. Read more about transaction fees in our [Encyclopedia -> Fees section](/encyclopedia/fee-surge-pricing-strategies).

#### Replace-by-Fee

You can apply a fee-bump transaction to increase a fee originating from your own account. However, if you submit two distinct transactions with the same source account and sequence number with the second transaction being a fee-bump transaction, the second transaction will replace the first transaction in the queue if and only if the fee bid of the second transaction is 10x the fee bid of the first transaction.

#### Fee-bump Transaction Envelope

When a fee-bump transaction is ready to be signed, it’s wrapped in a transaction envelope. This envelope contains the fee-bump transaction and the signature of the specified fee account.

## Validity of a Fee-bump Transaction

A fee-bump transaction goes through a series of checks in its lifecycle to determine validity. The following conditions must be met:

- **Fee Account:** The fee account for the fee-bump transaction must exist on the ledger.
- **Fee:** The fee must be greater than or equal to the network minimum fee for the number of operations in the inner transaction, plus one for the fee bump. The fee must also be greater than or equal to the fee specified in the inner transaction. If the fee-bump transaction is taking advantage of the replace-by-fee, the fee must be 10x higher than the first transaction.
- **Fee Account Signature:** The fee-bump transaction envelope must contain a valid signature for the fee account. Additionally, the weight of that signature must meet the low threshold for the fee account, and the appropriate network passphrase must be part of the transaction hash signed by the fee account.
- **Fee Account Balance:** The fee account must have a sufficient DIAM balance to cover the fee.
- **Inner Transaction:** The inner transaction must be valid, which means it must meet the requirements described in the Validity of a Transaction section. If validation of the inner transaction is successful, then the result is FEE_BUMP_INNER_SUCCESS, and the validation results from the validation of the inner transaction appear in the inner result. If the inner transaction is invalid, the result is FEE_BUMP_INNER_FAILED, and the fee-bump transaction is invalid because the inner transaction is invalid.

## Application

The sole purpose of a fee-bump transaction is to get an inner transaction included in a transaction set. Since the fee-bump transaction has no side effects other than paying a fee — and at the time the fee is paid the outer transaction must have been valid (otherwise nodes would not have voted for it) — there is no reason to check the validity of the fee-bump transaction at apply time. Therefore, the sequence number of the inner transaction is always consumed at apply time. The inner transaction, however, will still have its validity checked at apply time.

Every fee-bump transaction result contains a complete inner transaction result. This inner-transaction result is exactly what would have been produced had there been no fee-bump transaction, except that the inner fee will always be 0.
