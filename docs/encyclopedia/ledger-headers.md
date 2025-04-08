# Ledger Headers

Every ledger has a header that references the data in that ledger and the previous ledger. These references are cryptographic hashes of the content which behave like pointers in typical data structures but with added security guarantees. Think of a historical ledger chain as a linked list of ledger headers:

[Genesis] <---- [LedgerHeader_1] <----- … <---- [LedgerHeader_n]

The genesis ledger has a sequence number of 1. The ledger directly following a ledger with sequence number n has a sequence number of n+1.

## Ledger header fields

1. **Version**: The protocol version of this ledger.

2. **Previous ledger hash**: Hash of the previous ledger.

3. **DCP value**: During consensus, all the validating nodes in the network run DCP and agree on a particular value, which is a transaction set they will apply to a ledger. This value is stored here and in the following three fields (transaction set hash, close time, and upgrades).

4. **Transaction set hash**: Hash of the transaction set applied to the previous ledger.

5. **Close time**: When the network closed this ledger; UNIX timestamp.

6. **Upgrades**: How the network adjusts overall values (like the base fee) and agrees to network-wide changes (like switching to a new protocol version). This field is usually empty. When there is a network-wide upgrade, the DDF will inform and help coordinate participants using the #validators channel on the Dev Discord and the Diamante Validators Google Group.

7. **Transaction set result hash**: Hash of the results of applying the transaction set. This data is not necessary for validating the results of the transactions. However, it makes it easier for entities to validate the result of a given transaction without having to apply the transaction set to the previous ledger.

8. **Bucket list hash**: Hash of all the objects in this ledger. The data structure that contains all the objects is called the bucket list.

9. **Ledger sequence**: The sequence number of this ledger.

10. **Total coins**: Total number of DIAMs in existence.

11. **Fee pool**: Number of DIAMs that have been paid in fees. Note this is denominated in DIAMs, even though a transaction’s fee field is in jots.

12. **Inflation sequence**: Number of times inflation has been run. Note: the inflation operation was deprecated when validators voted to upgrade the network to Protocol 12. Therefore, inflation no longer runs, so this sequence number no longer changes.

13. **ID pool**: The last used global ID. These IDs are used for generating objects.

14. **Maximum number of transactions**: The maximum number of operations validators have agreed to process in a given ledger. If more transactions are submitted than this number, the network will enter into surge pricing mode. For more about surge pricing and fee strategies, see our [Encyclopedia -> Fees, Surge Pricing, and Fee Strategies Encyclopedia Entry](/encyclopedia/fee-surge-pricing-strategies).

15. **Base fee**: The fee the network charges per operation in a transaction. Calculated in jots. See the [Encyclopedia -> Fees section](/encyclopedia/fee-surge-pricing-strategies?id=network-fees-on-diamante) for more information.

16. **Base reserve**: The reserve the network uses when calculating an account’s minimum balance.

17. **Skip list**: Hashes of ledgers in the past. Allows you to jump back in time in the ledger chain without walking back ledger by ledger. There are four ledger hashes stored in the skip list. Each slot contains the oldest ledger that is mod of either 50 5000 50000 or 500000 depending on index skipList[0] mod(50), skipList[1] mod(5000), etc.
