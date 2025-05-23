# Path Payments

In a path payment, the asset received differs from the asset sent. Rather than the operation transferring assets directly from one account to another, path payments cross through the SDEX and/or liquidity pools before arriving at the destination account. For the path payment to succeed, there has to be a DEX offer or liquidity pool exchange path in existence. It can sometimes take several hops of conversion to succeed.

For example:

Account A sells DIAM → [buy DIAM / sell ETH → buy ETH / sell BTC → buy BTC / sell USDC] → Account B receives USDC

It is possible for path payments to fail if there are no viable exchange paths.

### Operations

Path payments use the Path Payment Strict Send or Path Payment Strict Receive operations.

- **Path Payment Strict Send:** Allows a user to specify the amount of the asset to send. The amount received will vary based on offers in the order books and/or liquidity pools.

- **Path Payment Strict Receive:** Allows a user to specify the amount of the asset received. The amount sent will vary based on the offers in the order books/liquidity pools.

### Path payments - more info

- Path payments don’t allow intermediate offers to be from the source account as this would yield a worse exchange rate. You’ll need to either split the path payment into two smaller path payments or ensure that the source account’s offers are not at the top of the order book.
- Balances are settled at the very end of the operation.
- This is especially important when (Destination, Destination Asset) == (Source, Send Asset) as this provides a functionality equivalent to getting a no-interest loan for the duration of the operation.
- Destination min is a protective measure, it allows you to specify a lower bound for an acceptable conversion. If offers in the order books are not favorable enough for the operation to deliver that amount, the operation will fail.
