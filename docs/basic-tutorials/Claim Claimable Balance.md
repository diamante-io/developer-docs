# Claim Claimable Balance

The `Claim Claimable Balance` operation allows an account to claim a specific ClaimableBalanceEntry identified by a unique `BalanceID`. Once the claim is successful, the amount of the specified asset in the claimable balance is added to the source account.

### Key Characteristics:

1. **Claimable Balances**:

- A claimable balance is a pool of funds stored on the blockchain that can only be claimed by accounts specified as claimants. These claimants must fulfill specific conditions (claim predicates) before claiming the balance.

2. **Threshold**:

- The operation requires a low threshold, making it accessible to accounts with minimal authorization.

3. **BalanceID**:

- The BalanceID uniquely identifies a claimable balance. This ID is returned when the balance is created using the Create Claimable Balance operation. The BalanceID must be provided to claim the balance.

4. **Result Type**:

- The operation produces a ClaimClaimableBalanceResult, which indicates whether the claim was successful or if there were errors (e.g., if conditions weren’t met or the balance no longer exists).

### Use Case

1. `Delayed Transfers`: Funds are sent to another account with conditions specifying when or how they can be claimed. The recipient uses this operation to claim the balance once the conditions are met.
2. `Escrow-Like Scenarios`: A platform holds funds for a user until certain conditions (e.g., time locks or other claim predicates) are satisfied. Once fulfilled, the user claims the balance.
3. `Reward Distribution`: A rewards program distributes funds to multiple accounts as claimable balances, and users can claim their rewards individually when eligible.
4. `Fund Release Automation`: Conditional payouts are released to claimants automatically when the criteria are met.

### Key Components

1. **BalanceID**: The unique identifier of the claimable balance entry. It links to the specific balance the `claimant` wants to claim.
   Source Account:
2. The account attempting to claim the balance. This account must be one of the designated claimants for the claimable balance entry.
3. **Result**: If successful, the asset amount is transferred from the claimable balance entry to the source account. If not, an error indicates why the claim failed.

<!-- tabs:start -->

#### **Javascript**

```js
const {
  Aurora,
  Keypair,
  Operation,
  TransactionBuilder,
  BASE_FEE,
} = require("diamnet-sdk");
async function claimClaimableBalance(sourceSecret, balanceId) {
  const server = new Aurora.Server("https://diamtestnet.diamcircle.io/");
  const sourceKeypair = Keypair.fromSecret(sourceSecret);

  try {
    // Load the source account
    const sourceAccount = await server.loadAccount(sourceKeypair.publicKey());

    // Create the claim operation with the given BalanceID
    const claimOp = Operation.claimClaimableBalance({
      balanceId: balanceId, // The BalanceID of the claimable balance
    });

    // Build the transaction
    const transaction = new TransactionBuilder(sourceAccount, {
      fee: BASE_FEE,
      networkPassphrase: "Diamante Testnet 2024",
    })
      .addOperation(claimOp)
      .setTimeout(30)
      .build();

    // Sign the transaction
    transaction.sign(sourceKeypair);

    // Submit the transaction
    const response = await server.submitTransaction(transaction);

    console.log("Claim transaction response:", response.hash);
  } catch (error) {
    console.error("Transaction submission error:", error);
    console.error("Full error details:", JSON.stringify(error, null, 2));
  }
}

const sourceSecret = "SAZNYHS73MGFUKUU4JTIXBZETWQGL7UJFPXTBOY4EAMX4HO35OJB2OLJ"; // Your secret key for same as cleamed destination
const balanceId =
  "00000000237f124f3f5536c430a4c7a2e86893902ff579dbeeedade8210117ee8f06348d"; // Your BalanceID

(async () => {
  await claimClaimableBalance(sourceSecret, balanceId);
})();
```

<!-- tabs:end -->

you see your `balanceId` : https://diamtestnet.diamcircle.io/claimable_balances

By using the `Claim Claimable Balance` operation, accounts can securely claim funds when they meet the required conditions, enabling advanced scenarios like conditional payments, automated escrow, and more.
