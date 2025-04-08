# Change Trust

The `Change Trust` operation in the Diamante is used to manage trustlines. A trustline is a relationship between an account and an asset issued by another account (an anchor). The `ChangeTrust` operation allows an account to create, update, or delete a trustline with a specific asset, and set a limit for how much of that asset it is willing to hold or accept. This is crucial for enabling an account to transact with assets that are not native to the blockchain (like custom assets issued by other accounts or anchors).

### Key Characteristics

- **Asset-Specific**: Trustlines are created for specific assets, which could be anything from a stablecoin to other custom tokens.
- **Limit Setting**: When you create or update a trustline, you can define a limit for how much of that asset your account is willing to hold. This is useful for preventing the account from holding too much of an asset (such as a stablecoin) that could potentially become worthless.
- **Flexible Operations**: You can change a trustline by either:
  - Creating a trustline for a new asset.
  - Updating an existing trustline (e.g., changing the limit or asset).
  - Deleting an existing trustline if you no longer want to hold that asset.
- **Transaction Type**: This operation requires a medium threshold for the account, meaning it requires the master key's weight or a sufficient threshold of signers.

### Use Case

A use case for the `ChangeTrust` operation is as follows: 1.**Creating a Trustline for a New Asset**:

- If an account wants to accept payments or interact with a specific asset (for example, a custom token like USD issued by a trusted anchor), it needs to create a trustline to accept that asset.
- Example: A user wants to accept USD from a specific anchor and creates a trustline with a limit of 200 USD. This operation establishes the trust relationship between the user's account and the anchor’s asset.

2. **Updating a Trustline Limit**:

- If an account’s needs change and it wants to accept a higher or lower amount of the asset, it can update the limit of the existing trustline.
- Example: A user previously accepted 200 USD from an anchor and wants to increase this to 500 USD. They would update the trustline's limit accordingly.

3. **Deleting a Trustline**:

- If an account no longer wishes to hold an asset, it can delete the trustline.
- Example: If a user no longer wants to accept USD from a particular anchor, they can delete the trustline, removing any future interactions with that asset.

### Key Components

- **Asset**: This represents the asset for which the trustline is created. It is typically denoted in the form of Asset:Issuer (ex: "TDIAM" ,"GBQYVC5XHICL3U3O6B3EP2A6TXX43NUU7XDPVX3E6LQXXXXXXXXXXXX").
- **Limit (Integer)**: The limit is the maximum amount of the asset the account is willing to hold or accept. It is specified as an integer value.
- **Result (ChangeTrustResult)**:The result is returned upon submission of the transaction and indicates whether the trustline operation was successful or not.

##### Detailed Workflow

1 - We'll start, as always, with our SDK and helper utilities and Network configuration

<!-- tabs:start -->

#### **Javascript**

```js
const {
  Asset,
  Aurora,
  BASE_FEE,
  Keypair,
  Networks,
  Operation,
  TransactionBuilder,
} = require("diamnet-sdk");

const server = new Aurora.Server("https://diamtestnet.diamcircle.io/");
const secret = "SB66D5RA64ETEDRE7FU7UTT6A72KFFQMFGE75XIEJS3OL4FEBXXXXXXX";
const sourceKeypair = Keypair.fromSecret(secret);
const sourcePublicKey = sourceKeypair.publicKey();
```

<!-- tabs:end -->

2 - `Creates a trustline` for an asset between the account and the asset issuer. A trustline allows the account to hold and interact with the specified asset.`assetCode`: The code of the asset (e.g., "TSKON"). `assetIssuer`: The public key of the issuer of the asset. The account details are loaded from the Diamante blockchain using the account's public key. A changeTrust operation is added to the transaction for creating the trustline. The transaction is configured with a fee (BASE_FEE) and a timeout. The transaction is signed with the secret key of the account. The signed transaction is submitted to the Diamante blockchain server

<!-- tabs:start -->

#### **Javascript**

