# Create Claimable Balance

The `Create Claimable Balance` operation allows an account to move an asset into a Claimable Balance Entry, making it `claimable` by specific accounts under defined conditions. The asset is locked until the claimants meet the conditions set in the claim predicates.

### Key Characteristics:

1. **Claimable Balance**:

- Allows an asset `including DIAM` to be locked in a claimable balance, which can only be claimed by authorized accounts under specified conditions.

2. **Conditional Claiming**:

- The claimable balance can only be claimed by the accounts specified in the list of `Claimants`, subject to the `ClaimPredicate` conditions.

3. **Security**:

- The asset is held in a claimable state until the conditions for claiming it are met. This ensures that assets can be safely distributed or held until certain requirements are satisfied.

4. **Threshold**:

- Requires a `medium threshold` authorization level for the source account to perform the operation.

5. **Result Type**:

- The operation returns a `CreateClaimableBalanceResult`, which indicates whether the creation of the claimable balance was successful or failed.

### Use Case

`Escrow`: The create claimable balance operation can be used to hold funds in escrow, making them available for release to the recipient only once specific conditions are met (e.g., a contract condition), `Timed Distribution`:Used to distribute assets to recipients at a future time or once certain conditions (e.g., time, behavior) are met, `Conditional Payments`: Allows businesses or platforms to hold assets for customers or partners and release them only when the predefined claim conditions are fulfilled .`Rewards Systems`: Can be used to lock rewards for users that can be claimed when certain achievements or conditions are met.

### Key Components

1. **Asset**: Specifies the asset (e.g., DIAM or any other token) that will be held in the claimable balance entry. It must be in the format asset_code:issuing_address (e.g., USD:GA6T...) or native for native assets (DIAM).
2. **Amount**: The amount of the asset that is being locked in the claimable balance. It must be an integer.
3. **Claimants**: A list of claimants who can claim the balance. Each claimant is defined by `Account address`: The address of the account that will receive the asset once the claim conditions are met. `ClaimPredicate`: A set of conditions that must be fulfilled for the claimant to claim the asset (e.g., time-based conditions, signature-based conditions, etc.).

#### Detailed Workflow

<!-- tabs:start -->

#### **Javascript**

```js
const {
  Asset,
  Aurora,
  Keypair,
  Operation,
  BASE_FEE,
  TransactionBuilder,
  Claimant,
} = require("diamnet-sdk");

async function createClaimableBalance(sourceSecret, destinationPublicKey) {
  const server = new Aurora.Server("https://diamtestnet.diamcircle.io/");
  const sourceKeypair = Keypair.fromSecret(sourceSecret);

  try {
    // Load the source account
    const sourceAccount = await server.loadAccount(sourceKeypair.publicKey());

    // Amount to lock in the claimable balance
    const amount = "5";

    // Creates a claimant object with an unconditional predicate, meaning the destination account can claim the balance without any additional conditions.
    const claimant = new Claimant(
      destinationPublicKey,
      Claimant.predicateUnconditional()
    );

    // Create the claimable balance entry operation
    const claimableBalanceOp = Operation.createClaimableBalance({
      asset: Asset.native(), // Asset type (DIAM in this case)
      amount: amount, // Amount to lock in the claimable balance
      claimants: [claimant], // Add the claimant to the claimable balance
    });

    // Build the transaction
    const transaction = new TransactionBuilder(sourceAccount, {
      fee: BASE_FEE,
      networkPassphrase: "Diamante Testnet 2024",
    })
      .addOperation(claimableBalanceOp)
      .setTimeout(30)
      .build();

    // Sign the transaction
    transaction.sign(sourceKeypair);

    // Submit the transaction
    const response = await server.submitTransaction(transaction);

    console.log("Transaction response:", response.hash);
  } catch (error) {
    console.error("Transaction submission error:", error);
  }
}

const sourceSecret = "SCYER7WUB3HQ3NK3YULVGVBP3FF6CGHUTPJ2YBI7LFGTP4XQZRPTENPO";
const destinationPublicKey =
  "GDC5ZMDJX6CREOCQORHUTGEMBJE6ZLG3YCBNYGBRCXV5NGQSDBO7EGC3";

(async () => {
  await createClaimableBalance(sourceSecret, destinationPublicKey);
})();
```

<!-- tabs:end -->

`Benefits of Using Create Claimable Balance`: Conditional Asset Transfer: Enables assets to be held and claimed only when specified conditions are met. Escrow-Like Functionality: Supports the creation of escrow systems where assets are locked and can only be claimed once requirements are fulfilled. Flexible Claim Conditions: Claim conditions can be customized using claim predicates, allowing for time-based, signature-based, or other custom rules for claiming assets.
