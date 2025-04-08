# Fees, Surge Pricing, and Fee Strategies

Diamante requires a small fee for all transactions to prevent ledger spam and prioritize transactions during surge pricing. All fees are paid in DIAMs (DIAM).

## Network Fees on Diamante

The fee for a given transaction equals the number of operations in the transaction multiplied by the effective base fee for the given ledger (transaction fee = # of operations \* effective base fee).

- **Effective Base Fee:** The fee required per operation for a transaction to make it to the ledger. This cannot be lower than 100 Jots per operation (the network minimum).
- **Jots:** The smallest unit of a DIAM, one ten-millionth of a DIAM (.0000001 DIAM).

When you decide on a base fee for a transaction, you specify the maximum amount that you’re willing to pay per operation in that transaction. That does not necessarily mean that you’ll pay that amount, you will only be charged the lowest amount needed for your transaction to make it to the ledger. If network traffic is light and the number of submitted operations is below the network ledger limit (which is configured by validators, currently 1,000 ops per ledger on the pubnet and 100 ops per ledger on the testnet), you will only pay the network minimum (also configured by validators, currently 100 jots).

Alternatively, your transaction may not make it to the ledger if the effective base fee is higher than your base fee bid. When network traffic exceeds the ledger limit, the network enters into surge pricing mode, and your fee becomes a max bid. This amount can vary depending on network activity, but we recommend submitting a base fee of 100,000 jots for consumer-facing applications. But it's up to you.

Fees are deducted from the source account unless there is a fee-bump transaction that states otherwise. To learn about fee-bump transactions, see our [Encyclopedia -> Fee-Bump Transaction Encyclopedia Entry](/encyclopedia/fee-bump-transactions).

The DIAMs collected from transaction fees go into a locked account and are not given to or used by anyone.

## Surge Pricing

When the number of operations submitted to a ledger exceeds the network capacity (1,000 ops per ledger on the Pubnet; 100 ops per ledger on the Testnet), the network enters surge pricing mode. During this time, the network uses market dynamics to decide which submissions to include in the ledger — transactions that offer a higher fee per operation make it to the ledger first.

If multiple transactions offer the same base fee during surge pricing, the transactions are shuffled randomly and the transactions at the top make the ledger. The rest of the transactions are pushed to the next ledger or discarded if they’ve been waiting for too long. If your transaction is discarded, aurora will return a timeout error.

## Fee Strategies

There are three primary methods to deal with fee fluctuations and surge pricing:

- Method 1: Set the highest fee you’re comfortable paying. This does not mean that you’ll pay that amount on every transaction- you will only pay what’s necessary to get you into the ledger. Under normal (non-surge) circumstances, you will only pay the standard fee even if you have a higher maximum fee set. This method is simple, convenient, and efficient but can still potentially fail.

- Method 2: Track fee fluctuations with the fee_stats endpoint. Use this to make specific, informed choices about the fee you’re comfortable paying. All three of the DDF-maintained SDKs allow you to poll the /fee_stats endpoint: Go. This method provides reliable submissions but is more inefficient.

- Method 3: Use a fee-bump transaction. Set the highest fee you’re comfortable paying

In general, it’s a good idea to choose the highest fee you’re willing to pay per operation for your transaction to make it to the ledger.

Wallet developers may want to offer users a chance to specify their own base fee, though it may make more sense to set a persistent global base fee that’s above the market rate since the average user probably doesn’t care if they’re paying 0.8 cents or 0.00008 cents.

## Track Fee Fluctuations

In general, it is important to track fee costs. If network fees surge beyond what you’re willing to pay, consider waiting for activity to die down or periodically trying to resubmit the transaction with the same fee.