```js
// Create a Trustline
async function createTrustline(assetCode, assetIssuer) {
  try {
    const asset = new Asset(assetCode, assetIssuer);
    console.log("Creating trustline for asset:", assetCode);

    const account = await server.loadAccount(sourcePublicKey);
    const transaction = new TransactionBuilder(account, {
      fee: BASE_FEE,
      networkPassphrase: "Diamante Testnet 2024",
    })
      .addOperation(
        Operation.changeTrust({
          asset: asset,
        })
      )
      .setTimeout(30)
      .build();

    transaction.sign(sourceKeypair);
    const result = await server.submitTransaction(transaction);
    console.log("Trustline created successfully.....");
    return result;
  } catch (error) {
    console.error("Error creating trustline:", error);
    throw error;
  }
}
// Example Calls
(async () => {
  try {
    // Create a trustline
    await createTrustline(
      "TSKON",
      "GBQYVC5XHICL3U3O6B3EP2A6TXX43NUU7XDPVX3E6LQ2W6U2EJCCAAXXX"
    );
  } catch (error) {
    console.error("Operation failed:", error);
  }
})();
```

<!-- tabs:end -->

3 - `updateTrustlineLimit` : Modifies the trustline by updating the maximum limit of the asset that the account is willing to hold. Similar to the createTrustline function, the Asset object is created. The account is loaded from the blockchain using its public key. `Build the Transaction` A `changeTrust` operation is added to the transaction, but this time, the `limit` is set to the specified `newLimit`. and The transaction is signed with the secret key and submitted to the blockchain.

<!-- tabs:start -->

#### **Javascript**

```js
// Update a Trustline Limit
async function updateTrustlineLimit(assetCode, assetIssuer, newLimit) {
  try {
    const asset = new Asset(assetCode, assetIssuer);
    console.log(
      `Updating trustline for asset: ${assetCode} with new limit: ${newLimit}`
    );

    const account = await server.loadAccount(sourcePublicKey);
    const transaction = new TransactionBuilder(account, {
      fee: BASE_FEE,
      networkPassphrase: "Diamante Testnet 2024",
    })
      .addOperation(
        Operation.changeTrust({
          asset: asset,
          limit: newLimit.toString(), // Set the new limit
        })
      )
      .setTimeout(30)
      .build();

    transaction.sign(sourceKeypair);
    const result = await server.submitTransaction(transaction);
    console.log("Trustline limit updated successfully.....");
    return result;
  } catch (error) {
    console.error("Error updating trustline limit:", error);
    throw error;
  }
}
// Example Calls
(async () => {
  try {
    // Update the trustline limit
    await updateTrustlineLimit(
      "TSKON",
      "GBQYVC5XHICL3U3O6B3EP2A6TXX43NUU7XDPVX3E6LQ2W6U2EJCCAAXXX",
      1000
    );
  } catch (error) {
    console.error("Operation failed:", error);
  }
})();
```

<!-- tabs:end -->

4 - `DeleteTrustline`: Deletes the trustline for the specified asset by setting its limit to 0. This indicates the account no longer wants to hold or interact with the asset. The `Asset` object is created with the `assetCode` and `assetIssuer`. `Build the Transaction` :A `changeTrust` operation is added to the transaction with the `limit` set to `"0"`. This effectively deletes the trustline. The transaction is signed with the secret key and submitted.

<!-- tabs:start -->

#### **Javascript**

```js
// Delete a Trustline
async function deleteTrustline(assetCode, assetIssuer) {
  try {
    const asset = new Asset(assetCode, assetIssuer);
    console.log("Deleting trustline for asset:", assetCode);

    const account = await server.loadAccount(sourcePublicKey);
    const transaction = new TransactionBuilder(account, {
      fee: BASE_FEE,
      networkPassphrase: "Diamante Testnet 2024",
    })
      .addOperation(
        Operation.changeTrust({
          asset: asset,
          limit: "0", // Set limit to 0 to delete the trustline
        })
      )
      .setTimeout(30)
      .build();

    transaction.sign(sourceKeypair);
    const result = await server.submitTransaction(transaction);
    console.log("Trustline deleted successfully.....");
    return result;
  } catch (error) {
    console.error("Error deleting trustline:", error);
    throw error;
  }
}

// Example Calls
(async () => {
  try {
    // Delete the trustline
    await deleteTrustline(
      "TSKON",
      "GBQYVC5XHICL3U3O6B3EP2A6TXX43NUU7XDPVX3E6LQ2W6U2EJCCAAXXX"
    );
  } catch (error) {
    console.error("Operation failed:", error);
  }
})();
```
