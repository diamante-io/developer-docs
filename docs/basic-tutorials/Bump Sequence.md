# Bump Sequence

The `Bump Sequence` operation allows the sequence number of the source account to be incremented to a specified value. This invalidates any transaction with a sequence number smaller than the specified value, ensuring greater control over transaction ordering and lifecycle.

### Key Characteristics:

1. **Sequence Management**:

- The operation modifies the sequence number of the source account.
- Transactions with sequence numbers less than the new value will be invalidated.

2. **Account Integrity**:

- Ensures transactions cannot be replayed or processed out of sequence.

3. **Low Threshold**:

- Requires only a low threshold authorization level, making it accessible for most account configurations.

4. **Efficient Control**:

- Simplifies invalidating pending or queued transactions without having to submit or process each individually.

### Use Case

1. `Cancel Pending Transactions`: By bumping the sequence number forward, previously signed but unsubmitted transactions with smaller sequence numbers are invalidated.
2. `Improve Security`: Protects against transaction replay attacks by advancing the sequence number beyond the range of pending or maliciously crafted transactions.
3. `Regain Control`: Useful for recovering accounts where unauthorized transactions have been queued with lower sequence numbers.

### Key Components

1. **Threshold**:

- The operation requires only a low threshold, making it straightforward for account owners to use.

2. **Parameter**: `bumpTo`:

- Type: SequenceNumber (integer): Specifies the desired sequence number to which the source account should be bumped. The new sequence number must be greater than the current one.

<!-- tabs:start -->

#### **Javascript**

```js
const {
  Aurora,
  Keypair,
  Operation,
  BASE_FEE,
  TransactionBuilder,
} = require("diamnet-sdk");

async function bumpSequence(sourceSecret) {
  const server = new Aurora.Server("https://diamtestnet.diamcircle.io/");
  const sourceKeypair = Keypair.fromSecret(sourceSecret);

  try {
    // Load the source account
    const sourceAccount = await server.loadAccount(sourceKeypair.publicKey());

    // Check and log the current sequence number
    console.log("Current sequence number:", sourceAccount.sequence);

    // Calculate the new sequence number to bump to (increment current sequence by 1)
    const bumpTo = (BigInt(sourceAccount.sequence) + BigInt(1)).toString();

    // Log the calculated bumpTo value
    console.log("Bumping sequence to:", bumpTo);

    // Build the transaction to bump the sequence number
    const tx = new TransactionBuilder(sourceAccount, {
      fee: BASE_FEE,
      networkPassphrase: "Diamante Testnet 2024",
    })
      .addOperation(
        Operation.bumpSequence({
          bumpTo: bumpTo, // The new sequence number to bump to (calculated)
        })
      )
      .setTimeout(30)
      .build();

    // Sign the transaction
    tx.sign(sourceKeypair);

    // Submit the transaction
    const response = await server.submitTransaction(tx);

    if (response.successful) {
      console.log("Sequence bump successful.");
      // Load the account again to check the new sequence number after bumping
      const updatedAccount = await server.loadAccount(
        sourceKeypair.publicKey()
      );
      console.log("Updated sequence number:", updatedAccount.sequence);
    } else {
      console.error("Transaction failed:", response);
    }
  } catch (error) {
    console.error("Transaction submission error:", error);
  }
}
const sourceSecret = "SBZM56J24QK7IHSUXXROFZSYFIIUG3IOWGXACML7DF42FRBNJWAY3VGS";

(async () => {
  await bumpSequence(sourceSecret);
})();
```

<!-- tabs:end -->

By using the Bump Sequence operation, you can manage account sequence numbers effectively and maintain tighter control over your blockchain account's transaction history.
