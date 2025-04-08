# Account Merge

The `Account Merge` operation is used to permanently `delete a blockchain account` and transfer its remaining `DIAM` balance to another account. After the operation is successfully executed, the source account is removed from the ledger.

### Key Characteristics:

1. **Account Deletion**:

- The operation removes the source account entirely from the Diamante blockchain ledger.

2. **DIAM Transfer**:

- Any remaining DIAM balance in the source account is transferred to the destination account specified in the operation.

3. **Final Action**:

- This operation is irreversible; once the account is merged, it cannot be restored.

4. **Threshold**:

- Requires the high threshold of the source account, as this is a critical operation.

5. **Reserved DIAM**:

- Reserved DIAM (for trustlines, offers, etc.) is freed during the merge and included in the transferred balance.

### Use Cases

- `Account Consolidation` Merge multiple accounts into a single account to simplify account management. `Inactive Account Cleanup` Remove unused or inactive accounts from the blockchain ledger.`Resource Optimization` Free up DIAM reserved for minimum balances and reclaim them into a primary account.`Migration` Transition assets and funds to a new account when an old account is no longer needed.

### Key Components

1. Destination : The account that receives the `DIAM` balance of the source account after the merge.

### Requirements

1. `Valid Destination Account`: The destination account must already exist.
2. `Remaining DIAM Balance`: The source account must have enough balance to cover. The transaction fee for the merge operation.
3. `Source Account Ownership`: The operation requires signatures from the source account.

##### Detailed Workflow

<!-- tabs:start -->

#### **Javascript**

```js
const {
  Keypair,
  Operation,
  TransactionBuilder,
  Networks,
  BASE_FEE,
  Aurora,
} = require("diamnet-sdk");

const sourceSecret = "SXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"; // Source account's secret key
const destinationPublicKey = "GXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"; // Destination account's public key

const sourceKeypair = Keypair.fromSecret(sourceSecret);
const sourcePublicKey = sourceKeypair.publicKey();

const server = new Aurora.Server("https://diamtestnet.diamcircle.io/");

async function mergeAccount() {
  try {
    console.log(
      "Merging account:",
      sourcePublicKey,
      "into:",
      destinationPublicKey
    );

    const sourceAccount = await server.loadAccount(sourcePublicKey);

    const transaction = new TransactionBuilder(sourceAccount, {
      fee: BASE_FEE,
      networkPassphrase: "Diamante Testnet 2024",
    })
      .addOperation(
        Operation.accountMerge({
          destination: destinationPublicKey,
        })
      )
      .setTimeout(30)
      .build();

    transaction.sign(sourceKeypair);

    const result = await server.submitTransaction(transaction);
    console.log("Account merge successful:", result);
  } catch (error) {
    console.error("Error during account merge operation:", error);
  }
}

mergeAccount();
```

<!-- tabs:end -->

`Important Notes`

- Ensure the destination account exists before merging, or the transaction will fail.
- The operation is irreversible. Double-check the destination account before proceeding.
